// Chen Qianyu hair release entry. The real hair material also renders the
// validated light-aware fringe shadow before its normal hair and rim passes.
#define EF_HAIR_FACE_SHADOW_PASS 1
#define EF_HAIR_FACE_SHADOW_OFFSET_X 0.055
#define EF_HAIR_FACE_SHADOW_OFFSET_Y 0.090
#define EF_HAIR_FACE_SHADOW_LIGHT_INFLUENCE 1.0
#define EF_HAIR_FACE_SHADOW_LIGHT_EASING 1.0
#define EF_HAIR_FACE_SHADOW_DEPTH_BIAS 0.12
#define EF_HAIR_FACE_SHADOW_COLOR float3(0.36, 0.25, 0.28)
#define EF_HAIR_FACE_SHADOW_OPACITY 0.32
#define EF_HAIR_FACE_SHADOW_USE_D_ALPHA 0

#include "EndfieldHair_Final.fx"
