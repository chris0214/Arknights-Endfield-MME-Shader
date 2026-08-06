# Endfield Shader Tool

面向 MMD/MME 的 Endfield 材质工程工具。它读取 PMX 材质，自动建议 Face、Hair、Skin、Cloth、Iris、EyeWhite、EyeHighlight、BrowLash、Mouth 和眼透覆盖等材质域，并从同级 `ShaderTemplate` 生成可移动的角色包。

工具不会修改原始 PMX、原始 `EndfieldMME` 或用户已有的 EMM。生成过程使用 staging 目录，校验通过后才原子提交到输出目录。

## 使用

1. 启动 `EndfieldShaderTool.exe`。发行包会自动寻找 GUI 上一级目录的 `ShaderTemplate`；也可以在“模板目录”一栏手动选择任意模板目录。
2. 选择 PMX，填写角色名和输出目录，点击“导入 PMX”。
3. 在材质列表中确认自动分类；通用模型可以逐项改为 Face、Hair、Skin、Cloth 或眼部域。
4. 右侧按材质域选择模型自带贴图或外部贴图：Base、Normal、MRO/Property、RD、RS、LUT、SDF、ST、ColorMask、HairLine 和 MATCAP 05/07。顶部可单独开关眼透与后处理。
5. 点击“保存工程”保存 `.endfieldproject.json`，点击“生成角色包”生成 FX、控制器、运行时、贴图和可选 EMM。
6. 如果安装了 `fxc.exe`，点击“编译检查”进行静态路径验证和 FXC 检查。

## 默认行为

- 基础色默认使用 PMX 的 `MATERIALTEXTURE`，不会强行套用陈千语贴图。
- 雨水默认关闭，雨量默认值为 `0`；只有启用 Cloth 雨水后才写入雨水宏。
- MATCAP 05/07 缺失只产生警告，GUI 可以关闭对应功能，不会阻止其他材质生成；MATCAP 05/07 不会自动从某个角色借用。
- Face 使用头骨名称和面部 SDF；EyeThrough 是可选运行时，不要求所有模型都提供派生模型。
- 正式描边继续使用 MMD 原生描边；Endfield 材质只提供屏幕空间边缘光和材质高光。
- ZMDshadow 是唯一的阴影后端，生成包会复制 `ZMDshadow.x`、`ZMDshadow.fx`、两个映射 `.fxsub` 和 Endfield 控制器。

## 生成包结构

```text
<输出>/<role_slug>/
  internal/                       Endfield HLSL 核心
  textures/common/                MATCAP、FGD、HDR、雨水贴图
  textures/environment_presets/   可选环境预设
  textures/<role_slug>/           当前角色实际使用的贴图
  presets/<role_slug>/            每个材质域的 FX 和 include
  controller/                     Endfield 全局、Face、Skin、Hair、Cloth、Post 控制器
  ZMDshadow.x / ZMDshadow.fx
  EndfieldEyeThrough.x / EndfieldPost.x（按选项复制）
  <role_slug>.endfieldproject.json
  <role_slug>_自动映射.emm（可选）
  FXC_UNVERIFIED.txt 或 FXC_VALIDATED.txt
```

EMM 使用当前机器的绝对路径，适合立即在 MMD 中载入；移动角色包后，在 GUI 中重新生成即可。角色包本身的工程 JSON 和贴图引用使用相对路径，可以整体搬移。

## 通用模型注意事项

- 不同模型的材质命名、UV、法线贴图和 MATCAP 资源可能不同，自动分类只提供初始建议。
- 没有 MATCAP 05/07、SDF、追加 UV1 或派生 EyeThrough 模型时，关闭相应开关即可，不能用陈千语资源替代模型自身数据。
- 法线默认按 Unity/DX 约定读取；遇到 GL 法线时，在材质参数中将 Normal Y Sign 改为 `-1`。
- Cloth 的 MRO/ORM 通道和雨水法线只在选择对应贴图后启用；雨水生命周期、法线强度和环境高光仍可通过控制器微调。

## 开发

```powershell
$env:DOTNET_CLI_HOME = "$PWD/.dotnet_home"
$env:APPDATA = "$PWD/.appdata"
$env:LOCALAPPDATA = "$PWD/.localappdata"
dotnet restore EndfieldShaderTool.slnx --configfile NuGet.Config
dotnet build EndfieldShaderTool.slnx --no-restore
./publish-win-x64.ps1
```

发布脚本生成 `artifacts/publish/EndfieldShaderTool.exe` 的 framework-dependent 多文件版本，需要安装 .NET 8 Desktop Runtime。发布脚本只写入 `artifacts/publish`，不会覆盖原始 Shader、备份目录或工作模板。
