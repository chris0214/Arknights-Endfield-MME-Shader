# Post-Processing Reference Analysis

Date: 2026-08-04

## Decision

Post-processing must remain a separate screen-space attachment. It must not be
embedded in the face, hair, skin or cloth material shaders. The material set
must still read correctly with post-processing disabled, while the post module
provides a consistent final exposure, highlight shoulder, Bloom, grading and
dither for the complete MMD scene.

The current skin GGX test should therefore be judged first with no new post
effect loaded. Post-processing changes the apparent width, brightness and
saturation of a specular lobe, so tuning both variables at once would hide the
source of any mismatch.

## Unity Perlica Sample Scene

The sample camera renders HDR with post-processing enabled. Its visible result
is not a raw material preview.

### Built-In URP Volume

`Assets/Settings/SampleSceneProfile.asset` enables:

| Effect | Active values |
| --- | --- |
| Tonemapping | Neutral (`mode = 1`) |
| Bloom | threshold `1.0`, intensity `0.25`, scatter `0.5` |
| Bloom filtering | high-quality filtering enabled |
| Vignette | intensity `0.2` |
| Motion Blur | disabled |

URP builds Bloom before the final color transform, then applies exposure,
grading and Neutral tone compression in its post-processing composite. Neutral
Tonemap is important when comparing highlights: it compresses bright values
into a softer shoulder instead of letting them clip abruptly.

### Custom ZMD Pass

`PC_Renderer.asset` also enables `ZmdPostProcessFeature`. Its render event is
`AfterRenderingPostProcessing`, so it runs after the built-in URP post chain.
Its local order is:

1. custom color correction and LUT;
2. custom half-resolution Bloom;
3. optional FXAA, disabled in this scene.

The active custom LUT material uses:

| Parameter | Value |
| --- | ---: |
| Exposure | `0.09` EV |
| Contrast | `1.12` |
| Saturation | `1.0` |
| Gamma | `1.0` |
| Effect intensity | `0.61` |
| LUT contribution | `0.20` |

The active custom Bloom material uses:

| Parameter | Value |
| --- | ---: |
| Threshold | `1.0` |
| Intensity | `1.0` |
| Scatter/composite scale | `0.7` |
| Tint | white |

This second Bloom is a small four-pass path: half-resolution bright prefilter,
horizontal Gaussian blur, vertical Gaussian blur and additive composite. It is
not the same as the built-in multi-level URP Bloom. Consequently, the sample
image has two Bloom opportunities: the main HDR Bloom inside URP and a simpler
post-tonemap finishing Bloom.

## DanbaidongRP Engine Capabilities

DanbaidongRP contains more post-processing modes than the sample scene actively
uses. They must not be confused with the sample's serialized settings.

Its tone-mapping dispatcher supports:

- Gran Turismo/Uchimura;
- sampled ACES filmic;
- full ACES;
- Neutral.

Its custom `BloomDanbaidong` path starts at quarter resolution, runs a
prefilter and separable pre-blur, builds three lower-resolution levels, blurs
each level and composites them with configurable multi-scale weights. Default
engine-side values include threshold `0.7`, intensity `0.75`, luminance range
scale `0.2`, prefilter scale `2.5`, scatter `0.7`, and weights
`(0.30, 0.30, 0.26, 0.15)`.

That architecture is useful for understanding the intended broad, stable glow,
but it is heavier than the small custom Bloom actually attached to the Perlica
sample renderer.

## Goo Blender Reference

The inspected Goo Blender scene uses:

| Setting | Active value |
| --- | --- |
| Renderer | Eevee Next |
| View Transform | AgX |
| Look | Medium High Contrast |
| Exposure | `+0.1` |
| Gamma | `1.0` |
| TAA samples | `256` |

The connected compositor path is only:

`Render Layers -> Color Correction -> Composite/Viewer`

Active Color Correction values include master saturation `1.025`, master gain
`1.10`, midtone gain `1.05`, shadow saturation `1.05`, shadow gamma `0.99` and
shadow gain `0.90`.

There is no connected Bloom or Glare node. Tonemap, Color Balance and
Hue/Saturation nodes exist in the file but are disconnected, so they are not
part of the rendered reference. Goo's smooth, rich highlights mainly come from
AgX highlight compression plus restrained color correction, not from a glow
filter.

## MMD References

### ray-mmd

ray-mmd demonstrates the full high-end DX9 route:

- `A16B16G16R16F` HDR scene and work targets;
- five Bloom scales from half to 1/32 resolution;
- bright and emissive extraction;
- separable Gaussian blur and weighted multi-scale composite;
- manual exposure and optional eye adaptation;
- color temperature and grading;
- filmic/ACES-family tone mapping;
- linear-to-sRGB output, dithering and anti-aliasing.

This proves that a complete HDR pipeline is possible in MME, but copying its
whole render architecture would make EndfieldMME unnecessarily large and tightly
coupled. ray-mmd remains structural research only.

### HS_Snow SnowPost

SnowPost is the closest local prototype for an independent Endfield post module.
It already separates three entry choices:

- default/compatibility scene capture in `A8R8G8B8` with float Bloom buffers;
- explicit LDR compatibility capture;
- opt-in `A16B16G16R16F` HDR scene capture and float work buffers.

Its chain is soft-knee prefilter, five-level downsample, separable low-level
blur, progressive upsample, exposure/white balance/contrast/saturation,
ACES-fitted or Gran Turismo Tonemap, LUT and blue-noise dither. Neutral defaults
leave Bloom and Tonemap off until enabled by its controller.

SnowPost confirms the right MME ownership boundary, but EndfieldMME should use
its own smaller implementation and control names rather than importing the
the reference post-processing chain wholesale.

## Color-Space Constraint

A post effect cannot recreate HDR detail after it has already been clipped.
There are two valid Endfield paths:

### Compatibility Path

Capture the normal MMD image, convert sRGB to linear for filtering, use float
Bloom work buffers, apply a gentle display shoulder, then return to sRGB with
dither. This is broadly compatible and can improve the final image, but values
already clipped by material output or the scene target remain unrecoverable.

### True HDR Path

Render the scene into an `A16B16G16R16F` target, keep material output linear and
unclamped, extract Bloom before Tonemap, then perform Tonemap, grading, sRGB
conversion and dither exactly once. This produces the correct engine-style
relationship between emission, specular and Bloom, but it requires coordinated
HDR material output and is an opt-in rendering profile rather than a drop-in
finishing filter.

The current material shaders still clamp their final display output. The first
post prototype should therefore be labeled compatibility/LDR; a later HDR mode
must explicitly revise the material-output contract instead of pretending that
an LDR capture is HDR.

## Recommended EndfieldMME Route

Implement post-processing after the remaining material and outline work, in two
clearly separated stages.

### Stage A: Lightweight Compatibility Post

1. independent `EndfieldPost` attachment and controller;
2. scene capture plus sRGB-to-linear conversion;
3. high-quality multi-level float Bloom with a soft knee, adjustable scale
   weights, intensity, threshold, scatter and RGB tint;
4. selectable Gran Turismo, AgX-like, Neutral and ACES tone curves;
5. exposure, contrast, saturation and optional 32-slice LUT;
6. low-strength blue-noise dither;
7. neutral defaults and per-feature disable controls.

A sensible first visual preset is exposure `+0.05` to `+0.10` EV, Bloom
threshold near `1.0`, Bloom intensity `0.10` to `0.25`, scatter around `0.5`
to `0.65`, LUT contribution `0.10` to `0.20`, and no mandatory vignette.

### Stage B: Optional HDR Profile

1. float scene capture;
2. unclamped linear output variants for Endfield materials;
3. Bloom before tone mapping;
4. the same GT, AgX-like, Neutral and ACES tone-curve choices;
5. final grading, sRGB conversion and dither;
6. performance and compatibility fallback to Stage A.

## Acceptance Criteria

- With post disabled, face, hair, skin, eye and cloth remain visually valid.
- Bloom reacts to authored bright values and does not wash out the whole body.
- Hair highlight bands retain their sharp upper boundary and soft lower falloff.
- Skin GGX remains a micro-highlight rather than becoming a white rim.
- Neutral white metal stays neutral after Bloom and grading.
- Tone mapping removes harsh highlight clipping without turning midtones gray.
- The final 8-bit output shows less banding after LUT and Tonemap because dither
  is applied last.
- 720p, 1080p and 1440p preserve similar Bloom radius and perceived strength.
