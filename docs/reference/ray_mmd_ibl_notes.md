# ray-mmd IBL Reference Notes

## Scope

The clothing environment-specular stage was initially validated with a copied
prefiltered environment asset from the local `ray-mmd` reference tree:

```text
ray-mmd/Lighting/SphereLight/Default IBL/texture/skyspec_hdr.dds
```

Fallback copy:

```text
textures/common/ray_default_skyspec_hdr.dds
```

The production Shader now samples the GUI-managed runtime slot
`textures/common/cloth_environment_current.dds`. Seven user-supplied CC0 HDRs
are prefiltered into compatible presets by ray's customized cmft wrapper. The
fallback asset remains available, but it is no longer the default runtime slot.

All preset DDS files are 1024x512 equirectangular RGBM textures with seven mip
levels. They are sampled directly by `internal/endfield_cloth.hlsl`; the project
does not load `ray.x`, ray's GBuffer, skybox Effects, lighting attachments or
controller.

## Implementation Boundary

Only the general IBL structure is retained: reflect the view vector, map the
direction to equirectangular UV, choose a prefiltered mip from roughness, decode
RGBM, and combine it with the project's own Endfield DFG/F0/RS response. The
runtime Shader is independently integrated into the existing forward clothing
pass.

## License

ray-mmd is distributed under the MIT License, copyright 2016-2018 Rui. The
verbatim license is preserved in `docs/reference/ray_mmd_LICENSE.txt`.
