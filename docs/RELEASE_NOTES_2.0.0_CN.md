# Endfield Material Studio 2.0.0

发布日期：2026-08-10

## 主要内容

- 全新的通用 PMX 材质编辑与打包工具。
- 独立材质 FX 工作流，减少对固定角色 EMM 绑定的依赖。
- 从普通 PMX 生成不修改源模型的眼透派生 PMX。
- 自动生成模型专属 EyeThrough Capture、ZMD 阴影路由、EMM 与材质映射清单。
- PMX 基础、球面与外部 Toon 贴图自包含打包。
- 缺失 PMX 路径可从 `other tex` / `other_tex` 精确同名回退，不进行模糊匹配。
- Windows x64 单文件、自包含 GUI，无需另外安装 .NET Desktop Runtime。

## 已验证

- Release 构建：0 个错误。
- 陈千语完整回归：`ALL_TESTS_PASSED`。
- PMX 贴图回退回归：`PMX_TEXTURE_FALLBACK_TEST_PASSED`。
- 先前人工验证模型：陈千语、李织烟、祀。

自动匹配仍是初始建议。不同模型作者的材质命名、贴图通道与透明层可能不同，发布使用前必须人工检查材质类型和贴图槽。

## 兼容环境

- Windows x64。
- MikuMikuDance 9.32 x64。
- MikuMikuEffect 0.37 x64。
- DirectX 9 / Shader Model 3.0。

## 许可提醒

项目原创或独立重写的代码与文档按 MIT License 发布。兼容运行时内来源未确认的游戏命名贴图、MatCap、FGD、雨水与旧环境资源不受项目 MIT 许可覆盖。详见 `ASSET_LICENSE_BOUNDARY_CN.md` 与 `THIRD_PARTY_NOTICES.md`。
