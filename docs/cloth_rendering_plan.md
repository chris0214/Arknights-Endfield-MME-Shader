# Cloth Rendering Plan

## Scope

The first clothing target is the sample model's material 10, `Cloth1`. It contains
54,743 triangles and spans the complete authored clothing assembly, including
cloth, hard-surface trim and emissive accents.

## Asset Contract

| Asset | Initial role |
| --- | --- |
| `T_actor_<role>_cloth_01_D.png` | authored base color |
| `T_actor_<role>_cloth_01_N.png` | tangent-space normal |
| `T_actor_<role>_cloth_01_P.png` | material property masks; channels require probing |
| `T_actor_<role>_cloth_01_ST.png` | stylized material controls; channels require probing |
| `T_actor_<role>_cloth_01_E.png` | authored emission |
| `T_actor_common_cloth_04_RD.png` | diffuse ramp RGB/A |
| `T_actor_common_cloth_04_RS.png` | specular ramp |
| `T_actor_common_cloth_lut_01_D.png` | cloth color mapping LUT |
| `Eff_MatCap_019.png` | default Goo-style MatCap environment source |
| `cloth_environment_current.dds` | GUI-selected prefiltered HDR environment LD slot |

## Test Order

1. D texture only, opaque and double-sided. **Accepted.**
2. MMD geometric-normal direct light. **Accepted.**
3. Cloth RD RGB/A diffuse response. **Accepted.**
4. Cloth LUT on the dark branch. **Accepted.**
5. Tangent-space normal map. **Accepted.**
6. Probe and document P/ST channels one at a time.
   - `P.r`: metallic. **Current test:** direct-light GGX and diffuse energy
     transfer.
   - `P.g`: reflectivity. **Current test:** dielectric F0 control.
   - `P.b`: ambient occlusion. **Accepted:** false-color probing confirmed its
     UV and distribution; production uses separate dark-branch and light-branch
     strengths. The accepted baked preset is `AO Dark = 0.50`,
     `AO Light = 0.00`.
   - `P.a`: smoothness. **Current test:** converted to roughness for GGX/RS.
   - `ST.rgb`: local binary mask. Current evidence associates similar assets
     with outline or special-material filtering, so it is deferred to the
     final outline pass rather than guessed into the surface shader.
7. GGX direct specular and cloth RS color refinement. **Accepted as the direct
   specular baseline.**
   - `P.r/g/a` drive metallic, reflectivity and smoothness.
   - Metallic regions surrender diffuse energy to the specular lobe.
   - Initial safety values: specular strength `0.35`, peak clamp `1.5`.
8. Metallic/roughness response and switchable environment term.
   **Accepted; MatCap is the default and Studio HDR remains selectable.**
   - Uses one standalone 1024x512 RGBM equirectangular DDS with seven
     prefiltered mip levels; there is no `ray.x`, GBuffer or ray controller
     runtime dependency.
   - Reflection direction selects the environment UV and `P.a` roughness
     selects the mip level.
   - The environment LD is desaturated before the Endfield DFG/F0/RS response,
     keeping authored material color while restoring broad metal reflections.
   - Broad IBL retains `25%` of metallic F0 chroma while direct GGX retains the
     full authored color. This removes the excessive yellow/brass wash seen in
     the first Studio-HDR test without flattening material identity.
   - Shared environment strength is `0.80`; `P.b` suppresses reflection in
     authored cavities with a separate `0.65` AO influence.
   - `EnvMode=0` uses Goo MatCap 019, `EnvMode=1` uses HDR, and intermediate
     morph values continuously blend the two sources.
   - HDR is exposed at `0.65` relative strength so changing EnvMode does not
     create the large brightness jump seen in the first A/B test.
   - The full Goo/Unity pre-integrated GGX/Disney diffuse LUT is enabled by
     default. `FGDOff=1` restores the analytic environment BRDF, and intermediate
     values continuously fade out the LUT contribution.
   - Seven CC0 environments are prebuilt as GUI-selectable presets. The Shader
     still loads only `textures/common/cloth_environment_current.dds`.
   - `monochrome_studio_02` is the neutral default; the original ray-mmd DDS is
     retained only as a built-in fallback asset.
9. Emission mask and color. **Deferred for the sample Cloth1 profile.**
   - Direct UV0 sampling of the role-specific cloth emission map produced two hard
     rectangular patches on the hanging strap instead of a credible luminous
     region.
   - The asset is likely tied to an unused material variant or alternate UV
     set. It is not part of the active Shader or runtime texture set.
10. ZMDshadow projection/self-shadow.
11. NoV and light-side screen-space Rim.
12. Runtime controller.
13. Outline, deferred until the final cross-material pass.

Temporary debug entries must be replaced rather than accumulated. Each visual
test introduces only one new variable over the last accepted stage.

## Controller Notes

The planned `EndfieldCloth_controller.pmx` must expose `AO Dark` and `AO Light`
as independent signed controls. The dual Shader parameters already exist, but
the PMX controller is intentionally deferred until the GGX, emission, shadow
and Rim parameter set stops changing.

The stage-8 IBL implementation is a clean, local forward-material path. It
borrows the standard prefiltered-environment structure validated by ray-mmd but
does not load or include any ray-mmd Effect code at runtime. Asset provenance is
recorded in `docs/reference/ray_mmd_ibl_notes.md`.
