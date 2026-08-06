# Face / EyeThrough Runtime Validation Record

> 本文是历史样例的验收记录，用来解释通用 EyeThrough、发影深度和面部接收器的
> 设计依据。文中的角色名、PMX 名称、材质编号和贴图名不是发行依赖；实际使用时
> 请让 GUI 根据当前模型重新分类并生成材质入口。

Updated: 2026-08-03  
Status: Face, dynamic fringe shadow, EyeThrough, sclera, authored Eye HL, iris
D.A, optional parallax, MatCap 05/07, and final grading are accepted. The Chen
Qianyu facial module was closed by visual acceptance on 2026-08-03.

## Runtime model

Use `陈千语_Endfield_面部材质.pmx` beside the source `陈千语.pmx`.
Keeping the copy in that directory preserves every original `textures/`
relative path for materials outside the Endfield face package.

`ChenQianyu_Endfield.emm` loads this model, all five production controllers,
ZMDshadow, EyeThrough, and the production FX assignments below in one step.

The source `陈千语.pmx` is unchanged. The runtime builder preserves all 12
original material indices and appends two geometry/index copies:

| Index | Material | FX |
| --- | --- | --- |
| 0 | 面 | `EndfieldFace_ChenQianyu.fx` |
| 1 | 目 | `EndfieldEyeBase_ChenQianyu.fx` |
| 3 | 目白 | `EndfieldEyeWhite_ChenQianyu.fx` |
| 5 | 睫眉 | `EndfieldFacial_ChenQianyu.fx` |
| 6 | 口内 | `EndfieldMouth_ChenQianyu.fx` |
| 7 | 发 | `EndfieldHair_ChenQianyu.fx` |
| 12 | 目透发 / EyeOverlay | `EndfieldEyeOverlay_ChenQianyu.fx` |
| 13 | 睫眉透发 / BrowOverlay | `EndfieldBrowOverlay_ChenQianyu.fx` |

### EyeThrough model requirement and future GUI

The accepted EyeThrough path currently requires this generated runtime PMX.
It does **not** require editing the source model by hand:

- No source vertices, bones, weights, morphs, textures, or original material
  records are changed.
- The builder copies only the existing `目` and `睫眉` index slices and appends
  two renamed material records after the original material list.
- The appended geometry is currently used by the EyeThrough capture as shifted
  depth-only occluders; it is part of the accepted side/rear rejection contract.
- The original PMX remains the immutable input, and the generated PMX is a
  disposable runtime artifact that can always be rebuilt.

The planned HS_Snow-style GUI should make this operation automatic. Its
EyeThrough setup action must:

1. Inspect the PMX and identify eye, eyelash/brow, hair, and head-bone roles.
2. Refuse ambiguous material mappings instead of modifying the wrong subset.
3. Generate a sibling runtime PMX rather than overwrite the input file.
4. Append the two overlay/index copies in the required draw order.
5. Generate or update the EMM assignments for EyeThrough, Hair, Face, and the
   controller objects.
6. Validate material counts, copied index bytes, relative texture paths, and
   output hashes, then provide a reversible rebuild/remove action.

Therefore model generation is a current runtime requirement, but manual model
editing is not and will not be part of the intended user workflow.

Leave `目HL`, `目白`, and `目影` on their original materials. They are deliberately
not duplicated, so the package cannot create a white eye-socket block below the
fringe. EyeThrough captures the required original subsets directly. The intended
runtime hides `目影`, so it is not part of the current completion gate.

## Runtime contract

Load `ZMDshadow.x`, `EndfieldEyeThrough.x`, and all five controllers from the
`controller/` directory as in the accepted full-character setup.

The accepted dynamic fringe-shadow contract uses a shared projected-shadow
receiver bit. Face writes Stencil bit 1 through a dedicated colorless receiver
pass filtered by the character Face ST green channel and the head-facing
receiver normal; base iris and sclera also write bit 1, while opaque Hair writes
bit 2. The ST filter prevents ear, mouth, and side/back-face islands from
receiving shifted hair geometry. The eye receiver coverage is necessary because the face mesh has
eye-socket openings. Without the base iris and sclera writes, the shadow pass is
never executed on those pixels and produces eye-shaped holes. The appended
EyeThrough overlay materials still do not need a private Stencil bit: their
copied geometry supplies the facial-feature domain and they read opaque Hair
bit 2 for the first-stage fringe classifier.

The projected shadow uses `ZFunc=LESSEQUAL` plus receiver depth bias `0.0025`.
This keeps the shadow above nearby iris/sclera surfaces while still rejecting
hair that is substantially behind the face. A diagnostic build using
`ZFunc=ALWAYS` and opacity `1.0` still showed the eye-shaped holes, proving that
the pixel shader was not running there; expanding receiver Stencil coverage,
not another depth or blending exception, fixed the issue.

The Face ST texture is a per-character resource contract. Across the tested
Chen Qianyu, Liino, and Si textures, G contains the consistent soft
eye/upper-face receiver region, R/B contain hard eye/mouth exclusions, and A is
constant white. This evidence supports a shared face-region/stencil role, but
does not prove that the texture alone implements EyeThrough. A future GUI must
select or disable the ST resource per model profile instead of assuming the
Chen Qianyu filename universally.

Both overlays use `ZFunc=ALWAYS` because Hair bit 2 is the first-stage fringe
classifier, and both retain the Head Forward versus ViewDir profile fade. This
maps the reference renderers more faithfully: duplicated geometry corresponds
to the eye/eyelash domain, while Hair bit 2 corresponds to their HairMask.

The second gate samples `ZMDshadow_ViewportMap2.g`, whose value is the nearest
scene surface's linear camera distance. It compares that value with the copied
eye/brow fragment's camera distance and fades the overlay out as the gap grows.
Current validation values are `Start=0.05`, `End=3.0`, and `Bias=0.02` in MMD
model units. Missing ZMDshadow falls back to the HairMask-only result.

The first HairMask-plus-depth baseline uses `Eye Alpha=0.36, Gain=1.0` and
`Brow Alpha=0.44, Gain=1.0`. These intentionally keep opaque hair visually
dominant.

## Accepted EyeThrough compositor

The release path additionally loads `EndfieldEyeThrough.x`. Its offscreen
capture reads the original eye, eye-highlight, sclera, eye-shadow, brow, hair,
and shifted-occluder subsets, then composites only the accepted facial-feature
color over the finished scene.

- Eye/brow Alpha is reduced continuously by the head-forward view profile and
  reaches zero at 86 degrees, preventing side and rear eye leakage.
- Shifted occluder subsets write depth only; they do not add visible color.
- Occlusion-only passes use strict `LESS`, not `LESSEQUAL`. At long camera
  distances, DX9 depth quantization can collapse an eye and a farther surface
  to the same stored value; accepting equality would let the rear surface clear
  the captured eye Alpha and expose the completed scene behind it.
- Only iris, sclera, authored Eye HL, eyebrows, and eyelashes contribute feature
  RGB/Alpha. The authored eye-shadow plane is ignored by the feature capture.
- Real hair and the dynamic fringe shadow remain entirely in the completed main
  scene. Hair contributes shifted depth only in the feature capture, so the
  final eye/brow composite passes through both hair color and its projected
  face shadow at the same visual layer.

The compositor defaults are `Strength=0.38` and `Color Gain=1.05`. This stage
is now accepted; it is no longer a debug or provisional visibility path.

The projected fringe-shadow depth bias is applied as a fixed view-space
model-unit displacement. The former clip-space offset was multiplied by clip
`w`; in long shots its effective world displacement became large enough to
pull rear hair over the face receiver. The view-space form preserves the
accepted close-shot shadow while keeping rear hair behind the face at distance.

EyeThrough also has a distance LOD in the capture wrapper. It remains unchanged
through close and medium shots, fades continuously from camera distance `26` to
`38`, and is fully disabled beyond that range. This prevents subpixel facial
features and MSAA coverage from turning the `0.38` blend into apparent scene or
rear-object transparency in long shots.

## Current scope

- Eyelash and eyebrow base: accepted authored Face D RGB-only path. This matches
  the Goo reference, which does not assign a separate lighting shader to this
  subset.
- Mouth interior: accepted authored Face D-only path. Goo's Chen Qianyu Face
  slot contains exactly 2800 triangles, matching PMX `面` 1992 + `目白` 232 +
  `口内` 576. There is no independent Goo mouth shader to reproduce, and the
  inward-facing mouth geometry must not inherit face SDF or Rim.
- Iris: accepted authored Iris D color refinement, D.A local emission, camera-space
  MatCap 05, UV-fixed emissive MatCap 07, soft exposure, and final iris-only grading.
  The derivative-reconstructed UV parallax path is optional and has also passed its
  dedicated angled-view check. Current values are Parallax Depth `0.020`, Max
  Offset `0.035`, MatCap 05 `0.5666667`, MatCap 07 `0.08`, final output gain
  `0.88`, and final saturation `1.10`.
- Hair-through eye/brow: accepted offscreen capture/composite, shifted depth
  occluders, dynamic fringe-shadow preservation, and 86-degree side fade.
- Sclera: accepted shared main-view/EyeThrough soft-light stage. It uses the
  authored Face D atlas, `Gain=1.02`, `Saturation=0.88`, `Contrast=0.96`,
  `Lift=(0.004, 0.003, 0.002)`, a broad Half-Lambert value range of
  `0.86..1.03`, curve `0.72`, and only `0.12` MMD-light color tint. It has no
  SDF, parallax, or specular term.
- The authored Eye HL geometry is an accepted fixed emissive decal. It samples
  the authored highlight island, uses emission `1.4`, does not dim or disappear
  with camera rotation, and is captured separately by EyeThrough. Visible pixels
  write depth so the later `目白` pass cannot erase the part crossing the sclera.
  `EyeHL-` reduces coverage and clips the layer before the depth write when fully
  disabled.
- `EndfieldFace_controller.pmx` now hosts all 16 Face morphs plus 14 Eye morphs.
  The seven eye parameter pairs provide a `0x..5x` range and share the same
  functions in the main view and EyeThrough capture.

## Completion state

The Chen Qianyu Face/Eye implementation is complete. The final parallax probe used
`IrisParallax+=1.0` at an angled camera view and confirmed that the optional UV
offset is active. Further color or strength changes are character presets rather
than missing shader features. `目影` remains intentionally hidden in the intended
runtime.

## Optional MatCap assets and future GUI

MatCap and parallax are character capabilities, not mandatory Endfield eye assets.
The current package scan gives this matrix; it records files only and does not by
itself prove how the original shader connected them:

| Character package | Files | Iris D | MatCap candidates |
| --- | ---: | --- | --- |
| Chen Qianyu | 35 | `T_actor_chen_iris_01_D.png` | `T_actor_common_matcap_06_D.png` |
| Li Zhiyan | 21 | `T_actor_lizhiyan_iris_01_D.png` | none |
| Liino | 56 | `T_actor_liino_iris_01_D.png` | `T_actor_common_matcap_08_D.png` |
| Jiss / 祀 | 61 | `T_actor_jsspsi_iris_01_D.png` | `T_actor_common_matcap_08_D.png` |

In this four-character sample, Iris D is present in 4/4 packages and a MatCap
candidate is present in 3/4 packages. This makes capability detection worthwhile,
but it is not evidence that every original material enabled parallax or consumed
the discovered MatCap.

The Liino and Jiss MatCap 08 files are byte-identical, with SHA-256
`BDC9EE34CC8696F269DABA2FB8DBA0247A86C627657B23FD9B1E10EF618D7DF8`.
Their MatCap 08 is a 256x256 ARGB spherical environment image with window and
colored-star reflections. MatCap 06 and 08 both visually resemble full spherical environment reflections,
but have different hashes. They are environment-MatCap candidates until their
material graphs or single-variable renders establish sampling, blend mode, and
strength. Chen Qianyu's accepted production Profile uses MatCap 05/07 obtained
from the Goo reference, even though the standalone MMD package exposes MatCap 06;
this proves that scanning `other tex` is necessary but not sufficient.

Parallax must be detected independently. It needs a suitable iris UV layout but
no dedicated parallax texture. The presence of Iris D therefore means
"algorithm-compatible candidate", not "original preset enabled": Chen Qianyu has
Iris D while its Goo preset leaves `parallaxUV` disconnected.

The future GUI must expose three independent capabilities:

1. `Parallax`: `Auto / On / Off`, with depth and maximum offset. `Auto` reads a
   known character Profile; an Iris D filename alone must not force it on.
2. `Environment MatCap`: `Auto / On / Off / Custom`, for camera-space or
   pseudo-cornea-normal sampling. Known candidate numbers currently include 05,
   06, and 08, but the number alone must not select a blend formula.
3. `Detail MatCap`: `Auto / On / Off / Custom`, for UV-fixed reflection or
   emissive detail such as Chen Qianyu's accepted MatCap 07 path.
4. `Auto` may activate only a known, validated Profile. Unknown resources are
   shown as candidates for user confirmation; the GUI must never silently borrow
   another character's texture.
5. Disabled slots emit compile-time guards that remove their sampler and texture
   read. The current Chen Profile maps these to
   `EF_EYE_IRIS_MATCAP05_ENABLED` and `EF_EYE_IRIS_MATCAP07_ENABLED`; future
   generic wrappers should use semantic slot names while preserving these aliases.
6. The generated manifest records texture path, SHA-256, sampling mode, blend
   mode, strength, and enabled state for every slot. Main iris and EyeThrough
   capture wrappers must receive the identical manifest.
7. The unified Face controller may keep both existing MatCap morph pairs. The GUI
   can relabel them semantically, and disabled features make them harmless no-ops.

### MME nested include rule

MikuMikuEffect resolves nested includes from the public Effect directory rather
than from the directory of the currently included file. Shared internal modules
must therefore use root-relative paths such as
`#include "internal/endfield_eye_controls.inc"`. FXC can hide this error because
it first finds a sibling include beside the current HLSL file; runtime validation
must also exercise MMD-style root-relative resolution.

Regenerate the runtime model with:

```powershell
python EndfieldMME/tools/build_chen_facial_model.py
```
