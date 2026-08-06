# 材质与贴图映射

| 域 | 最小输入 | 可选输入 | 说明 |
|---|---|---|---|
| Face | Base/MATERIALTEXTURE | SDF、RD、LUT、ST、唇高光 | 面部阴影以 SDF/角度响应为主 |
| Hair | Base | HN、ORM、RD、RS、ST、HairLine、UV1 | 需要 UV1 才启用 Unity 风格高光 |
| Skin | Base | RD、LUT、Normal | SSS、GGX 微高光、屏幕空间 Rim |
| Cloth/Prop | Base | Normal、MRO/ORM、RD、RS、LUT、MATCAP、FGD、雨水 | MRO 通道约定 R=Metallic、G=Reflectivity、B=AO、A=Smoothness；粗糙度使用 One Minus |
| Iris | Base | MATCAP 05/07、视差 | 缺贴图时关闭对应 MatCap |
| EyeWhite/Highlight | Base/MATERIALTEXTURE | 高光贴图 | 高光层默认自发光，避免角度遮挡穿帮 |

贴图选择优先级是“当前模型自身资源 > 用户明确选择的外部资源 > 不启用”。核心模板不会自动引用陈千语贴图。
