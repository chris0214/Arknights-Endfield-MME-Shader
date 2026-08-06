# 快速教程

## MMD 场景顺序

1. `ShaderTemplate/ZMDshadow.x`
2. 角色模型
3. `ShaderTemplate/EndfieldEyeThrough.x`（只有启用眼透时）
4. 六个控制器：全局、头发、面部、皮肤、衣服、后处理
5. `ShaderTemplate/EndfieldPost.x`（需要全屏后处理时）

不要同时加载 HgShadow、ExcellentShadow 或其他自阴影后端。正式描边交给 MMD 原生边缘流程。

## GUI 工作流

选择 PMX 后先检查材质分类。Face、Hair、Skin、Cloth、Iris、EyeWhite、EyeHighlight、BrowLash、Mouth 和 Overlay 都只是初始建议；不同模型必须人工确认。没有 MATCAP 05/07、SDF、追加 UV1 或眼透覆盖模型时，关闭对应功能，不要借用其他角色资源。

## 眼透

眼透是可选运行时。GUI 会按当前模型材质域生成捕获文件，保留眼睛、眼白、眉睫，排除面部其他区域，并让头发/发影只提供深度层。远景会自动淡出，避免小尺寸眼睛把后方物体错误透出。

## 雨水与环境

衣服雨水默认关闭。打开衣服控制器中的雨量后，流水、独立水滴相位、湿润粗糙度和环境高光才会生效。环境反射通过 `textures/common/cloth_environment_current.dds` 单槽读取；GUI 或脚本可将七套 CC0 预设复制到该槽。

## 常见问题

- 紫色或黑屏：检查 FX include 相对路径和 DirectX 9/ps_3_0；不要把 `internal/` 单独移动。
- 法线凹凸反向：切换 `Normal Y Sign`，DX 为 `+1`，GL 为 `-1`。
- 眼透穿出耳朵/脖子：关闭错误材质域的 EyeThrough 绑定，重新生成；不要把整张面部材质标成可透。
- 高光过亮：先用全局控制器降低亮面/高光，再调分部控制器；Bloom 必须在 Tonemap 前。
- 控制器无效：确认控制器 PMX 已加载，且 FX 中的 `CONTROLOBJECT` 名称与文件名一致。
