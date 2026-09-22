# Arknights Endfield MME Shader

本仓库提供 Endfield MME Shader 和 Endfield Material Studio GUI 工具源码。

## 目录与下载包

- `EndfieldMME/`：唯一运行时，包含 Shader、采集依赖、控制器、通用贴图和第三方声明。
- `Source/EndfieldMaterialStudio/`：GUI 与材质生成器源码、回归测试、发布脚本。
- `docs/`：控制器和环境预设使用说明。
- `CHANGELOG.md`：更新说明；`ASSET_MANIFEST.json`：运行资产清单。

GitHub 源码下载不包含编译出的 EXE。用户发布包才包含 `GUI/EndfieldMaterialStudio.exe`，并与同级的 `EndfieldMME/` 配套使用。
`EndfieldMME/*ChenQianyu*` 是当前 GUI 读取并替换贴图、骨骼和材质编号的模板，不能按文件名当作废弃文件删除。它们不是开箱即用的其他角色材质。
模型与角色贴图由用户提供，不随公开包分发。构建目录、日志、测试输出和本地备份不进入发布包。

## 使用

1. 解压用户发布包，启动 `GUI/EndfieldMaterialStudio.exe`。
2. 确认运行时为包内 `EndfieldMME/`，导入 PMX，检查材质类型和贴图槽。
3. 检查工程并生成角色包，再加载角色包中的 PMX、`ZMDshadow.x` 和需要的眼透附件。
4. 用 EMM 或材质映射说明分配生成的 FX。全局雨量默认关闭。

FaceDepth 入口与核心文件必须同时存在，GUI 会根据最终 PMX 的 Face 材质生成专用采集包装和路由。
布料基础色、法线、属性贴图默认使用 WRAP；特殊素材可在材质 FX 的 include 之前定义 `EF_CLOTH_UV_ADDRESS_MODE CLAMP` 或 `MIRROR`。
完整步骤见 [使用说明](USER_GUIDE_CN.md)。

## 源码构建和发布

使用能读取 `.slnx` 的 .NET SDK（例如 .NET 10 SDK），目标框架仍为 .NET 8。

```powershell
dotnet build Source/EndfieldMaterialStudio/EndfieldMaterialStudio.slnx -c Release
dotnet run --project Source/EndfieldMaterialStudio/EndfieldMaterialStudio.Tests -c Release
pwsh Source/EndfieldMaterialStudio/publish-win-x64.ps1
# 自包含候选包，单独选择一个尚不存在的输出目录
pwsh Source/EndfieldMaterialStudio/publish-win-x64.ps1 -SelfContained -OutputDirectory ./Source/EndfieldMaterialStudio/artifacts/release-self-contained
```

默认输出 `Source/EndfieldMaterialStudio/artifacts/release-win-x64/`，仅含 `GUI/`、一套 `EndfieldMME/`、使用说明、许可和 SHA256 清单。
默认轻量 GUI 需要 .NET 8 Desktop Runtime；`-SelfContained` 包含运行环境，体积较大。
已有输出目录不会被删除或覆盖，请指定新目录。脚本会检查运行时、构建 GUI 并再次检查打包结果；缺少必需文件时停止。
自动检查不代替 MMD 实机视觉验收。

## 许可与参考

原创或独立重写的 Shader、GUI、控制器和文档按 MIT 发布。兼容贴图不因根目录 MIT 自动获得授权；保留资产清单、许可及第三方署名。
见 [资产边界](ASSET_LICENSE_BOUNDARY_CN.md)、[第三方声明](THIRD_PARTY_NOTICES.md)、[作者](AUTHORS.md) 和 [参考](REFERENCES.md)。
