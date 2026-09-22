# 环境预设

`EndfieldMME/textures/environment_presets/` 提供七套环境反射 DDS，名称和来源见该目录的 `manifest.json`。
运行时使用 `textures/common/cloth_environment_current.dds`。要切换环境，在本地角色包中将选定预设复制为这个文件名，再重新加载材质。
这些资源影响衣服环境反射，不是天空盒或角色模型贴图。保留 DDS 的尺寸、Mip 和编码，不能直接换成普通 PNG。
原始 HDR 与转换工具不随包分发；预设来源和许可范围以 `ASSET_MANIFEST.json`、`THIRD_PARTY_NOTICES.md` 为准。
