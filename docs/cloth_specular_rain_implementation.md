# 衣服物理高光与雨水湿润实现计划

## 文档状态

- 日期：2026-08-05
- 状态：H1-H4 已验收；H5a HDR 审计通过，H5b F0=0.08 待验证
- 目标模块：通用衣服材质
 - 首个验证模型：样例模型 Cloth1；实现本身不绑定角色名称或材质编号
- 最终目标：可由未来 GUI 为不同模型生成配置，而不是只适配某一个角色

本文同时规划两条工作线：

1. 改善干燥状态下的 GGX/PBR 高光，使主高光更接近 Goo/Unity
   参考工程中的物理形状，同时保留已经验收的宽高光、方向性布料
   高光、MatCap/HDR 和屏幕空间边缘光。
2. 增加可关闭的雨水、湿润表面、流动法线与水滴层。

材质分类与 MatCap mipmap 的独立实施方案见：

- `docs/cloth_material_mipmap_plan.md`

该方案必须先验证 MatCap 的粗糙度层级，再测试宽高光法线细节，最后才
进入本文的雨水阶段。三者不能在同一轮同时修改。

两条工作线必须逐步测试。任何一步出现异常时，只回退当前一步，
不能同时改强度、颜色、法线、粗糙度和环境反射。

---

## 1. 不可破坏的规则

### 1.1 通用性

 - internal/endfield_cloth.hlsl 中不能写死样例模型的材质编号、模型名称、
  UV 区域或角色尺寸。
- 角色贴图路径只能由外层 FX 或未来 GUI 生成的配置定义。
- 雨水关闭时，不得要求模型目录存在雨水贴图。
- 长条流痕依赖模型 UV 方向。第一版使用 UV 空间，但必须预留缩放与
   旋转配置，不能假设所有模型的 UV 都与样例模型一致。

### 1.2 基线兼容

- 所有新增控制器保持零值时，必须复现当前已经验收的干燥衣服效果。
- 雨水总量为 0 时，输出应与未编译雨水模块时一致。
- 不改当前已验收的 AO、RD、LUT、ZMDshadow、Rim、MatCap/HDR、
  FGD 和描边路径，除非进入对应的独立测试阶段。

### 1.3 单变量测试

- 每个测试 FX 只比上一个通过版本多一个视觉变量。
- Debug FX 只保留一个可复用文件，下一阶段覆盖它，不累计大量
  H1、H2、R1、R2 文件。
- 每一步必须先得到 MMD 实机截图确认，再合并到生产 FX。
- 高光强度、峰值上限、粗糙度、F0 和色调不能在同一步一起调整。

### 1.4 MME 资源约束

- 当前衣服像素着色路径约使用 10 个采样器，其中包括阴影 RT。
- ps_3_0 通常最多提供 16 个像素采样器，因此第一版雨水只增加一个
  打包雨水纹理采样器，保留余量给现有功能和后续兼容处理。
- 雨水资源声明、sampler 和采样代码全部放进
  EF_CLOTH_RAIN_ENABLED 编译保护内，避免未启用雨水的模型因为缺少
  贴图而报错。

### 1.5 参考与版权

- Goo 工程只用于观察参数含义、节点结构和画面行为。
- GGX、Schlick Fresnel、Smith Joint Visibility 和 RNM 都采用公开的
  标准数学形式独立实现，不复制参考工程节点代码。
- 当前 rain_01/02/03 是游戏解包资源。公开发布前必须确认授权，
  或换成自制/可再分发的同通道格式贴图。GUI 中需要记录资源来源。

---

## 2. 当前干燥衣服基线

生产入口：

 - 由 GUI 生成的通用 EndfieldCloth 入口
- EndfieldMME/internal/endfield_cloth.hlsl
- EndfieldMME/internal/endfield_cloth_controls.inc
- EndfieldMME/tools/build_cloth_controller.py

当前已验收的重要数值：

| 项目 | 当前值 |
| --- | ---: |
| 主直接高光 | 2.00 |
| 高光峰值上限 | 20.00 |
| 宽高光 | 1.00 |
| 方向性布料高光 | 0.55 |
| 环境高光 | 0.80 |
| 高光视角锁定 | 0.65 |
| 亮面 AO | 0.25 |
| 暗面 AO | 0.65 |
| 默认环境模式 | MatCap 019 |
| 可选环境模式 | HDR |
| PreIntegrated FGD | 默认开启 |

当前 P 贴图通道约定：

| 通道 | 用途 |
| --- | --- |
| P.r | Metallic |
| P.g | Reflectivity |
| P.b | AO |
| P.a | Smoothness，Shader 中转换为 Roughness |

当前高光并不是从零开始。已有：

- 法线贴图与 UV 导数重建 TBN
- 直接 GGX 主高光
- 宽高光
- 各向异性布料高光
- MatCap/HDR 环境反射切换
- PreIntegratedFGD_GGXDisneyDiffuse
- 多次散射能量补偿
- RS 贴图颜色修正
- 光照侧屏幕空间边缘光
- ZMDshadow 对高光和环境光的衰减

因此后续不是重写整套材质，而是修正主高光的物理核心，并在其上增加
独立的湿润层。

---

## 3. Goo 高光观察结果

两个 Goo 预设都使用了以下核心结构：

- 物理半程向量 H = normalize(L + V)
- Smith Joint GGX 可见性项
- Schlick Fresnel，角度项使用 LdotH
- P.r 控制金属度
- P.a 控制光滑度
- F0 在约 0.08 的介电基值与 BaseColor 金属 F0 之间插值
- PreIntegrated GGX/Disney Diffuse FGD
- FGD 采样使用 sqrt(NoV) 与感知粗糙度
- 多次散射能量补偿
- 法线贴图直接参与高光方向
- SpecularColor 可以保留大于 1 的 HDR 能量，再交给 Bloom 与 Tonemap

较新的 Fluorite 2.0 预设还混合了：

- Eff_MatCap_019.png
- HDR/Cubemap 反射
- FGD 响应
- 湿润与雨水流动法线

### 3.1 我们与参考的关键差异

当前 EfClothStylizedHalfDirection 会把物理 H 与相机锁定后的艺术 H
混合，而且主高光、宽高光和方向性高光共用该结果。这使高光比较稳定，
但也会出现以下差异：

- 主 GGX 峰值更像经过相机约束的装饰高光，不完全沿真实反射方向移动。
- EfClothDirectGgx 的 visibility 是简化形式，并非对称的 Smith Joint
  GGX。
- 主高光 Fresnel 当前使用 NoV；参考使用 LdotH。NoV 更容易把能量推向
  轮廓，看起来像边缘光。
- 当前介电 F0 还乘了 P.g Reflectivity，不能直接照搬参考的 0.08，
  否则会同时改变材质遮罩含义。
- 当前宽高光和方向性高光是已经验收的艺术层，不应因为修主 GGX 而一起
  变形。

结论：主高光应逐步恢复物理 H、Smith Joint Visibility 和 LdotH
Fresnel；宽高光、方向性高光与 Rim 暂时继续使用艺术 H。

---

## 4. 干燥高光实施阶段

### H0：固定当前基线

不改代码，只保存对比素材。

必须记录：

1. 正面光、角色正面
2. 45 度侧光
3. 接近轮廓的侧视角
4. 背光
5. 膝盖、袖口、金属件各一个近景
6. MatCap 模式 0 与 HDR 模式 1

记录当前控制器值、日光方向、相机距离和后处理参数。后续对比不得在
不同曝光或 Bloom 强度下判断高光算法。

通过标准：截图与参数记录完整。

### H1：拆分物理 H 与艺术 H

只做代码结构调整，不改变任何像素结果。

实施状态：2026-08-05 已完成并通过 MMD 实机验证。

建议新增：

~~~hlsl
float3 EfClothPhysicalHalfDirection(float3 viewDirWS, float3 lightDirWS)
{
    float3 h = viewDirWS + lightDirWS;
    float hLengthSq = dot(h, h);
    return hLengthSq > 1e-8
        ? h * rsqrt(hLengthSq)
        : viewDirWS;
}
~~~

EfClothStylizedHalfDirection 内复用该函数，但 EfClothPS 暂时仍把艺术 H
传给全部现有高光。此阶段不能修改高光强度、Fresnel、Visibility、
Roughness 或 F0。

测试重点：

- 与 H0 同角度切换 FX
- 高光位置、亮度、宽度应肉眼一致
- 编译无警告，控制器继续有效

通过标准：零视觉变化。第一轮实际代码测试必须停在 H1，等待确认。

### H2：主 GGX 改为对称 Smith Joint Visibility

仍使用艺术 H，只替换 EfClothDirectGgx 的 visibility。D、F0、强度和
峰值上限保持原值。

实施状态：2026-08-05 已为主高光新增独立 Smith Joint 路径，宽高光
仍保留旧 Visibility，并已通过 MMD 阈值图验证。

建议形式：

~~~hlsl
float EfClothSmithJointVisibility(
    float noV,
    float noL,
    float roughness)
{
    float alpha = max(roughness * roughness, 0.0078125);
    float alpha2 = alpha * alpha;
    float lambdaV = noL * sqrt(max(
        noV * noV * (1.0 - alpha2) + alpha2,
        1e-6));
    float lambdaL = noV * sqrt(max(
        noL * noL * (1.0 - alpha2) + alpha2,
        1e-6));
    return 0.5 / max(lambdaV + lambdaL, 1e-5);
}
~~~

此阶段暂不补 D 项中的 1/PI，因为当前 2.0 强度是在现有 D 标度下验收
的。若要恢复完整标准归一化，必须另开一次测试并重新标定强度。

测试重点：

- 正面与 45 度处的峰值是否更完整
- 曲面移动时是否比当前更连贯
- 暗面不能无条件发亮
- 不应新增轮廓带

通过标准：高光连续性改善，亮度变化可解释，没有变成 Rim。

### H3：Schlick Fresnel 改用物理 LdotH

分布仍可继续使用艺术 H，但 Fresnel 的角度必须来自物理 H：

实施状态：2026-08-05 已完成主高光 LdotH Fresnel，并通过 MMD
阈值图与正常画面验证。

~~~hlsl
float3 physicalH = EfClothPhysicalHalfDirection(V, L);
float lDotH = saturate(dot(L, physicalH));
float3 F = F0 + (1.0 - F0) * pow(1.0 - lDotH, 5.0);
~~~

不能再使用：

~~~hlsl
pow(1.0 - NoV, 5.0)
~~~

测试重点：

- 正视衣服时主高光应仍存在
- 接近轮廓时不能突然形成一圈白边
- 金属件和普通布料都要检查

通过标准：主高光更像表面反射，而不是只在边缘增强。

### H4：只有主高光切换到物理 H

此阶段才让直接 GGX 主峰的 D 项使用 physicalH：

实施状态：2026-08-05 已完成主峰 physicalH 切换，RS、宽高光与方向性
高光仍使用 stylizedH，并已通过 MMD 阈值图与正常画面验证。

~~~hlsl
float3 physicalH = EfClothPhysicalHalfDirection(V, L);
float3 stylizedH = EfClothStylizedHalfDirection(V, L);

directSpecular     = EfClothDirectGgx(..., physicalH, ...);
broadSpecular      = EfClothDirectGgx(..., stylizedH, ...);
anisotropicSpecular = EfClothAnisotropicGgx(..., stylizedH, ...);
~~~

保持不变：

- 宽高光仍使用艺术 H
- 方向性布料高光仍使用艺术 H
- Rim 与屏幕空间 Rim 不动
- MatCap/HDR 不动
- RS 采样坐标先不动

如果主峰位置通过，但 RS 颜色与峰值位置分离，再单独增加 H4b，让
EfClothRefineSpecular 的 NoH 使用 physicalH。不能与 H4 同时改。

测试重点：

- 转相机和转日光时，主峰是否沿真实反射方向平滑移动
- 参考图中膝盖、袖口的亮点是否更集中
- 宽高光仍应提供已验收的大面积质感

通过标准：主峰物理、宽峰稳定，两者分工明确。

### H5：HDR 能量与参考亮度标定

只有 H1-H4 全部通过后，才调能量。

实施状态：

- H5a 已确认高光至最终输出没有上限 saturate，HDR 能量可进入
  Bloom/Tonemap。
 - H5b 已在样例测试配置中把介电 F0 从 0.06 改为 0.08，P.g
  Reflectivity 遮罩与其他高光参数保持不变，等待 MMD 验证。

按以下顺序分别测试：

1. H5a：确认 directSpecular 相加前没有 saturate，保留大于 1 的 HDR
   值给全局 Bloom 与 Tonemap。
2. H5b：只比较介电 F0 0.06 与 0.08。P.g Reflectivity 的遮罩语义保持
   不变，不能同时去掉它。
3. H5c：只调整主高光强度或峰值上限中的一个。
4. H5d：比较 MatCap 与 HDR 下相同材质的峰值，必要时调整
   EF_CLOTH_HDR_RELATIVE_STRENGTH，但不改变 MatCap 贴图。
5. H5e：确认 FGD 与多次散射仍默认开启，关闭 FGD 时只是用于 A/B，
   不能成为新的默认值。

推荐判断顺序：

- 先看高光位置
- 再看高光形状
- 再看材质颜色
- 最后才看亮度与 Bloom

若位置不对，增加强度只会把错误放大。

### H6：高光控制器收口

衣服控制器目前已经很拥挤。高光阶段不预先增加大量新表情。

最终只考虑：

- 复用已有 高光強+ / 高光強-
- 可选增加一个 物理高光 或 高光模式

测试期优先使用 FX 编译开关。只有物理路径验收后才决定控制器默认值。
如果物理路径成为正式默认，控制器的零状态必须对应正式默认，旧艺术
主峰只作为兼容模式。

---

## 5. 雨水贴图观察结果

当前运行时只保留实际使用的 `textures/common/rain/T_actor_common_rain_02_M.png`，
并配合 `rain_drops.png` 与 `rain_drops_phase.png` 生成水滴和相位变化。未被当前 Shader
引用的 rain_01、rain_03 已从发行树移除。

已确认 Goo 的 Rain 节点对 rain_02 做了两次采样：

- 第一层 UV 缩放约为 scale
- 第二层 UV 缩放约为 scale + 5
- RG 解码为切线空间法线 XY
- B 作为覆盖遮罩
- B 通过 smoothstep(0.2, 1.0, B) 整形
- 两层流动法线通过 RNM 合成

参考默认参数约为：

| 参数 | Goo 观察值 |
| --- | ---: |
| Flow Scale | 2.3 |
| Flow Normal Strength | 1.2 |
| Flow Strength | 1.8 |
| Flow Speed | 1.0 |
| Droplet Normal Strength | 1.0 |
| Droplet Strength | 1.5 |

rain_01 与 rain_03 的通道意义尚未确认，不能根据画面直接猜通道。

---

## 6. 雨水与湿润实施阶段

### R0：资源绑定与通道 Debug

先只绑定 rain_02，不参与最终着色。

建议资源保护：

~~~hlsl
#ifndef EF_CLOTH_RAIN_ENABLED
#define EF_CLOTH_RAIN_ENABLED 0
#endif

#if EF_CLOTH_RAIN_ENABLED
#ifndef EF_CLOTH_RAIN_TEXTURE_RESOURCE
#define EF_CLOTH_RAIN_TEXTURE_RESOURCE \
    "textures/common/rain/T_actor_common_rain_02_M.png"
#endif

texture2D EfClothRainTexture <
    string ResourceName = EF_CLOTH_RAIN_TEXTURE_RESOURCE;
>;
sampler2D EfClothRainSampler = sampler_state {
    texture = <EfClothRainTexture>;
    AddressU = WRAP;
    AddressV = WRAP;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
};
#endif
~~~

Debug 顺序：

1. RGB 原图
2. R 单通道
3. G 单通道
4. B 单通道
5. RG 解码后的法线假色

通过标准：

- UV 对齐模型且无读取报错
- RG 的变化确实能形成法线方向
- B 的亮区与流痕覆盖区域一致

R0 不能改粗糙度、颜色或高光。

### R1：统一湿润，只改 Roughness

先不用雨纹遮罩，使用全局雨量验证材质响应：

~~~hlsl
float wetMask = saturate(rainAmount);
roughness = lerp(
    roughness,
    min(roughness, wetTargetRoughness),
    wetMask);
~~~

使用 min 的原因是湿润应该让粗糙表面变光滑，但不应把本来已经很光滑的
金属强行变粗。

建议起始值：

- rainAmount = 1.0
- wetTargetRoughness = 0.12

测试重点：

- 膝盖和袖口高光是否变窄、变清晰
- 颜色、AO 和法线纹理必须与干燥版本相同
- 暗面不能凭空出现自发光

通过标准：只看到光滑度变化。

### R2a：重构切线空间法线路径，零视觉变化

当前 EfClothApplyNormalMap 直接把基础法线变换到世界空间。雨水需要先在
切线空间中把基础法线与雨水法线合成，因此先拆为：

~~~hlsl
float3 EfClothSampleBaseNormalTS(float2 uv);

float3 EfClothTangentToWorld(
    float3 normalTS,
    float3 tangentWS,
    float3 bitangentWS,
    float3 geometryNormalWS);
~~~

R2a 仍只采样原法线贴图，输出必须与当前版本一致。

通过标准：

- 关闭雨水时逐像素结果肉眼一致
- DX/GL 法线翻转控制仍有效
- TBN 失败时仍回退到 geometryNormalWS

### R2b：单层静态流动法线

只采样一层 rain_02，不加动画：

~~~hlsl
float4 rainSample = tex2D(EfClothRainSampler, rainUv);
float coverage = smoothstep(0.2, 1.0, rainSample.b);
float3 rainNormalTS = EfClothDecodeNormalRG(rainSample.rg);
rainNormalTS.xy *= rainNormalStrength
    * coverage
    * rainAmount;
rainNormalTS.z = sqrt(saturate(
    1.0 - dot(rainNormalTS.xy, rainNormalTS.xy)));
~~~

使用 RNM 合成，而不是直接相加：

~~~hlsl
float3 EfClothBlendRnm(
    float3 baseNormalTS,
    float3 detailNormalTS)
{
    float3 t = baseNormalTS + float3(0.0, 0.0, 1.0);
    float3 u = detailNormalTS * float3(-1.0, -1.0, 1.0);
    return normalize(t * dot(t, u) - u * t.z);
}
~~~

通过标准：

- 静止截图能看到连续水痕法线
- 原衣服织物法线仍存在
- 雨水区域外与干燥版本一致

### R3：双尺度 RNM 流动法线

在 R2b 通过后增加第二层：

~~~hlsl
float2 uv0 = rotatedUv * flowScale;
float2 uv1 = rotatedUv * (flowScale + 5.0);
~~~

两层分别解码、乘各自 B 遮罩，再先合成 flowNormal，最后与
baseNormalTS 合成：

~~~hlsl
float3 flowNormalTS = EfClothBlendRnm(flowNormal0, flowNormal1);
float3 wetNormalTS = EfClothBlendRnm(baseNormalTS, flowNormalTS);
~~~

第一版覆盖率使用 max(coverage0, coverage1)，避免两层相加后整件衣服
都被水纹覆盖。若水纹太稀，再单独测试并集形式：

~~~hlsl
1.0 - (1.0 - coverage0) * (1.0 - coverage1)
~~~

通过标准：

- 大流痕与细流痕同时存在
- 不出现明显重复方格
- 不把基础法线完全冲掉

### R4：使用 TIME 增加流动

只有静态双层通过后才加时间：

~~~hlsl
#if EF_CLOTH_RAIN_ENABLED
float EfClothRainTime : TIME;
#endif

float phase = EfClothRainTime * rainFlowSpeed;
float2 uv0 = rotatedUv * flowScale
    + float2(0.0, -phase);
float2 uv1 = rotatedUv * (flowScale + 5.0)
    + float2(0.13, -phase * 1.37);
~~~

两层速度不能完全相同，否则会像整张贴图一起平移。偏移和速度比应固定
在 Shader 内，控制器只提供总流速。

通用性注意：

- UV 向下不一定等于世界向下。
- 第一版为低成本 UV 流动，GUI 应保存每个模型的 rainUvRotation。
- 不在第一版使用三平面世界投影，因为它需要更多采样且会增加 ps_3_0
  成本。

通过标准：

- 水纹连续向一个方向流动
- 角色动画时没有明显闪烁
- UV 接缝处不能比干燥法线更显眼

### R5：独立的湿润清漆高光

粗糙度变化通过后，增加一层中性的水膜高光。该层使用：

- 物理 H
- H2/H3 验收后的 Smith Joint GGX 与 LdotH Fresnel
- 雨水合成后的 wetNormalWS
- 介电 F0 约 0.02
- 较低粗糙度，建议从 0.10 开始
- rain coverage、rainAmount、NoL 与场景阴影共同控制

示意：

~~~hlsl
float3 waterF0 = 0.02.xxx;
float3 wetDirect = EfClothPhysicalGgx(
    wetNormalWS,
    physicalH,
    V,
    L,
    wetRoughness,
    waterF0);
wetDirect *= wetMask
    * lightColor
    * wetSpecularStrength
    * wetShadowWeight;
~~~

环境湿润高光使用同一个 wetRoughness 和 waterF0，通过现有
MatCap/HDR + FGD 路径取得宽反射。它不能用 BaseColor 染色，否则白色
水膜会变成黄褐色金属。

通过标准：

- 受光面出现清晰但不过曝的水膜高光
- 暗面只有合理的环境反射，不自发光
- 金属底材不被双重高光洗白

### R6：湿润颜色变深

最后才增加轻微的湿润变暗：

~~~hlsl
float wetMask = saturate(rainAmount * coverage);
albedoLinear *= lerp(
    1.0,
    1.0 - wetAlbedoDarken,
    wetMask);
~~~

建议 wetAlbedoDarken 从 0.08 开始，不超过 0.20。只修改漫反射底色，
不压暗水膜高光。

通过标准：

- 湿区比干区略深
- 不变灰、不变脏
- 不破坏 RD/LUT 的暗部颜色

### R7：水滴贴图

rain_01 与 rain_03 必须分别完成 R/G/B/A 单通道探针后再决定用途。

预计顺序：

1. 优先探测 rain_01，确认分散水滴是否能提供法线与遮罩。
2. rain_03 只在确认它是表面拖尾而非屏幕空间下落粒子后使用。
3. 先做静态水滴。
4. 静态水滴通过后，再决定是否需要慢速滑动或独立时间相位。

此阶段之前不增加 水滴強、水滴大小 等控制器，避免控制器继续膨胀。

### R8：控制器与 GUI 收口

衣服控制器已有大量表情，雨水第一版只保留最低必要集合：

| 控制 | 用途 |
| --- | --- |
| 雨量 | 0 为完全干燥，1 为完整雨水遮罩 |
| 湿潤高光+ / 湿潤高光- | 调整水膜高光 |
| 流紋強+ / 流紋強- | 调整流动法线 |
| 流速+ / 流速- | 调整 TIME 速度 |
| 雨紋大小+ / 雨紋大小- | 调整 UV 缩放 |

原则：

- 雨量使用直观的 0 到 1。
- 需要大动态范围的强度继续沿用现有控制器的倍率映射。
- 不在 PMX 中增加每个技术参数。UV 旋转、默认纹理、是否启用雨水等
  适合放进未来 GUI 的模型配置。
- GUI 关闭雨水时生成 EF_CLOTH_RAIN_ENABLED 0，不复制雨水贴图。
- GUI 开启雨水时再选择资源、复制到 common/rain，并写入外层 FX。

---

## 7. 推荐执行顺序

严格按下列顺序推进：

1. H0 固定截图基线
2. H1 拆分 H，要求零视觉变化
3. H2 Smith Joint Visibility
4. H3 LdotH Fresnel
5. H4 主峰切换物理 H
6. H5 高光能量标定
7. 高光正式合并
8. R0 rain_02 通道 Debug
9. R1 统一湿润 Roughness
10. R2a 法线函数零变化重构
11. R2b 单层静态雨水法线
12. R3 双尺度 RNM
13. R4 TIME 流动
14. R5 水膜高光
15. R6 湿润底色
16. R7 水滴探针与实现
17. R8 控制器和 GUI 配置

先完成干燥物理高光，再做水膜高光。否则湿润层建立在仍会变化的 GGX
核心上，后续很难判断问题来自水纹、粗糙度还是基础 BRDF。

---

## 8. 每一步的统一测试矩阵

### 光照

- 正面光
- 45 度侧光
- 近背光
- 完全背光
- ZMDshadow 覆盖区与非覆盖区

### 相机

- 正面
- 45 度
- 近侧面
- 近景
- 远景

### 材质区域

- 普通布料
- 膝盖曲面
- 袖口
- 金属饰件
- UV 接缝附近

### 雨水额外测试

- 雨量 0、0.25、0.5、1.0
- 时间暂停与播放
- 模型静止与动作播放
- MatCap 模式与 HDR 模式
- Bloom 关闭与开启

### 失败条件

出现以下任一情况时不合并：

- 雨量 0 仍改变干燥外观
- 主高光只剩轮廓光
- 高光转角突然消失或闪现
- 湿润层在完全暗面自发亮
- 雨水法线吞掉原法线
- 金属被环境贴图严重染色
- UV 接缝出现明显断裂
- 远处闪烁、摩尔纹或采样器超限
- 某个缺少雨水贴图的模型无法加载 FX

---

## 9. 当前实际任务

H1-H4 已完成并验收。当前为 H5b：

- 主高光继续使用对称 Smith Joint GGX Visibility
- 主高光分布改用物理 H
- 主高光 Fresnel 改用物理 LdotH
- RS、宽高光与方向性高光继续使用艺术 H
- 宽高光继续使用旧 Visibility
- HDR 输出链没有上限截断
 - 样例测试配置的介电 F0 从 0.06 改为 0.08
- 高光强度、峰值、贴图和控制器数值均未改动

请先使用 EndfieldCloth_Debug.fx 检查 0.25 黑白阈值，再使用
生成的 EndfieldCloth 入口检查正常画面。F0 通过后再决定是否需要
调整强度或峰值，不能同时修改。
雨水代码在干燥物理高光完成前不进入生产 Shader。
