// Generic eyelash and eyebrow base material.
// The Zhihu reference deliberately keeps this layer to authored base color.
#define EF_FACIAL_MAIN_TEXTURE_RESOURCE \
    "__EF_FACIAL_BASE_TEXTURE__"
#define EF_FACIAL_BASE_COLOR float3(1.0, 1.0, 1.0)
#define EF_FACIAL_BASE_COLOR_POW 1.0
#define EF_FACIAL_ALPHA_CUTOFF 0.01
// The duplicated overlay mesh already defines the eyelash/eyebrow region, so
// the base material does not need a private stencil bit.

float4x4 EfFacialHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = "頭";
>;

#include "internal/endfield_facial.hlsl"
