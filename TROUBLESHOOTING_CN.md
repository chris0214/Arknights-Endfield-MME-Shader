# 故障排查

## 报错或紫色

检查 MME 版本、DirectX 9、FX 相对路径和 `internal/` 是否与入口 FX 同级。紫色通常表示贴图或 include 找不到。

## 阴影异常

只加载 `ZMDshadow.x`，确认 MMD 自阴影已打开。全局阴影倍率默认 `0.4`，不要同时加载 HgShadow/ExcellentShadow。

## 眼透错误

眼透不是“整张脸透明”。只绑定 Iris、EyeWhite、EyeHighlight、BrowLash 和必要 Overlay；耳朵、脖子、面部其他材质必须保持普通深度。远景淡出是设计行为。

## 雨水同步出现

保留独立 `rain_drops_phase.png`，不要把所有水滴采样到同一个时间相位。雨量为 `0` 时应完全关闭雨水分支。

## 颜色不一致

先确认 Base 是否使用模型自己的 MATERIALTEXTURE，再检查 LUT/RD 是否只给一侧材质启用。衣服 LUT 默认强度为 `0`，可通过控制器手动开启。
