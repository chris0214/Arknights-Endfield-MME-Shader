# ZMD 雨水效果参考分析

## 文档状态

- 日期：2026-08-05
- 参考视频：Bilibili `BV1b57g6sEAf`
- 参考工程：`M:/MMD相关的/ENDFIELD/ZMD`
- 对比目标：`EndfieldMME` 当前衣服雨水实现
- 本轮性质：只分析，不修改 Shader

## 1. 结论先行

ZMD 的雨水看起来真实，核心并不是雨滴特别多、法线特别强，而是它把
雨水拆成了互相独立但共同工作的几层：

1. 小尺度、随时间变化的雨滴法线。
2. 垂直表面的低速流水法线。
3. 不随每一帧雨滴消失的持续湿润遮罩。
4. 根据材质吸水性区分的变暗、光滑度和高光响应。
5. 强度较低的环境/MatCap 湿润反射。
6. 场景雨线、积水、涟漪、反射和整体灰雨天气共同提供的环境依据。

视频里最重要的视觉特征是“表面一直是湿的，但局部水滴法线在变化”。
它没有依靠密集的亮点反复整片刷新来表达下雨。因此即使动态水滴本身
很克制，材质仍然持续呈现湿润、反光和有水膜的状态。

EndfieldMME 当前已经完成了流水方向、双尺度流水、独立雨滴相位、
0.65 秒寿命、水膜高光等基础工作。与 ZMD 相比，当前主要缺口不是再加
一种雨滴动画，而是：

- 动态法线与持续湿润遮罩还没有完整分离。
- 湿润响应主要由统一雨量控制，材质差异不足。
- Debug FX 的雨滴法线仍是诊断用的 4.0，远高于 ZMD 角色预设的 1.0。
- Debug FX 使用全方向覆盖，破坏了顶部雨滴、侧面流水、底面较干的方向
  层次。
- 场景雨水与角色雨水尚未形成视频里的完整环境闭环。

最高收益的下一步不是继续提高雨滴强度，而是先完成“动画遮罩/持续湿润
遮罩分离”，并用现有 P 贴图推导材质吸水性。第一阶段可以不增加任何
新采样器。

---

## 2. 视频画面观察

已逐段检查约 41 秒的视频，并按近景、半身和远景抽帧比较。

### 2.1 角色近景

视频中的角色表面同时存在四个尺度：

| 尺度 | 画面表现 |
| --- | --- |
| 大尺度 | 整片布料湿润后颜色略深、反射更完整 |
| 中尺度 | 袖子、衣摆和皮革上的连续纵向水痕 |
| 小尺度 | 分散而稳定的小水珠凸起与高光 |
| 微尺度 | 原材质法线、布纹和皮革纹理仍然存在 |

水滴没有吞掉原始材质细节。蓝色布料仍然像布，黑色袖子仍然像光滑
皮革，浅色衣摆也没有被统一变成透明塑料。

### 2.2 时间连续性

相邻帧中湿润反射和大部分水珠分布具有连续性，变化主要发生在局部法线
和流水位置。画面没有出现“这一帧整片雨滴全亮，下一帧整片换一套”的
明显切换。

这与 ZMD 代码一致：动态法线使用动画遮罩，但湿润材质使用包含静态
部分的持续遮罩。雨滴动画退场以后，表面不会立即恢复成完全干燥。

### 2.3 材质区分

- 粗糙布料：主要表现为颜色稍深、宽而柔和的湿润高光。
- 光滑皮革：更容易保留清晰水珠和窄反射。
- 金属：保持金属底色与环境反射，不用雨水颜色重新染色。
- 皮肤：没有和衣服一样铺满圆形水滴，而是偏向流水/湿润响应。
- 头发：角色入口明确跳过雨滴与流水法线，只保留可选的湿润材质响应。

因此 ZMD 并不是“全身使用同一套雨滴”。它按材质类别做了艺术化分工。

### 2.4 场景贡献

视频中的真实感不能全部归因于角色 Shader。画面还包含：

- 屏幕中的雨线和落雨粒子。
- 地面积水、风纹与同心涟漪。
- 湿地面反射或屏幕空间平面反射。
- 低对比度阴天环境光。
- 高亮反射经过后处理后的柔和扩散。

只移植角色水滴而没有场景湿地、反射和雨线，最终画面不会完整达到视频
观感。这些应作为独立场景模块处理，不能塞进衣服材质本体。

---

## 3. ZMD 角色雨水调用链

主要文件：

- `ZMD/Assets/Script/Rain/Shader/RainEffects.hlsl`
- `ZMD/Assets/Char/Shader/S_Char_Cloth.shader`
- `ZMD/Assets/Char/Shader/S_Char_Skin.shader`
- `ZMD/Assets/Char/Shader/S_Char_Hair.shader`
- `ZMD/Assets/Script/Rain/C#/GlobalRainCharacterController.cs`
- `ZMD/Assets/Scenes/Chen.unity`

角色入口调用关系：

```text
S_Char_Cloth.fragment
  -> PermeabilityApproximation
  -> Rain_Character(rainMode = 1)
       -> RainDrops_Char -> RainDrops
       -> RainDrips_Char -> RainDrips
       -> BlendRainEffects
  -> ApplyWetness_Char
  -> 计算 base/spec/env 等正式光照
```

不同材质的模式：

| rainMode | 材质 | 法线效果 |
| ---: | --- | --- |
| 1 | 衣服 | 雨滴 + 流水 |
| 2 | 身体/皮肤 | 仅流水 |
| 3 | 头发 | 跳过雨水法线 |

这说明 ZMD 首先决定“哪些材质应该出现什么形态的水”，再决定强度。

---

## 4. ZMD 算法分层

### 4.1 材质吸水性

`PermeabilityApproximation` 优先读取可选的渗透率贴图。没有贴图时，
根据光滑度和金属度估算：

```text
absorption ~= 1 - max(contrastedSmoothness, metallic)
```

这个值在两条路径中被相反使用：

- 湿润变暗：乘 `absorption`，吸水布料更容易颜色变深。
- 表面水滴/流水：乘 `1 - absorption`，不吸水的皮革和金属更容易留珠。

这是 ZMD 材质区分最关键的一点。它不是简单地让所有材质同时变暗、
变光滑、长满水滴，而是让吸水材质和疏水材质呈现不同结果。

### 4.2 雨滴层

`RainDrops` 的角色路径使用模型 UV：

- RG：解码切线空间法线。
- B：每个雨滴的时间相位。
- A：带正负区间的雨滴形状遮罩。

核心时间关系：

```text
dropPhase = frac(texture.b - time * speed)
```

重要点不在于必须把相位放在 B 通道，而在于同一颗雨滴内部有稳定一致
的相位，不同雨滴之间又有不同相位。EndfieldMME 当前独立
`rain_drops_phase.png` 已经解决了整片同步的问题，应保留这个方案，
不必退回 ZMD 的具体打包格式。

方向遮罩为：

```text
sideMask = saturate(normalWS.y + normalYOffset)
```

角色预设使用 `normalYOffset = 0.72`，所以它并非只允许严格朝上的表面，
而是把覆盖扩展到大部分侧面，同时仍然压制真正朝下的底面。这比直接把
全方向覆盖设为 1 更自然。

### 4.3 流水层

`RainDrips` 使用物体空间位置进行三平面投射：

- 不依赖每个模型的 UV 上下方向。
- 通过 `1 - abs(normal.y)` 偏向垂直表面。
- 使用独立的流水法线贴图与时间遮罩贴图。
- 每层具有不同位置偏移、时间偏移和相位。
- 最多三层，但角色实际预设 `dripDensity = 0`，仍会保留最少一层。

这解释了视频中流水存在，但不会密集到把整个角色刷成条纹。

EndfieldMME 当前使用相对物体原点的世界竖直投射和双尺度采样，已经解决
了 UV 逆流问题。它与 ZMD 的具体坐标系不同，但目标相同：让水流遵循
统一竖直方向而不是任由 UV 决定。因此无需为了“像 ZMD”直接推翻已经
验收的投射方式。

### 4.4 动态法线与持续湿润分离

`BlendRainEffects` 同时输出三个不同概念：

- `animMask`：当前正在出现的雨滴/流水，用于法线混合。
- `staticMask`：贴图中可能存在水的区域，不随当前动画立即消失。
- `dropDripMask`：最终持续湿润遮罩。

关键组合：

```text
animMask = saturate(dropMask + dripMask)
staticMask = saturate(staticDropMask + staticDripMask)
dropDripMask = max(animMask, staticMask * 0.5)
```

随后：

- 法线混合只使用 `animMask`。
- 湿润材质响应使用 `dropDripMask`。

这避免了两个极端：

1. 用持续遮罩驱动法线，导致满身固定凸点。
2. 用瞬时遮罩驱动全部湿润，导致水滴一消失材质立刻变干。

### 4.5 湿润材质层

`ApplyWetness_Char` 在材质拆分和正式光照之前执行。它会：

- 采样独立湿润贴图。
- 用 offset/contrast 调整湿区分布。
- 将湿润贴图与雨水持续遮罩合并。
- 对吸水材质提高饱和度并变暗。
- 提高 smoothness。
- 提高直接高光 shininess。
- 提高直接高光强度。

因为它发生在 BRDF/高光计算之前，后面的直接光和环境光会同时看到同一
套湿润材质参数，不会出现“颜色湿了但反射仍是干的”这种割裂。

### 4.6 MatCap/环境反射

ZMD 使用视空间法线采样 MatCap，并以较低强度加法叠加。陈场景的角色
预设为 `matcapIntensity = 0.3`。

值得注意的是，MatCap 使用进入 `ApplyWetness` 之前的雨水遮罩，而不是
无条件覆盖完整湿润贴图。这让亮反射集中在真正有水滴/流水的区域，避免
整件衣服像自发光塑料。

EndfieldMME 已经有 MatCap/HDR、FGD 和水膜高光，不需要再复制一套新
环境反射。后续只需让现有环境高光读取正确的持续湿润/水膜遮罩。

---

## 5. Chen 场景实际角色预设

`Chen.unity` 中角色控制器实际绑定：

| 插槽 | 资源 |
| --- | --- |
| Drop | `rain_drops.png` |
| Drip | `rain_drips.png` |
| Drip Mask | `rain_drips_mask.png` |
| Cloth Wetness | `Leak.png` |
| Skin/Hair Wetness | `clouds.png` |
| Permeability | 未绑定，使用公式回退 |
| MatCap | `T_actor_common_matcap_06_D.png` |

实际参数：

| 参数 | 值 |
| --- | ---: |
| Wetness Intensity | 1.00 |
| Wetness Tiling | 3.36 |
| Wetness Offset | 0.55 |
| Wetness Contrast | 1.64 |
| Darken Intensity | 0.50 |
| Shininess Multiplier | 10.00 |
| Env Smoothness Multiplier | 1.50 |
| Specular Multiplier | 3.00 |
| Drop Tiling | 3.00 |
| Drop Speed | 1.00 |
| Drop Normal Y Offset | 0.72 |
| Drop Edge Smoothness | 2.30 |
| Drop Normal Intensity | 1.00 |
| Drop Permeability Offset | -0.79 |
| Drip Tiling | 3.00 |
| Drip Speed | 0.10 |
| Drip Sharpness | 10.00 |
| Drip Density | 0.00，实际仍为一层 |
| Drip Normal Intensity | 0.70 |
| Drip Permeability Offset | -0.50 |
| MatCap Intensity | 0.30 |

这些数值说明视频的策略是：

- 雨滴法线保持正常强度 1.0，而不是用极强法线制造存在感。
- 流水比雨滴慢很多。
- 通过较高 Y offset 扩展雨滴覆盖，但不完全取消方向判断。
- 湿润高光提升很强，但由遮罩和材质吸水性约束。
- MatCap 只是辅助层，不是主效果。

---

## 6. EndfieldMME 当前实现状态

当前雨水主要位于：

- `EndfieldMME/internal/endfield_cloth.hlsl`
- `EndfieldMME/EndfieldCloth_Debug.fx`

已完成并值得保留的部分：

- 使用 `T_actor_common_rain_02_M.png` 的竖直流水法线。
- 相对物体原点的竖直双投影，避免直接依赖 UV 上下方向。
- 双尺度 2.3 / 7.3 流水与 RNM 合成。
- 流水法线强度 1.25，速度 0.08。
- 独立水膜直接高光与环境高光。
- 使用 `rain_drops.png` 的独立水滴法线。
- 使用单独 `rain_drops_phase.png` 保证不同水滴独立相位。
- 水滴大小 3.5、重复速度 0.25、寿命 0.65 秒。
- 用户已确认水滴不再整片同步出现，且流水方向已经正确向下。

当前 Debug FX 中仍属于诊断参数的部分：

| 参数 | Debug 值 | ZMD 角色值 | 判断 |
| --- | ---: | ---: | --- |
| Drop Normal Strength | 4.00 | 1.00 | 明显过强，只适合确认凸起 |
| Drop Omni Coverage | 1.00 | 不使用 | 取消了方向层次 |
| Drop Normal Offset | 0.00 | 0.72 | 无法用柔和方式扩展到侧面 |
| Drop Edge Smoothness | 5.00 | 2.30 | 过渡更硬 |

正式内部默认 `EF_CLOTH_RAIN_DROP_NORMAL_STRENGTH` 已经是 1.0，问题主要
来自 `EndfieldCloth_Debug.fx` 的覆盖值 4.0。报告后续所说的“降低到 1.0”
只针对 Debug 测试配置，不代表重写正式默认。

当前湿润粗糙度仍主要使用：

```text
wetMask = saturate(EF_CLOTH_RAIN_AMOUNT)
```

这会让所有材质按同一全局雨量向目标粗糙度靠拢。它能证明水膜路径有效，
但还没有 ZMD 的材质吸水性与局部持续湿润分布。

---

## 7. 两套实现的关键差异

| 项目 | ZMD | EndfieldMME 当前 | 视觉后果 |
| --- | --- | --- | --- |
| 动态法线与湿润 | 两套遮罩 | 仍较多共享全局雨量/覆盖 | 容易忽干忽湿或整体塑料化 |
| 材质吸水性 | 公式或贴图 | 尚未正式使用 | 布、皮、金属差异不足 |
| 雨滴方向 | Y offset 扩展 | Debug 全方向覆盖 | 底面也长水珠，空间感减弱 |
| 雨滴法线 | 1.0 | Debug 4.0 | 像油画凸点或颗粒 |
| 流水投射 | 物体空间三平面 | 相对物体原点的世界竖直双投影 | 两者均可用，当前方案更强调重力方向 |
| 持续湿润纹理 | 独立纹理 | 统一雨量为主 | 缺少大中小尺度层次 |
| 湿润进入光照 | BRDF 前统一修改 | 粗糙度和独立清漆分开处理 | 现有层可保留，但遮罩需统一 |
| 环境反射 | 低强度 MatCap | MatCap/HDR + FGD | EndfieldMME 能力足够，无需新增一套 |
| 场景配合 | 雨线、积水、涟漪、反射 | 当前主要完成全局 Bloom/Tonemap | 角色单独看会缺少环境依据 |

---

## 8. 推荐改造方案

以下阶段遵守“一次只测试一个视觉概念”。不要同时修改雨滴大小、寿命、
流速、颜色和高光。

### ZR0：固定当前通过版

不改代码，记录当前：

- Debug FX 参数。
- 正面、45 度、侧面和背面截图。
- 近景与远景。
- 时间 0 秒、0.3 秒、0.65 秒和 1.3 秒截图。

目的：保存独立相位和 0.65 秒退场已经通过的基线。

### ZR1：雨滴法线从诊断强度恢复到正式强度

只改：

```text
EF_CLOTH_RAIN_DROP_NORMAL_STRENGTH: 4.0 -> 1.0
```

不改大小、速度、寿命、相位、覆盖和流水。

预期：

- 水滴不再像油画凸点。
- 高光仍能显示水珠形状。
- 原布料法线重新成为主要微细节。

### ZR2：恢复方向分类，但保留大范围覆盖

停止使用完全全方向覆盖，改成 ZMD 类型的柔和方向扩展：

```text
normalYOffset ~= 0.72
edgeSmoothness ~= 2.3
omniCoverage = 0
```

这是一个整体的“方向分类”测试，不改任何法线或高光强度。

预期：

- 正面和侧面仍能看到水滴。
- 真正朝下的底面逐渐隐藏。
- 水滴与流水不会在同一区域同样强。

如果 MMD 控制器需要允许全身覆盖，应提供“方向扩展”而不是简单的
全方向开关。最大值也建议保留少量底面抑制。

### ZR3：分离动画遮罩与持续湿润遮罩

复用现有贴图，不增加采样器：

```text
animMask = 当前雨滴 envelope + 当前流水动画覆盖
staticMask = 雨滴静态 A + 流水静态 B
persistentWetMask = max(animMask, staticMask * 0.5)
```

用途：

- `animMask` 只驱动雨水法线。
- `persistentWetMask` 驱动粗糙度、水膜高光和轻微颜色变化。

预期：雨滴退场以后凸起消失，但表面不会瞬间完全变干。

### ZR4：用现有 P 贴图推导吸水性

第一版不增加渗透率贴图。使用已有：

- P.r：Metallic
- P.a：Smoothness

建议独立函数：

```text
absorption = 1 - saturate(max(contrast(smoothness), metallic))
beadRetention = 1 - absorption
```

然后：

- 湿润变暗权重乘 `absorption`。
- 雨滴/流水表面法线权重乘 `beadRetention`。
- 水膜高光在两者之间使用可调混合，避免粗布完全没有湿高光。

预期：

- 布料偏向深色、柔和湿润。
- 皮革偏向留珠、清晰反射。
- 金属保持中性反射，不被雨滴颜色染色。

### ZR5：把统一 Roughness 雨量替换为局部持续遮罩

将当前：

```text
wetMask = EF_CLOTH_RAIN_AMOUNT
```

逐步替换为：

```text
wetMask = EF_CLOTH_RAIN_AMOUNT * persistentWetMask
```

此阶段只改粗糙度遮罩，不增加颜色变暗，也不改变清漆强度。

### ZR6：轻微湿润颜色响应

在粗糙度遮罩通过后再加：

- 轻微提高饱和度。
- 吸水区域轻微变暗。
- 不压暗水膜高光。
- 不使用 MatCap/HDR 的颜色给水滴染色。

ZMD 的 `darkenIntensity = 0.5` 是其自身 Shader 的目标乘数，不建议直接
照搬到 EndfieldMME。我们的 RD/LUT、Tonemap 和基础色链不同，应从
5%-10% 的视觉变暗开始重新标定。

### ZR7：环境高光遮罩统一

不新增 MatCap。让现有水膜环境高光读取 `persistentWetMask`，同时让
动态水珠的窄高光继续读取 `animMask` 或雨滴 coverage。

这样可以得到：

- 持续、宽而柔和的湿表面反射。
- 短暂、局部、较窄的水珠凸起高光。

### ZR8：可选场景雨水模块

角色雨水完成后，另开场景任务：

1. 全局雨线附件。
2. 地面湿润遮罩。
3. 积水风纹。
4. 雨滴涟漪。
5. 可选屏幕空间反射或轻量平面反射。

这部分不能写进 `endfield_cloth.hlsl`，应作为独立 MME/附件和全局控制器。

---

## 9. 控制器建议

不建议立刻把 ZMD 的全部参数做成表情。第一轮只需要：

| 控制 | 用途 |
| --- | --- |
| 雨量 | 总开关与湿润比例 |
| 雨滴强度 | 动态水滴法线/高光 |
| 雨滴大小 | 当前 tiling |
| 雨滴寿命 | 当前 0.65 秒附近调整 |
| 方向扩展 | 从顶部覆盖逐渐扩展到侧面 |
| 流纹强度 | 已有流水法线 |
| 流速 | 已有流水速度 |
| 水膜高光 | 已有 direct/env coat |
| 吸水差异 | 控制 absorption 影响程度 |

高级项如 permeability texture、湿润噪声贴图、投射空间和通道打包方式，
应留给未来 GUI，不继续增加 PMX 表情数量。

---

## 10. 风险与版权

### 10.1 通用性

- 不写死陈千语 UV 区域、材质编号或尺寸。
- 方向分类只使用法线、世界/物体位置和已有 P 通道。
- 可选贴图必须由未来 GUI 检测并绑定。
- 缺少雨水贴图时必须能编译为干燥版本。

### 10.2 MME 性能

第一阶段优先复用现有采样：

- 雨滴 RG/A 与独立相位贴图。
- 流水 RG/B。
- 已有 P 贴图的 Metallic/Smoothness。

ZR1-ZR5 理论上不需要新增采样器。独立湿润噪声和渗透率贴图应等基础
遮罩逻辑通过后再评估 ps_3_0 采样器预算。

### 10.3 参考使用

本报告提取的是公开项目中的算法结构、参数含义和画面行为。正式实现应
继续使用独立编写的 HLSL，并在 README 中注明 ZMD/SeaTran 项目为雨水
效果研究参考。贴图是否可以再分发必须单独核对项目许可证；不能因为
项目可查看就默认所有资源都可随 MME 重新发布。

---

## 11. 最终判断

EndfieldMME 当前雨水并不是方向错误，而是已经进入“基础功能有效，但
材质层次还未收口”的阶段。

按收益排序，最值得做的是：

1. Debug 雨滴法线 4.0 恢复到 1.0。
2. 用方向扩展替代完全全方向覆盖。
3. 分离动画法线遮罩与持续湿润遮罩。
4. 用 P 贴图建立吸水/留珠差异。
5. 用持续遮罩统一粗糙度、水膜高光和轻微颜色响应。
6. 最后再补独立场景雨线、积水和反射。

其中第 3、4 项是接近 ZMD 真实感的核心，第 1、2 项则是下一轮最容易
验证、风险最低的视觉修正。
