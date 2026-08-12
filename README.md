# Arknights Endfield MME Shader

## 目录

- `EndfieldMME/`：唯一权威运行时，包含 HLSL、FX/FXSUB、控制器、阴影/后处理入口和必要兼容贴图。
- `GUI/`：Windows x64 单文件 `EndfieldMaterialStudio.exe`（由源码发布脚本生成）。
- `Source/EndfieldMaterialStudio/`：GUI、PMX/EMM 生成器、模板内嵌资源和便携测试源码。
- `docs/`：实现说明、控制器说明、参考资料和开发记录。
- `ASSET_MANIFEST.json`：唯一有效的当前资产清单。

## 快速开始

1. 安装 MMD 9.32 x64、MME 0.37 x64 和 Windows x64 运行环境。
2. 在 MMD 中加载 `EndfieldMME/ZMDshadow.x`，再按需要加载 `EndfieldMME/EndfieldEyeThrough.x` 和 `EndfieldMME/EndfieldPost.x`。
3. 启动 `GUI/EndfieldMaterialStudio.exe`。GUI 会自动查找同级上级目录中的 `EndfieldMME`，也可以在界面中手动选择运行时目录。
4. 导入普通 PMX，检查材质角色和贴图槽，点击“检查工程”，再生成角色包与 EMM。
5. 后处理顺序保持 **Bloom 在前，Tonemap 在后**。全局雨量默认关闭（0）。

完整流程见 [`USER_GUIDE_CN.md`](USER_GUIDE_CN.md)。

## 源码构建

```powershell
dotnet build Source/EndfieldMaterialStudio/EndfieldMaterialStudio.slnx -c Release
dotnet run --project Source/EndfieldMaterialStudio/EndfieldMaterialStudio.Tests -c Release
pwsh Source/EndfieldMaterialStudio/publish-win-x64.ps1
# 可选：生成体积较大的自包含 Release
pwsh Source/EndfieldMaterialStudio/publish-win-x64.ps1 -SelfContained
```

发布脚本默认生成需要 .NET 8 Desktop Runtime 的轻量单文件 GUI；加 `-SelfContained` 可生成无需另装运行时的较大版本。两种模式都会输出 `artifacts/release-win-x64/GUI/EndfieldMaterialStudio.exe` 并复制当前 `EndfieldMME`，不会创建第二份运行时目录。

## 许可与参考

原创或独立重写的 Shader、GUI、控制器和文档按 MIT 发布。`ASSET_MANIFEST.json` 对游戏命名贴图、雨水贴图、MatCap/FGD 等兼容资产单独标注，它们不因根目录 MIT 自动获得再分发授权。请阅读 [`ASSET_LICENSE_BOUNDARY_CN.md`](ASSET_LICENSE_BOUNDARY_CN.md) 和 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

研究参考包括 ray-mmd、HgShadow、ZMD、DanbaidongRP、Goo Blender 预设、ComicalEdge 以及 MMD/MME 社区；参考不表示原作者为本项目背书，也不随包分发角色模型或 Unity/Blender 工程。详见 [`AUTHORS.md`](AUTHORS.md) 与 [`REFERENCES.md`](REFERENCES.md)。
