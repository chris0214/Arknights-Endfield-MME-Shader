# 新 GUI 入门教程

## 推荐学习工程

先打开：

`陈千语_从普通PMX开始.endfieldstudio.json`

这个工程已经配置好材质类型与贴图，但 PMX 仍然是普通模型，适合演示完整流程。

## 操作顺序

1. 启动 `EndfieldMaterialStudio.exe`。
2. 点击“打开工程”，选择 `陈千语_从普通PMX开始.endfieldstudio.json`。
3. 在左侧逐项查看 PMX 材质：
   - `#0 面`：Face
   - `#1 目`：Iris
   - `#2 目HL`：EyeHighlight
   - `#3 目白`：EyeWhite
   - `#4 目影`：None
   - `#5 睫眉`：BrowLash
   - `#6 口内`：Mouth
   - `#7 发`：Hair
   - `#8 发影`：None
   - `#9 肌`：Skin
   - `#10 Cloth1`：Cloth
   - `#11 表情`：FaceProxy
4. 选择材质后，在右侧查看该类型需要的贴图槽。
5. 点击“生成眼透派生 PMX”。工具会复制眼睛与睫眉三角面，追加：
   - EyeOverlay
   - BrowOverlay
6. 点击“检查工程”。必须没有 ERROR 才继续。
7. 点击“生成角色包与 EMM”。
8. 在 MMD 中加载生成的派生 PMX，再加载自动映射 EMM。

## 完成工程

`陈千语_眼透完成示例.endfieldstudio.json` 已经指向派生 PMX，并包含 EyeOverlay 与 BrowOverlay，可用于对照最终结构。

## 重要类型

- `None`：保留原材质，不分配 Endfield FX。
- `FaceProxy`：透明表情或面部代理层，不显示 Endfield FX，只参与眼透 shifted depth。
- 未识别材质默认是 `None`，需要用户确认后才会应用 shader。
