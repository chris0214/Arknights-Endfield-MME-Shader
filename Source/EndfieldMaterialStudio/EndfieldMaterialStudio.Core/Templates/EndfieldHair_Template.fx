// Generic production hair template. The real hair material also renders the
// light-aware fringe shadow before its normal hair and rim passes.
#define EF_HAIR_FACE_SHADOW_PASS 1
#define EF_HAIR_FACE_SHADOW_OFFSET_X 0.055
#define EF_HAIR_FACE_SHADOW_OFFSET_Y 0.090
#define EF_HAIR_FACE_SHADOW_LIGHT_INFLUENCE 1.0
#define EF_HAIR_FACE_SHADOW_LIGHT_EASING 1.0
#define EF_HAIR_FACE_SHADOW_DEPTH_BIAS 0.12
#define EF_HAIR_FACE_SHADOW_COLOR float3(0.36, 0.25, 0.28)
#define EF_HAIR_FACE_SHADOW_OPACITY 0.32
#define EF_HAIR_FACE_SHADOW_USE_D_ALPHA 1
#define EF_HAIR_FACE_SHADOW_SOURCE_VISIBILITY_ENABLED 1
#define EF_HAIR_FACE_SHADOW_SOURCE_VISIBILITY_DEBUG 0
#define EF_HAIR_VISIBILITY_RT_DECLARED 1

shared texture2D EndfieldHairVisibility_RT : OFFSCREENRENDERTARGET <
    string Description = "Endfield camera-visible hair caster depth";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0.0, 0.0, 0.0, 0.0};
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    string DefaultEffect =
        "*controller*.pmx = hide;"
        "ZMDshadow*.x = hide;"
        "EndfieldPost*.x = hide;"
        "EndfieldEyeThrough*.x = hide;"
        "*Endfield*.pmx = EndfieldHairVisibility_Capture.fxsub;"
        "*.pmd = hide;"
        "*.pmx = hide;"
        "*.x = hide;"
        "* = hide;"
        ;
>;

#include "EndfieldHair_Final.fx"
