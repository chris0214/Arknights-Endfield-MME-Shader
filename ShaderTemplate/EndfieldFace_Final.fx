// Endfield MME - shared face assembly wrapper.
// Generic face assembly wrapper. Generated profile entries define feature
// switches and resources before including this file; absent textures fall back
// to the current PMX material texture.
#define EF_DOMAIN 2
#define EF_FACE_BASE_COLOR float3(1.0, 1.0, 1.0)
#define EF_FACE_BASE_COLOR_POW 1.0
#ifndef EF_FACE_AO_STRENGTH
#define EF_FACE_AO_STRENGTH 1.0
#endif
#define EF_FACE_CULL_MODE NONE

#include "internal/endfield_face.hlsl"
