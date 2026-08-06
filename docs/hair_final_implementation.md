# 头发模块最终实现说明

更新日期：2026-08-02  
状态：正式完成并冻结；后续仅接受明确的回归修复

## 1. 正式入口与职责

- GUI 生成的 Hair 材质入口：按当前模型材质分配，直接包含正式版，不保存独立参数副本。
- `EndfieldHair_Final.fx`：头发功能和参数的唯一正式来源。
- `EndfieldHair_controller_Range5.pmx`：74 morph 表情控制器，全部为 0 时返回封版中性值。
- `ZMDshadow.x`：MMD 投影、自阴影和供屏幕空间 Rim 使用的深度附件。

2026-07-30 已删除 75 个迭代测试 FX。后续修改必须从 `EndfieldHair_Final.fx` 和
`internal/` 开始，不再从历史文件名复原实验分支。

职责边界：动态刘海投脸阴影已经作为真实 `发` 材质的独立偏移 Pass 合入
生成的 Hair 材质入口，由共享接收 Stencil bit 1 限定作用域。面、虹膜和眼白共同写入
该接收位，以补齐面部网格的眼窝开口；真实不透明头发写入 bit 2。投影使用
`LESSEQUAL + 0.0025` 接收端深度偏移，使阴影覆盖邻近五官表面但拒绝明显位于脸后的头发。
模型自带的 `发影` 仍可能只是作者制作的模拟阴影几何，正式配置中应按模型测试决定是否关闭。

本次排查的判定方法必须保留：即使把发影临时改为 `ZFunc=ALWAYS`、Opacity=`1.0`，眼睛区域
仍然出现空洞，说明问题不是深度比较或混合强度，而是该像素根本没有通过 Stencil、PS 未执行。
给虹膜和眼白补写共享接收位后空洞消失。以后遇到形状固定的缺口，应先检查接收覆盖，再调深度。

## 2. 资产与通道契约

| 资产 | 色彩空间 | 正式用途 |
|---|---|---|
| `T_actor_<role>_hair_01_D.png` | sRGB | 基础色与原始透明度 |
| `T_actor_<role>_hair_01_HN.png` | Linear | RG 为常规切线空间法线；BA 为高光软化法线 |
| `T_actor_<role>_hair_01_P.png` | Linear | R 为外层/内层法线选择；G 为高光节奏；B 为 AO；A 为暗线区域 |
| `T_actor_common_hair_01_RD.png` | sRGB | 漫反射 Ramp |
| `T_actor_common_hair_08_RS.png` | sRGB 后转 Linear | Kajiya-Kay 高光颜色 LUT |
| `T_actor_common_hairst_01_ST.png` | Linear | R 通道各向异性扰动 |
| `T_actor_common_hairline_03_M.png` | Linear | 发丝暗线纹理 |
| `ZMDshadow_ViewportMap2` | Linear | R 为阴影量，G 为线性相机深度 |

正式汇编绑定上述七张头发贴图和 ZMDshadow，共八个 sampler。不要按文件名猜通道，
也不要把 HN.ba 当透明度、把 P.a 当 smoothness，或把 HairLine 当高光遮罩单独使用。

## 3. 主 Pass 着色顺序

1. 采样 D/HN/P/RD/RS/ST/HairLine，并在线性空间处理颜色。
2. 使用模型法线与 HN.rg 计算漫反射法线；无可靠 PMX 切线时通过 `ddx/ddy` 重建 TBN。
3. 构造高光法线：外层默认 `75%` 头部中心球形法线 + `25% HN.ba`，再由 P.r 选择
   外层软法线或内层常规法线。
4. MMD 主光方向驱动三层卡通漫反射；RD、AO、ZMDshadow、自阴影和逆光补偿共同形成
   亮部、暗部与暗中暗。
5. 世界向上的锥形遮罩只给 `N.y=0.45..0.70` 的头冠补光；它不读取 MMD 灯光方向。
6. P.a 与 HairLine 形成暗线，P.g 保护/切分高光节奏，避免暗部出现连续塑料高光。
7. 使用文章/Unity 路径的 Kajiya-Kay 几何范围，前发采用单侧硬上沿与柔下沿；ST.r、
   XY 缩放和频率控制提供横向长度、纵向厚度及齿形变化。
8. 高光颜色先形成 Goo A/B 分层，再叠加 `linear(RS) * 0.28 * 0.35`。RS 坐标为：

   ```text
   U = saturate(dot(viewDirWS.xz, hairNormalWS.xz))
   V = saturate(rawKkRange)
   ```

9. 最后应用 Base RGB、饱和度、亮度与曝光。控制器映射在 VS 预计算，像素调色顺序不变。

## 4. 灯光与视角约定

- 漫反射、ZMDshadow 投影/自阴影和 Rim 跟随 MMD 全局灯。
- KK 高光使用相机相对的美术键，不直接跟随 MMD 灯，避免转灯时天使环散乱。
- 高光仍会随相机变化，但由软法线、前发 NoV 展宽和 Range320 收敛位置与形状。
- 顶冠光是世界向上补光，只用于恢复头顶层次，不等于环境光或全头提亮。

## 5. 独立屏幕空间 Rim Pass

主 PS 已达到 DX9 预算上限附近，因此 Goo 深度 Rim 不再内联到主色，而在同一 technique 的
`DrawHairRim` 中以 `ONE/ONE` 加法输出。MME Script 必须包含：

```text
Pass=DrawObject;Pass=DrawHairRim;
```

Rim 读取 ZMDshadow 线性深度，使用独立宽高偏移、Fresnel、垂直方向和灯光方向限制。
这是预算约束下的正式结构；不要把旧的内联 Rim 开关重新打开，否则主 PS 会超过 512 槽。

### 5.1 AlphaTest 状态契约与 2026-07-31 异常排查

`DrawHairRim` 必须显式设置以下状态：

```hlsl
ZEnable = true;
ZWriteEnable = false;
ZFunc = LESSEQUAL;
AlphaTestEnable = false;
AlphaBlendEnable = true;
SrcBlend = ONE;
DestBlend = ONE;
BlendOp = ADD;
```

Rim Pass 只向 RGB 做加法，因此像素着色器有意输出 Alpha=`0`。MMD 头发材质可能把
`AlphaTestEnable=true` 留在设备状态中；如果第二 Pass 不主动关闭 Alpha Test，这些 Alpha=`0`
像素会在进入 `ONE/ONE` 混合之前全部被裁掉，屏幕空间 Rim 因而严格为零。深度纹理、Rim
公式、控制器和 technique 调度此时都可能仍然正常。

本次排查按以下顺序完成，可复用于以后所有 MME 多 Pass 异常：

1. 主 Pass 输出纯绿，确认新 FX 已加载，排除 MME 缓存和材质分配错误。
2. 第二 Pass 关闭 ZTest、关闭混合并以 Alpha=`1` 覆盖洋红；实机变洋红，证明 Pass 已执行。
3. 第二 Pass 恢复 `ONE/ONE`、恢复 Alpha=`0`，只增加 `AlphaTestEnable=false`；实机再次变洋红，
   唯一确定零条件为继承的 Alpha Test。
4. 正式版只合入 `AlphaTestEnable=false`，恢复原深度测试和实际 Rim PS；实机确认 Rim 恢复。

不要用“把输出 Alpha 改为 1”作为正式修复，它会无意义地累加目标 Alpha；也不要因这一症状
回退单 Pass 或怀疑 MMD 不支持多 Pass。新增任何叠加 Pass 时，都必须显式声明 Alpha Test、
Alpha Blend、ZTest 和 ZWrite，不能依赖继承状态。

## 6. Range5 控制器

控制器共有 74 个 morph，完整名称与公式见 `hair_controller_spec.md`。分组如下：

- 高光：强度、上下位置、上/中/下段比例、上沿锐度、下沿柔度、层混合、暖度、饱和度与颜色。
- 基础发色：RGB、饱和度、亮度、曝光。
- 形状：外层 HN、Highlight Scale X/Y、Jaggedness、Jagged Frequency X。
- 漫反射：TopLight、TopLight Offset、DarkLine Strength/Saturation。
- 合成：HairRim。
- 刘海投脸阴影：FaceShadow Left/Right/Up/Down、Strength、Brightness、RGB；只在启用动态投影 Pass 时读取。

MMD 滑块仍为 `0..1`；Range5 将正向强度扩到 `5x`、反向降到 `0`，比例/频率覆盖
`0.2x..5x`，位置行程为旧值五倍。颜色、HN 混合和遮罩类参数继续钳制在合法范围。

## 7. 预算与验证

| 程序 | 指令预算 |
|---|---:|
| 主 PS | `504/512`（`9 texture + 495 arithmetic`） |
| 主 VS | `48` |
| Rim PS | `146`（`3 texture + 143 arithmetic`） |
| Rim VS | `16` |

- 四个生产 FX 均通过 `fx_2_0 + /Ges`。
- 生成的 Hair 入口与 `EndfieldHair_Final.fx` 的编译二进制 SHA-256 应完全相同。
- Range5 控制器为 `34833` bytes、74 morph，可复现生成；SHA-256：
  `2F23EC6D9EC3ED4F9550FA586EC124B8D642EF0C90171BFC43169A43EA7D5CCB`。
- 原 60 个着色 CONTROLOBJECT 参数继续进入主 PS、主 VS 或 Rim PS；四个位置项进入动态投影
  VS，十个强度、亮度和 RGB 项进入动态投影 PS。

## 8. 明确淘汰或不合并的路径

- 不恢复 IBL/GGX 主高光；正式版选择 KK+RS，避免双高光和灯光旋转失稳。
- 不恢复普通法线直接驱动外层天使环；外层使用球形/HN.ba 软法线。
- 不恢复上下对称柔化；前发正式轮廓为硬上沿、柔下沿。
- 不恢复整头 Half-Lambert 顶光；只保留头冠锥形遮罩。
- 不恢复主 Pass 内联 Rim；Rim 固定为第二 Pass。
- 历史 Debug FX 已删除，算法演进记录只保存在 `docs/history/hair_pipeline_reevaluation.md`。

## 9. MMD 最终验收表

1. 正、左、右、后视图检查前发连续度、侧面下坠和后脑碎片。
2. 转相机检查高光位置收敛、上下边界和前后发切换。
3. 转 MMD 灯检查漫反射/阴影/Rim 正常响应，同时 KK 不发生无规则漂移。
4. 刘海投脸阴影由真实 `发` 材质的独立偏移 Pass 验证，PMX `发影` 不参与。
5. 检查 Rim 加法亮度、RS 是否偏蓝或过曝、顶光是否只覆盖头冠。
6. 检查 Range5 全部分组的正负极值，确认无黑屏、NaN、穿帮或静默参数。

## 10. EyeThrough 跨模块深度契约与封版结论

EyeThrough 是面部后处理，但会重新捕获真实 `发[7]` 的动态刘海投影 RGB。该捕获只用于
避免眼睛/眉毛透发合成把脸上的刘海阴影洗掉，不会改变正式 Hair 主 Pass、高光、Rim 或
生产环境中的刘海投影深度。

2026-08-02 实机确认最终状态：

```hlsl
// EndfieldEyeThrough_Capture.fxsub，仅捕获用
#define EF_HAIR_FACE_SHADOW_DEPTH_BIAS 0.0015
ZEnable = true;
ZWriteEnable = false;
ZFunc = LESSEQUAL;
ColorWriteEnable = 7;
```

- `ColorWriteEnable=7` 只混合 RGB，保留眼睛/眉毛已经写入捕获 RT 的 Alpha。
- 深度测试关闭或改成 `ALWAYS` 会把 `发[7]` 中位于头后的片层也写进捕获纹理，表现为
  后脑头发穿到虹膜前方。
- 恢复 `LESSEQUAL` 后，`0.0015` 的捕获专用 clip-space bias 只负责跨过虹膜附近的小深度差，
  同时继续拒绝真正位于眼睛之后的头发。
- 正式 Hair 入口的生产刘海投影不使用这项捕获偏置，不能为了修 EyeThrough
  同步修改 Hair 主包装中的深度值。

至此头发模块的基础色、法线、三层漫反射、AO/暗线、KK+RS 高光、顶冠光、ZMDshadow、
屏幕空间 Rim、动态刘海投脸阴影、Range5 控制器及 EyeThrough 交互均已完成。历史 Debug
路径不再恢复；新功能应进入其他材质模块，不再继续扩张头发主 PS。
