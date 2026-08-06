# Skin Controller Specification

## Runtime Contract

`EndfieldSkin_controller.pmx` drives the accepted body-skin shader through MME
`CONTROLOBJECT` morph values. Load it with the GUI-generated Endfield skin entry.

All morphs at `0` reproduce the baked profile preset exactly. Every control
uses a signed `+/-` pair, so equal values cancel back to the neutral preset.

Strength and brightness controls map the MMD `0..1` positive morph range to a
Shader multiplier of `1..5`; the negative morph reaches zero. Unit blend and RGB
controls remain clamped to `0..1`.

## Display Frames

### Skin Tone

| Morph pair | Baked value | Range / meaning |
| --- | ---: | --- |
| `皮膚亮部+/-` | `1.12` | light-branch brightness, `0..5x` |
| `皮膚暗部+/-` | `0.82` | dark-branch brightness, `0..5x` |
| `明暗曲線+/-` | `1.0` | half-Lambert curve, `0.1..5.0` |
| `RD色強+/-` | `0.35` | body RD RGB tint blend, `0..1` |
| `LUT強+/-` | `0.35` | dark-branch skin LUT blend, `0..1` |

### Skin SSS

| Morph pair | Baked value | Range / meaning |
| --- | ---: | --- |
| `SSS範囲+/-` | `0.5` | NoV affected range, `0..5` |
| `SSS強+/-` | `1.0` | SSS effect strength, `0..5x` |
| `SSS赤+/-` | `0.822936177` | SSS red channel, `0..1` |
| `SSS緑+/-` | `0.669170380` | SSS green channel, `0..1` |
| `SSS青+/-` | `0.648408771` | SSS blue channel, `0..1` |

### Skin Shadow

| Morph pair | Baked value | Range / meaning |
| --- | ---: | --- |
| `陰影強+/-` | `1.0` | shadow opacity, off to `5x` |
| `陰影柔+/-` | `0.35` | projection transition width, `0.02..2.0` |
| `陰影位置+/-` | `0.5` | projection threshold, `0..1` |

### Skin Specular

| Morph pair | Baked value | Range / meaning |
| --- | ---: | --- |
| `微高光強+/-` | `0.65` | direct-light GGX intensity, off to `25x`; the wider positive range compensates for skin's low dielectric F0 |

### Skin Rim

| Morph pair | Baked value | Range / meaning |
| --- | ---: | --- |
| `辺光強+/-` | `1.17` | NoV Rim intensity, `0..5x` |
| `辺光幅+/-` | `0.35` | NoV Rim area, `0.02..1.0` |
| `辺光硬+/-` | `1.0` | shared NoV/screen Rim contrast, `0.25..8.0` |
| `辺光色切` | `0.0` | `0` PMX `EDGECOLOR.rgb`, `1` manual RGB; intermediate values blend |
| `辺光赤+/-` | `1.0` | Rim red channel, `0..1` |
| `辺光緑+/-` | `0.82` | Rim green channel, `0..1` |
| `辺光青+/-` | `0.78` | Rim blue channel, `0..1` |
| `Screen辺光強+/-` | `0.7` | light-side screen-space depth Rim, `0..5x` |
| `Screen辺光幅+/-` | `1.0` | screen-space offset width, `0..5x` |

## Banding And Rim Decisions

One broad, continuous body light/dark band is the authored `RD.a` transition and
is expected for this NPR material. Broken LUT interpolation would instead appear
as several parallel discrete color steps. The LUT sampler interpolates adjacent
32-slice tiles, so the accepted preset should not expose visible slice bands.

Skin keeps the accepted NoV Rim and adds a separate hair-family screen-space
depth Rim. The depth Rim samples `ZMDshadow_ViewportMap2.g`, but is masked by
the signed direct-light term: the dark-facing hemisphere is zero and the Rim
appears only after the surface turns toward the MMD light. Its strength and
width can be independently reduced to zero if a shot needs only the NoV Rim.

The NoV and screen-space Rim share `辺光色切`, manual RGB, and contrast, but
retain independent strength and width controls. In mode `0`, PMX edge RGB is
decoded from sRGB before lighting. Native MMD outline visibility is independent
from this semantic, so disabling the native outline does not disable Rim color
sampling. `EDGECOLOR.a` is intentionally not used as an intensity multiplier.

## Rebuild

Run:

```powershell
python -B tools\build_skin_controller.py
```

The builder verifies that the PMX morph order exactly matches
`internal/endfield_skin_controls.inc` before writing the controller.
Current output: 45 morphs, 4987 bytes, SHA-256
`4E3A241D95AB2602C47B2D806720A938A71CA3CE3A89F15556EC882CB3C4094B`.
