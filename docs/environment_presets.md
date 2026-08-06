# Cloth Environment Presets

## Runtime Contract

The cloth Shader always loads one fixed resource:

```text
textures/common/cloth_environment_current.dds
```

The future GUI selects a preset by copying its prebuilt DDS from
`textures/environment_presets/` into that runtime slot. This keeps the MME
Effect at one sampler and one FX file regardless of how many presets exist.

`textures/environment_presets/manifest.json` is the machine-readable GUI
contract. Recommended strength and rotation values are starting points, not
hard constraints; the cloth controller remains responsible for artistic
adjustment.

## Default

`monochrome_studio_02` is the default because its large, orderly softboxes give
silver trim and knee armor a broad neutral reflection without imposing a
strong outdoor color cast. `studio_small_09` is the higher-contrast studio
alternative.

The three outdoor presets remain useful for scenes where reflections should
follow a natural horizon and sun direction.

## Conversion

Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\EndfieldMME\tools\convert_hdr_presets.ps1
```

The script uses ray-mmd's customized cmft wrapper in an ASCII-only directory
under the user's `%TEMP%`. It does not call OpenImageIO or `oiiotool.exe`; this
avoids the missing `OpenEXR.dll` failure seen with the abandoned conversion
path.

Each output is a 1024x512 equirectangular RGBM DDS with seven prefiltered mip
levels. The script validates those values directly from the DDS header and
skips already valid presets, so interrupted batches can resume. Only the
specular output is retained. The original 4K HDR files are development inputs
and are not loaded by MMD.

The packaged cmft `fast` executable is intentionally used because it emits the
same 1024x512 runtime profile as ray-mmd's existing DDS. The `high` executable
emits 2048x1024 files, quadrupling preset storage without changing the Shader
contract.

## Licensing

The seven HDR sources were supplied as CC0 assets. cmft is BSD-2-Clause; its
license remains beside the extracted development tool. ray-mmd's runtime and
license boundary is documented separately in
`docs/reference/ray_mmd_ibl_notes.md`.
