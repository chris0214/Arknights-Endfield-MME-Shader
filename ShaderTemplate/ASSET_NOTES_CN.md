# 模板固定资产说明

核心模板只默认携带项目代码、控制器、ZMDshadow、七套 CC0 环境 DDS 和明确保留的第三方通知。MatCap、FGD、雨水等来源未确认贴图位于发行包根目录的 `OptionalAssets/ProvenanceUnverified/`，不会被自动加载。

若要启用衣服高光/雨水测试，请先确认贴图许可，再复制到 `textures/common/` 或 `textures/common/rain/`，然后在 GUI 中选择。雨水默认关闭，雨量默认 `0`。

需要从自己的 CC0 HDR 重新生成环境 DDS 时，准备外部 cmft 压缩包并运行：

```powershell
powershell -ExecutionPolicy Bypass -File tools\convert_hdr_presets.ps1 `
  -SourceRoot "D:\HDR\EndfieldPresets" `
  -CmftArchive "D:\Tools\cmft_rgbt_x1024.zip"
```

`-SourceRoot` 必须包含清单中的七个 `*_4k.hdr` 文件；脚本不会依赖作者机器上的固定盘符。
