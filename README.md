	# Endfield MME 开源发行包

这是面向 **MikuMikuDance 9.32 x64 + MME 0.37 x64 + DirectX 9** 的通用 Endfield 风格材质与后处理模板。它不是某一个角色的专用 Shader：GUI 会读取当前 PMX 的材质、贴图和 UV，生成对应的材质域包装与可移动角色包。

## 目录

- `ShaderTemplate/`：通用 HLSL、FX/FXSUB、控制器、ZMDshadow、后处理和可再分发的固定资产。
- `Tool/`：Windows GUI 发布版。默认寻找同级 `ShaderTemplate`，也可以手动选择模板目录。
- `Source/`：GUI 的 C# 源码、测试和发布脚本。
- `OptionalAssets/`：来源或再分发许可尚未确认的研究资产；不会被核心模板自动引用。
- `Examples_LocalOnly/`：本机角色示例的占位目录，不含角色模型或贴图。
- `docs/`：中文快速教程、材质映射、控制器、故障排查和致谢。
- `ASSET_MANIFEST.json` / `SHA256SUMS.txt`：资产来源边界与文件校验。

## 三分钟开始

1. 安装 MMD 9.32 x64、MME 0.37 x64 和 .NET 8 Desktop Runtime。
2. 在 MMD 中先加载 `ShaderTemplate/ZMDshadow.x`；不要同时加载另一套阴影后端。
3. 运行 `Tool/EndfieldShaderTool.exe`，导入 PMX，确认材质域和贴图，再生成角色包。
4. 将生成包中的控制器拖入 MMD，按生成的材质说明把 FX 分配给对应材质。
5. 后处理顺序固定为：**Bloom 在前，Tonemap 在后**。雨水默认关闭，主控制器雨量默认是 `0`。

完整步骤见 [`QUICKSTART_CN.md`](QUICKSTART_CN.md)。

## 许可边界

本项目自行编写的 Shader、工具、控制器脚本和文档按根目录 `LICENSE` 发布。七套环境 DDS 是用户提供的 CC0 HDR 转换结果。`OptionalAssets/ProvenanceUnverified/` 中的 MatCap、FGD 和雨水贴图来自参考工程，未被本项目声明为可自由再分发资产；发布者应在使用前自行确认权利，或用自己的等价贴图替换。

核心模板不携带来源未确认的 Ray 回退环境图；运行时槽位使用
`textures/common/cloth_environment_current.dds`，可从七套 CC0 环境预设中选择。
旧的 Ray 回退图若有本地研究需要，可从 `OptionalAssets/ProvenanceUnverified/`
单独安装，但它不属于核心许可范围。

参考工程只用于研究算法和行为，不代表代码复制或版权转移。详见 [`AUTHORS.md`](AUTHORS.md) 与 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

致谢：
-秋大叔@知乎：阴影以及整体渲染思路；本项目重新实现并适配 MME。
-新杨XIYAG ：PBR 高光、材质分层、LUT 和后处理思路参考
-ray-mmd：预过滤环境贴图工作流和 IBL 行为参考；保留 MIT 通知。
-針金P：HgShadow及 MMD/MME 社区：阴影与 MME 生态基础。
-SeaTran：雨水效果代码参考。
