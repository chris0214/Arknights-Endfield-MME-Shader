// Endfield MME - shared face assembly wrapper.
// Generated character entries define feature switches and resources
// before including this file; the implementation lives in endfield_face.hlsl.
#define EF_DOMAIN 2
#define EF_FACE_MAIN_TEXTURE_RESOURCE "__EF_FACE_BASE_TEXTURE__"
#define EF_FACE_BASE_COLOR float3(1.0, 1.0, 1.0)
#define EF_FACE_BASE_COLOR_POW 1.0
#ifndef EF_FACE_AO_STRENGTH
#define EF_FACE_AO_STRENGTH 1.0
#endif
#define EF_FACE_CULL_MODE NONE

#include "internal/endfield_face.hlsl"
