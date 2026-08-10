# 资产许可边界

根目录 `LICENSE` 的 MIT 许可只覆盖克里斯提亚娜原创或独立重写的代码、控制器和文档。它不会自动覆盖文件名中带有游戏资产命名、从参考工程导出或来源尚未核实的贴图。

## 可以明确再分发

- `ShaderTemplate/internal/**`：项目原创/独立重写 Shader 源码，MIT。
- `ShaderTemplate/controller/*.pmx`：项目生成的单三角面控制器，MIT。
- `ShaderTemplate/textures/environment_presets/*.dds`：由用户提供的 CC0 HDR 转换；清单见 `manifest.json`。
- ray-mmd 与 HgShadow 的原始许可/说明文件：按各自原许可保留。

## 不受根目录 MIT 覆盖

- `T_actor_common_*`、`T_actor_*` 等游戏资源命名贴图。
- `Eff_MatCap_019*.png`、`PreIntegratedFGD_GGXDisneyDiffuse.png`。
- `textures/common/rain/**` 雨水贴图。
- `ray_default_skyspec_hdr.dds` 及其他来源没有单独确认的贴图。

这些文件若出现在二进制 release 中，只是为了兼容当前已验证运行时；本项目不声称拥有其版权，也不授予其 MIT 权利。公开再分发前，发布者应自行确认权利，或替换为自制/明确许可的等价资产。

## 不得随项目发布

- 任何角色 PMX、角色专属贴图、作者模型包、Goo `.blend` 工程。
- 李织烟模型及其贴图：原模型说明禁止二次配布。
- 从游戏或参考项目中提取、且没有明确再分发许可的原始资源。

如发现资产权利标注有误，请提交 issue；确认后应优先移除或替换，而不是默认纳入 MIT。
