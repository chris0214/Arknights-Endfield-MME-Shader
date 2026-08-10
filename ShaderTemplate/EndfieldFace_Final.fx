// Endfield MME - shared face assembly wrapper.
// Character entries define their validated feature switches and resources
// before including this file; the implementation lives in endfield_face.hlsl.
#define EF_DOMAIN 2
#define EF_FACE_MAIN_TEXTURE_RESOURCE "textures/chen/T_actor_chen_face_01_D.png"
#define EF_FACE_BASE_COLOR float3(1.0, 1.0, 1.0)
#define EF_FACE_BASE_COLOR_POW 1.0
#ifndef EF_FACE_AO_STRENGTH
#define EF_FACE_AO_STRENGTH 1.0
#endif
#define EF_FACE_CULL_MODE NONE

#include "internal/endfield_face.hlsl"
