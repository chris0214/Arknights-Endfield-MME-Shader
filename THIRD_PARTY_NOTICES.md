# 第三方与资产说明

## ZMD / HgShadow

`ShaderTemplate/ZMDshadow*` 与 `HgShadow_*.fxh` 用于 MMD 阴影后端兼容。请保留 `ShaderTemplate/docs/reference/HgShadow_Readme.txt` 中的原始说明和署名。

本发行包只保留运行时需要的兼容头与说明，不把完整的第三方开发树伪装成项目自有代码。

## ray-mmd

本项目只使用 IBL 结构和预过滤环境工作流，不加载 ray.x、GBuffer 或 ray 的后处理管线。MIT 许可文本见 `ShaderTemplate/docs/reference/ray_mmd_LICENSE.txt`。

核心包不携带 Ray 回退环境图。旧回退图如需本地研究，位于
`OptionalAssets/ProvenanceUnverified/`，不由根目录 MIT 许可覆盖。

## CC0 环境

`ShaderTemplate/textures/environment_presets/*.dds` 是用户提供的 CC0 HDR 转换结果；清单见 `manifest.json`。原始 4K HDR 不在运行时包中。

## 来源未确认资产

MatCap 019、FGD LUT 和雨水贴图目前放在 `OptionalAssets/ProvenanceUnverified/`。它们不由根目录 MIT 许可流程，覆盖。重新发布前请确认原作者许可，或者替换为自制/明确许可资源。


