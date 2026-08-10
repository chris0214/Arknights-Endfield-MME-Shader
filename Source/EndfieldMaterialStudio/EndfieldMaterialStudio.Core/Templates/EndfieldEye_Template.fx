// Generic iris material template. The GUI replaces the base texture and bone.
// Pseudo-cornea normals and MatCap remain separate later tests.
#define EF_FACIAL_MAIN_TEXTURE_RESOURCE \
    "__EF_FACIAL_BASE_TEXTURE__"
#define EF_FACIAL_IRIS_ENABLED 1
#define EF_EYE_IRIS_PARALLAX_DEPTH 0.020
#define EF_EYE_IRIS_PARALLAX_SCALE_X 1.0
#define EF_EYE_IRIS_PARALLAX_SCALE_Y 0.25
#define EF_EYE_IRIS_PARALLAX_MASK_INNER 0.22
#define EF_EYE_IRIS_PARALLAX_MASK_OUTER 0.50
#define EF_EYE_IRIS_PARALLAX_MAX_OFFSET 0.035
#define EF_FACIAL_BASE_COLOR float3(1.0, 1.0, 1.0)
#define EF_FACIAL_BASE_COLOR_POW 1.0
#define EF_FACIAL_COLOR_GAIN 1.06
#define EF_FACIAL_COLOR_SATURATION 0.94
#define EF_FACIAL_COLOR_CONTRAST 1.02
#define EF_FACIAL_COLOR_LIFT float3(0.008, 0.006, 0.004)
#define EF_FACIAL_SOFT_EXPOSURE 3.0
#define EF_FACIAL_ALPHA_CUTOFF 0.01
// The base iris writes the shared projected-shadow receiver bit. This closes
// the face mesh's eye-socket opening; it is not a private EyeThrough bit.
#define EF_FACIAL_BASE_STENCIL_ENABLED 1
#define EF_FACIAL_BASE_STENCIL_REF 1
#define EF_FACIAL_BASE_STENCIL_WRITE_MASK 1

float4x4 EfFacialHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = "頭";
>;

#include "internal/endfield_facial.hlsl"
