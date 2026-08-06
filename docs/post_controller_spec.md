# Endfield Post Controller

`EndfieldPost_controller.pmx` controls the independent `EndfieldPost.x`
screen-space attachment. All morphs at zero select the accepted full-screen
Log2 preset: exposure `+0.08 EV` and Log2 strength `1.25`.

## Modes

- All mode morphs at zero: Log2.
- `GT模式`, `AgX模式`, `Neutral模式`, `ACES模式`: select that curve at `1`.
- Intermediate values blend with Log2. Multiple active modes blend together.
- `原色模式`: bypasses common grading and tone mapping at `1`.

## Common Grade

- `曝光+/-`: `-3..+3 EV`.
- `対比+/-`: log-space contrast `0.5..2.0` around middle gray.
- `飽和+/-`: saturation `0..2.0`.

## White Balance

White balance is applied to the scene-linear HDR signal after exposure and
before contrast, saturation and Tonemap. All four controls at zero are exactly
neutral and preserve the accepted image.

- `色温暖` / `色温冷`: warm/cool chromatic adaptation, range `-1..1`.
- `色偏緑` / `色偏紫`: green/magenta tint adaptation, range `-1..1`.

## Curve Controls

- `Log2曲線+/-`: logarithmic curve strength `0.05..8.0`.
- `GT対比+/-`: Gran Turismo linear-section contrast `0.5..2.0`.
- `GT肩部+/-`: Gran Turismo shoulder position `0.10..0.85`.
- `AgX対比+/-`: AgX look contrast `0.6..1.6`.
- `AgX飽和+/-`: AgX look saturation `0..2.0`.
- `Neutral肩部+/-`: Neutral compression start `0.35..0.95`.
- `Neutral脱色+/-`: Neutral compressed-highlight desaturation `0..1.0`.
- `ACES白点+/-`: ACES fitted white point `1..16`.

## Bloom

Bloom is enabled by default with a restrained preset. The complete scene is
captured in FP16. A Karis-weighted 13-tap first downsample suppresses isolated
fireflies before the five-level float pyramid. Bloom is added to the
scene-referred color before exposure and tone mapping, so the selected Tonemap
compresses the combined HDR result instead of clipping a post-Tonemap glow.

- `Bloom強+/-`: intensity `0..3`, baked value `0.16`.
- `Bloom閾値+/-`: linear threshold `0..1.5`, baked value `0.65`.
- `Bloom柔+/-`: relative soft-knee width `0.01..0.50`, baked value `0.35`.
- `Bloom半径+/-`: lowest-level blur radius `0.25..3.0`.
- `Bloom範囲+/-`: pyramid scatter `0..0.95`, baked value `0.62`.
- `Bloom赤/緑/藍+/-`: per-channel tint `0..2`.
- `Bloom確認`: diagnostic view of the final global Bloom contribution.
  It includes qualifying bright areas from characters and the environment and
  does not change the production Bloom result at zero.

Setting `Bloom強-` to `1` disables Bloom without unloading the attachment.

## Final Output

A stable screen-space interleaved Dither is applied after Tonemap and sRGB
conversion, immediately before the 8-bit output. The baked strength is
`0.5/255`, enough to break up dark gradients without visible grain or temporal
flicker.

- `Dither強+/-`: final-output Dither strength `0..2/255`.

### Adaptive Sharpen

`鋭化強` controls a restrained five-tap contrast-adaptive sharpen after
Tonemap and before sRGB conversion. It is disabled by default (`0`) and ranges
from `0..1.5`. Local range limiting reduces bright/dark halos at silhouettes.

The final order is:

`Bloom -> white balance/exposure/grade -> Tonemap -> sharpen -> sRGB -> Dither`

## Global LUT Status

The extracted `1024x32` Endfield LUT assets currently available in this
workspace are material lookups for cloth and female skin. The
`PreIntegratedFGD_GGXDisneyDiffuse` texture is a BRDF integration table, not a
color-grading LUT. No asset has been identified reliably as the original
game's global post-process color LUT, so the production post effect does not
bind a substitute LUT.
