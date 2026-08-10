// Chen Qianyu eyelash/eyebrow overlay copy. Its duplicated geometry defines
// the feature region; Hair stencil bit 2 selects real-fringe coverage.
#define EF_FACIAL_MAIN_TEXTURE_RESOURCE \
    "textures/chen/T_actor_chen_face_01_D.png"
#define EF_FACIAL_OVERLAY_ENABLED 1
#define EF_FACIAL_OVERLAY_ALPHA 0.0
#define EF_FACIAL_OVERLAY_COLOR_GAIN 1.0
#define EF_FACIAL_OVERLAY_SIDE_FADE_END 0.18
#define EF_FACIAL_OVERLAY_SIDE_FADE_START 0.55
#define EF_FACIAL_OVERLAY_STENCIL_REF 2
#define EF_FACIAL_OVERLAY_STENCIL_MASK 2
#define EF_FACIAL_OVERLAY_STENCIL_ENABLED 1
#define EF_FACIAL_OVERLAY_ZFUNC ALWAYS
#define EF_FACIAL_OVERLAY_DEPTH_FADE_ENABLED 0
#define EF_FACIAL_OVERLAY_DEPTH_FADE_START 0.05
#define EF_FACIAL_OVERLAY_DEPTH_FADE_END 3.0
#define EF_FACIAL_OVERLAY_DEPTH_BIAS 0.02
#define EF_FACIAL_ALPHA_CUTOFF 0.01

float4x4 EfFacialHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = "“ª";
>;

#include "internal/endfield_facial.hlsl"
