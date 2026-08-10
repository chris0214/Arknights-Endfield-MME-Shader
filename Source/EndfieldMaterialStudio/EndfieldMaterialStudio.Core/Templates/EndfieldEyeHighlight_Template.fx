// Generic authored Eye HL layer.
// The mesh samples the lower-left highlight island from the iris D texture.
// Keep it independent from the main iris MatCap so both can be tuned without
// double-lighting the iris base.
#define EF_EYE_HL_TEXTURE_RESOURCE \
    "__EF_EYE_HIGHLIGHT_TEXTURE__"
#define EF_EYE_HL_COLOR_GAIN 1.0
#define EF_EYE_HL_SATURATION 1.0
#define EF_EYE_HL_EMISSION 1.4
#define EF_EYE_HL_ALPHA_OFFSET 0.70
#define EF_EYE_HL_ALPHA_SCALE 1.0

#include "internal/__EF_FACE_BINDING__"
#define EfEyeHlHeadBone EfFaceHeadBone
#include "internal/endfield_eye_highlight.hlsl"
