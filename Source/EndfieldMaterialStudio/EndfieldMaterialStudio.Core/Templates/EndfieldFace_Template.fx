// Generic production face template used by Endfield Material Studio.
// The GUI replaces resource tokens and the head-bone binding per model.

#include "internal/__EF_FACE_BINDING__"

#define EF_FACE_SDF_TEXTURE_RESOURCE \
    "__EF_FACE_SDF_TEXTURE__"
#define EF_FACE_CMM_TEXTURE_RESOURCE \
    "__EF_FACE_COLOR_MASK_TEXTURE__"
#define EF_FACE_RD_TEXTURE_RESOURCE \
    "__EF_FACE_RD_TEXTURE__"
#define EF_FACE_SKIN_LUT_TEXTURE_RESOURCE \
    "__EF_FACE_LUT_TEXTURE__"

// Validated Goo/Unity face-light response.
#define EF_FACE_SDF_GOO_ANGLE_DEBUG 1
#define EF_FACE_SDF_CMM_BLEND_DEBUG 1
#define EF_FACE_SDF_GOO_CENTER 0.1
#define EF_FACE_SDF_GOO_SHARP 0.5
#define EF_FACE_SDF_GOO_BASE 100000.0

// Validated skin color pipeline: LUT dark color, RD chroma, AO/RD ramp,
// Goo brightness and MyZmd view-dependent 3S refinement.
#define EF_FACE_LUT_RD_COLOR_DEBUG 1
#define EF_FACE_LUT_RD_COLOR_AO_RAMP_DEBUG 1
#define EF_FACE_SKIN_LUT_USE_BRG 1
#define EF_FACE_RD_COLOR_STRENGTH 0.4
#define EF_FACE_AO_STRENGTH 0.3
#define EF_FACE_FINAL_BRIGHTNESS_DEBUG 1
#define EF_FACE_FINAL_BRIGHTNESS 1.15
#define EF_FACE_FINAL_SOFT_EXPOSURE_ENABLED 1
#define EF_FACE_FINAL_SOFT_EXPOSURE 1.6666667
#define EF_FACE_SSS_ENABLED 1
#define EF_FACE_SSS_AREA 0.5
#define EF_FACE_SSS_COLOR float3(0.822936177, 0.669170380, 0.648408771)

// Validated lit-side face detail.
#define EF_FACE_LIP_SPECULAR_ENABLED 1
#define EF_FACE_RIM_ENABLED 1
#define EF_FACE_RIM_INTENSITY 1.0
#define EF_FACE_RIM_WIDTH 1.0
#define EF_FACE_RIM_NOV_THRESHOLD 0.75
#define EF_FACE_RIM_COLOR float3(1.0, 1.0, 1.0)

// No custom edge technique: MMD falls back to its built-in outline renderer.
#define EF_FACE_OUTLINE_ENABLED 0
#define EF_OUTLINE_CONTROLLER_ENABLED 0

// Mark visible face pixels before the real hair material draws its
// projected-shadow pass. Material indices are generated per PMX elsewhere.
#define EF_FACE_STENCIL_WRITE_ENABLED 1
#define EF_FACE_STENCIL_REF 1
#define EF_FACE_STENCIL_WRITE_MASK 1
#define EF_FACE_SHADOW_RECEIVER_ST_ENABLED 1
#define EF_FACE_SHADOW_RECEIVER_ST_TEXTURE_RESOURCE \
    "__EF_FACE_ST_TEXTURE__"
#define EF_FACE_SHADOW_RECEIVER_ST_THRESHOLD 0.05

#include "EndfieldFace_Final.fx"
