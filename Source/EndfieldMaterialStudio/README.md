# Endfield Material Studio

一套独立的 MMD Endfield 材质分配工具。它读取普通 PMX，帮助用户确认材质类型和贴图槽，并生成：

**主要作者：克里斯提亚娜。** 完整操作流程见 `USER_GUIDE_CN.md`；许可、第三方通知与资产边界分别见 `LICENSE`、`THIRD_PARTY_NOTICES.md` 和 `ASSET_LICENSE_BOUNDARY_CN.md`。

- 不修改源模型的眼透派生 PMX，并随角色包放入 `Model` 文件夹
- PMX 实际引用的基础、球面与外部 Toon 贴图，按原相对目录复制到 `Model`
- 每个 PMX 材质对应的 FX 包装文件
- EyeThrough Capture 配置
- ZMD 阴影与眼透顺序正确的 EMM
- 可移动保存的 `.endfieldstudio.json` 工程

## 设计边界

- `EndfieldMME` 是唯一权威渲染运行时。
- 工具不会修改 `internal/*.hlsl` 或权威 FX 的算法与数值。
- 生成 FX 只把权威入口中的陈千语贴图路径替换成当前角色贴图，并替换头骨名称和材质序号。
- 未识别材质默认不绑定 FX，不会自动当成衣服。
- 材质语义贴图（SDF、RD、RS、LUT、法线等）缺失时停止生成，不使用可能改变观感的隐式猜测。
- PMX 自身声明的基础、球面或外部 Toon 贴图若原路径缺失，只会在模型同级的 `other tex` / `other_tex` 中精确查找同名文件；命中时显示 `PMX_TEXTURE_FALLBACK` 警告，不做模糊匹配。
- 角色包仍按 PMX 原声明路径写入回退贴图，因此无需修改原 PMX，生成后的 `Model` 目录可自包含使用。

## 基本流程

1. 点击“新建 / 导入 PMX”或 PMX 路径右侧的“选择”，选择普通 PMX。
2. 用“运行时”右侧的“选择”指定已验证的 `EndfieldMME`；用“输出”右侧的“选择”指定角色包保存位置。
3. 确认自动识别的材质类型。
4. 点击“自动匹配贴图”，再逐项检查右侧贴图槽。
5. 需要眼透时，确认至少存在 `Iris` 和 `BrowLash`，并把透明表情/面部代理材质标记为 `FaceProxy`。
6. 点击“检查工程”，修复所有错误。
7. 点击“生成角色包与 EMM”。生成后，EMM、FX、运行时和 `Model/<派生模型>.pmx` 均位于同一个角色包中。

## 材质类型

- `Face`: SDF 面部，仅使用面部 SDF 光照链。
- `Iris`: 虹膜、视差和共享 stencil。
- `EyeHighlight`: 眼睛高光层。
- `EyeWhite`: 眼白。
- `BrowLash`: 眉毛与睫毛。
- `Mouth`: 口内。
- `Hair`: 头发、KK/RS 高光、屏幕空间边缘光和偏移发影。
- `Skin`: 身体皮肤。
- `Cloth`: 衣服、皮革、金属、ZMD 阴影和雨水链。
- `FaceProxy`: 透明表情/面部代理层，仅参与眼透 shifted depth，不绑定可见 FX。
- `EyeOverlay` / `BrowOverlay`: 由眼透派生 PMX 自动生成。
- `None`: 不绑定 FX。

## 回归保护

`EndfieldMaterialStudio.Tests` 会使用陈千语普通 PMX 验证：

- 眼透页面在 ZMD 页面之前
- 控制器仅为 `Pmd3..Pmd7`，没有 `Pmd8`
- 衣服和皮肤使用 ZMD 阴影
- 头发偏移阴影与眼透深度存在
- 虹膜和覆盖层 stencil 正确
- 输出 `internal` 文件与权威 `EndfieldMME` 文件哈希一致
- EMM 与生成后的工程 JSON 都指向角色包内 PMX
- PMX 引用贴图全部存在于角色包 `Model` 文件夹
- PMX 缺失声明路径可从 `other tex` / `other_tex` 精确回退，重开工程后仍有效
- 近似文件名不会被误匹配，打包后贴图恢复到 PMX 原相对路径

## 发布说明

- `Release-win-x64`：单文件 GUI 与运行所需 `ShaderTemplate`。
- `Source`：GUI、打包器、PMX/EMM 处理与测试源码。
- 正式公开包不包含角色 PMX、角色专属贴图或 Goo `.blend` 工程。
- `ShaderTemplate` 中来源未确认的兼容贴图不受项目 MIT 许可覆盖；公开再分发前请阅读资产边界文档。

## 集成测试

测试项目不会附带或下载角色模型。未设置 `ENDFIELD_TEST_PMX` 时会显示 `INTEGRATION_TEST_SKIPPED`。完整回归由测试者自行准备有权使用的 PMX：

```powershell
$env:ENDFIELD_MME_RUNTIME = "本地 EndfieldMME 路径"
$env:ENDFIELD_TEST_PMX = "本地陈千语回归 PMX 路径"
dotnet run --project EndfieldMaterialStudio.Tests -c Release
```
