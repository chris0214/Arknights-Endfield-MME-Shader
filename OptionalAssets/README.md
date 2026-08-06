# 可选资产

`ProvenanceUnverified/` 保存当前功能测试使用、但尚未确认可公开再分发许可的固定贴图（包括旧 Ray 回退环境图）。它们不会被核心 `ShaderTemplate` 自动引用，也不受根目录 MIT 许可覆盖。

如果你拥有这些贴图的再分发权，可以把对应文件复制到：

```text
ShaderTemplate/textures/common/
```

雨水贴图放入 `ShaderTemplate/textures/common/rain/`。复制后重新生成角色包，并在 GUI 中确认对应 MATCAP/FGD/雨水选项。没有这些贴图时，关闭对应功能即可，Shader 会回退到模型自身 `MATERIALTEXTURE` 或关闭可选分支。
