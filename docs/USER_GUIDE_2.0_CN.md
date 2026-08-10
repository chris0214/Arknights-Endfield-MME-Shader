# Endfield Material Studio 完整使用教程

本文适用于 Endfield Material Studio 2.0.0。工具用于读取普通 PMX、分配 Endfield MME 材质、生成眼透派生模型，并输出可移动的角色包与 EMM。工具不会改写 EndfieldMME 的核心 Shader。

## 一、准备工作

需要准备：

- MikuMikuDance 9.32 x64。
- MikuMikuEffect 0.37 x64。
- 一个合法取得、可正常载入的 PMX 模型。
- 模型原有基础贴图，以及模型自己的 SDF、法线、Property/MRO 等语义贴图。
- 本发行包内的 `EndfieldMaterialStudio.exe` 和 `ShaderTemplate`。

请把 EXE 与 `ShaderTemplate` 保持在同一目录。不要直接删除或重命名 `ShaderTemplate/internal`。

## 二、从普通 PMX 新建工程

1. 启动 `EndfieldMaterialStudio.exe`。
2. 点击“新建 / 导入 PMX”，选择普通模型，而不是已经生成过覆盖材质的派生 PMX。
3. “运行时”选择发行包内的 `ShaderTemplate`。软件能够自动找到时，可保留自动结果。
4. “输出”选择一个新的空目录；最终角色包、派生 PMX、FX、EMM 与工程 JSON 会放在这里。
5. 设置工程名。建议只使用中文、英文、数字、空格、下划线和短横线。

导入后先核对 PMX 材质编号、日文名/中文名和基础贴图预览，不要立即生成。

## 三、材质分类

为每个 PMX 材质选择最符合实际用途的类型：

- `Face`：面部主材质，只走 SDF 面部光照，不接收普通衣服阴影。
- `Iris`：虹膜/瞳孔，包含眼睛视差、MatCap 与眼透 stencil。
- `EyeHighlight`：眼睛高光层。
- `EyeWhite`：眼白。
- `BrowLash`：眉毛、睫毛。
- `Mouth`：嘴唇与口内材质。
- `Hair`：头发，包含头发高光、屏幕空间边缘光与偏移发影。
- `Skin`：脖子、身体与四肢皮肤。
- `Cloth`：衣服、布料、皮革和金属；包含 ZMD 阴影与可选雨水链。
- `FaceProxy`：模型原有的透明表情、面部代理或面部遮挡层，只参加眼透深度，不作为可见材质渲染。
- `None`：不生成 FX，保留给不应使用本 Shader 的材质。

不要仅凭材质名称猜测。尤其要逐项确认眼白、虹膜、眼睛高光、眉睫、发影和透明面部材质。

## 四、基础色与语义贴图

点击“自动匹配贴图”后仍需人工检查。通用编辑器不能保证不同作者的文件命名完全一致。

### 基础色

- 默认优先使用 PMX 已声明且实际存在的基础贴图。
- 如果 PMX 声明路径缺失，软件只会在模型同级的 `other tex` 或 `other_tex` 中精确查找同名文件。
- `PMX_TEXTURE_FALLBACK` 是可解释的警告：打包时会把命中的贴图恢复到 PMX 原声明相对路径。
- 软件不会采用近似文件名，以免把错误贴图悄悄装进角色包。

### 面部

- `Base`：角色自己的面部基础色。
- `SDF`：角色自己的面部 SDF；不能用另一个角色的 SDF。
- `RD/LUT/ST/Color Mask`：按模型资源实际情况选择。
- 面部只需要 SDF 阴影；衣服、皮肤、头发仍由正常世界光与 ZMD 阴影负责。

### 头发

- `Base`：角色自己的头发基础色。
- `Normal`：头发法线。
- `Property`：角色材质属性贴图。
- `RD/RS/ST/Hair Line`：按模型资源选择；缺少追加 UV1 时 ST 会回退到 UV0。
- 头发材质负责屏幕空间边缘光和偏移发影，不能把头发误分为 `Cloth`。

### 衣服与皮肤

- `Base`：模型自己的基础色。
- `Normal`：通常按 DirectX 法线使用；控制器可翻转绿色通道以兼容 OpenGL 法线。
- `Property/MRO`：必须确认通道定义。当前工作流常见约定为 R=Metallic、G=Reflectivity、B=AO、A=Smoothness；若来源不同应以原模型说明为准。
- `RD/RS/LUT`：只在来源和用途明确时使用。衣服 LUT 默认可关闭，避免改变模型原色。

## 五、生成眼透派生 PMX

眼透至少需要：

- 一个 `Iris` 材质。
- 一个 `BrowLash` 材质。
- 正确标记的头发 `Hair` 材质。
- 模型若存在透明表情或面部代理材质，应标为 `FaceProxy`。

启用“眼透”和“生成派生 PMX”后，软件会：

1. 复制普通 PMX，不修改原文件。
2. 为虹膜和眉睫建立覆盖材质。
3. 保留模型原来的材质顺序与贴图依赖。
4. 把派生模型放进输出角色包的 `Model` 目录。
5. 生成模型专属 `EndfieldEyeThrough_Capture.fxsub`。

不要把某个角色固定的材质序号写进其他模型。软件会根据当前工程的分类结果生成 Capture 子集。

## 六、检查工程

生成前点击“检查工程”。必须修复所有 `ERROR`。

常见信息：

- `SDF_TEXTURE` / `FACE_SDF_TEXTURE`：面部启用了 SDF，但没有选择角色自己的 SDF。
- `MATERIAL_BINDING`：启用的材质类型没有绑定实际 PMX 材质。
- `DUPLICATE_BINDING`：一个 PMX 材质被重复绑定。
- `UNBOUND_MATERIAL`：该材质不会获得 Endfield FX；确认这是有意的 `None`。
- `PMX_BASE_MISSING`：PMX 材质没有基础贴图；透明遮罩材质可能正常，其他材质应核对。
- `HAIR_HIGHLIGHT_NO_UV1`：模型没有追加 UV1，头发 ST 将回退到 UV0。
- `PMX_TEXTURE_FALLBACK`：原声明路径缺失，但在 `other tex` / `other_tex` 精确找到同名贴图。

## 七、生成角色包

检查无错误后点击“生成角色包与 EMM”。输出目录包含：

- `Model/`：派生 PMX 与模型原依赖贴图。
- `textures/character/`：当前角色语义贴图的打包副本。
- `Material_###_Role.fx`：每个材质独立的 FX。
- `material-map.json` 与中文材质映射说明。
- `EndfieldEyeThrough.x/.fx` 与模型专属 Capture。
- `ZMDshadow.x/.fx`。
- 控制器、`internal`、通用贴图与环境预设。
- `工程名_自动映射.emm`。
- 完成后的 `.endfieldstudio.json`。

生成后的工程 JSON 会改为引用角色包内的 PMX、运行时和贴图，因此整个输出目录可以移动。

## 八、在 MMD 中加载

推荐顺序：

1. 打开输出角色包中的派生 PMX。
2. 拖入 `ZMDshadow.x`。
3. 拖入 `EndfieldEyeThrough.x`。
4. 根据需要拖入 `EndfieldPost.x`。
5. 载入自动生成的 EMM，或在 MME 效果分配中按 `material-map.json` 手动把各材质绑定到对应 `Material_*.fx`。
6. 载入控制器 PMX，调整全局、头发、面部、皮肤、衣服与后处理参数。

当前材质、阴影和眼透包含自路由规则，EMM 是便利入口而不是唯一依赖。若其他 MME 改写了相同 RT，仍需在 MME 效果排序中确认 EyeThrough 与 ZMD 的执行顺序。

## 九、后处理

- Bloom 应在 Tonemap 之前执行。
- Tonemap 支持工程内提供的模式；曝光、白平衡、Dither 和锐化由后处理控制器调整。
- 轻量锐化默认关闭。
- 若画面过曝，先降低 Bloom 强度或阈值范围，再调整曝光和 Tonemap；不要只把基础色压暗。

## 十、雨水

- 雨量默认是 0。
- 雨水包含湿润光滑、雨滴、流水、水花和干湿变化。
- 先用较低雨量确认法线方向，再增加雨量、流速和可见强度。
- 法线看起来内凹时，检查模型法线格式并尝试控制器的 DX/GL 翻转，而不是修改核心 Shader。

## 十一、通用模型注意事项

- 自动分类和自动贴图匹配只是初始建议，最终结果必须由用户按模型材质表确认。
- 每个角色都必须使用自己的基础色、SDF、法线和属性贴图。
- 不要分发模型作者禁止二次配布的 PMX 或角色贴图。
- 不要把游戏提取资源视为本项目 MIT 资产。许可边界见 `ASSET_LICENSE_BOUNDARY_CN.md`。
- 遇到异常时保存工程 JSON、`material-map.json`、PMX 材质表和 MME 报错截图，以便定位是分类、贴图、绑定还是 RT 排序问题。

## 十二、源码构建

安装 .NET 8 SDK 后，在源码目录运行：

```powershell
dotnet restore EndfieldMaterialStudio.slnx -r win-x64
dotnet build EndfieldMaterialStudio.slnx -c Release
./publish-win-x64.ps1 -RuntimeRoot "完整的 EndfieldMME 或 ShaderTemplate 路径"
```

发布脚本优先复用同工作区旧工具的本地 .NET 8 运行时缓存；没有缓存时需要联网下载 Microsoft 的 `win-x64` 运行时包。

集成回归不会附带或下载角色模型。运行陈千语回归时，由测试者自行准备有权使用的 PMX，并设置：

```powershell
$env:ENDFIELD_MME_RUNTIME = "本地 EndfieldMME 路径"
$env:ENDFIELD_TEST_PMX = "本地陈千语回归 PMX 路径"
dotnet run --project EndfieldMaterialStudio.Tests -c Release
```

没有设置 `ENDFIELD_TEST_PMX` 时测试程序会明确显示 `INTEGRATION_TEST_SKIPPED`，不会把角色模型打进源码或从网络下载。

## 十三、署名、许可与参考

- 主要作者：克里斯提亚娜。
- 项目原创/独立重写代码和文档：MIT License。
- 第三方通知：`THIRD_PARTY_NOTICES.md`。
- 资产边界：`ASSET_LICENSE_BOUNDARY_CN.md`。
- 研究参考：`REFERENCES.md`。

参考与致谢不代表任何第三方为本项目背书，也不改变原作品许可。
