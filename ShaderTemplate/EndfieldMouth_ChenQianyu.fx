// Chen Qianyu mouth-interior base material (material 6: Mouth Interior).
// It preserves the authored face-atlas color and stays opaque/depth-writing.
#define EF_FACIAL_MAIN_TEXTURE_RESOURCE \
    "textures/chen/T_actor_chen_face_01_D.png"
#define EF_FACIAL_BASE_COLOR float3(1.0, 1.0, 1.0)
#define EF_FACIAL_BASE_COLOR_POW 1.0
#define EF_FACIAL_ALPHA_CUTOFF 0.01

float4x4 EfFacialHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = "“ª";
>;

#include "internal/endfield_facial.hlsl"
