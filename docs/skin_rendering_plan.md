# Skin Rendering Plan

## Decision

Implement the `肌` skin material before `Cloth1`.

The accepted face pipeline already provides the closest reusable behavior:
linear/sRGB handling, skin LUT sampling, RD color control, soft exposure, NoV
SSS, ZMDshadow integration and a restrained NoV rim. Skin lets these pieces be
validated on body geometry without introducing the cloth material's normal,
P/RMO, emission, metallic, roughness, GGX and IBL variables at the same time.

The sample source PMX reinforces this order:

| Material | Index | Triangles | Authored texture set |
| --- | ---: | ---: | --- |
| `肌` | 9 | 1,434 | Body D plus common body RD and skin LUT |
| `Cloth1` | 10 | 54,743 | D, N, P, ST, E, cloth RD, RS and cloth LUT |

Skin is therefore the smaller single-variable validation surface. Clothing will
follow by extending the validated diffuse/shadow/rim base with material response.

## Asset Contract

| Asset | Size | Initial role |
| --- | ---: | --- |
| `T_actor_<role>_body_01_D.png` | 512x512 ARGB | Authored body color; alpha semantics remain a probe item |
| `T_actor_common_body_01_RD.png` | 256x1 ARGB | Skin light/dark ramp and transition alpha |
| `T_actor_common_femaleskincolor02_lut_D.png` | 1024x32 ARGB | Dark-side skin color mapping |

There is no sample body normal or P/RMO texture in `other tex`. The first skin
implementation must not invent those inputs or borrow cloth textures.

## Reference Behavior

The archived Zhihu/Unity implementation describes skin as a reduced PBR-toon
variant:

- no IBL specular, while the direct-light specular and Rim remain available;
- NoV-driven SSS tint applied to albedo;
- half-Lambert sampling of the body RD ramp;
- skin LUT applied to the dark albedo branch;
- final light/dark blend constrained by ramp alpha and shadow;
- the same restrained NoV rim family used by the base material.

The current MMD skin stage does not yet add a dedicated micro-specular lobe.
That response must be introduced as a separate visual test after the corrected
dark-side diffuse is accepted.

Our MMD version will keep MMD's native light direction and ZMDshadow as the
lighting contract. Face SDF, lip highlight, hair depth rim and eye features are
not part of the skin material.

## Single-Variable Test Order

1. GUI-generated Endfield skin entry: body D only, with neutral vertex/material color. **Accepted.**
2. Add normalized MMD direct light and establish the accepted body brightness. **Accepted.**
3. Add body RD RGB/A and verify the hard/soft transition independently. **Accepted.**
4. Add the skin LUT only to the dark branch and check for banding. **Accepted.**
5. Add NoV SSS with range, color and strength exposed separately. **Accepted.**
6. Add ZMDshadow projection/self-shadow response. **Accepted.**
7. Add a restrained NoV rim. **Accepted.**
8. Add a skin controller after the neutral preset is visually accepted. **Implemented; awaiting visual acceptance.**
9. Add a light-direction-aware screen-space depth Rim. **Implemented; awaiting visual acceptance.**
10. Re-enable and tune the normal-expanded outline as the final skin task. **Deferred by user request.**
11. Add a broad, weak direct-light GGX micro-specular. **Implemented as an isolated visual test.**

The controller exposes tone, SSS, shadow, GGX strength and Rim controls through
42 signed `+/-` morphs. Strength/brightness controls use the established MMD
`0..1` morph to Shader `0..5x` mapping.
It should also expose outline width, brightness and color after the neutral
outline preset is accepted.

Every stage gets one temporary test entry at most. Once accepted, it replaces
the previous entry so Debug/Test FX do not accumulate in the public directory.

## Planned Files

- GUI-generated Endfield skin entry: character binding and validated defaults.
- `internal/endfield_skin.hlsl`: shared skin implementation.
- `internal/endfield_skin_controls.inc`: skin-only MME controller contract.
- `../EndfieldSkin_controller.pmx`: generated four-frame runtime controller.
- `tools/build_skin_controller.py`: deterministic controller builder.

The first deliverable is intentionally limited to base color. Clothing starts
only after the complete skin chain is accepted.

## Acceptance Criteria

- Body skin brightness and hue remain continuous with the accepted face.
- Dark areas retain warm color and do not become gray, black or visibly banded.
- SSS appears at grazing angles without lifting the whole body.
- ZMDshadow remains stable under MMD light rotation.
- No mirror-like or dark-side gloss appears on skin; the optional GGX lobe
  remains broad, weak and confined to accepted light/shadow visibility.
- One smooth RD transition band is expected; multiple discrete LUT slice bands
  are not.
- The shader compiles within DirectX 9 `ps_3_0` limits and introduces no new
  runtime object beyond the existing controllers unless later testing requires it.

The skin now has both the accepted NoV Rim and a separate screen-space depth
Rim derived from `ZMDshadow_ViewportMap2.g`. Unlike the hair preset, its direct
light mask is strict: `N dot L <= 0` produces no depth Rim, and the contribution
smoothly reaches full strength over the positive light-facing interval. Both
strength and width remain controller-adjustable so shots can disable it without
changing the accepted NoV Rim.

## Dark-Side Reference Correction (2026-08-04)

The dry gray dark side was traced by comparing the local Zhihu PDF, the Unity
Perlica reference and the Goo Blender material graph:

- Zhihu compresses the Fresnel SSS input with `NoV * 0.85 + 0.15` before
  multiplying the warm SSS tint into albedo.
- Unity/Goo preserve a distinct light, dark and dark-in-dark diffuse structure;
  Ramp color is treated as hue information rather than an unrestricted second
  brightness multiplier.
- Goo exposes `GlobalShadowBrightnessAdjustment`, a warm direct specular color,
  FGD strength and environmental reflection separately. Its body skin does not
  use a native Blender subsurface shader.

The MMD correction therefore keeps the stylized multiplicative NoV SSS, applies
the same compressed range, raises the sample dark branch from `0.72` to
`0.82`, and limits RD hue luminance recovery to `1.5x`. This removes accidental
stacked dimming while retaining the authored LUT shadow color and real light/dark
separation.

The first direct micro-specular test follows the Unity skin branch rather than
adding skin IBL: dielectric `F0 = 0.04 * 0.50`, roughness `0.58`, strength
`0.65`, and a restrained warm-white color. It uses the geometric body normal,
is multiplied by the accepted RD/ZMD light visibility, and is strictly zero on
the back-facing light hemisphere. `SkinSpecStrength+/-` is now exposed for the
visual comparison: the negative morph reaches fully off and the positive morph
reaches `5x` the baked strength. Roughness and reflectivity remain baked until
the lobe shape is visually accepted.
