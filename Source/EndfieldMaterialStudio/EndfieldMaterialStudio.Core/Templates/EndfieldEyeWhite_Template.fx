// Generic sclera material template.
// The face atlas supplies authored color; a restrained MMD-light half-Lambert
// prevents a flat white card without producing a hard facial shadow.
#define EF_FACIAL_MAIN_TEXTURE_RESOURCE \
    "__EF_FACIAL_BASE_TEXTURE__"
#define EF_FACIAL_EYE_WHITE_ENABLED 1
#define EF_FACIAL_ALPHA_CUTOFF 0.01

#define EF_EYE_WHITE_COLOR_GAIN 1.02
#define EF_EYE_WHITE_COLOR_SATURATION 0.88
#define EF_EYE_WHITE_COLOR_CONTRAST 0.96
#define EF_EYE_WHITE_COLOR_LIFT float3(0.004, 0.003, 0.002)
#define EF_EYE_WHITE_DARK_VALUE 0.86
#define EF_EYE_WHITE_LIGHT_VALUE 1.03
#define EF_EYE_WHITE_LIGHT_CURVE 0.72
#define EF_EYE_WHITE_LIGHT_TINT 0.12
#define EF_EYE_WHITE_SOFT_EXPOSURE 3.0

// Eye sockets are openings in the face mesh. Mark the sclera as part of the
// shared projected-shadow receiver so the face stencil has no eye-shaped holes.
#define EF_FACIAL_BASE_STENCIL_ENABLED 1
#define EF_FACIAL_BASE_STENCIL_REF 1
#define EF_FACIAL_BASE_STENCIL_WRITE_MASK 1

#include "internal/endfield_eye_white.hlsl"
#include "internal/endfield_facial.hlsl"
