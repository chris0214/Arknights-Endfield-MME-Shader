# 衣服材质层级与 MatCap Mipmap 改造方案

## 1. 目标

当前衣服已经具备 GGX 主高光、宽高光、方向性高光、FGD、MatCap/HDR
环境反射和 AO，但布料、皮革、金属仍容易呈现相似的“统一亮面”。本轮
不继续盲目增加高光能量，而是让 `_P` 属性贴图真正控制反射的清晰度与
材质层级。

本方案结合：

 - SnowBreak/HS-Snow 的公开参考实现（本地路径不属于发行包依赖）
- `EndfieldMME/docs/cloth_specular_rain_implementation.md`
- 当前 `EndfieldMME/internal/endfield_cloth.hlsl`

最终仍是通用 Shader。共享 HLSL 不允许写死角色、材质编号或 UV 区域，
角色贴图和默认参数由外层 FX 或未来 GUI 生成。

## 2. SnowBreak 中可复用的结构

SnowBreak 的 MatCap 层级有两条路径：

1. 纹理本身带 mipmap 时，使用 `tex2Dlod` 显式选择 LOD。
2. MME 无法可靠读取 PNG mipmap 时，使用手工预模糊图集。

手工图集布局为：

- 原图 LOD 0 放在左侧完整正方形。
- LOD 1 到最终 1 x 1 层依次堆叠在右侧。
- 图集尺寸为原图的 `1.5 x 1.0`。
- 采样时读取相邻两层，并按小数 LOD 插值，避免层级跳变。

这套结构可以直接借鉴，因为 SnowBreak Shader 是本项目作者自己的代码。
但 LOD 的材质输入不能照搬：SnowBreak 使用自己的材质通道，终末地衣服
必须使用已经确认的 `_P.a` Smoothness。

## 3. 终末地属性约定

角色 `_P` 贴图通道：

| 通道 | 含义 | 当前用法 |
| --- | --- | --- |
| R | Metallic | 金属 F0 与金属遮罩 |
| G | Reflectivity | 介电反射强度与艺术遮罩 |
| B | AO | 直接光和环境光遮蔽 |
| A | Smoothness | `Roughness = 1 - A` |

MatCap LOD 应由最终 Roughness 驱动，而不是由 Metallic 或 Reflectivity
直接驱动。这样同一套 Shader 才能自然得到：

- 光滑金属：低 LOD，反射清晰。
- 皮革：中低 LOD，反射连续但略软。
- 普通布料：中高 LOD，反射宽而柔。
- 粗糙布料：高 LOD，只保留低频明暗。

Metallic、Reflectivity、FGD 和 AO 继续控制反射能量；LOD 只控制反射
频率与清晰度，不能同时承担亮度控制。

## 4. 现有实现的差距

当前 HDR 环境反射已经使用：

```hlsl
mipLevel = roughness * roughness * (mipCount - 1)
```

所以 HDR 模式已经具备基础的粗糙度分层。

当前 MatCap 始终使用普通 `tex2D` 读取 `Eff_MatCap_019.png` 原图，完全
不受 Roughness 影响。这是不同材质容易共享同一种清漆外观的主要来源。

另外两个独立问题不能与 MatCap LOD 同时修改：

- 宽高光把 Roughness 强制抬到至少 `0.50`。
- 宽高光法线平滑为 `0.85`，只保留约 15% 的法线贴图细节。

它们会降低布料细节，但属于直接光高光形状，不属于环境反射 mipmap。
必须等 MatCap LOD 单独验收后再测试。

## 5. 实施阶段

### M0：保持生产基线

- 通用 `EndfieldCloth` 入口不启用新路径。
- 新宏默认值全部为关闭或零偏移。
- 雨水、AO、GGX、宽高光、各向异性、Rim 和后处理不改。

通过标准：生产 FX 与修改前画面一致。

### M1：手工 MatCap mip 图集

从 `Eff_MatCap_019.png` 生成：

`textures/common/Eff_MatCap_019_manual_lod.png`

256 x 256 原图生成 384 x 256 图集，共 LOD 0 到 LOD 8。生成工具应在
线性色彩空间中做 2 x 2 平均，再编码回 sRGB，避免模糊层无故发暗。

首轮只在 `EndfieldCloth_Debug.fx` 启用。采样相邻两层并连续插值，不使用
整数四舍五入。

LOD 初始映射采用感知粗糙度曲线：

```hlsl
mappedRoughness = roughness * (1.7 - 0.7 * roughness);
lod = mappedRoughness * lodCount;
```

它比 `roughness * roughness` 更容易在中等粗糙度上看出分层，也接近常见
实时 IBL 的感知粗糙度映射。此阶段提供编译期 override，必要时可以强制
LOD 0、4、8 排查图集或采样是否生效。

测试文件：

- 基线：当前模型生成的 `EndfieldCloth` 入口
- M1：`EndfieldCloth_Debug.fx`

测试重点：

1. 金属件仍有相对清晰的环境高光。
2. 普通布料的 MatCap 形状变软，不再像统一清漆。
3. 材质边界来自 `_P.a`，不能出现屏幕空间分块或色带。
4. 转相机时层级稳定，不闪烁、不突然跳变。
5. MatCap/HDR 模式切换继续有效；HDR 画面不应被本阶段改变。

### M2：LOD 曲线标定

只有 M1 确认路径有效后，才单独调整以下一个参数：

- LOD Scale：整体放大或缩小模糊程度。
- LOD Bias：整体向清晰或模糊方向平移。

不在 M2 同时修改环境强度、F0、FGD 或 Tonemap。

首轮 MMD 验证确认布料反射已经变柔。`1.15` 也通过测试，但正式默认按
用户选择回到 `1.00`，并增加独立的 `反射模糊+/-` 衣服控制器。该控制
只改变 MatCap LOD scale，不联动 GGX Roughness、HDR、环境强度或颜色。

推荐先看三类区域：金属件、皮革/胶质区域、普通布料。如果金属也过糊，
优先降低 Scale；如果只有布料仍太亮，不要用 Bias 修亮度，应进入材质能量
阶段处理 Reflectivity 或环境强度。

### M3：生产合并与兼容路径

M1/M2 通过后：

- 正式 FX 默认启用手工 MatCap LOD。
- 保留原始 MatCap 采样作为兼容开关。
- 未来 GUI 在导入 MatCap 时自动生成手工 mip 图集。
- GUI 记录原图尺寸、LOD 数量和生成版本。
- 缺少图集时回退原始 MatCap，不能让 FX 编译失败。

实施状态：2026-08-05 已把手工 MatCap LOD 以 `1.00` 默认倍率合并到
正式衣服 FX；控制器零值保持默认，`反射模糊+/-` 可独立调节层级。

控制器暂时不增加多个 mip 参数。若确有用户需求，只保留一个接近中文的
`反射清晰` 或 `反射模糊` 控制，Scale/Bias 等技术参数放在 GUI 高级设置。

### M4：宽高光法线细节

与 mipmap 分开测试：

```hlsl
EF_CLOTH_BROAD_SPECULAR_NORMAL_SMOOTHING: 0.85 -> 0.55
```

只改变宽高光使用多少法线贴图细节，不修改宽高光强度和 Roughness floor。
目标是让布料纹理参与宽高光，但不能把整块高光打碎成噪点。

首轮 `0.55` 已确认法线细节能够进入宽高光。当前 Debug FX 进一步测试
`0.40`，并输出连续灰度的宽高光最终贡献：黑色为无贡献，越白代表高光
越强。灰度显示使用曝光压缩，仅用于观察，不会改变正式高光能量。正式
FX 仍为 `0.85`，等待 MMD 实机截图确认后再决定最终值。

### M5：宽高光 Roughness 分区

M4 通过后，取消所有非金属材质统一的 `roughness >= 0.50` 外观。建议改为
由基础 Roughness 与一个较弱的宽峰偏移组合，而不是固定下限：

```hlsl
broadRoughness = saturate(roughness + broadRoughnessOffset);
```

此阶段必须单独测试，不能同时调整 M4 的法线平滑。

### M6：通用材质模式与 GUI

最终 GUI 提供：

- Auto / P-map：默认，根据 `_P` 自动计算。
- Fabric：允许更强法线细节、更宽直接高光和较高 MatCap LOD。
- Leather：中等 LOD、连续宽峰、较弱各向异性。
- Metal：低 LOD、较清晰环境反射、关闭非金属宽峰。

模式只提供参数偏置，不能按角色名称或材质编号写死。角色 `_P` 和通用
MRO 的通道规则不同，GUI 必须让用户选择贴图类型，不能自动把所有 MRO
都按终末地 `_P` 解码。

## 6. 与雨水阶段的衔接

`cloth_specular_rain_implementation.md` 中 R1 会降低湿润区域 Roughness。
MatCap mipmap 完成后，湿润区域会自然选择更低 LOD，环境反射因此变得更
清晰，不需要再为湿润 MatCap 写一套独立采样算法。

推荐后续顺序：

1. M1 MatCap mip 路径。
2. M2 LOD 曲线标定。
3. M3 合并生产版。
4. M4 宽高光法线细节。
5. M5 宽高光 Roughness 分区。
6. R0-R4 雨水贴图与流动法线。
7. R5 湿润清漆高光。

## 7. 首轮失败条件

出现以下任一情况时不合并 M1：

- Debug FX 报纹理或编译错误。
- 粗糙材质反而比光滑材质更清晰。
- 层级在相机移动时突然跳变。
- 图集边缘出现黑线、串层或十字接缝。
- HDR 模式也发生非预期变化。
- 生产 FX 与原画面不一致。

首轮只判断“粗糙度是否可靠控制 MatCap 清晰度”。亮度、饱和度、AO 和
直接高光细节都留到后续独立阶段。
