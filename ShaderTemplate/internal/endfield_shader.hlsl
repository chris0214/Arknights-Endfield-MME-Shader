#ifndef ENDFIELD_SHADER_INCLUDED
#define ENDFIELD_SHADER_INCLUDED

// Endfield MME - single-core shader. M1 implements the Hair domain by porting
// Perlica HairToonShader.shader into MME/DX9 (ps_3_0). The Body/Face/etc.
// domains reuse this frame in later milestones.

#define EF_DOMAIN_HAIR 1

#ifndef EF_DOMAIN
#define EF_DOMAIN EF_DOMAIN_HAIR
#endif

#ifndef EF_HAIR_CONTROLLER_ENABLED
#define EF_HAIR_CONTROLLER_ENABLED 0
#endif
#ifndef EF_HAIR_CONTROLLER_C5_ENABLED
#define EF_HAIR_CONTROLLER_C5_ENABLED 0
#endif
#ifndef EF_HAIR_CONTROLLER_C5_HNORMAL_ENABLED
#define EF_HAIR_CONTROLLER_C5_HNORMAL_ENABLED EF_HAIR_CONTROLLER_C5_ENABLED
#endif
#ifndef EF_HAIR_CONTROLLER_C5_SHAPE_ENABLED
#define EF_HAIR_CONTROLLER_C5_SHAPE_ENABLED EF_HAIR_CONTROLLER_C5_ENABLED
#endif
#ifndef EF_HAIR_CONTROLLER_C5_DIFFUSE_ENABLED
#define EF_HAIR_CONTROLLER_C5_DIFFUSE_ENABLED EF_HAIR_CONTROLLER_C5_ENABLED
#endif
#ifndef EF_HAIR_CONTROLLER_BASE_GRADE_ENABLED
#define EF_HAIR_CONTROLLER_BASE_GRADE_ENABLED EF_HAIR_CONTROLLER_ENABLED
#endif
#ifndef EF_HAIR_CONTROLLER_BASE_GRADE_VERTEX_PRECOMPUTE
#define EF_HAIR_CONTROLLER_BASE_GRADE_VERTEX_PRECOMPUTE 0
#endif
#ifndef EF_HAIR_HIGHLIGHT_INTENSITY
#define EF_HAIR_HIGHLIGHT_INTENSITY 1.0
#endif

// ── Hair tunables (Perlica Property defaults; overridable per wrapper) ──
#ifndef EF_BUMP_SCALE
#define EF_BUMP_SCALE 1.0
#endif
#ifndef EF_USE_NORMAL_MAP
#define EF_USE_NORMAL_MAP 1
#endif
#ifndef EF_USE_ORM
#define EF_USE_ORM 1
#endif
#ifndef EF_FORWARD_DIR_STRENGTH
#define EF_FORWARD_DIR_STRENGTH 0.0
#endif
#ifndef EF_OTHER_LIGHT_DIR
#define EF_OTHER_LIGHT_DIR float3(0.0, 1.0, 0.3)
#endif
#ifndef EF_OTHER_LIGHT_COLOR
#define EF_OTHER_LIGHT_COLOR float3(0.9, 0.95, 1.0)
#endif
#ifndef EF_OTHER_LIGHT_OFFSET
#define EF_OTHER_LIGHT_OFFSET 0.0
#endif
#ifndef EF_OTHER_LIGHT_STRENGTH
#define EF_OTHER_LIGHT_STRENGTH 0.25
#endif
#ifndef EF_OTHER_LIGHT_STRENGTH_OFFSET
// The Unity default 0.1 floor lifts the darkest hair toward mid-grey under
// MMD's flat front light. Drop it so blacks stay seated.
#define EF_OTHER_LIGHT_STRENGTH_OFFSET 0.02
#endif
#ifndef EF_OTHER_DAY1
#define EF_OTHER_DAY1 0.2
#endif
#ifndef EF_OTHER_DAY0
#define EF_OTHER_DAY0 1.0
#endif
#ifndef EF_SHADOW_CENTER
#define EF_SHADOW_CENTER 0.5
#endif
#ifndef EF_SHADOW_SMOOTHNESS
#define EF_SHADOW_SMOOTHNESS 0.02
#endif
#ifndef EF_SHADOW_OFFSET
#define EF_SHADOW_OFFSET 0.0
#endif
#ifndef EF_SHADOW_STRENGTH
#define EF_SHADOW_STRENGTH 1.0
#endif
#ifndef EF_AO_STRENGTH
#define EF_AO_STRENGTH 1.0
#endif
#ifndef EF_BASE_COLOR
#define EF_BASE_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_BASE_COLOR_POW
// The reference hair albedo is mid-grey (~0.31 gamma). >1 contrast in linear space
// seats it toward the reference near-black without crushing detail.
#define EF_BASE_COLOR_POW 1.3
#endif
#ifndef EF_ALBEDO_DARK_STRENGTH
#define EF_ALBEDO_DARK_STRENGTH 0.8
#endif
#ifndef EF_ALBEDO_DARK_SATURATION
#define EF_ALBEDO_DARK_SATURATION 0.8
#endif
#ifndef EF_DIFFUSE_BLEND_EFFECT
#define EF_DIFFUSE_BLEND_EFFECT 0.6
#endif
#ifndef EF_FACE_CENTER
// A character-specific face center may be supplied by a generated wrapper;
// this fallback keeps the validated neutral coordinate for generic entries.
// The sphere normal (posWS - center) is a SMOOTH position-based normal that
// stays continuous across separate hair cards — the tutorial's own trick for
// the neat aligned highlight. Retune per model if hair sits elsewhere.
#define EF_FACE_CENTER float3(0.0, 18.5, 0.04)
#endif
// MyZmd blends from a position-based sphere normal to the HN normal with the
// hair mask (P.r). This stays optional so wrappers for models without a known
// head center can fall back to HN only.
#ifndef EF_USE_SPHERE_NORMAL
#define EF_USE_SPHERE_NORMAL 0
#endif
// Rim
#ifndef EF_RIM_AREA
#define EF_RIM_AREA 0.3
#endif
#ifndef EF_RIM_COLOR
#define EF_RIM_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_RIM_STRENGTH
// Reference hair shows almost no white rim; the Unity 0.8 default reads as a
// bright fringe on every strand under MMD lighting. Tone it down.
#define EF_RIM_STRENGTH 0.25
#endif
#ifndef EF_RIM_DIFFUSE_EFFECT
#define EF_RIM_DIFFUSE_EFFECT 0.6
#endif
#ifndef EF_RIM_NOLXZ_STRENGTH
#define EF_RIM_NOLXZ_STRENGTH 0.25
#endif
// Kajiya-Kay
#ifndef EF_SPEC_TRICK_FLATTEN
#define EF_SPEC_TRICK_FLATTEN 0.5
#endif
#ifndef EF_VIEWDIR_Y_OFFSET
#define EF_VIEWDIR_Y_OFFSET 0.0
#endif
#ifndef EF_SPEC_POW_STRENGTH
// Canonical MyZmdShaders hard-codes 200 here (sin^200 = a very tight strand
// band). Perlica's 20 was 10x too broad and smeared the highlight into a wash.
#define EF_SPEC_POW_STRENGTH 200.0
#endif
#ifndef EF_LUT_V_POW_STRENGTH
#define EF_LUT_V_POW_STRENGTH 1.0
#endif
#ifndef EF_SPEC_BACK_F0
// This is the grey back-light lobe. At the Unity 0.1 default it reads as a
// broad grey wash over the hair mass; the reference keeps it subtle.
#define EF_SPEC_BACK_F0 float3(0.03, 0.03, 0.03)
#endif
#ifndef EF_SPEC_BACK_F0_TOH_POW
#define EF_SPEC_BACK_F0_TOH_POW 0.5
#endif
// Gain on the colored LUT lobe (Unity hard-codes 7). Lower = less bloom.
#ifndef EF_HAIR_LUT_GAIN
#define EF_HAIR_LUT_GAIN 4.0
#endif
// Stylized hair highlights use an art-directed key by default. Binding this to
// MMD's global light makes the band orbit when the user rotates the scene light.
// The direction must be a normalized surface-to-light vector in world space.
#ifndef EF_HAIR_SPEC_USE_MMD_LIGHT
#define EF_HAIR_SPEC_USE_MMD_LIGHT 0
#endif
// With MMD light disabled, use cameraForward as both the stabilized view and
// highlight key. This is the MME equivalent of Perlica's ForwardDirStrength=1
// stabilization. Disable it only when a world-space art key is desired.
#ifndef EF_HAIR_SPEC_VIEW_LOCK
#define EF_HAIR_SPEC_VIEW_LOCK 1
#endif
#ifndef EF_HAIR_SPEC_KEY_UP
#define EF_HAIR_SPEC_KEY_UP 0.36397023
#endif
#ifndef EF_HAIR_SPEC_LIGHT_DIR
#define EF_HAIR_SPEC_LIGHT_DIR float3(-0.46984631, 0.57357644, -0.67101007)
#endif
#ifndef EF_HAIR_SPEC_LIGHT_COLOR
#define EF_HAIR_SPEC_LIGHT_COLOR float3(1.0, 1.0, 1.0)
#endif
// Debug: set to 1 in the wrapper to kill all hair specular (isolate diffuse).
#ifndef EF_HAIR_SPEC_OFF
#define EF_HAIR_SPEC_OFF 0
#endif
// Debug: set to 1 to output solid magenta — a load/cache sanity check. If the
// hair does NOT turn magenta after reassigning, MME is using a stale compile.
#ifndef EF_DEBUG_SOLID
#define EF_DEBUG_SOLID 0
#endif
// Diagnostic stage: D texture and BaseColor only. The early return deliberately
// excludes P/HN, lighting, shadows, rim, color grading and every specular model.
#ifndef EF_HAIR_BASE_COLOR_ONLY
#define EF_HAIR_BASE_COLOR_ONLY 0
#endif
// Diagnostic stage: D * BaseColor * decoded P.b AO only. No lighting term.
#ifndef EF_HAIR_BASE_COLOR_AO_ONLY
#define EF_HAIR_BASE_COLOR_AO_ONLY 0
#endif
// Diagnostic stage: geometric-normal half-Lambert under a fixed white key.
#ifndef EF_HAIR_GEOMETRY_NOL_DEBUG
#define EF_HAIR_GEOMETRY_NOL_DEBUG 0
#endif
#ifndef EF_GEOMETRY_NOL_LIGHT_DIR
#define EF_GEOMETRY_NOL_LIGHT_DIR float3(-0.46984631, 0.57357644, -0.67101007)
#endif
// Diagnostic stage: the same geometric-normal half-Lambert, but driven only
// by MMD's raw world light. MMD supplies the ray travel direction, so shading
// uses its opposite (surface-to-light). CameraLight and LightColor are absent.
#ifndef EF_HAIR_MMD_NOL_DEBUG
#define EF_HAIR_MMD_NOL_DEBUG 0
#endif
// Diagnostic stage: validated D/BaseColor multiplied by MMD Half-Lambert and
// the unnormalized MMD LightColor. RD/ambient are intentionally absent, so
// this is an input-chain probe rather than the final toon diffuse response.
#ifndef EF_HAIR_MMD_DIFFUSE_DEBUG
#define EF_HAIR_MMD_DIFFUSE_DEBUG 0
#endif
// Diagnostic stage: HN.RG detail normal replaces the geometric diffuse normal
// in the validated MMD-light probe. HN.BA and all other material maps are off.
#ifndef EF_HAIR_HN_RG_DIFFUSE_DEBUG
#define EF_HAIR_HN_RG_DIFFUSE_DEBUG 0
#endif
// Diagnostic stage: decode HN.BA as the authored soft tangent-space normal,
// transform it through the derivative TBN, and display the resulting world
// normal as RGB. No P.r blend, lighting, specular, or color map is involved.
#ifndef EF_HAIR_HN_BA_SOFT_NORMAL_DEBUG
#define EF_HAIR_HN_BA_SOFT_NORMAL_DEBUG 0
#endif
// Diagnostic stage: blend the authored HN.BA soft normal toward the HN.RG
// regular normal using P.r exactly as the asset-native hair path specifies.
#ifndef EF_HAIR_HN_P_R_BLEND_DEBUG
#define EF_HAIR_HN_P_R_BLEND_DEBUG 0
#endif
// Diagnostic stage: uncolored and unmasked Kajiya-Kay range built from the
// validated P.r-blended hair normal. It uses an independent view-relative key.
#ifndef EF_HAIR_KK_RANGE_DEBUG
#define EF_HAIR_KK_RANGE_DEBUG 0
#endif
#ifndef EF_HAIR_KK_RANGE
#define EF_HAIR_KK_RANGE 64.0
#endif
// Reference-matching compatibility stage: threshold only the KK range used by
// the final mask so both band edges become crisp. The unmodified range remains
// available to the authored RS V coordinate.
#ifndef EF_HAIR_KK_SHARP_BAND_DEBUG
#define EF_HAIR_KK_SHARP_BAND_DEBUG 0
#endif
#ifndef EF_HAIR_KK_GOO_LENGTH_FRONT_DEBUG
#define EF_HAIR_KK_GOO_LENGTH_FRONT_DEBUG 0
#endif
// Asset-native article path: the P.r=0 outer/front branch uses the unmodified
// Kajiya-Kay range. P.r=1 rear/inner hair may keep a separately accepted mask.
#ifndef EF_HAIR_KK_ARTICLE_RANGE_FRONT_DEBUG
#define EF_HAIR_KK_ARTICLE_RANGE_FRONT_DEBUG 0
#endif
#ifndef EF_HAIR_KK_FRONT_NOV_WIDEN_DEBUG
#define EF_HAIR_KK_FRONT_NOV_WIDEN_DEBUG 0
#endif
#ifndef EF_HAIR_KK_FRONT_NOV_POWER
#define EF_HAIR_KK_FRONT_NOV_POWER 1.0
#endif
#ifndef EF_HAIR_KK_FRONT_BAND_HARDEN_DEBUG
#define EF_HAIR_KK_FRONT_BAND_HARDEN_DEBUG 0
#endif
#ifndef EF_HAIR_KK_FRONT_BAND_HARDEN_LOW
#define EF_HAIR_KK_FRONT_BAND_HARDEN_LOW 0.35
#endif
#ifndef EF_HAIR_KK_FRONT_BAND_HARDEN_HIGH
#define EF_HAIR_KK_FRONT_BAND_HARDEN_HIGH 0.65
#endif
#ifndef EF_HAIR_KK_BAND_EDGE_LOW
#define EF_HAIR_KK_BAND_EDGE_LOW 0.35
#endif
#ifndef EF_HAIR_KK_BAND_EDGE_HIGH
#define EF_HAIR_KK_BAND_EDGE_HIGH 0.55
#endif
// Diagnostic stage: H2 plus only the zero-centered red anisotropic noise map.
#ifndef EF_HAIR_KK_NOISE_DEBUG
#define EF_HAIR_KK_NOISE_DEBUG 0
#endif
#ifndef EF_HAIR_ANISO_NOISE_STRENGTH
#define EF_HAIR_ANISO_NOISE_STRENGTH 0.1
#endif
// Constant term from the asset-native anisotropicOffset expression. Keep the
// locked H3a probe at zero; H3b wrappers use equal positive/negative values to
// establish the model-specific screen direction before choosing a final value.
#ifndef EF_HAIR_ANISO_BASE_OFFSET
#define EF_HAIR_ANISO_BASE_OFFSET 0.0
#endif
// H4 diagnostic: output the inverse second Kajiya-Kay lobe used as the hard
// upper cut mask. The article adds the full offset a second time to the already
// shifted hair tangent; the extra cut delta therefore starts at zero.
#ifndef EF_HAIR_KK_CUT_MASK_DEBUG
#define EF_HAIR_KK_CUT_MASK_DEBUG 0
#endif
// H4b diagnostic: multiply the locked H3 range by the confirmed H4a mask.
#ifndef EF_HAIR_KK_CUT_COMPOSITE_DEBUG
#define EF_HAIR_KK_CUT_COMPOSITE_DEBUG 0
#endif
#ifndef EF_HAIR_ANISO_CUT_OFFSET
#define EF_HAIR_ANISO_CUT_OFFSET 0.0
#endif
// H5a diagnostic: apply the asset-native forward-facing NoV^3 gate to the
// confirmed H4 composite. Despite the source article's "fresnelMask" name,
// this is NoV cubed rather than an inverse Fresnel term.
#ifndef EF_HAIR_KK_NOV3_DEBUG
#define EF_HAIR_KK_NOV3_DEBUG 0
#endif
// H5b diagnostic: multiply the confirmed geometric highlight by the authored
// P.g anisotropic rhythm mask. HairLine and RS remain separate later stages.
#ifndef EF_HAIR_KK_PG_MASK_DEBUG
#define EF_HAIR_KK_PG_MASK_DEBUG 0
#endif
// H5c diagnostic: suppress highlight on the white strands of the authored
// black hair-line texture. It is a data mask and is not sRGB-decoded.
#ifndef EF_HAIR_KK_HAIRLINE_MASK_DEBUG
#define EF_HAIR_KK_HAIRLINE_MASK_DEBUG 0
#endif
#ifndef EF_HAIR_LINE_UV_ST
#define EF_HAIR_LINE_UV_ST float4(1.0, 1.0, 0.0, 0.0)
#endif
// H6 diagnostic: sample the authored RS color map with the asset-native axes,
// U = horizontal view/normal projection and V = the unmasked KK range.
#ifndef EF_HAIR_KK_RS_COLOR_DEBUG
#define EF_HAIR_KK_RS_COLOR_DEBUG 0
#endif
// H6a visibility probe: show the raw RS sample in display space without any
// highlight mask. This isolates UV orientation from final linear intensity.
#ifndef EF_HAIR_KK_RS_SAMPLE_ONLY_DEBUG
#define EF_HAIR_KK_RS_SAMPLE_ONLY_DEBUG 0
#endif
// H6b intensity probe: apply the explicit MyZmd LUT gain and encode the
// resulting linear highlight back to display sRGB. It remains light-independent.
#ifndef EF_HAIR_KK_RS_GAINED_DEBUG
#define EF_HAIR_KK_RS_GAINED_DEBUG 0
#endif
#ifndef EF_HAIR_RS_GAIN
#define EF_HAIR_RS_GAIN 7.0
#endif
// Goo-style color-layer probe. The reference blend uses two linear
// highlight colors selected by a one-sided sqrt(-T.H) smoothstep. The diffuse
// hair beneath the masked band remains the third visible color layer.
#ifndef EF_HAIR_KK_GOO_AB_COLOR_DEBUG
#define EF_HAIR_KK_GOO_AB_COLOR_DEBUG 0
#endif
// Final C6 color path: retain Goo's accepted A/B layering and add a restrained
// article/MyZmd RS contribution (dielectric F0 0.04 * LUT gain 7 = 0.28).
#ifndef EF_HAIR_KK_GOO_RS_FUSION
#define EF_HAIR_KK_GOO_RS_FUSION 0
#endif
#ifndef EF_HAIR_GOO_RS_FUSION_STRENGTH
#define EF_HAIR_GOO_RS_FUSION_STRENGTH 0.35
#endif
#ifndef EF_HAIR_GOO_RS_DIELECTRIC_GAIN
#define EF_HAIR_GOO_RS_DIELECTRIC_GAIN 0.28
#endif
#ifndef EF_HAIR_GOO_HIGHLIGHT_COLOR_A
#define EF_HAIR_GOO_HIGHLIGHT_COLOR_A float3(0.13202350, 0.13240357, 0.15691248)
#endif
#ifndef EF_HAIR_GOO_HIGHLIGHT_COLOR_B
#define EF_HAIR_GOO_HIGHLIGHT_COLOR_B float3(1.0, 0.64452434, 0.43651119)
#endif
#ifndef EF_HAIR_GOO_UPPER_COLOR_MIX
#define EF_HAIR_GOO_UPPER_COLOR_MIX 1.0
#endif
#ifndef EF_HAIR_GOO_COLOR_LERP_MIN
#define EF_HAIR_GOO_COLOR_LERP_MIN 0.1
#endif
#ifndef EF_HAIR_GOO_COLOR_LERP_MAX
#define EF_HAIR_GOO_COLOR_LERP_MAX 0.4
#endif
#ifndef EF_HAIR_GOO_COLOR_LERP_OFFSET
#define EF_HAIR_GOO_COLOR_LERP_OFFSET 0.0
#endif
// Independent front-hair edge tuning. Defaults reproduce the previously
// accepted mask exactly; the dedicated color/edge probe overrides them.
#ifndef EF_HAIR_KK_FRONT_EDGE_TUNE_DEBUG
#define EF_HAIR_KK_FRONT_EDGE_TUNE_DEBUG 0
#endif
#ifndef EF_HAIR_KK_FRONT_UPPER_CUT_SOFTNESS
#define EF_HAIR_KK_FRONT_UPPER_CUT_SOFTNESS 0.1
#endif
#ifndef EF_HAIR_KK_FRONT_LOWER_FADE_POWER
#define EF_HAIR_KK_FRONT_LOWER_FADE_POWER 1.0
#endif
#ifndef EF_HAIR_KK_FRONT_LOWER_ONE_SIDED
#define EF_HAIR_KK_FRONT_LOWER_ONE_SIDED 0
#endif
#ifndef EF_HAIR_KK_SHAPE_SCALE_DEBUG
#define EF_HAIR_KK_SHAPE_SCALE_DEBUG 0
#endif
#ifndef EF_HAIR_KK_JAGGED_CONTROL_DEBUG
#define EF_HAIR_KK_JAGGED_CONTROL_DEBUG 0
#endif
#ifndef EF_HAIR_HIGHLIGHT_SCALE_X
#define EF_HAIR_HIGHLIGHT_SCALE_X 1.0
#endif
#ifndef EF_HAIR_HIGHLIGHT_SCALE_Y
#define EF_HAIR_HIGHLIGHT_SCALE_Y 1.0
#endif
#ifndef EF_HAIR_ANISO_NOISE_UV_ST
#define EF_HAIR_ANISO_NOISE_UV_ST float4(1.0, 1.0, 0.0, 0.0)
#endif
#ifndef EF_HAIR_RS_U_POWER
#define EF_HAIR_RS_U_POWER 1.0
#endif
// Diagnostic for MMD models that cannot carry Unity's authored vertex tangents.
// Only the P.r=0 outer shell switches to a position-based sphere normal; P.r=1
// inner layers keep the asset-native regular HN.rg normal.
#ifndef EF_HAIR_KK_SPHERE_OUTER_DEBUG
#define EF_HAIR_KK_SPHERE_OUTER_DEBUG 0
#endif
#ifndef EF_HAIR_KK_SPHERE_HN_BLEND
#define EF_HAIR_KK_SPHERE_HN_BLEND 0.0
#endif
// H8 diffuse refinements from the asset-native article. Top light is a small
// world-up fill; the dark-line path uses P.a, HairLine and the raw KK range.
#ifndef EF_HAIR_RD_TOP_LIGHT_DEBUG
#define EF_HAIR_RD_TOP_LIGHT_DEBUG 0
#endif
#ifndef EF_HAIR_TOP_LIGHT_COLOR
#define EF_HAIR_TOP_LIGHT_COLOR float3(0.92, 0.96, 1.0)
#endif
#ifndef EF_HAIR_TOP_LIGHT_STRENGTH
#define EF_HAIR_TOP_LIGHT_STRENGTH 0.12
#endif
#ifndef EF_HAIR_TOP_LIGHT_OFFSET
#define EF_HAIR_TOP_LIGHT_OFFSET -0.25
#endif
#ifndef EF_HAIR_TOP_LIGHT_CONE_DEBUG
#define EF_HAIR_TOP_LIGHT_CONE_DEBUG 0
#endif
#ifndef EF_HAIR_TOP_LIGHT_THRESHOLD
#define EF_HAIR_TOP_LIGHT_THRESHOLD 0.45
#endif
#ifndef EF_HAIR_TOP_LIGHT_SOFTNESS
#define EF_HAIR_TOP_LIGHT_SOFTNESS 0.25
#endif
#ifndef EF_HAIR_TOP_LIGHT_NORMAL_DETAIL
#define EF_HAIR_TOP_LIGHT_NORMAL_DETAIL 0.25
#endif
#ifndef EF_HAIR_RD_DARK_LINE_DEBUG
#define EF_HAIR_RD_DARK_LINE_DEBUG 0
#endif
#ifndef EF_HAIR_DARK_LINE_STRENGTH
#define EF_HAIR_DARK_LINE_STRENGTH 0.70
#endif
#ifndef EF_HAIR_DARK_LINE_SATURATION
#define EF_HAIR_DARK_LINE_SATURATION 0.80
#endif
#ifndef EF_HAIR_DARK_LINE_SPECULAR_PROTECT
#define EF_HAIR_DARK_LINE_SPECULAR_PROTECT 3.0
#endif
// Diagnostic stage: Goo's remapped Half-Lambert samples RD.rgb, then multiplies
// the validated D/BaseColor and raw MMD LightColor. RD.a and cast shadow stay off.
#ifndef EF_HAIR_RD_DIFFUSE_DEBUG
#define EF_HAIR_RD_DIFFUSE_DEBUG 0
#endif
// Diagnostic stage: RD1 plus the Goo global-shadow brightness factor from RD.a.
#ifndef EF_HAIR_RD_ALPHA_DIFFUSE_DEBUG
#define EF_HAIR_RD_ALPHA_DIFFUSE_DEBUG 0
#endif
// Diagnostic stage: RD2 plus HS_Snow's MMD MaterialAmbient dark-side floor.
#ifndef EF_HAIR_RD_AMBIENT_DIFFUSE_DEBUG
#define EF_HAIR_RD_AMBIENT_DIFFUSE_DEBUG 0
#endif
// Diagnostic stage: RD2 with HS_Snow's effective non-zero Hair Ramp shadow endpoint.
#ifndef EF_HAIR_RD_BASE_LIGHTNESS_DEBUG
#define EF_HAIR_RD_BASE_LIGHTNESS_DEBUG 0
#endif
// Diagnostic stage: RD5 with MyZmd's verified deep-dark albedo layer as a floor.
#ifndef EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG
#define EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG 0
#endif
// Diagnostic stage: RD6 with display-targeted dark/light balance around the RD split.
#ifndef EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG
#define EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG 0
#endif
#ifndef EF_HAIR_NORMALIZE_MMD_LIGHT_INTENSITY
#define EF_HAIR_NORMALIZE_MMD_LIGHT_INTENSITY 0
#endif
// Diagnostic stage: Goo's screen-depth rim mask before any Fresnel/color terms.
#ifndef EF_HAIR_RD_GOO_DEPTH_RIM_DEBUG
#define EF_HAIR_RD_GOO_DEPTH_RIM_DEBUG 0
#endif
// Diagnostic stage: confirmed DepthRim multiplied only by Goo's (1-NoV)^4.
#ifndef EF_HAIR_RD_GOO_DEPTH_FRESNEL_RIM_DEBUG
#define EF_HAIR_RD_GOO_DEPTH_FRESNEL_RIM_DEBUG 0
#endif
// Diagnostic stage: D1 multiplied by Goo's world-up normal attenuation.
#ifndef EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_RIM_DEBUG
#define EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_RIM_DEBUG 0
#endif
// Diagnostic stage: D2 multiplied by Goo's main-light attenuation.
#ifndef EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_RIM_DEBUG
#define EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_RIM_DEBUG 0
#endif
// Diagnostic stage: D3 multiplied by Goo's optional object-X rim limitation.
#ifndef EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_LIMITED_RIM_DEBUG
#define EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_LIMITED_RIM_DEBUG 0
#endif
// Diagnostic stage: confirmed D4S rim contribution added to the RD diffuse path.
#ifndef EF_HAIR_RD_GOO_RIM_COMPOSITE_DEBUG
#define EF_HAIR_RD_GOO_RIM_COMPOSITE_DEBUG 0
#endif
// Release-only budget path. The accepted Goo screen-space rim is rendered as
// a separate additive pass so the main ps_3_0 can retain every hair feature.
#ifndef EF_HAIR_FINAL_RIM_PASS
#define EF_HAIR_FINAL_RIM_PASS 0
#endif
// Optional face-shadow pass drawn by the real hair material. Face writes bit 0;
// the shifted copy is drawn before visible hair and accepts Face only. The main
// hair pass then overwrites every real hair pixel and writes bit 1 for later
// through-hair effects.
#ifndef EF_HAIR_FACE_SHADOW_PASS
#define EF_HAIR_FACE_SHADOW_PASS 0
#endif
#ifndef EF_HAIR_FACE_SHADOW_FACE_REF
#define EF_HAIR_FACE_SHADOW_FACE_REF 1
#endif
#ifndef EF_HAIR_FACE_SHADOW_HAIR_REF
#define EF_HAIR_FACE_SHADOW_HAIR_REF 2
#endif
#ifndef EF_HAIR_FACE_SHADOW_READ_MASK
#define EF_HAIR_FACE_SHADOW_READ_MASK 1
#endif
#ifndef EF_HAIR_FACE_SHADOW_HAIR_WRITE_MASK
#define EF_HAIR_FACE_SHADOW_HAIR_WRITE_MASK 2
#endif
#ifndef EF_HAIR_FACE_SHADOW_OFFSET_X
// Danbaidong's 0.0045 Unity-unit offset, converted to this PMX's scale.
#define EF_HAIR_FACE_SHADOW_OFFSET_X 0.055
#endif
#ifndef EF_HAIR_FACE_SHADOW_OFFSET_Y
// Downward baseline keeps the fringe visible under a frontal MMD light.
#define EF_HAIR_FACE_SHADOW_OFFSET_Y 0.090
#endif
#ifndef EF_HAIR_FACE_SHADOW_CONTROLLER_STEP_X
#define EF_HAIR_FACE_SHADOW_CONTROLLER_STEP_X 0.025
#endif
#ifndef EF_HAIR_FACE_SHADOW_CONTROLLER_STEP_Y
#define EF_HAIR_FACE_SHADOW_CONTROLLER_STEP_Y 0.025
#endif
#ifndef EF_HAIR_FACE_SHADOW_LIGHT_INFLUENCE
#define EF_HAIR_FACE_SHADOW_LIGHT_INFLUENCE 1.0
#endif
#ifndef EF_HAIR_FACE_SHADOW_LIGHT_EASING
// 0 keeps the reference linear projection; 1 applies a signed C1 ease at the
// frontal center and side extrema without introducing thresholds or snapping.
#define EF_HAIR_FACE_SHADOW_LIGHT_EASING 0.0
#endif
#ifndef EF_HAIR_FACE_SHADOW_CAMERA_PITCH_MIN
#define EF_HAIR_FACE_SHADOW_CAMERA_PITCH_MIN 0.1
#endif
#ifndef EF_HAIR_FACE_SHADOW_CAMERA_PITCH_MAX
#define EF_HAIR_FACE_SHADOW_CAMERA_PITCH_MAX 0.9
#endif
#ifndef EF_HAIR_FACE_SHADOW_DEPTH_BIAS
// View-space model-unit bias. Applying a constant clip/NDC depth offset made
// its effective world displacement grow rapidly with camera distance, which
// could pull rear hair over the face in long shots.
#define EF_HAIR_FACE_SHADOW_DEPTH_BIAS 0.0
#endif
#ifndef EF_HAIR_FACE_SHADOW_ZFUNC
#define EF_HAIR_FACE_SHADOW_ZFUNC LESSEQUAL
#endif
#ifndef EF_HAIR_FACE_SHADOW_COLOR
#define EF_HAIR_FACE_SHADOW_COLOR float3(0.36, 0.25, 0.28)
#endif
#ifndef EF_HAIR_FACE_SHADOW_OPACITY
#define EF_HAIR_FACE_SHADOW_OPACITY 0.32
#endif
#ifndef EF_HAIR_FACE_SHADOW_USE_D_ALPHA
// Hair D.a is already used as an SSS mask and is not a validated opacity map.
#define EF_HAIR_FACE_SHADOW_USE_D_ALPHA 0
#endif
#ifndef EF_HAIR_FACE_SHADOW_ALPHA_CUTOFF
#define EF_HAIR_FACE_SHADOW_ALPHA_CUTOFF 0.5
#endif
#ifndef EF_HAIR_FACE_SHADOW_ALPHA_SOFTNESS
#define EF_HAIR_FACE_SHADOW_ALPHA_SOFTNESS 0.1
#endif
// H7 diagnostic: add the confirmed asset-native KK/RS highlight to the D5
// linear diffuse/Rim result before the single final sRGB encode.
#ifndef EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG
#define EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG 0
#endif
// Legacy diagnostic stage: SS1 plus Goo's isolated (1-NoV)^4 multiplier.
#ifndef EF_HAIR_RD_GOO_FRESNEL_RIM_DEBUG
#define EF_HAIR_RD_GOO_FRESNEL_RIM_DEBUG 0
#endif
// Diagnostic stage: HG1 plus HS_Snow's controller-weighted shadow visibility.
#ifndef EF_HAIR_RD_SELF_SHADOW_DEBUG
#define EF_HAIR_RD_SELF_SHADOW_DEBUG \
    (EF_HAIR_RD_GOO_FRESNEL_RIM_DEBUG || EF_HAIR_RD_GOO_DEPTH_RIM_DEBUG \
        || EF_HAIR_RD_GOO_DEPTH_FRESNEL_RIM_DEBUG \
        || EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_RIM_DEBUG \
        || EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_RIM_DEBUG \
        || EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_LIMITED_RIM_DEBUG \
        || EF_HAIR_RD_GOO_RIM_COMPOSITE_DEBUG \
        || EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG)
#endif
// Diagnostic stage: AO1 plus HgShadow visibility in the scalar RD attenuation.
#ifndef EF_HAIR_RD_HGSHADOW_DEBUG
#define EF_HAIR_RD_HGSHADOW_DEBUG EF_HAIR_RD_SELF_SHADOW_DEBUG
#endif
// Diagnostic stage: RD7 with decoded P.b AO bounded by the confirmed deep-dark layer.
// The HgShadow probe inherits this complete AO1 path before adding its one variable.
#ifndef EF_HAIR_RD_AO_DEBUG
#define EF_HAIR_RD_AO_DEBUG EF_HAIR_RD_HGSHADOW_DEBUG
#endif
#ifndef EF_RD_HALFLAMBERT_CENTER
#define EF_RD_HALFLAMBERT_CENTER 0.57000005245
#endif
#ifndef EF_RD_HALFLAMBERT_SHARP
#define EF_RD_HALFLAMBERT_SHARP 0.18000000715
#endif
#ifndef EF_RD_GLOBAL_SHADOW_MIN
#define EF_RD_GLOBAL_SHADOW_MIN -1.7261145115
#endif
#ifndef EF_RD_GLOBAL_SHADOW_MAX
#define EF_RD_GLOBAL_SHADOW_MAX 1.0
#endif
#ifndef EF_MMD_AMBIENT_COLOR
#define EF_MMD_AMBIENT_COLOR float3(0.42, 0.46, 0.55)
#endif
#ifndef EF_MMD_AMBIENT_SCALE
#define EF_MMD_AMBIENT_SCALE 0.12
#endif
#ifndef EF_MMD_AMBIENT_STRENGTH
#define EF_MMD_AMBIENT_STRENGTH 1.0
#endif
// Linear value: pow(144 / 255, 2.2) * 0.825 from HS_Snow's Hair Ramp dark endpoint.
#ifndef EF_RD_DIRECT_SHADOW_FLOOR
#define EF_RD_DIRECT_SHADOW_FLOOR 0.23467295
#endif
#ifndef EF_ALBEDO_DARK_STRENGTH
#define EF_ALBEDO_DARK_STRENGTH 0.8
#endif
#ifndef EF_ALBEDO_DARK_SATURATION
#define EF_ALBEDO_DARK_SATURATION 0.8
#endif
#ifndef EF_DEEP_DARK_STRENGTH
#define EF_DEEP_DARK_STRENGTH 0.65
#endif
// pow(0.875, 2.2) and pow(1.225, 2.2): -12.5%/+22.5% after sRGB output.
#ifndef EF_RD_DARK_TONE_LINEAR_SCALE
#define EF_RD_DARK_TONE_LINEAR_SCALE 0.74544862
#endif
#ifndef EF_RD_LIGHT_TONE_LINEAR_SCALE
#define EF_RD_LIGHT_TONE_LINEAR_SCALE 1.56278558
#endif
// HS_Snow's neutral self-shadow strength. Runtime morphs scale this value.
#ifndef EF_RD_SELF_SHADOW_STRENGTH
#define EF_RD_SELF_SHADOW_STRENGTH 1.0
#endif
#ifndef EF_GOO_RIM_FRESNEL_POWER
#define EF_GOO_RIM_FRESNEL_POWER 4.0
#endif
#ifndef EF_GOO_RIM_DIRECTIONAL_ATTENUATION
#define EF_GOO_RIM_DIRECTIONAL_ATTENUATION 0.961783409
#endif
#ifndef EF_GOO_RIM_LIMITATION_STRENGTH
#define EF_GOO_RIM_LIMITATION_STRENGTH 1.0
#endif
#ifndef EF_GOO_RIM_COLOR
#define EF_GOO_RIM_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_HAIR_RIM_EDGE_COLOR_MIN
// PMX hair materials commonly leave EDGECOLOR at exact black. Treat only
// near-black values as "unset" so dark intentional edge colors still work.
#define EF_HAIR_RIM_EDGE_COLOR_MIN 0.004
#endif
#ifndef EF_GOO_RIM_COLOR_STRENGTH
#define EF_GOO_RIM_COLOR_STRENGTH 2.0
#endif
#ifndef EF_GOO_RIM_WIDTH_X
#define EF_GOO_RIM_WIDTH_X 0.041847
#endif
#ifndef EF_GOO_RIM_WIDTH_Y
#define EF_GOO_RIM_WIDTH_Y 0.019108
#endif
// Exact DepthRim group constants: view-space XY offset, then 0..5 -> 0..8 / 2.
#ifndef EF_GOO_DEPTH_RIM_VIEW_SCALE
#define EF_GOO_DEPTH_RIM_VIEW_SCALE 0.1
#endif
#ifndef EF_GOO_DEPTH_RIM_MODEL_SCALE
#define EF_GOO_DEPTH_RIM_MODEL_SCALE 1.0
#endif
#ifndef EF_GOO_DEPTH_RIM_DELTA_SCALE
#define EF_GOO_DEPTH_RIM_DELTA_SCALE 0.8
#endif
#ifndef EF_GOO_DEPTH_RIM_MAX
#define EF_GOO_DEPTH_RIM_MAX 4.0
#endif
#ifndef EF_SHADOW_VIEWPORT_MAP
#define EF_SHADOW_VIEWPORT_MAP ZMDshadow_ViewportMap2
#endif
#ifndef EF_SHADOW_CONTROLLER_NAME
#define EF_SHADOW_CONTROLLER_NAME "ZMDshadow.x"
#endif
// Diagnostic stage for validating the packed P texture one channel at a time.
// Channel: 0=R, 1=G, 2=B, 3=A. RGB follows the reference Blender sRGB image.
#ifndef EF_HAIR_P_DEBUG
#define EF_HAIR_P_DEBUG 0
#endif
#ifndef EF_HAIR_P_DEBUG_CHANNEL
#define EF_HAIR_P_DEBUG_CHANNEL 0
#endif
#ifndef EF_HAIR_P_MATCH_BLEND_SRGB
#define EF_HAIR_P_MATCH_BLEND_SRGB 1
#endif
#ifndef EF_HAIR_P_DEBUG_INVERT
#define EF_HAIR_P_DEBUG_INVERT 0
#endif
// Hair specular model: 0 = LUT Kajiya-Kay; 1 = analytic anisotropic GGX;
// 2 = Goo reference position/width probe (constant color, no LUT yet).
#ifndef EF_HAIR_SPEC_MODEL
#define EF_HAIR_SPEC_MODEL 1
#endif
#ifndef EF_GOO_HNORMAL_STRENGTH
#define EF_GOO_HNORMAL_STRENGTH 0.75
#endif
#ifndef EF_GOO_HIGHLIGHT_POSITION
#define EF_GOO_HIGHLIGHT_POSITION 0.4
#endif
#ifndef EF_GOO_HIGHLIGHT_LENGTH
#define EF_GOO_HIGHLIGHT_LENGTH 0.085
#endif
#ifndef EF_GOO_MATCH_BLEND_P_SRGB
#define EF_GOO_MATCH_BLEND_P_SRGB 1
#endif
#ifndef EF_GOO_POSITION_COLOR
#define EF_GOO_POSITION_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_GOO_POSITION_GAIN
#define EF_GOO_POSITION_GAIN 4.0
#endif
#ifndef EF_GOO_BASIS_MODE
// 0 = exact Goo tangent mix; 1 = camera-flat HN; 2 = camera-flat sphere HN;
// 3 = camera-flat sphere/HN hybrid controlled by P.r.
#define EF_GOO_BASIS_MODE 0
#endif
// GGX anisotropy amount [0,1): higher = thinner vertical band.
#ifndef EF_GGX_ANISO
#define EF_GGX_ANISO 0.85
#endif
// GGX overall gain and a numerical clamp on D*V.
#ifndef EF_GGX_GAIN
#define EF_GGX_GAIN 6.0
#endif
#ifndef EF_GGX_CLAMP
#define EF_GGX_CLAMP 8.0
#endif
// Hair anisotropy tangent source:
//   1 = RADIAL around world-up axis (SMOOTH, matches the Blender reference's
//       TANGENT node direction=RADIAL axis=Z). Analytic from the smooth HN, so
//       no per-triangle faceting — this is the "规格化平滑" fix. DEFAULT.
//   0 = UV-gradient (ddx/ddy) tangent/bitangent — per-face flat, faceted.
#ifndef EF_HAIR_TANGENT_MODE
#define EF_HAIR_TANGENT_MODE 1
#endif
// Radial axis (world up for MMD's Y-up world; Blender used Z in its Z-up world).
#ifndef EF_HAIR_RADIAL_AXIS
#define EF_HAIR_RADIAL_AXIS float3(0.0, 1.0, 0.0)
#endif
// Radial center: the vertical line the strand tangent circulates around. Only
// x/z matter (circulation ignores height). Blender derives its RADIAL tangent
// from object POSITION, so the pole sits on this interior axis line (invisible),
// NOT on the crown where the surface normal points up (that caused the swirl).
#ifndef EF_HAIR_RADIAL_CENTER
#define EF_HAIR_RADIAL_CENTER float3(0.0, 0.0, 0.0)
#endif
// KK anisotropy axis-normal source:
//   2 = SPHERE normal (posWS - EF_FACE_CENTER) — smoothest, position-based,
//       continuous across hair cards. The tutorial's trick for aligned
//       highlights. DEFAULT.
//   1 = smooth interpolated geometric normal (per-card smooth, jumps at seams).
//   0 = HN (ddx/ddy texture smooth normal, Unity-faithful but faceted).
#ifndef EF_HAIR_AXIS_MODE
#define EF_HAIR_AXIS_MODE 2
#endif
// Blend the sphere axis toward HN by this much (0 = pure sphere = smoothest).
#ifndef EF_HAIR_AXIS_HN_BLEND
#define EF_HAIR_AXIS_HN_BLEND 0.0
#endif
// For EF_HAIR_TANGENT_MODE 0: 1 = bitangent (V/strand on hair cards), 0 = tangent.
#ifndef EF_HAIR_STRAND_AXIS
#define EF_HAIR_STRAND_AXIS 1
#endif
#ifndef EF_SELF_AO_SHADOW_STRENGTH
#define EF_SELF_AO_SHADOW_STRENGTH 1.0
#endif
#ifndef EF_BINORMAL_OFFSET
#define EF_BINORMAL_OFFSET 0.0
#endif
#ifndef EF_CULL_MODE
#define EF_CULL_MODE NONE
#endif
// Outline (geometric-normal back-face expansion, M1 choice B).
#ifndef EF_USE_OUTLINE
#define EF_USE_OUTLINE 1
#endif
#ifndef EF_OUTLINE_WIDTH
#define EF_OUTLINE_WIDTH 1.0
#endif
#ifndef EF_OUTLINE_ZBIAS
#define EF_OUTLINE_ZBIAS 0.001
#endif
#ifndef EF_OUTLINE_COLOR
#define EF_OUTLINE_COLOR float3(0.1, 0.1, 0.1)
#endif
#ifndef EF_OUTLINE_BASE_COLOR
#define EF_OUTLINE_BASE_COLOR EF_OUTLINE_COLOR
#endif
#ifndef EF_OUTLINE_STRENGTH
#define EF_OUTLINE_STRENGTH 1.0
#endif
#ifndef EF_OUTLINE_ZMIN_REFINE
#define EF_OUTLINE_ZMIN_REFINE 0.4
#endif
#ifndef EF_OUTLINE_LIGHT_FLOOR
#define EF_OUTLINE_LIGHT_FLOOR 0.7
#endif
#ifndef EF_USE_ALPHA_CLIP
#define EF_USE_ALPHA_CLIP 0
#endif
#ifndef EF_ALPHA_CUTOFF
#define EF_ALPHA_CUTOFF 0.5
#endif

// Character texture resources are supplied by the generated wrapper. The
// base color falls back to MMD's material texture; optional maps are disabled
// by the generator when the current model does not provide them.

// ── MME semantic globals ────────────────────────────────
float4x4 matWorldViewProject : WORLDVIEWPROJECTION;
float4x4 matWorld : WORLD;
float4x4 matWorldInverse : WORLDINVERSE;
float4x4 matView : VIEW;
float4x4 matProjection : PROJECTION;
float3 LightDirection : DIRECTION < string Object = "Light"; >;
float3 LightColor : SPECULAR < string Object = "Light"; >;
float3 CameraPosition : POSITION < string Object = "Camera"; >;
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;
float4 MaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float4 MaterialAmbient : EMISSIVE < string Object = "Geometry"; >;
float4 EfHairMaterialEdgeColor : EDGECOLOR;

// ── Shared includes (order matters: globals above, helpers below) ──
#include "internal/endfield_camera_light.hlsl"
#if EF_USE_OUTLINE
#include "internal/endfield_outline.hlsl"
#endif
#include "internal/endfield_controls.inc"
#include "internal/endfield_global_shadow_scale.hlsl"
#if EF_HAIR_CONTROLLER_ENABLED
#include "internal/endfield_hair_controls.inc"
#endif
#if EF_HAIR_CONTROLLER_C5_ENABLED
#include "internal/endfield_hair_controls_c5.inc"
#endif
#include "internal/endfield_lighting.hlsl"
#include "internal/endfield_specular.hlsl"
#include "internal/endfield_hair_specular.hlsl"
#include "internal/endfield_hair_ggx.hlsl"
#include "internal/endfield_hair_goo_position.hlsl"

// ── Samplers ────────────────────────────────────────────
#ifdef EF_MAIN_TEXTURE_RESOURCE
texture2D EfMainTexture < string ResourceName = EF_MAIN_TEXTURE_RESOURCE; >;
#else
texture2D EfMainTexture : MATERIALTEXTURE < string Format = "A8R8G8B8"; >;
#endif
sampler2D EfMainSampler = sampler_state {
    texture = <EfMainTexture>;
    MinFilter = ANISOTROPIC; MagFilter = ANISOTROPIC; MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16; AddressU = WRAP; AddressV = WRAP;
};

#if EF_USE_ORM
texture2D EfOrmTexture < string ResourceName = EF_ORM_TEXTURE; >;
sampler2D EfOrmSampler = sampler_state {
    texture = <EfOrmTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};
#endif

#if EF_USE_NORMAL_MAP
texture2D EfNormalTexture < string ResourceName = EF_NORMAL_TEXTURE; >;
sampler2D EfNormalSampler = sampler_state {
    texture = <EfNormalTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};
#endif

#ifdef EF_RAMP_TEXTURE
texture2D EfRampTexture < string ResourceName = EF_RAMP_TEXTURE; >;
#else
texture2D EfRampTexture : MATERIALTEXTURE < string Format = "A8R8G8B8"; >;
#endif
sampler2D EfRampSampler = sampler_state {
    texture = <EfRampTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU = CLAMP; AddressV = CLAMP;
};

#ifdef EF_HAIR_SPEC_TEXTURE
texture2D EfHairSpecTexture < string ResourceName = EF_HAIR_SPEC_TEXTURE; >;
#else
texture2D EfHairSpecTexture : MATERIALTEXTURE < string Format = "A8R8G8B8"; >;
#endif
sampler2D EfHairSpecSampler = sampler_state {
    texture = <EfHairSpecTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU = CLAMP; AddressV = CLAMP;
};

#ifdef EF_HAIR_ANISO_NOISE_TEXTURE
texture2D EfHairAnisoNoiseTexture < string ResourceName = EF_HAIR_ANISO_NOISE_TEXTURE; >;
#else
texture2D EfHairAnisoNoiseTexture : MATERIALTEXTURE < string Format = "A8R8G8B8"; >;
#endif
sampler2D EfHairAnisoNoiseSampler = sampler_state {
    texture = <EfHairAnisoNoiseTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};

#if EF_HAIR_KK_HAIRLINE_MASK_DEBUG || EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG \
    || EF_HAIR_RD_DARK_LINE_DEBUG
#ifdef EF_HAIR_LINE_TEXTURE
texture2D EfHairLineTexture < string ResourceName = EF_HAIR_LINE_TEXTURE; >;
#else
texture2D EfHairLineTexture : MATERIALTEXTURE < string Format = "A8R8G8B8"; >;
#endif
sampler2D EfHairLineSampler = sampler_state {
    texture = <EfHairLineTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};
#endif

// Configurable HgShadow-compatible screen target. ZMDshadow keeps R as shadow
// visibility and additionally exports linear camera depth in G.
shared texture2D EF_SHADOW_VIEWPORT_MAP : RENDERCOLORTARGET;
sampler2D EfHgShadowSampler = sampler_state {
    texture = <EF_SHADOW_VIEWPORT_MAP>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU = CLAMP; AddressV = CLAMP;
};
float2 EfViewportSize : VIEWPORTPIXELSIZE;
bool  EfHgShadowValid : CONTROLOBJECT < string name = EF_SHADOW_CONTROLLER_NAME; >;
float EfHgShadowRotation : CONTROLOBJECT < string name = EF_SHADOW_CONTROLLER_NAME; string item = "Rx"; >;
float EfHgShadowDensityUp : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen+"; >;
float EfHgShadowDensityDown : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen-"; >;

// ── Utility ─────────────────────────────────────────────
float3 EfSRGBToLinear(float3 c) { return pow(max(c, 1e-5), 2.2); }
float3 EfLinearToSRGB(float3 c) { return pow(max(c, 1e-5), 1.0 / 2.2); }

float EfSigmoidSharp(float x, float center, float smoothness)
{
    float t = (x - center) / max(smoothness, 1e-6);
    return 1.0 / (1.0 + exp(-t));
}

// Exact SigmoidSharp node group used by the validated Goo-style hair preset.
float EfGooSigmoidSharp(float x, float center, float sharp)
{
    float exponent = -3.0 * sharp * (x - center);
    return 1.0 / (1.0 + pow(100000.0, exponent));
}

float3 EfUnpackNormal(float2 packedXY, float scale)
{
    float2 xy = (packedXY * 2.0 - 1.0) * scale;
    float z = sqrt(1.0 - saturate(dot(xy, xy)));
    return float3(xy, z);
}

// HgShadow screen-space visibility (1 = lit, 0 = fully occluded).
float EfSampleHgShadow(float4 screenPosition)
{
    if (!EfHgShadowValid || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }
    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 uv = float2((1.0 + ndc.x) * 0.5, (1.0 - ndc.y) * 0.5);
    uv += 0.5 / max(EfViewportSize, 1.0);
    float shadowAmount = saturate(tex2D(EfHgShadowSampler, uv).r);
    return 1.0 - shadowAmount;
}

#if EF_HAIR_RD_GOO_DEPTH_RIM_DEBUG || EF_HAIR_RD_GOO_DEPTH_FRESNEL_RIM_DEBUG \
    || EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_RIM_DEBUG \
    || EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_RIM_DEBUG \
    || EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_LIMITED_RIM_DEBUG \
    || EF_HAIR_RD_GOO_RIM_COMPOSITE_DEBUG || EF_HAIR_FINAL_RIM_PASS
float2 EfViewportUvFromClip(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / clipPosition.w;
    float2 uv = float2((1.0 + ndc.x) * 0.5, (1.0 - ndc.y) * 0.5);
    return uv + 0.5 / max(EfViewportSize, 1.0);
}

float EfGooDepthRimScaled(float3 positionWS, float3 geometryNormalWS,
    float4 screenPosition, float widthMultiplier)
{
    if (!EfHgShadowValid || abs(screenPosition.w) < 1e-6) {
        return 0.0;
    }

    float3 positionVS = mul(float4(positionWS, 1.0), matView).xyz;
    float3 normalVS = EfNormalizeOr(
        mul(geometryNormalWS, (float3x3)matView), float3(0.0, 0.0, 1.0));
    float3 rimOffsetVS = float3(
        normalVS.x * EF_GOO_RIM_WIDTH_X * EF_GOO_DEPTH_RIM_VIEW_SCALE
            * EF_GOO_DEPTH_RIM_MODEL_SCALE * widthMultiplier,
        normalVS.y * EF_GOO_RIM_WIDTH_Y * EF_GOO_DEPTH_RIM_VIEW_SCALE
            * EF_GOO_DEPTH_RIM_MODEL_SCALE * widthMultiplier,
        0.0
    );
    float4 offsetClip = mul(float4(positionVS + rimOffsetVS, 1.0), matProjection);
    if (abs(offsetClip.w) < 1e-6) {
        return 0.0;
    }

    float centerDepth = tex2D(
        EfHgShadowSampler, EfViewportUvFromClip(screenPosition)).g;
    float offsetDepth = tex2D(
        EfHgShadowSampler, EfViewportUvFromClip(offsetClip)).g;
    float depthDelta = offsetDepth - centerDepth;
    return clamp(
        depthDelta * EF_GOO_DEPTH_RIM_DELTA_SCALE,
        0.0,
        EF_GOO_DEPTH_RIM_MAX
    );
}

float EfGooDepthRim(float3 positionWS, float3 geometryNormalWS,
    float4 screenPosition)
{
    return EfGooDepthRimScaled(
        positionWS, geometryNormalWS, screenPosition, 1.0);
}
#endif

// HgShadow v0.04/HS_Snow sampling contract, including the effect's Rx density.
float EfSampleHgShadowHsSnow(float4 screenPosition, bool useSelfShadow)
{
    if (!useSelfShadow) {
        return 1.0;
    }
    float visibility = EfSampleHgShadow(screenPosition);
    float density = max(
        (degrees(EfHgShadowRotation) + 5.0 * EfHgShadowDensityUp + 1.0)
            * (1.0 - EfHgShadowDensityDown),
        0.0
    );
    return 1.0 - (1.0 - visibility) * min(density, 1.0);
}

float EfSelfShadowAttenuationHsSnow(float visibility)
{
    float strength = max(EF_RD_SELF_SHADOW_STRENGTH, 0.0) * EfSelfShadowCtrl();
    float weightedVisibility = lerp(1.0, saturate(visibility), saturate(strength));
    float extraStrength = saturate(strength - 1.0);
    return lerp(
        weightedVisibility,
        weightedVisibility * saturate(visibility),
        extraStrength
    );
}

// Reconstruct a TBN from screen derivatives (PMX carries no tangent). Returns
// the world-space geometric tangent/bitangent and a UV-Jacobian validity flag.
void EfReconstructTB(float3 positionWS, float3 normalWS, float2 uv,
    out float3 tangentWS, out float3 bitangentWS, out bool valid)
{
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;

    float derivScaleSq = max(dot(duvdx, duvdx) * dot(duvdy, duvdy), 1e-20);
    valid = !(abs(determinant) < 1e-12 || determinant * determinant < derivScaleSq * 1e-6);
    if (!valid) {
        tangentWS = float3(1.0, 0.0, 0.0);
        bitangentWS = float3(0.0, 0.0, 1.0);
        return;
    }

    float invDet = 1.0 / determinant;
    float3 tangentRaw = (dpdx * duvdy.y - dpdy * duvdx.y) * invDet;
    float3 bitangentRaw = (dpdy * duvdx.x - dpdx * duvdy.x) * invDet;
    float3 tangentOrtho = tangentRaw - normalWS * dot(normalWS, tangentRaw);
    tangentWS = normalize(tangentOrtho);
    float handedness = dot(cross(normalWS, tangentWS), bitangentRaw) < 0.0 ? -1.0 : 1.0;
    bitangentWS = normalize(cross(normalWS, tangentWS)) * handedness;
}

// ── Vertex ──────────────────────────────────────────────
struct EfAttributes {
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float2 texcoord0  : TEXCOORD0;
};

struct EfVaryings {
    float4 positionCS : POSITION;
    float2 uv         : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS   : TEXCOORD2;
    float4 screenPos  : TEXCOORD3;
#if EF_HAIR_CONTROLLER_ENABLED && EF_HAIR_CONTROLLER_BASE_GRADE_ENABLED \
    && EF_HAIR_CONTROLLER_BASE_GRADE_VERTEX_PRECOMPUTE
    float4 baseGrade  : TEXCOORD4;
#endif
};

EfVaryings EfMainVS(EfAttributes input)
{
    EfVaryings output = (EfVaryings)0;
    output.positionCS = mul(input.positionOS, matWorldViewProject);
    output.positionWS = mul(input.positionOS, matWorld).xyz;
    output.normalWS   = normalize(mul(input.normalOS, (float3x3)matWorld));
    output.uv         = input.texcoord0;
    output.screenPos  = output.positionCS;
#if EF_HAIR_CONTROLLER_ENABLED && EF_HAIR_CONTROLLER_BASE_GRADE_ENABLED \
    && EF_HAIR_CONTROLLER_BASE_GRADE_VERTEX_PRECOMPUTE
    float3 baseTintGain;
    float baseSaturation;
    EfHairControllerBaseGradeParameters(baseTintGain, baseSaturation);
    output.baseGrade = float4(baseTintGain, baseSaturation);
#endif
    return output;
}

#if EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG
float3 EfAssetKkRsHighlightLinear(EfVaryings input
#if EF_HAIR_RD_DARK_LINE_DEBUG
    ,
    out float diffuseKkRange, out float diffuseHairLine,
    out float diffusePackedLineMask
#endif
    )
{
#if EF_HAIR_RD_DARK_LINE_DEBUG
    diffuseKkRange = 0.0;
    diffuseHairLine = 0.0;
    diffusePackedLineMask = 0.0;
#endif
    float2 uv = input.uv;
    float3 geometryNormalWS = normalize(input.normalWS);
    float3 tangentWS, bitangentWS;
    bool tbnValid;
    EfReconstructTB(input.positionWS, geometryNormalWS, uv,
        tangentWS, bitangentWS, tbnValid);
    if (!tbnValid) {
        return 0.0;
    }

    float4 normalTexture = tex2D(EfNormalSampler, uv);
    float3 regularNormalTS = EfUnpackNormal(normalTexture.rg, EF_BUMP_SCALE);
    float3 softNormalTS = EfUnpackNormal(normalTexture.ba, 1.0);
    float3x3 tbn = float3x3(tangentWS, bitangentWS, geometryNormalWS);
    float3 regularNormalWS = normalize(mul(regularNormalTS, tbn));
    float3 softNormalWS = normalize(mul(softNormalTS, tbn));

    float4 pTexture = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    pTexture.rgb = EfSRGBToLinear(pTexture.rgb);
#endif
    float hairLayerMask = saturate(pTexture.r);
    float3 sphereNormalWS = EfNormalizeOr(
        input.positionWS - EF_FACE_CENTER, softNormalWS);
    float outerHnBlend = saturate(EF_HAIR_KK_SPHERE_HN_BLEND);
#if EF_HAIR_CONTROLLER_C5_HNORMAL_ENABLED
    outerHnBlend = EfHairControllerOuterHnBlend(outerHnBlend);
#endif
    float3 outerNormalWS = normalize(lerp(
        sphereNormalWS, softNormalWS, outerHnBlend));
    float3 hairNormalWS = normalize(lerp(
        outerNormalWS, regularNormalWS, hairLayerMask));

    float3 viewDirWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float3 cameraForwardWS = EfNormalizeOr(
        CameraPosition - EF_FACE_CENTER, viewDirWS);
    float3 highlightKeyWS = EfNormalizeOr(
        cameraForwardWS + float3(0.0, EF_HAIR_SPEC_KEY_UP, 0.0),
        cameraForwardWS);
    float3 halfDirWS = EfNormalizeOr(
        viewDirWS + highlightKeyWS, viewDirWS);

    float3 fakeBitangentWS = EfNormalizeOr(
        cross(float3(0.0, 1.0, 0.0), hairNormalWS), tangentWS);
    float3 baseHairTangentWS = EfNormalizeOr(
        cross(hairNormalWS, fakeBitangentWS), bitangentWS);
    float anisotropicNoiseStrength = EF_HAIR_ANISO_NOISE_STRENGTH;
#if EF_HAIR_KK_JAGGED_CONTROL_DEBUG
    float4 anisotropicNoiseUvSt = EF_HAIR_ANISO_NOISE_UV_ST;
#if EF_HAIR_CONTROLLER_C5_SHAPE_ENABLED
    anisotropicNoiseUvSt.x = EfHairControllerJaggedFrequencyX(
        anisotropicNoiseUvSt.x);
    anisotropicNoiseStrength = EfHairControllerJaggedness(
        anisotropicNoiseStrength);
#endif
    float2 anisotropicNoiseUv = uv * anisotropicNoiseUvSt.xy
        + anisotropicNoiseUvSt.zw;
    float anisotropicNoise = tex2D(
        EfHairAnisoNoiseSampler, anisotropicNoiseUv).r * 2.0 - 1.0;
#else
    float anisotropicNoise = tex2D(
        EfHairAnisoNoiseSampler, uv).r * 2.0 - 1.0;
#endif
    float anisotropicBaseOffset = EF_HAIR_ANISO_BASE_OFFSET;
#if EF_HAIR_CONTROLLER_ENABLED
    anisotropicBaseOffset += EfHairControllerHeightOffset();
#endif
    float3 anisotropicOffset = hairNormalWS
        * (anisotropicNoise * anisotropicNoiseStrength
            + anisotropicBaseOffset);
    float3 hairTangentWS = EfNormalizeOr(
        baseHairTangentWS + anisotropicOffset, baseHairTangentWS);

    float kkRange = EF_HAIR_KK_RANGE;
#if EF_HAIR_KK_SHAPE_SCALE_DEBUG
    float highlightScaleY = max(EF_HAIR_HIGHLIGHT_SCALE_Y, 0.25);
#if EF_HAIR_CONTROLLER_C5_SHAPE_ENABLED
    highlightScaleY = EfHairControllerHighlightScaleY(highlightScaleY);
#endif
    kkRange /= max(highlightScaleY, 0.25);
#endif
    float tDotH = dot(hairTangentWS, halfDirWS);
    float specularRange = pow(
        sqrt(saturate(1.0 - tDotH * tDotH)), kkRange);

    float3 anisotropicCutOffset = hairNormalWS
        * (anisotropicNoise * anisotropicNoiseStrength
            + anisotropicBaseOffset + EF_HAIR_ANISO_CUT_OFFSET);
    float3 cutHairTangentWS = EfNormalizeOr(
        hairTangentWS + anisotropicCutOffset, hairTangentWS);
    float cutTDotH = dot(cutHairTangentWS, halfDirWS);
    float cutLobe = pow(
        sqrt(saturate(1.0 - cutTDotH * cutTDotH)), kkRange);
    float maskSpecularRange = specularRange;
#if EF_HAIR_KK_SHARP_BAND_DEBUG
    maskSpecularRange = smoothstep(
        EF_HAIR_KK_BAND_EDGE_LOW,
        EF_HAIR_KK_BAND_EDGE_HIGH,
        specularRange);
#endif
#if EF_HAIR_KK_ARTICLE_RANGE_FRONT_DEBUG
    // Restore the article's raw KK range only on P.r=0 outer/front hair. This
    // keeps the already accepted rear/inner mask independent from the probe.
    maskSpecularRange = lerp(
        specularRange, maskSpecularRange, hairLayerMask);
#endif
#if EF_HAIR_KK_GOO_LENGTH_FRONT_DEBUG
    // The Goo-style preset uses a reversed Smoothstep with min=0.085, max=0
    // around abs(dot). Apply that width function only to P.r=0 outer/front
    // hair; the accepted P.r=1 rear/inner branch keeps the existing mask.
    float gooLengthBand = EfGooReverseSmoothstep(
        EF_GOO_HIGHLIGHT_LENGTH, abs(tDotH));
#if EF_HAIR_KK_FRONT_BAND_HARDEN_DEBUG
    gooLengthBand = smoothstep(
        EF_HAIR_KK_FRONT_BAND_HARDEN_LOW,
        EF_HAIR_KK_FRONT_BAND_HARDEN_HIGH,
        gooLengthBand);
#endif
    maskSpecularRange = lerp(
        gooLengthBand, maskSpecularRange, hairLayerMask);
#endif
#if EF_HAIR_KK_FRONT_EDGE_TUNE_DEBUG
    // Power below one extends only the raw front/base lobe tail. The rear and
    // inner SharpBand remain frozen through the authored P.r layer mask.
    float frontLowerFadePower = EF_HAIR_KK_FRONT_LOWER_FADE_POWER;
    float frontUpperCutSoftness = EF_HAIR_KK_FRONT_UPPER_CUT_SOFTNESS;
#if EF_HAIR_CONTROLLER_ENABLED
    frontLowerFadePower = EfHairControllerLowerFadePower(frontLowerFadePower);
    frontUpperCutSoftness = EfHairControllerUpperCutSoftness(
        frontUpperCutSoftness);
#endif
    float softenedFrontRange = pow(
        saturate(maskSpecularRange),
        frontLowerFadePower);
#if EF_HAIR_KK_FRONT_LOWER_ONE_SIDED
    // The KK lobe is symmetric, so a raw power changes both edges. Infer the
    // lower half from the signed displacement between the base and cut lobes:
    // the cut-lobe center is the upper side, and the opposite half is lower.
    float cutLobeDisplacement = cutTDotH - tDotH;
    float lowerSideDirection = cutLobeDisplacement >= 0.0 ? 1.0 : -1.0;
    float lowerSideMask = step(0.0, tDotH * lowerSideDirection);
    softenedFrontRange = lerp(
        maskSpecularRange, softenedFrontRange, lowerSideMask);
#endif
    maskSpecularRange = lerp(
        softenedFrontRange, maskSpecularRange, hairLayerMask);
    float upperCutSoftness = lerp(
        frontUpperCutSoftness, 0.1, hairLayerMask);
#else
    float upperCutSoftness = 0.1;
#endif
    float highlightMask = saturate(
        maskSpecularRange
        * (1.0 - smoothstep(0.0, upperCutSoftness, cutLobe)));

    float noV = saturate(dot(hairNormalWS, viewDirWS));
    float noVMask = noV * noV * noV;
#if EF_HAIR_KK_FRONT_NOV_WIDEN_DEBUG
    // Only slow the P.r=0 outer/front visibility falloff. This extends the
    // ring horizontally without changing its dot-space thickness or height.
    float frontNoVPower = EF_HAIR_KK_FRONT_NOV_POWER;
#if EF_HAIR_KK_SHAPE_SCALE_DEBUG
    float highlightScaleX = max(EF_HAIR_HIGHLIGHT_SCALE_X, 0.25);
#if EF_HAIR_CONTROLLER_C5_SHAPE_ENABLED
    highlightScaleX = EfHairControllerHighlightScaleX(highlightScaleX);
#endif
    frontNoVPower /= max(highlightScaleX, 0.25);
#endif
    float frontNoVMask = pow(noV, frontNoVPower);
    noVMask = lerp(frontNoVMask, noVMask, hairLayerMask);
#endif
    highlightMask *= noVMask;
    highlightMask *= saturate(pTexture.g);

    float4 hairLineUvSt = EF_HAIR_LINE_UV_ST;
    float2 hairLineUv = uv * hairLineUvSt.xy + hairLineUvSt.zw;
    float hairLine = saturate(tex2D(EfHairLineSampler, hairLineUv).r);
    highlightMask = saturate(highlightMask * (1.0 - hairLine));
#if EF_HAIR_RD_DARK_LINE_DEBUG
    diffuseKkRange = specularRange;
    diffuseHairLine = hairLine;
    diffusePackedLineMask = saturate(pTexture.a);
#endif

    // Right/forward form an orthonormal basis of world XZ. The dot product of
    // both projected vectors is therefore exactly V.xz dot N.xz, independent
    // of camera yaw; no per-pixel camera-basis reconstruction is necessary.
    float rsU = pow(
        saturate(dot(viewDirWS.xz, hairNormalWS.xz)), EF_HAIR_RS_U_POWER);
    float rsV = saturate(specularRange);
    float3 rsColor = EfSRGBToLinear(
        tex2D(EfHairSpecSampler, float2(rsU, rsV)).rgb);
#if EF_HAIR_KK_GOO_AB_COLOR_DEBUG
    // Exact Goo node ordering: sqrt(max(0, -dot(T,H))) + Offset, then the
    // material's 0.1..0.4 SmoothStep selects linear ColorA/ColorB.
    float gooColorCoordinate = sqrt(saturate(-tDotH))
        + EF_HAIR_GOO_COLOR_LERP_OFFSET;
    float gooColorLerpMin = EF_HAIR_GOO_COLOR_LERP_MIN;
    float gooColorLerpMax = EF_HAIR_GOO_COLOR_LERP_MAX;
    float gooUpperColorMix = saturate(EF_HAIR_GOO_UPPER_COLOR_MIX);
    float3 gooMiddleColor = EF_HAIR_GOO_HIGHLIGHT_COLOR_A;
#if EF_HAIR_CONTROLLER_ENABLED
    gooColorCoordinate += EfHairControllerUpperRatioOffset();
    float gooColorCenter = 0.5 * (gooColorLerpMin + gooColorLerpMax);
    float gooColorHalfWidth = EfHairControllerLayerHalfWidth(
        gooColorLerpMin, gooColorLerpMax);
    gooColorLerpMin = gooColorCenter - gooColorHalfWidth;
    gooColorLerpMax = gooColorCenter + gooColorHalfWidth;
    gooUpperColorMix = EfHairControllerWarmth(gooUpperColorMix);
    gooMiddleColor = EfHairControllerMiddleColor(gooMiddleColor);
#endif
    float gooColorFactor = smoothstep(
        gooColorLerpMin,
        gooColorLerpMax,
        gooColorCoordinate);
    float3 gooUpperColor = lerp(
        EF_HAIR_GOO_HIGHLIGHT_COLOR_A,
        EF_HAIR_GOO_HIGHLIGHT_COLOR_B,
        gooUpperColorMix);
#if EF_HAIR_CONTROLLER_ENABLED
    gooUpperColor = EfHairControllerUpperColor(gooUpperColor);
#endif
    float3 gooLayerColor = lerp(
        gooMiddleColor,
        gooUpperColor,
        gooColorFactor);
#if EF_HAIR_KK_GOO_RS_FUSION
    gooLayerColor += rsColor
        * (saturate(EF_HAIR_GOO_RS_FUSION_STRENGTH)
            * max(EF_HAIR_GOO_RS_DIELECTRIC_GAIN, 0.0));
#endif
    float highlightIntensity = EF_HAIR_HIGHLIGHT_INTENSITY;
#if EF_HAIR_CONTROLLER_ENABLED
    highlightIntensity = EfHairControllerHighlightIntensity(highlightIntensity);
#endif
    return gooLayerColor * highlightMask * highlightIntensity;
#else
    float highlightIntensity = EF_HAIR_HIGHLIGHT_INTENSITY;
#if EF_HAIR_CONTROLLER_ENABLED
    highlightIntensity = EfHairControllerHighlightIntensity(highlightIntensity);
#endif
    return rsColor * highlightMask * EF_HAIR_RS_GAIN * highlightIntensity;
#endif
}
#endif

// ── Pixel: Hair ─────────────────────────────────────────
float4 EfMainPS(EfVaryings input, float facing : VFACE,
    uniform bool useTexture, uniform bool useSelfShadow) : COLOR0
{
    float2 uv = input.uv;

#if EF_DEBUG_SOLID
    return float4(1.0, 0.0, 1.0, 1.0); // load/cache sanity check
#endif

    // Base albedo (linearized). MaterialDiffuse tints when no texture is bound.
    float4 mainTex = float4(saturate(MaterialDiffuse.rgb), MaterialDiffuse.a);
    if (useTexture || EF_HAIR_BASE_COLOR_ONLY || EF_HAIR_BASE_COLOR_AO_ONLY
        || EF_HAIR_GEOMETRY_NOL_DEBUG || EF_HAIR_MMD_NOL_DEBUG
        || EF_HAIR_MMD_DIFFUSE_DEBUG || EF_HAIR_HN_RG_DIFFUSE_DEBUG
        || EF_HAIR_HN_BA_SOFT_NORMAL_DEBUG
        || EF_HAIR_HN_P_R_BLEND_DEBUG
        || EF_HAIR_KK_RANGE_DEBUG
        || EF_HAIR_KK_NOISE_DEBUG
        || EF_HAIR_RD_DIFFUSE_DEBUG || EF_HAIR_RD_ALPHA_DIFFUSE_DEBUG
        || EF_HAIR_RD_AMBIENT_DIFFUSE_DEBUG || EF_HAIR_RD_BASE_LIGHTNESS_DEBUG
        || EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG
        || EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG
        || EF_HAIR_RD_AO_DEBUG || EF_HAIR_RD_TOP_LIGHT_DEBUG
        || EF_HAIR_RD_DARK_LINE_DEBUG
        || EF_HAIR_P_DEBUG) {
        float4 texel = tex2D(EfMainSampler, uv);
        mainTex.rgb = EfSRGBToLinear(texel.rgb);
        mainTex.a = texel.a;
    }
#if EF_USE_ALPHA_CLIP
    clip(mainTex.a - EF_ALPHA_CUTOFF);
#endif
#if EF_HAIR_P_DEBUG
    float4 pDebug = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    pDebug.rgb = EfSRGBToLinear(pDebug.rgb);
#endif
#if EF_HAIR_P_DEBUG_CHANNEL == 0
    float pChannel = pDebug.r;
#elif EF_HAIR_P_DEBUG_CHANNEL == 1
    float pChannel = pDebug.g;
#elif EF_HAIR_P_DEBUG_CHANNEL == 2
    float pChannel = pDebug.b;
#else
    float pChannel = pDebug.a;
#endif
#if EF_HAIR_P_DEBUG_INVERT
    pChannel = 1.0 - pChannel;
#endif
    return float4(EfLinearToSRGB(pChannel.xxx), mainTex.a);
#endif
#if EF_HAIR_BASE_COLOR_ONLY
    float3 baseOnly = mainTex.rgb * EF_BASE_COLOR;
    baseOnly = pow(max(baseOnly, 1e-5), EF_BASE_COLOR_POW);
    return float4(EfLinearToSRGB(baseOnly), mainTex.a);
#endif
#if EF_HAIR_BASE_COLOR_AO_ONLY
    float4 pAO = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    pAO.rgb = EfSRGBToLinear(pAO.rgb);
#endif
    float aoOnly = pow(saturate(pAO.b), EF_AO_STRENGTH);
    float3 baseAO = mainTex.rgb * EF_BASE_COLOR;
    baseAO = pow(max(baseAO, 1e-5), EF_BASE_COLOR_POW) * aoOnly;
    return float4(EfLinearToSRGB(baseAO), mainTex.a);
#endif
#if EF_HAIR_GEOMETRY_NOL_DEBUG
    float geometryFaceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometryNormal = normalize(input.normalWS) * geometryFaceSign;
    float3 geometryLight = normalize(EF_GEOMETRY_NOL_LIGHT_DIR);
    float geometryNoL = saturate(dot(geometryNormal, geometryLight) * 0.5 + 0.5);
    return float4(EfLinearToSRGB(geometryNoL.xxx), mainTex.a);
#endif
#if EF_HAIR_MMD_NOL_DEBUG
    float mmdFaceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 mmdGeometryNormal = normalize(input.normalWS) * mmdFaceSign;
    float3 mmdSurfaceToLight = EfNormalizeOr(
        -LightDirection, float3(0.0, 0.70710678, -0.70710678));
    float mmdNoL = saturate(dot(mmdGeometryNormal, mmdSurfaceToLight) * 0.5 + 0.5);
    return float4(EfLinearToSRGB(mmdNoL.xxx), mainTex.a);
#endif
#if EF_HAIR_MMD_DIFFUSE_DEBUG
    float mmdDiffuseFaceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 mmdDiffuseNormal = normalize(input.normalWS) * mmdDiffuseFaceSign;
    float3 mmdDiffuseLight = EfNormalizeOr(
        -LightDirection, float3(0.0, 0.70710678, -0.70710678));
    float mmdDiffuseNoL = saturate(dot(mmdDiffuseNormal, mmdDiffuseLight) * 0.5 + 0.5);
    float3 mmdDiffuseBase = mainTex.rgb * EF_BASE_COLOR;
    mmdDiffuseBase = pow(max(mmdDiffuseBase, 1e-5), EF_BASE_COLOR_POW);
    float3 mmdDiffuse = mmdDiffuseBase * mmdDiffuseNoL * max(LightColor, 0.0);
    return float4(EfLinearToSRGB(mmdDiffuse), mainTex.a);
#endif
#if EF_HAIR_HN_RG_DIFFUSE_DEBUG
    float hnFaceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 hnGeometryNormal = normalize(input.normalWS);
    float3 hnTangentWS, hnBitangentWS;
    bool hnTbnValid;
    EfReconstructTB(input.positionWS, hnGeometryNormal, uv,
        hnTangentWS, hnBitangentWS, hnTbnValid);
    if (!hnTbnValid) {
        return float4(1.0, 0.0, 1.0, mainTex.a);
    }

    float4 hnTexture = tex2D(EfNormalSampler, uv);
    float3 hnNormalTS = EfUnpackNormal(hnTexture.rg, EF_BUMP_SCALE);
    float3x3 hnTBN = float3x3(hnTangentWS, hnBitangentWS, hnGeometryNormal);
    float3 hnNormalWS = normalize(mul(hnNormalTS, hnTBN)) * hnFaceSign;
    float3 hnLightWS = EfNormalizeOr(
        -LightDirection, float3(0.0, 0.70710678, -0.70710678));
    float hnNoL = saturate(dot(hnNormalWS, hnLightWS) * 0.5 + 0.5);
    float3 hnBase = mainTex.rgb * EF_BASE_COLOR;
    hnBase = pow(max(hnBase, 1e-5), EF_BASE_COLOR_POW);
    float3 hnDiffuse = hnBase * hnNoL * max(LightColor, 0.0);
    return float4(EfLinearToSRGB(hnDiffuse), mainTex.a);
#endif
#if EF_HAIR_HN_BA_SOFT_NORMAL_DEBUG
    float3 softGeometryNormal = normalize(input.normalWS);
    float3 softTangentWS, softBitangentWS;
    bool softTbnValid;
    EfReconstructTB(input.positionWS, softGeometryNormal, uv,
        softTangentWS, softBitangentWS, softTbnValid);
    if (!softTbnValid) {
        return float4(1.0, 0.0, 1.0, mainTex.a);
    }

    float4 softNormalTexture = tex2D(EfNormalSampler, uv);
    float3 softNormalTS = EfUnpackNormal(softNormalTexture.ba, 1.0);
    float3x3 softTBN = float3x3(
        softTangentWS, softBitangentWS, softGeometryNormal);
    float3 softNormalWS = normalize(mul(softNormalTS, softTBN));
    float3 softNormalDebug = softNormalWS * 0.5 + 0.5;
    return float4(saturate(softNormalDebug), mainTex.a);
#endif
#if EF_HAIR_HN_P_R_BLEND_DEBUG
    float3 blendGeometryNormal = normalize(input.normalWS);
    float3 blendTangentWS, blendBitangentWS;
    bool blendTbnValid;
    EfReconstructTB(input.positionWS, blendGeometryNormal, uv,
        blendTangentWS, blendBitangentWS, blendTbnValid);
    if (!blendTbnValid) {
        return float4(1.0, 0.0, 1.0, mainTex.a);
    }

    float4 blendNormalTexture = tex2D(EfNormalSampler, uv);
    float3 blendRegularTS = EfUnpackNormal(blendNormalTexture.rg, EF_BUMP_SCALE);
    float3 blendSoftTS = EfUnpackNormal(blendNormalTexture.ba, 1.0);
    float3x3 blendTBN = float3x3(
        blendTangentWS, blendBitangentWS, blendGeometryNormal);
    float3 blendRegularWS = normalize(mul(blendRegularTS, blendTBN));
    float3 blendSoftWS = normalize(mul(blendSoftTS, blendTBN));

    float4 blendP = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    blendP.rgb = EfSRGBToLinear(blendP.rgb);
#endif
    float frontHair = saturate(blendP.r);
    float3 blendedHairNormalWS = normalize(
        lerp(blendSoftWS, blendRegularWS, frontHair));
    float3 blendedHairNormalDebug = blendedHairNormalWS * 0.5 + 0.5;
    return float4(saturate(blendedHairNormalDebug), mainTex.a);
#endif
#if EF_HAIR_KK_RANGE_DEBUG
    float3 kkGeometryNormal = normalize(input.normalWS);
    float3 kkTangentWS, kkBitangentWS;
    bool kkTbnValid;
    EfReconstructTB(input.positionWS, kkGeometryNormal, uv,
        kkTangentWS, kkBitangentWS, kkTbnValid);
    if (!kkTbnValid) {
        return float4(1.0, 0.0, 1.0, mainTex.a);
    }

    float4 kkNormalTexture = tex2D(EfNormalSampler, uv);
    float3 kkRegularTS = EfUnpackNormal(kkNormalTexture.rg, EF_BUMP_SCALE);
    float3 kkSoftTS = EfUnpackNormal(kkNormalTexture.ba, 1.0);
    float3x3 kkTBN = float3x3(kkTangentWS, kkBitangentWS, kkGeometryNormal);
    float3 kkRegularWS = normalize(mul(kkRegularTS, kkTBN));
    float3 kkSoftWS = normalize(mul(kkSoftTS, kkTBN));

    float4 kkP = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    kkP.rgb = EfSRGBToLinear(kkP.rgb);
#endif
    float3 kkHairNormalWS = normalize(
        lerp(kkSoftWS, kkRegularWS, saturate(kkP.r)));

    float3 kkViewDirWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float3 kkCameraForwardWS = EfNormalizeOr(
        CameraPosition - EF_FACE_CENTER, kkViewDirWS);
    float3 kkLightDirWS = EfNormalizeOr(
        kkCameraForwardWS + float3(0.0, EF_HAIR_SPEC_KEY_UP, 0.0),
        kkCameraForwardWS);
    float3 kkHalfDirWS = EfNormalizeOr(
        kkViewDirWS + kkLightDirWS, kkViewDirWS);

    float3 kkFakeBitangentRaw = cross(
        float3(0.0, 1.0, 0.0), kkHairNormalWS);
    float3 kkFakeBitangentWS = EfNormalizeOr(
        kkFakeBitangentRaw, kkTangentWS);
    float3 kkHairTangentWS = EfNormalizeOr(
        cross(kkHairNormalWS, kkFakeBitangentWS), kkBitangentWS);
    float kkTdotH = dot(kkHairTangentWS, kkHalfDirWS);
    float kkSinTH = sqrt(saturate(1.0 - kkTdotH * kkTdotH));
    float kkSpecularRange = pow(kkSinTH, EF_HAIR_KK_RANGE);
    return float4(saturate(kkSpecularRange).xxx, mainTex.a);
#endif
#if EF_HAIR_KK_NOISE_DEBUG
    float3 noiseGeometryNormal = normalize(input.normalWS);
    float3 noiseTangentWS, noiseBitangentWS;
    bool noiseTbnValid;
    EfReconstructTB(input.positionWS, noiseGeometryNormal, uv,
        noiseTangentWS, noiseBitangentWS, noiseTbnValid);
    if (!noiseTbnValid) {
        return float4(1.0, 0.0, 1.0, mainTex.a);
    }

    float4 noiseNormalTexture = tex2D(EfNormalSampler, uv);
    float3 noiseRegularTS = EfUnpackNormal(noiseNormalTexture.rg, EF_BUMP_SCALE);
    float3 noiseSoftTS = EfUnpackNormal(noiseNormalTexture.ba, 1.0);
    float3x3 noiseTBN = float3x3(
        noiseTangentWS, noiseBitangentWS, noiseGeometryNormal);
    float3 noiseRegularWS = normalize(mul(noiseRegularTS, noiseTBN));
    float3 noiseSoftWS = normalize(mul(noiseSoftTS, noiseTBN));

    float4 noiseP = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    noiseP.rgb = EfSRGBToLinear(noiseP.rgb);
#endif
    float hairLayerMask = saturate(noiseP.r);
#if EF_HAIR_KK_SPHERE_OUTER_DEBUG
    float3 sphereHairNormalWS = EfNormalizeOr(
        input.positionWS - EF_FACE_CENTER, noiseSoftWS);
    float3 outerHairNormalWS = normalize(lerp(
        sphereHairNormalWS,
        noiseSoftWS,
        saturate(EF_HAIR_KK_SPHERE_HN_BLEND)
    ));
    float3 noiseHairNormalWS = normalize(
        lerp(outerHairNormalWS, noiseRegularWS, hairLayerMask));
#else
    float3 noiseHairNormalWS = normalize(
        lerp(noiseSoftWS, noiseRegularWS, hairLayerMask));
#endif

    float3 noiseViewDirWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float3 noiseCameraForwardWS = EfNormalizeOr(
        CameraPosition - EF_FACE_CENTER, noiseViewDirWS);
    float3 noiseLightDirWS = EfNormalizeOr(
        noiseCameraForwardWS + float3(0.0, EF_HAIR_SPEC_KEY_UP, 0.0),
        noiseCameraForwardWS);
    float3 noiseHalfDirWS = EfNormalizeOr(
        noiseViewDirWS + noiseLightDirWS, noiseViewDirWS);

    float3 noiseFakeBitangentRaw = cross(
        float3(0.0, 1.0, 0.0), noiseHairNormalWS);
    float3 noiseFakeBitangentWS = EfNormalizeOr(
        noiseFakeBitangentRaw, noiseTangentWS);
    float3 noiseBaseHairTangentWS = EfNormalizeOr(
        cross(noiseHairNormalWS, noiseFakeBitangentWS), noiseBitangentWS);

    // The texture is centered around 0.5 (measured mean 126.3/255), so its
    // red channel is a signed perturbation field rather than a positive mask.
    float anisotropicNoise = tex2D(EfHairAnisoNoiseSampler, uv).r * 2.0 - 1.0;
    float3 anisotropicOffset = noiseHairNormalWS
        * (anisotropicNoise * EF_HAIR_ANISO_NOISE_STRENGTH
            + EF_HAIR_ANISO_BASE_OFFSET);
    float3 noiseHairTangentWS = EfNormalizeOr(
        noiseBaseHairTangentWS + anisotropicOffset, noiseBaseHairTangentWS);

    float noiseTdotH = dot(noiseHairTangentWS, noiseHalfDirWS);
    float noiseSinTH = sqrt(saturate(1.0 - noiseTdotH * noiseTdotH));
    float noiseSpecularRange = pow(noiseSinTH, EF_HAIR_KK_RANGE);
#if EF_HAIR_KK_CUT_MASK_DEBUG || EF_HAIR_KK_CUT_COMPOSITE_DEBUG
    // Asset-native H4 formula: the normalized H3 tangent receives the complete
    // noise/base offset again, plus a separately tunable relative cut delta.
    float3 anisotropicCutOffset = noiseHairNormalWS
        * (anisotropicNoise * EF_HAIR_ANISO_NOISE_STRENGTH
            + EF_HAIR_ANISO_BASE_OFFSET + EF_HAIR_ANISO_CUT_OFFSET);
    float3 cutHairTangentWS = EfNormalizeOr(
        noiseHairTangentWS + anisotropicCutOffset, noiseHairTangentWS);
    float cutTdotH = dot(cutHairTangentWS, noiseHalfDirWS);
    float cutSinTH = sqrt(saturate(1.0 - cutTdotH * cutTdotH));
    float cutLobe = pow(cutSinTH, EF_HAIR_KK_RANGE);
    float cutMask = 1.0 - smoothstep(0.0, 0.1, cutLobe);
#if EF_HAIR_KK_CUT_COMPOSITE_DEBUG
    float cutSpecularRange = saturate(noiseSpecularRange * cutMask);
#if EF_HAIR_KK_NOV3_DEBUG
    float hairNoV = saturate(dot(noiseHairNormalWS, noiseViewDirWS));
    float forwardFacingMask = hairNoV * hairNoV * hairNoV;
    cutSpecularRange = saturate(cutSpecularRange * forwardFacingMask);
#endif
#if EF_HAIR_KK_PG_MASK_DEBUG
    float anisotropicRhythmMask = saturate(noiseP.g);
    cutSpecularRange = saturate(cutSpecularRange * anisotropicRhythmMask);
#endif
#if EF_HAIR_KK_HAIRLINE_MASK_DEBUG
    float4 hairLineUvSt = EF_HAIR_LINE_UV_ST;
    float2 hairLineUv = uv * hairLineUvSt.xy + hairLineUvSt.zw;
    float hairLineMask = saturate(tex2D(EfHairLineSampler, hairLineUv).r);
    cutSpecularRange = saturate(cutSpecularRange * (1.0 - hairLineMask));
#endif
#if EF_HAIR_KK_RS_COLOR_DEBUG || EF_HAIR_KK_RS_SAMPLE_ONLY_DEBUG \
    || EF_HAIR_KK_RS_GAINED_DEBUG
    float rsU = pow(
        saturate(dot(noiseViewDirWS.xz, noiseHairNormalWS.xz)),
        EF_HAIR_RS_U_POWER);
    float rsV = saturate(noiseSpecularRange);
    float3 rsSample = tex2D(EfHairSpecSampler, float2(rsU, rsV)).rgb;
#if EF_HAIR_KK_RS_SAMPLE_ONLY_DEBUG
    return float4(rsSample, mainTex.a);
#else
    float3 rsColor = EfSRGBToLinear(rsSample);
#if EF_HAIR_KK_RS_GAINED_DEBUG
    float3 gainedRsHighlight = rsColor * cutSpecularRange * EF_HAIR_RS_GAIN;
    return float4(EfLinearToSRGB(gainedRsHighlight), mainTex.a);
#else
    return float4(rsColor * cutSpecularRange, mainTex.a);
#endif
#endif
#endif
    return float4(cutSpecularRange.xxx, mainTex.a);
#else
    return float4(saturate(cutMask).xxx, mainTex.a);
#endif
#else
    return float4(saturate(noiseSpecularRange).xxx, mainTex.a);
#endif
#endif
#if EF_HAIR_RD_DIFFUSE_DEBUG || EF_HAIR_RD_ALPHA_DIFFUSE_DEBUG \
    || EF_HAIR_RD_AMBIENT_DIFFUSE_DEBUG || EF_HAIR_RD_BASE_LIGHTNESS_DEBUG \
    || EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG || EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG \
    || EF_HAIR_RD_AO_DEBUG || EF_HAIR_RD_TOP_LIGHT_DEBUG \
    || EF_HAIR_RD_DARK_LINE_DEBUG
    float rdFaceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 rdGeometryNormal = normalize(input.normalWS);
    float3 rdNormalWS = rdGeometryNormal * rdFaceSign;
    float3 rdTangentWS, rdBitangentWS;
    bool rdTbnValid;
    EfReconstructTB(input.positionWS, rdGeometryNormal, uv,
        rdTangentWS, rdBitangentWS, rdTbnValid);
    if (rdTbnValid) {
        float4 rdNormalTexture = tex2D(EfNormalSampler, uv);
        float3 rdNormalTS = EfUnpackNormal(rdNormalTexture.rg, EF_BUMP_SCALE);
        float3x3 rdTBN = float3x3(rdTangentWS, rdBitangentWS, rdGeometryNormal);
        rdNormalWS = normalize(mul(rdNormalTS, rdTBN)) * rdFaceSign;
    }

    float3 rdLightWS = EfNormalizeOr(
        -LightDirection, float3(0.0, 0.70710678, -0.70710678));
    float rdHalfLambert = saturate(dot(rdNormalWS, rdLightWS) * 0.5 + 0.5);
    float rdAttenuation = rdHalfLambert;
#if EF_HAIR_RD_HGSHADOW_DEBUG
    float rdHgVisibility = EfSampleHgShadowHsSnow(input.screenPos, useSelfShadow);
#if EF_HAIR_RD_SELF_SHADOW_DEBUG
    rdHgVisibility = EfSelfShadowAttenuationHsSnow(rdHgVisibility);
#endif
    rdAttenuation *= rdHgVisibility;
#endif
    float rdU = saturate(EfGooSigmoidSharp(rdAttenuation,
        EF_RD_HALFLAMBERT_CENTER, EF_RD_HALFLAMBERT_SHARP));
    float4 rdSample = tex2D(EfRampSampler, float2(rdU, 0.5));
    float3 rdColor = EfSRGBToLinear(rdSample.rgb);
#if EF_HAIR_RD_BASE_LIGHTNESS_DEBUG || EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG \
    || EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG || EF_HAIR_RD_AO_DEBUG
    float3 rdShadowFloor = float3(
        EF_RD_DIRECT_SHADOW_FLOOR,
        EF_RD_DIRECT_SHADOW_FLOOR,
        EF_RD_DIRECT_SHADOW_FLOOR
    );
    rdColor = max(rdColor, rdShadowFloor);
#endif
#if EF_HAIR_RD_AO_DEBUG
    float4 rdP = tex2D(EfOrmSampler, uv);
#if EF_HAIR_P_MATCH_BLEND_SRGB
    rdP.rgb = EfSRGBToLinear(rdP.rgb);
#endif
    float rdAo = pow(saturate(rdP.b), EF_AO_STRENGTH);
#endif

    float3 rdBase = mainTex.rgb * EF_BASE_COLOR;
    rdBase = pow(max(rdBase, 1e-5), EF_BASE_COLOR_POW);
    float3 rdMainLightColor = max(LightColor, 0.0);
#if EF_HAIR_NORMALIZE_MMD_LIGHT_INTENSITY
    // Endfield/Goo uses the main light hue here; the authored RD/controller
    // chain owns brightness. MMD's default light value must not dim the
    // complete hair material a second time.
    rdMainLightColor /= max(EfLuminance(rdMainLightColor), 0.001);
#endif
    float3 rdDiffuse = rdBase * rdColor * rdMainLightColor;
#if EF_HAIR_RD_AMBIENT_DIFFUSE_DEBUG
    float3 rdAmbient = rdBase * saturate(MaterialAmbient.rgb)
        * EF_MMD_AMBIENT_COLOR * EF_MMD_AMBIENT_SCALE * EF_MMD_AMBIENT_STRENGTH;
    rdDiffuse += rdAmbient;
#endif
#if EF_HAIR_RD_ALPHA_DIFFUSE_DEBUG || EF_HAIR_RD_AMBIENT_DIFFUSE_DEBUG \
    || EF_HAIR_RD_BASE_LIGHTNESS_DEBUG || EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG \
    || EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG || EF_HAIR_RD_AO_DEBUG
    float rdShadowBrightness = smoothstep(
        EF_RD_GLOBAL_SHADOW_MIN, EF_RD_GLOBAL_SHADOW_MAX, rdSample.a);
    rdDiffuse *= rdShadowBrightness;
#endif
#if EF_HAIR_RD_MYZMD_DARK_FLOOR_DEBUG || EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG \
    || EF_HAIR_RD_AO_DEBUG
    float3 rdDarkBase = rdBase * EF_ALBEDO_DARK_STRENGTH;
    float rdDarkLuminance = dot(rdDarkBase, float3(0.212672904, 0.715152204, 0.0721750036));
    rdDarkBase = lerp(rdDarkLuminance.xxx, rdDarkBase, EF_ALBEDO_DARK_SATURATION);
    float3 rdDeepDarkFloor = rdDarkBase * EF_DEEP_DARK_STRENGTH
        * rdMainLightColor;
    rdDiffuse = max(rdDiffuse, rdDeepDarkFloor);
#endif
#if EF_HAIR_RD_BRIGHT_DARK_BALANCE_DEBUG || EF_HAIR_RD_AO_DEBUG
    float rdToneRegion = saturate(rdSample.a);
    float rdToneScale = lerp(
        EF_RD_DARK_TONE_LINEAR_SCALE,
        EF_RD_LIGHT_TONE_LINEAR_SCALE,
        rdToneRegion
    );
    rdDiffuse *= rdToneScale;
#endif
#if EF_HAIR_RD_AO_DEBUG
    float3 rdAoFloor = rdDeepDarkFloor * EF_RD_DARK_TONE_LINEAR_SCALE;
    rdDiffuse = max(rdDiffuse * rdAo, rdAoFloor);
#endif
#if EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG
#if EF_HAIR_RD_DARK_LINE_DEBUG
    float rdDiffuseKkRange;
    float rdDiffuseHairLine;
    float rdDiffusePackedLineMask;
    float3 rdKkHighlight = EfAssetKkRsHighlightLinear(
        input, rdDiffuseKkRange, rdDiffuseHairLine,
        rdDiffusePackedLineMask);
#else
    float3 rdKkHighlight = EfAssetKkRsHighlightLinear(input);
#endif
#endif
#if EF_HAIR_RD_TOP_LIGHT_DEBUG
    float rdTopLightOffset = EF_HAIR_TOP_LIGHT_OFFSET;
    float rdTopLightStrength = EF_HAIR_TOP_LIGHT_STRENGTH;
#if EF_HAIR_CONTROLLER_C5_DIFFUSE_ENABLED
    rdTopLightOffset = EfHairControllerTopLightOffset(rdTopLightOffset);
    rdTopLightStrength = EfHairControllerTopLightStrength(
        rdTopLightStrength);
#endif
#if EF_HAIR_TOP_LIGHT_CONE_DEBUG
    // The article Half-Lambert still contributes at N.y=0 and therefore lifts
    // the entire hairstyle. Use a geometric-normal-led upward cone so only
    // clearly upward-facing crown surfaces receive the fill.
    float rdTopFacing = saturate(lerp(
        rdGeometryNormal.y * rdFaceSign,
        rdNormalWS.y,
        saturate(EF_HAIR_TOP_LIGHT_NORMAL_DETAIL)));
    float rdTopThreshold = EF_HAIR_TOP_LIGHT_THRESHOLD - rdTopLightOffset;
    float rdTopSoftness = max(EF_HAIR_TOP_LIGHT_SOFTNESS, 0.001);
    float rdUpLambert = smoothstep(
        rdTopThreshold, rdTopThreshold + rdTopSoftness, rdTopFacing);
#else
    float rdUpLambert = saturate(
        rdNormalWS.y * 0.5 + 0.5 + rdTopLightOffset);
#endif
    rdDiffuse += rdBase * EF_HAIR_TOP_LIGHT_COLOR
        * rdUpLambert * max(rdTopLightStrength, 0.0);
#endif
#if EF_HAIR_RD_DARK_LINE_DEBUG && EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG
    float rdDarkLineStrength = EF_HAIR_DARK_LINE_STRENGTH;
    float rdDarkLineSaturation = EF_HAIR_DARK_LINE_SATURATION;
#if EF_HAIR_CONTROLLER_C5_DIFFUSE_ENABLED
    rdDarkLineStrength = EfHairControllerDarkLineStrength(
        rdDarkLineStrength);
    rdDarkLineSaturation = EfHairControllerDarkLineSaturation(
        rdDarkLineSaturation);
#endif
    float rdLineRange = lerp(
        1.0, 1.0 - rdDiffuseHairLine, saturate(rdDarkLineStrength));
    float rdLineSpecularProtect = saturate(
        rdDiffuseKkRange * EF_HAIR_DARK_LINE_SPECULAR_PROTECT);
    float rdLineMask = saturate(
        1.0 - rdDiffusePackedLineMask * (1.0 - rdLineRange)
            * (1.0 - rdLineSpecularProtect));
    float3 rdLineColor = rdDiffuse * rdLineMask;
    float rdLineLuminance = dot(
        rdLineColor, float3(0.2126, 0.7152, 0.0722));
    rdDiffuse = lerp(
        rdLineLuminance.xxx, rdLineColor,
        saturate(rdDarkLineSaturation));
#endif
#if EF_HAIR_CONTROLLER_ENABLED && EF_HAIR_CONTROLLER_BASE_GRADE_ENABLED
#if EF_HAIR_CONTROLLER_BASE_GRADE_VERTEX_PRECOMPUTE
    float3 rdGraded = max(rdDiffuse * input.baseGrade.rgb, 0.0);
    float rdGradeLuminance = dot(
        rdGraded, float3(0.2126, 0.7152, 0.0722));
    rdDiffuse = max(lerp(
        rdGradeLuminance.xxx, rdGraded, input.baseGrade.a), 0.0);
#else
    rdDiffuse = EfHairControllerApplyBaseGrade(rdDiffuse);
#endif
#endif
#if EF_HAIR_RD_GOO_DEPTH_FRESNEL_RIM_DEBUG
    float rdGooDepthFresnelDepth = EfGooDepthRim(
        input.positionWS, rdGeometryNormal, input.screenPos);
    float3 rdGooDepthFresnelViewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float rdGooDepthFresnelNoV = saturate(
        dot(rdNormalWS, rdGooDepthFresnelViewWS));
    float rdGooDepthFresnel = pow(
        saturate(1.0 - rdGooDepthFresnelNoV), EF_GOO_RIM_FRESNEL_POWER);
    float rdGooDepthFresnelMask = rdGooDepthFresnelDepth * rdGooDepthFresnel;
    return float4(saturate(rdGooDepthFresnelMask).xxx, mainTex.a);
#endif
#if EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_RIM_DEBUG
    float rdGooVerticalDepth = EfGooDepthRim(
        input.positionWS, rdGeometryNormal, input.screenPos);
    float3 rdGooVerticalViewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float rdGooVerticalNoV = saturate(dot(rdNormalWS, rdGooVerticalViewWS));
    float rdGooVerticalFresnel = pow(
        saturate(1.0 - rdGooVerticalNoV), EF_GOO_RIM_FRESNEL_POWER);
    // Goo uses Geometry Normal.Z in Blender's Z-up world; MMD world-up is Y.
    float rdGooVerticalAttenuation = rdGeometryNormal.y * 0.5 + 0.5;
    float rdGooVerticalMask = rdGooVerticalDepth * rdGooVerticalFresnel
        * rdGooVerticalAttenuation;
    return float4(saturate(rdGooVerticalMask).xxx, mainTex.a);
#endif
#if EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_RIM_DEBUG
    float rdGooDirectionalDepth = EfGooDepthRim(
        input.positionWS, rdGeometryNormal, input.screenPos);
    float3 rdGooDirectionalViewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float rdGooDirectionalNoV = saturate(dot(rdNormalWS, rdGooDirectionalViewWS));
    float rdGooDirectionalFresnel = pow(
        saturate(1.0 - rdGooDirectionalNoV), EF_GOO_RIM_FRESNEL_POWER);
    float rdGooDirectionalVertical = rdGeometryNormal.y * 0.5 + 0.5;
    float rdGooDirectionalNoL = saturate(dot(rdNormalWS, rdLightWS));
    float rdGooDirectionalAttenuation = lerp(
        1.0 - EF_GOO_RIM_DIRECTIONAL_ATTENUATION,
        1.0,
        rdGooDirectionalNoL
    );
    float rdGooDirectionalMask = rdGooDirectionalDepth
        * rdGooDirectionalFresnel * rdGooDirectionalVertical
        * rdGooDirectionalAttenuation;
    return float4(saturate(rdGooDirectionalMask).xxx, mainTex.a);
#endif
#if EF_HAIR_RD_GOO_DEPTH_FRESNEL_VERTICAL_DIRECTIONAL_LIMITED_RIM_DEBUG
    float rdGooLimitedDepth = EfGooDepthRim(
        input.positionWS, rdGeometryNormal, input.screenPos);
    float3 rdGooLimitedViewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float rdGooLimitedNoV = saturate(dot(rdNormalWS, rdGooLimitedViewWS));
    float rdGooLimitedFresnel = pow(
        saturate(1.0 - rdGooLimitedNoV), EF_GOO_RIM_FRESNEL_POWER);
    float rdGooLimitedVertical = rdGeometryNormal.y * 0.5 + 0.5;
    float rdGooLimitedNoL = saturate(dot(rdNormalWS, rdLightWS));
    float rdGooLimitedDirectional = lerp(
        1.0 - EF_GOO_RIM_DIRECTIONAL_ATTENUATION,
        1.0,
        rdGooLimitedNoL
    );
    // Goo uses a World-to-Object Vector transform and clamps local X.
    float3 rdGooLimitedNormalOS = mul(
        rdNormalWS, (float3x3)matWorldInverse);
    float rdGooLimitation = saturate(rdGooLimitedNormalOS.x);
    float rdGooLimitationMix = lerp(
        1.0, rdGooLimitation, saturate(EF_GOO_RIM_LIMITATION_STRENGTH));
    float rdGooLimitedMask = rdGooLimitedDepth * rdGooLimitedFresnel
        * rdGooLimitedVertical * rdGooLimitedDirectional * rdGooLimitationMix;
    return float4(saturate(rdGooLimitedMask).xxx, mainTex.a);
#endif
#if EF_HAIR_RD_GOO_RIM_COMPOSITE_DEBUG
    float rdGooCompositeDepth = EfGooDepthRim(
        input.positionWS, rdGeometryNormal, input.screenPos);
    float3 rdGooCompositeViewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float rdGooCompositeNoV = saturate(dot(rdNormalWS, rdGooCompositeViewWS));
    float rdGooCompositeFresnel = pow(
        saturate(1.0 - rdGooCompositeNoV), EF_GOO_RIM_FRESNEL_POWER);
    float rdGooCompositeVertical = rdGeometryNormal.y * 0.5 + 0.5;
    float rdGooCompositeNoL = saturate(dot(rdNormalWS, rdLightWS));
    float rdGooCompositeDirectional = lerp(
        1.0 - EF_GOO_RIM_DIRECTIONAL_ATTENUATION,
        1.0,
        rdGooCompositeNoL
    );
    float3 rdGooCompositeNormalOS = mul(
        rdNormalWS, (float3x3)matWorldInverse);
    float rdGooCompositeLimitation = saturate(rdGooCompositeNormalOS.x);
    float rdGooCompositeLimitationMix = lerp(
        1.0,
        rdGooCompositeLimitation,
        saturate(EF_GOO_RIM_LIMITATION_STRENGTH)
    );
    float rdGooCompositeMask = rdGooCompositeDepth * rdGooCompositeFresnel
        * rdGooCompositeVertical * rdGooCompositeDirectional
        * rdGooCompositeLimitationMix;
    rdDiffuse += EF_GOO_RIM_COLOR * EF_GOO_RIM_COLOR_STRENGTH
        * rdGooCompositeMask
#if EF_HAIR_CONTROLLER_ENABLED
        * EfHairControllerRimMultiplier()
#endif
        ;
#endif
#if EF_HAIR_RD_GOO_DEPTH_RIM_DEBUG
    float rdGooDepthRim = EfGooDepthRim(
        input.positionWS, rdGeometryNormal, input.screenPos);
    return float4(saturate(rdGooDepthRim).xxx, mainTex.a);
#endif
#if EF_HAIR_RD_GOO_FRESNEL_RIM_DEBUG
    float3 rdViewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float rdNoV = saturate(dot(rdNormalWS, rdViewWS));
    float rdGooFresnelRim = pow(
        saturate(1.0 - rdNoV), EF_GOO_RIM_FRESNEL_POWER);
    rdDiffuse += EF_GOO_RIM_COLOR * EF_GOO_RIM_COLOR_STRENGTH * rdGooFresnelRim;
#endif
#if EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG
    rdDiffuse += rdKkHighlight;
#endif
    return float4(EfLinearToSRGB(rdDiffuse), mainTex.a);
#endif

    // Canonical disabled-ORM default: R=0(mask) G=1(reflec) B=1(AO) A=0(rough=1).
    float4 ormTex = float4(0.0, 1.0, 1.0, 0.0);
#if EF_USE_ORM
    ormTex = tex2D(EfOrmSampler, uv);
#endif

    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geomN = normalize(input.normalWS);

    // TBN from screen derivatives (no PMX tangent).
    float3 tangentWS, bitangentWS; bool tbnValid;
    EfReconstructTB(input.positionWS, geomN, uv, tangentWS, bitangentWS, tbnValid);
    float3x3 TBN = float3x3(tangentWS, bitangentWS, geomN);

    // Detail normal (rg) and smooth "HN" normal (ba).
    float3 N = geomN;
    float3 HN = geomN;
#if EF_HAIR_SPEC_MODEL == 2
    float3 gooHN = geomN;
#endif
#if EF_USE_NORMAL_MAP
    float4 normalTex = tex2D(EfNormalSampler, uv);
    if (tbnValid) {
        float3 nTS = EfUnpackNormal(normalTex.xy, EF_BUMP_SCALE);
        N = normalize(mul(nTS, TBN));
        float3 nTS_H = EfUnpackNormal(normalTex.zw, EF_BUMP_SCALE);
        HN = normalize(mul(nTS_H, TBN));
#if EF_HAIR_SPEC_MODEL == 2
        float3 gooHTS = EfGooUnpackHNormal(normalTex.zw, EF_GOO_HNORMAL_STRENGTH);
        gooHN = normalize(mul(gooHTS, TBN));
#endif
    }
#endif
#if EF_USE_SPHERE_NORMAL
    float3 sphereN = normalize(input.positionWS - EF_FACE_CENTER);
    HN = normalize(lerp(sphereN, HN, saturate(ormTex.x)));
#endif
    N *= faceSign;

    // View dirs.
    float3 viewDir = normalize(CameraPosition - input.positionWS);
    // A single head-centered view vector reproduces Unity's uniform
    // cameraForward trick without relying on MME CameraDirection's ambiguous
    // sign convention. It is guaranteed to point in the same direction as V.
    float3 camFwd  = normalize(CameraPosition - EF_FACE_CENTER);
    viewDir = normalize(lerp(viewDir, camFwd, EF_FORWARD_DIR_STRENGTH));
    // Baked default offset + live controller shift (HairSpecUp/Down). Set the
    // baked default via EF_VIEWDIR_Y_OFFSET once the band sits right by default.
    float hairSpecYOffset = EF_VIEWDIR_Y_OFFSET + EfHairSpecShift();
    float3 hairVD  = normalize(viewDir + float3(0.0, hairSpecYOffset * (1.0 - ormTex.x), 0.0));

    // Main light (hue-normalized) + top fill + day blend.
    float3 L, Lxz, lightCol; float lightIntensity;
    EfGetMainLight(L, Lxz, lightCol, lightIntensity);
    float NoL = dot(N, L);
    float dayStrength = EfDayStrength();
    float3 otherLight = EfGetOtherLight(N, EF_OTHER_LIGHT_DIR, EF_OTHER_LIGHT_COLOR,
        EF_OTHER_LIGHT_OFFSET, EF_OTHER_LIGHT_STRENGTH, EF_OTHER_LIGHT_STRENGTH_OFFSET);
    float3 lightFinal = EfGetMainLightColorFinal(lightCol, otherLight, dayStrength,
        EF_OTHER_DAY1, EF_OTHER_DAY0);

    // Shadow: Sigmoid toon step over HgShadow visibility.
    float hgVis = useSelfShadow ? EfSampleHgShadow(input.screenPos) : 1.0;
    hgVis = lerp(1.0, hgVis, saturate(EF_SELF_AO_SHADOW_STRENGTH * EfSelfShadowCtrl()));
    float shadow = saturate((EfSigmoidSharp(hgVis, EF_SHADOW_CENTER, EF_SHADOW_SMOOTHNESS)
        + EF_SHADOW_OFFSET + 0.5 * (EfShadowP - EfShadowM)) * EF_SHADOW_STRENGTH);

    // Material. Canonical MyZmdShaders forces metallic = 0; the ORM R channel is
    // a HAIR-STRAND MASK (not metallic), used only for normal/shadow/binormal
    // blends. Treating R (~0.58 here) as metallic corrupted F0 and energyDist.
    float hairMask = ormTex.r;
    float rough = 1.0 - ormTex.w;
    float metallic = 0.0, reflec = ormTex.g;
    float ao = pow(saturate(ormTex.b), EF_AO_STRENGTH);

    float3 baseCol = mainTex.rgb * EF_BASE_COLOR;
    baseCol = pow(max(baseCol, 1e-5), EF_BASE_COLOR_POW);
    float3 darkCol = baseCol * EF_ALBEDO_DARK_STRENGTH;
    float darkLum = EfLuminance(darkCol);
    darkCol = lerp(darkLum.xxx, darkCol, EF_ALBEDO_DARK_SATURATION);

    float energyDist = 0.96 - 0.96 * metallic;
    float3 F0 = 0.04 * reflec.xxx + metallic * (baseCol - reflec.xxx * 0.04);

    // Ramp + 3-layer diffuse (back-light compensated).
    float back    = EfGetBackLight(camFwd, Lxz);
    float rampNoL = EfGetRampNoL(NoL, back);
    float4 rampCol = tex2D(EfRampSampler, float2(rampNoL, 0.5));
    rampCol.rgb = EfSRGBToLinear(rampCol.rgb);
    float rampNoF = tex2D(EfRampSampler, float2(dot(N, camFwd) * 0.5 + 0.5, 0.5)).w;

    // Ramp+/- widen or narrow the lit region before shading.
    rampNoL = saturate(rampNoL + 0.15 * (EfRampP - EfRampM));

    float3 diffLight, diffDark;
    float3 diffuse = EfGetDiffuseBRDF(baseCol, darkCol, ao, shadow, rampCol, rampNoF,
        energyDist, diffLight, diffDark);
    float3 diffRamp = EfApplyRampColor(diffuse, rampCol);

    float aoShaNoF  = ao * shadow * rampNoF;
    float minShadow = min(min(ao, shadow), rampCol.w);
    float3 diffLow  = lerp(diffDark * 0.65, diffLight, aoShaNoF);
    diffRamp = lerp(diffLow, diffRamp, dayStrength);
    // Bright/Dark controller lift on the composed diffuse.
    diffRamp *= lerp(EfDarkBranchMul(), EfBrightMul(), rampNoL);
    float3 diffResult = lightFinal * diffRamp;

    // Kajiya-Kay LUT specular.
    // Axis normal for the highlight (see EF_HAIR_AXIS_MODE).
#if EF_HAIR_AXIS_MODE == 2
    float3 sphereAxisN = normalize(input.positionWS - EF_FACE_CENTER);
    float3 axisN = normalize(lerp(sphereAxisN, HN, saturate(EF_HAIR_AXIS_HN_BLEND)));
#elif EF_HAIR_AXIS_MODE == 1
    float3 axisN = geomN;
#else
    float3 axisN = HN;
#endif
    // PMX has no authored tangent. Use the same radial cross-strand direction
    // as a continuous fallback, then move toward the reconstructed UV-U tangent
    // where P.r says the authored hair basis is reliable. Sign alignment keeps
    // mirrored UV islands from flipping the one-sided LUT lobe.
#if EF_HAIR_TANGENT_MODE
    float3 radialAxis = normalize(EF_HAIR_RADIAL_AXIS);
    float3 fromAxis = input.positionWS - EF_HAIR_RADIAL_CENTER;
    fromAxis -= radialAxis * dot(fromAxis, radialAxis);
    float3 radialRaw = cross(radialAxis, fromAxis);
    float3 radialFallback = cross(radialAxis, float3(0.0, 0.0, 1.0));
    radialRaw += radialFallback * (dot(radialRaw, radialRaw) < 1e-8 ? 1.0 : 0.0);
    float3 radialT = normalize(radialRaw);

    float3 uvRaw = tangentWS - axisN * dot(axisN, tangentWS);
    float uvValid = tbnValid && dot(uvRaw, uvRaw) > 1e-8 ? 1.0 : 0.0;
    float3 uvT = normalize(uvRaw + radialT * (1.0 - uvValid));
    uvT *= dot(radialT, uvT) < 0.0 ? -1.0 : 1.0;
    float3 strandTanWS = normalize(lerp(radialT, uvT, saturate(hairMask) * uvValid));
#elif EF_HAIR_STRAND_AXIS
    float3 strandTanWS = bitangentWS;
#else
    float3 strandTanWS = tangentWS;
#endif
    // Keep the stylized hair key independent from MMD's global light. This
    // preserves band placement while scene lighting still shapes the diffuse,
    // shadows and directional rim. The opt-in branch restores linked lighting.
#if EF_HAIR_SPEC_USE_MMD_LIGHT
    float3 hairSpecL = L;
    float3 hairSpecLightColor = lightFinal;
#elif EF_HAIR_SPEC_VIEW_LOCK
    // Preserve Kajiya-Kay H = V + L: L is a separate camera-relative top key,
    // not the same vector as V and not MMD's global directional light.
    float3 hairSpecL = normalize(camFwd + float3(0.0, EF_HAIR_SPEC_KEY_UP, 0.0));
    float3 hairSpecLightColor = EF_HAIR_SPEC_LIGHT_COLOR;
#else
    float3 hairSpecL = EF_HAIR_SPEC_LIGHT_DIR;
    float3 hairSpecLightColor = EF_HAIR_SPEC_LIGHT_COLOR;
#endif

    // Specular models are compile-time exclusive so probes cannot perturb v21.
#if EF_HAIR_SPEC_MODEL == 1
    float3 finalF0 = EfHairAnisoGGX(
        axisN, viewDir, hairSpecL, F0, reflec, ormTex.w,
        EF_GGX_ANISO, EF_HAIR_RADIAL_AXIS, EF_GGX_CLAMP) * EF_GGX_GAIN;
#elif EF_HAIR_SPEC_MODEL == 0
    float3 finalF0 = EfHairKajiyaKayF0(
        axisN, strandTanWS, camFwd, viewDir, hairVD, hairSpecL, F0, reflec, ormTex.w, ormTex.x,
        EfHairSpecSampler,
        EF_SPEC_TRICK_FLATTEN, EF_SPEC_POW_STRENGTH, EF_LUT_V_POW_STRENGTH,
        EF_SPEC_BACK_F0, EF_SPEC_BACK_F0_TOH_POW, EF_BINORMAL_OFFSET, EF_HAIR_LUT_GAIN);
#else
    float4 gooP = ormTex;
#if EF_GOO_MATCH_BLEND_P_SRGB
    // The source hair property texture marks P as sRGB in the reference blend,
    // despite the node-group socket being labelled Non-Color.
    gooP.rgb = EfSRGBToLinear(gooP.rgb);
#endif
    float gooUvValid = tbnValid ? 1.0 : 0.0;
    float3 gooRadialAxisWS = normalize(mul(EF_HAIR_RADIAL_AXIS, (float3x3)matWorld));
    float3 gooRadialCenterWS = mul(float4(EF_HAIR_RADIAL_CENTER, 1.0), matWorld).xyz;
#if EF_GOO_BASIS_MODE == 1 || EF_GOO_BASIS_MODE == 2 || EF_GOO_BASIS_MODE == 3
    float3 gooFaceCenterWS = mul(float4(EF_FACE_CENTER, 1.0), matWorld).xyz;
    float3 gooCameraForward = normalize(CameraPosition - gooFaceCenterWS);
#if EF_GOO_BASIS_MODE == 2
    // The position-based sphere normal is continuous across separate PMX hair
    // cards and avoids amplifying derivative-TBN seams in the narrow band.
    float3 gooBandHN = normalize(input.positionWS - gooFaceCenterWS);
#elif EF_GOO_BASIS_MODE == 3
    // MyZmd keeps the continuous sphere field only where P.r says the
    // authored HN basis is unreliable. This should recover the lateral shape
    // without returning fully to the derivative-TBN seams from mode 1.
    float3 gooSphereHN = normalize(input.positionWS - gooFaceCenterWS);
    float3 gooBandHN = normalize(lerp(gooSphereHN, gooHN, saturate(gooP.r)));
#else
    float3 gooBandHN = gooHN;
#endif
    float3 gooHairB = EfGooCameraFlatBinormal(
        gooBandHN, gooCameraForward, gooRadialAxisWS);
    float gooBand = EfGooHairBandFromBinormal(
        gooBandHN, gooHairB, viewDir, gooP,
        EF_GOO_HIGHLIGHT_POSITION, EF_GOO_HIGHLIGHT_LENGTH,
        gooRadialAxisWS);
#else
    float gooBand = EfGooHairBandMask(
        input.positionWS, gooHN, tangentWS, gooUvValid, viewDir, gooP,
        EF_GOO_HIGHLIGHT_POSITION, EF_GOO_HIGHLIGHT_LENGTH,
        gooRadialAxisWS, gooRadialCenterWS);
#endif
    float3 finalF0 = EF_GOO_POSITION_COLOR * gooBand * EF_GOO_POSITION_GAIN;
#endif

    float aoShaLow = lerp(aoShaNoF, minShadow, dayStrength);
    float selfAo   = lerp(EF_SELF_AO_SHADOW_STRENGTH, 1.0, aoShaLow);
#if EF_HAIR_SPEC_MODEL == 2
    // The position probe must not inherit MMD light color, NoL ramp or shadow.
    float3 specResult = finalF0 * EfSpecularMul();
#else
    float3 specResult = hairSpecLightColor * selfAo * finalF0 * EfSpecularMul();
#endif
#if EF_HAIR_SPEC_OFF
    specResult = 0.0;
#endif

    // SSS diffuse attenuation via base alpha, then compose.
    float sssBlend = 1.0 - EF_DIFFUSE_BLEND_EFFECT * (1.0 - mainTex.a);
    float3 mainResult = diffResult * sssBlend + specResult;

    // Rim (Fresnel + directional NoLxz).
    float NoV = saturate(dot(N, viewDir));
    float3 hairRimColor = EfSRGBToLinear(
        saturate(EfHairMaterialEdgeColor.rgb));
    float hairRimContrast = 1.0;
#if EF_HAIR_CONTROLLER_C5_ENABLED
    hairRimColor = EfHairControllerRimColor(
        hairRimColor, EF_RIM_COLOR);
    hairRimContrast = EfHairControllerRimContrast();
#endif
    float3 rimFresnel = EfFresnelRimContrast(NoV, diffLight, ao,
        EF_RIM_AREA, hairRimColor, EF_RIM_STRENGTH * EfRimMul(),
        EF_RIM_DIFFUSE_EFFECT, hairRimContrast);
    float3 rimLxz = EfNoLxzRim(N, Lxz, NoV, lightCol, lightIntensity, diffLight, ao,
        dayStrength, EF_RIM_NOLXZ_STRENGTH * EfRimMul());
    float3 rimResult = rimFresnel + rimLxz;

    float3 color = mainResult + max(rimResult, 0.0);
    color = EfApplyHairColorGrade(color);
    color = EfApplyGlobalColorGrade(color);
    return float4(EfLinearToSRGB(color), mainTex.a);
}

#if EF_HAIR_FINAL_RIM_PASS
struct EfHairRimVaryings {
    float4 positionCS : POSITION;
    float2 uv         : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS   : TEXCOORD2;
    float4 screenPos  : TEXCOORD3;
};

EfHairRimVaryings EfHairRimVS(EfAttributes input)
{
    EfHairRimVaryings output = (EfHairRimVaryings)0;
    output.positionCS = mul(input.positionOS, matWorldViewProject);
    output.positionWS = mul(input.positionOS, matWorld).xyz;
    output.normalWS = normalize(mul(input.normalOS, (float3x3)matWorld));
    output.uv = input.texcoord0;
    output.screenPos = output.positionCS;
    return output;
}

float4 EfHairRimPS(EfHairRimVaryings input, float facing : VFACE) : COLOR0
{
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometryNormalWS = normalize(input.normalWS);
    float3 normalWS = geometryNormalWS * faceSign;

#if EF_USE_NORMAL_MAP
    float3 tangentWS, bitangentWS;
    bool tbnValid;
    EfReconstructTB(input.positionWS, geometryNormalWS, input.uv,
        tangentWS, bitangentWS, tbnValid);
    // Rim width remains geometric; its Fresnel/directional attenuation uses
    // the same detail normal as the accepted in-main composite.
    if (tbnValid) {
        float4 normalTexture = tex2D(EfNormalSampler, input.uv);
        float3 normalTS = EfUnpackNormal(normalTexture.rg, EF_BUMP_SCALE);
        float3x3 tbn = float3x3(tangentWS, bitangentWS, geometryNormalWS);
        normalWS = normalize(mul(normalTS, tbn)) * faceSign;
    }
#endif

    float rimWidthMultiplier = 1.0;
    float rimContrast = 1.0;
#if EF_HAIR_CONTROLLER_C5_ENABLED
    rimWidthMultiplier = EfHairControllerRimWidth();
    rimContrast = EfHairControllerRimContrast();
#endif
    float depthRim = EfGooDepthRimScaled(
        input.positionWS, geometryNormalWS, input.screenPos,
        rimWidthMultiplier);
    float3 viewWS = EfNormalizeOr(
        CameraPosition - input.positionWS, float3(0.0, 0.0, 1.0));
    float noV = saturate(dot(normalWS, viewWS));
    float fresnel = pow(
        saturate(1.0 - noV), EF_GOO_RIM_FRESNEL_POWER);
    float vertical = geometryNormalWS.y * 0.5 + 0.5;
    float3 lightWS = EfMmdSurfaceToLightWS(
        LightDirection,
        float3(0.0, 0.70710678, -0.70710678));
    float noL = saturate(dot(normalWS, lightWS));
    float directional = lerp(
        1.0 - EF_GOO_RIM_DIRECTIONAL_ATTENUATION, 1.0, noL);
    float3 normalOS = mul(normalWS, (float3x3)matWorldInverse);
    float limitation = saturate(normalOS.x);
    float limitationMix = lerp(
        1.0, limitation, saturate(EF_GOO_RIM_LIMITATION_STRENGTH));
    float rimMask = EfRimApplyContrast(
        saturate(depthRim * fresnel * vertical
            * directional * limitationMix),
        rimContrast);
    float rimMultiplier = 1.0;
#if EF_HAIR_CONTROLLER_ENABLED
    rimMultiplier = EfHairControllerRimMultiplier();
#endif
    float3 materialRimSrgb = saturate(EfHairMaterialEdgeColor.rgb);
    float materialRimPeak = max(
        materialRimSrgb.r, max(materialRimSrgb.g, materialRimSrgb.b));
    float useMaterialRimColor = step(
        EF_HAIR_RIM_EDGE_COLOR_MIN, materialRimPeak);
    float3 rimColor = lerp(
        EF_GOO_RIM_COLOR,
        EfSRGBToLinear(materialRimSrgb),
        useMaterialRimColor);
#if EF_HAIR_CONTROLLER_C5_ENABLED
    rimColor = EfHairControllerRimColor(rimColor, EF_GOO_RIM_COLOR);
#endif
    float3 rimLinear = rimColor * EF_GOO_RIM_COLOR_STRENGTH
        * rimMask * rimMultiplier * EfGlobalBrightnessMul();
    // The main pass has already encoded its destination. Supplying the small
    // linear rim increment to ONE/ONE blending best approximates linear add on
    // MMD's non-HDR target without re-encoding and over-brightening the edge.
    return float4(max(rimLinear, 0.0), 0.0);
}
#endif

// -- Hair-to-face projected shadow -------------------------------------------
#if EF_HAIR_FACE_SHADOW_PASS
struct EfHairFaceShadowVaryings {
    float4 positionCS : POSITION;
    float2 uv         : TEXCOORD0;
};

EfHairFaceShadowVaryings EfHairFaceShadowVS(EfAttributes input)
{
    EfHairFaceShadowVaryings output = (EfHairFaceShadowVaryings)0;
    float3 positionWS = mul(input.positionOS, matWorld).xyz;
    float3 positionVS = mul(float4(positionWS, 1.0), matView).xyz;

    // Fringe projection always follows MMD's native directional light. Do not
    // inherit the optional camera-locked art light used by other hair terms.
    float3 surfaceToLightWS = EfNormalizeOr(
        -LightDirection, float3(0.0, 0.70710678, -0.70710678));
    float3 surfaceToLightVS = EfNormalizeOr(
        mul(surfaceToLightWS, (float3x3)matView),
        float3(0.0, 0.70710678, -0.70710678));

    float3 headCenterWS = mul(float4(EF_FACE_CENTER, 1.0), matWorld).xyz;
    float3 cameraToHeadWS = EfNormalizeOr(
        CameraPosition - headCenterWS, float3(0.0, 0.0, -1.0));
    float3 cameraToHeadOS = EfNormalizeOr(
        mul(cameraToHeadWS, (float3x3)matWorldInverse),
        float3(0.0, 0.0, -1.0));
    float cameraPitchFactor = 1.0 - smoothstep(
        EF_HAIR_FACE_SHADOW_CAMERA_PITCH_MIN,
        EF_HAIR_FACE_SHADOW_CAMERA_PITCH_MAX,
        cameraToHeadOS.y);

    float2 controllerOffsetVS = float2(0.0, 0.0);
#if EF_HAIR_CONTROLLER_C5_ENABLED
    controllerOffsetVS = EfHairControllerFaceShadowOffset();
#endif

    float lightResponseX = clamp(surfaceToLightVS.x, -1.0, 1.0);
    float lightResponseMagnitude = abs(lightResponseX);
    float easedLightResponseMagnitude = lightResponseMagnitude
        * lightResponseMagnitude * (3.0 - 2.0 * lightResponseMagnitude);
    float easedLightResponseX = sign(lightResponseX)
        * easedLightResponseMagnitude;
    lightResponseX = lerp(
        lightResponseX,
        easedLightResponseX,
        saturate(EF_HAIR_FACE_SHADOW_LIGHT_EASING));

    positionVS.x -= lightResponseX
        * EF_HAIR_FACE_SHADOW_OFFSET_X
        * EF_HAIR_FACE_SHADOW_LIGHT_INFLUENCE;
    positionVS.x += controllerOffsetVS.x;
    positionVS.y -= EF_HAIR_FACE_SHADOW_OFFSET_Y * cameraPitchFactor;
    positionVS.y += controllerOffsetVS.y;

    positionVS.z -= max(EF_HAIR_FACE_SHADOW_DEPTH_BIAS, 0.0);
    output.positionCS = mul(float4(positionVS, 1.0), matProjection);
    output.uv = input.texcoord0;
    return output;
}

float4 EfHairFaceShadowPS(EfHairFaceShadowVaryings input,
    uniform bool useTexture) : COLOR0
{
    float coverage = 1.0;
#if EF_HAIR_FACE_SHADOW_USE_D_ALPHA
    if (useTexture) {
        float alpha = tex2D(EfMainSampler, input.uv).a;
        float softness = max(EF_HAIR_FACE_SHADOW_ALPHA_SOFTNESS, 1e-4);
        coverage = smoothstep(
            EF_HAIR_FACE_SHADOW_ALPHA_CUTOFF - softness,
            EF_HAIR_FACE_SHADOW_ALPHA_CUTOFF + softness,
            alpha);
        clip(coverage - 1e-4);
    }
#endif
    float shadowStrength = 1.0;
    float shadowBrightness = 1.0;
    float3 shadowColor = EF_HAIR_FACE_SHADOW_COLOR;
#if EF_HAIR_CONTROLLER_C5_ENABLED
    shadowStrength = EfHairControllerFaceShadowStrength();
    shadowBrightness = EfHairControllerFaceShadowBrightness();
    shadowColor = EfHairControllerFaceShadowColor(shadowColor);
#endif
    float opacity = saturate(
        EF_HAIR_FACE_SHADOW_OPACITY * MaterialDiffuse.a * coverage
            * shadowStrength);
    return float4(
        saturate(shadowColor * shadowBrightness * EfDarkBranchMul()),
        opacity);
}
#endif

// MMD native edge passthrough. MMD has already expanded POSITION for the
// MMDPass="edge" draw, including the PMX per-vertex edge scale.
struct EfOutlineVaryings {
    float4 positionCS : POSITION;
    float3 normalWS   : TEXCOORD0;
    float2 uv         : TEXCOORD1;
};

EfOutlineVaryings EfOutlineVS(EfAttributes input)
{
    EfOutlineVaryings output = (EfOutlineVaryings)0;
    float4 positionCS = mul(input.positionOS, matWorldViewProject);
    float3 normalWS = normalize(mul(input.normalOS, (float3x3)matWorld));
    output.positionCS = positionCS;
    output.normalWS = normalWS;
    output.uv = input.texcoord0;
    return output;
}

float4 EfOutlinePS(EfOutlineVaryings input,
    uniform bool useTexture) : COLOR0
{
    float4 edgeColor = saturate(EfHairMaterialEdgeColor);
    clip(edgeColor.a - 1e-4);
    return edgeColor;
}

#if EF_USE_OUTLINE
#define EF_OUTLINE_OBJECT_PASS(useTextureValue) \
        pass DrawOutline { \
            ZEnable = true; ZWriteEnable = false; ZFunc = LESSEQUAL; \
            CullMode = EF_OUTLINE_CULL_MODE; \
            StencilEnable = false; \
            AlphaTestEnable = false; \
            AlphaBlendEnable = true; \
            SrcBlend = SRCALPHA; DestBlend = INVSRCALPHA; BlendOp = ADD; \
            VertexShader = compile vs_3_0 EfOutlineVS(); \
            PixelShader = compile ps_3_0 EfOutlinePS(useTextureValue); \
        }
#else
#define EF_OUTLINE_OBJECT_PASS(useTextureValue)
#endif
// Intentionally emit no MMDPass="edge" technique. Its absence lets MMD use
// the native outline renderer and keeps edge-pass state out of later layers.
#define EF_OUTLINE_EDGE_TECHNIQUE

#if EF_HAIR_FINAL_RIM_PASS
// Hair materials can leave alpha testing enabled. The additive pass writes
// alpha 0 intentionally, so inherited alpha testing would discard every rim
// pixel before ONE/ONE blending.
#define EF_FINAL_RIM_PASS_BLOCK \
    pass DrawHairRim { \
        ZEnable = true; ZWriteEnable = false; ZFunc = LESSEQUAL; \
        CullMode = EF_CULL_MODE; \
        AlphaTestEnable = false; \
        AlphaBlendEnable = true; \
        ColorWriteEnable = 15; \
        SrcBlend = ONE; DestBlend = ONE; BlendOp = ADD; \
        VertexShader = compile vs_3_0 EfHairRimVS(); \
        PixelShader = compile ps_3_0 EfHairRimPS(); \
    }
#else
#define EF_FINAL_RIM_PASS_BLOCK
#endif

#if EF_HAIR_FACE_SHADOW_PASS
#define EF_HAIR_MAIN_STENCIL_STATES \
    StencilEnable = true; \
    StencilFunc = ALWAYS; \
    StencilRef = EF_HAIR_FACE_SHADOW_HAIR_REF; \
    StencilWriteMask = EF_HAIR_FACE_SHADOW_HAIR_WRITE_MASK; \
    StencilFail = KEEP; \
    StencilZFail = KEEP; \
    StencilPass = REPLACE;
#define EF_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
    pass DrawHairFaceShadow { \
        ZEnable = true; ZWriteEnable = false; \
        ZFunc = EF_HAIR_FACE_SHADOW_ZFUNC; \
        CullMode = EF_CULL_MODE; \
        AlphaTestEnable = false; \
        AlphaBlendEnable = true; \
        ColorWriteEnable = 15; \
        SrcBlend = SRCALPHA; DestBlend = INVSRCALPHA; BlendOp = ADD; \
        StencilEnable = true; \
        StencilFunc = EQUAL; \
        StencilRef = EF_HAIR_FACE_SHADOW_FACE_REF; \
        StencilMask = EF_HAIR_FACE_SHADOW_READ_MASK; \
        StencilWriteMask = 0; \
        StencilFail = KEEP; \
        StencilZFail = KEEP; \
        StencilPass = KEEP; \
        VertexShader = compile vs_3_0 EfHairFaceShadowVS(); \
        PixelShader = compile ps_3_0 EfHairFaceShadowPS(useTextureValue); \
    }
#else
#define EF_HAIR_MAIN_STENCIL_STATES \
    StencilEnable = false;
#define EF_FACE_SHADOW_PASS_BLOCK(useTextureValue)
#endif

// ── Techniques ──────────────────────────────────────────
#ifndef EF_NO_TECHNIQUES
#define EF_PASS_STATES \
    AlphaBlendEnable = false; \
    ColorWriteEnable = 15; \
    ZWriteEnable = true; \
    EF_HAIR_MAIN_STENCIL_STATES

#if EF_USE_OUTLINE && EF_HAIR_FINAL_RIM_PASS && EF_HAIR_FACE_SHADOW_PASS
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;Pass=DrawOutline;Pass=DrawHairRim;"
#elif EF_USE_OUTLINE && EF_HAIR_FINAL_RIM_PASS
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;Pass=DrawOutline;Pass=DrawHairRim;"
#elif EF_USE_OUTLINE && EF_HAIR_FACE_SHADOW_PASS
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;Pass=DrawOutline;"
#elif EF_USE_OUTLINE
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;Pass=DrawOutline;"
#elif EF_HAIR_FINAL_RIM_PASS && EF_HAIR_FACE_SHADOW_PASS
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;Pass=DrawHairRim;"
#elif EF_HAIR_FINAL_RIM_PASS
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;Pass=DrawHairRim;"
#elif EF_HAIR_FACE_SHADOW_PASS
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;"
#else
#define EF_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;"
#endif

#define EF_OBJECT_TECHNIQUE(name, passName, useTextureValue, useShadowValue) \
    technique name < \
        string MMDPass = passName; \
        string Script = EF_OBJECT_SCRIPT; \
        bool UseTexture = useTextureValue; \
        bool UseSphereMap = false; \
        bool UseSelfShadow = useShadowValue; \
    > { \
        pass DrawObject { \
            ZEnable = true; \
            CullMode = EF_CULL_MODE; \
            EF_PASS_STATES \
            VertexShader = compile vs_3_0 EfMainVS(); \
            PixelShader = compile ps_3_0 EfMainPS(useTextureValue, useShadowValue); \
        } \
        EF_OUTLINE_OBJECT_PASS(useTextureValue) \
        EF_FINAL_RIM_PASS_BLOCK \
        EF_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
    }

EF_OBJECT_TECHNIQUE(EfObjectNoTexture,       "object",    false, true)
EF_OBJECT_TECHNIQUE(EfObjectTexture,         "object",    true,  true)
EF_OBJECT_TECHNIQUE(EfObjectShadowNoTexture, "object_ss", false, true)
EF_OBJECT_TECHNIQUE(EfObjectShadowTexture,   "object_ss", true,  true)
EF_OUTLINE_EDGE_TECHNIQUE
#endif // EF_NO_TECHNIQUES

// Standalone ps_3_0 probe (EF_NO_TECHNIQUES builds): fixed uniform args so the
// pixel shader can be compiled directly for instruction/register reporting.
#ifdef EF_NO_TECHNIQUES
float4 EfProbePS(EfVaryings input, float facing : VFACE) : COLOR0
{
    return EfMainPS(input, facing, true, true);
}
#endif

#endif
