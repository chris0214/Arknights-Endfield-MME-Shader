// Endfield MME - analytic anisotropic hair specular (world-space, camera-stable).
// Ported from the Blender reference node groups DV_SmithJointGGXAniso /
// DV_SmithJointGGX_Aniso (Unity HDRP D_GGXAniso + V_SmithJointGGXAniso).
//
// Unlike the LUT Kajiya-Kay path, the tangent frame here is built entirely in
// world space from the smooth (sphere) normal, so the highlight behaves like a
// real specular lobe and does NOT arc across the head as the camera yaws.
//
//   N = smooth sphere normal (world)         axisN from the caller
//   T = meridian tangent (up/down the head)  = worldUp projected off N
//   B = latitude (horizontal ring)           = cross(N, T)
// roughT tight (thin band vertically) + roughB wide (wraps horizontally) =
// the neat anime horizontal highlight band.
#ifndef ENDFIELD_HAIR_GGX_INCLUDED
#define ENDFIELD_HAIR_GGX_INCLUDED

#ifndef EF_GGX_INV_PI
#define EF_GGX_INV_PI 0.31830988618
#endif

// Unity HDRP D_GGXAniso
float EfDGGXAniso(float TdotH, float BdotH, float NdotH, float roughT, float roughB)
{
    float a2 = roughT * roughB;
    float3 v = float3(roughB * TdotH, roughT * BdotH, a2 * NdotH);
    float s = dot(v, v);
    float k = a2 / max(s, 1e-6);
    return EF_GGX_INV_PI * a2 * k * k;
}

// Unity HDRP V_SmithJointGGXAniso (height-correlated Smith visibility)
float EfVGGXAniso(float TdotV, float BdotV, float NdotV,
    float TdotL, float BdotL, float NdotL, float roughT, float roughB)
{
    float lambdaV = NdotL * length(float3(roughT * TdotV, roughB * BdotV, NdotV));
    float lambdaL = NdotV * length(float3(roughT * TdotL, roughB * BdotL, NdotL));
    return 0.5 / max(lambdaV + lambdaL, 1e-5);
}

// Returns the specular color contribution (before lightFinal * selfAo).
//   viewDirWS/lightDirWS point away from the surface (toward camera / light).
//   anisoAmount in [0,1): higher = tighter vertical band. smoothness = ORM.a.
float3 EfHairAnisoGGX(
    float3 N, float3 viewDirWS, float3 lightDirWS, float3 F0,
    float reflec, float smoothness, float anisoAmount,
    float3 upAxisWS, float ggxClamp)
{
    // Meridian tangent from world-up projected onto the shading plane. Smooth
    // everywhere the sphere normal is (the only singularity is the exact pole).
    float3 up = normalize(upAxisWS);
    float3 T = up - N * dot(N, up);
    float tl = dot(T, T);
    T = tl > 1e-5 ? T * rsqrt(tl) : normalize(cross(N, float3(0.0, 0.0, 1.0)));
    float3 B = normalize(cross(N, T));

    float3 H = viewDirWS + lightDirWS;
    float hl = dot(H, H);
    if (hl < 1e-8) return 0.0;
    H *= rsqrt(hl);

    float TdotH = dot(T, H);
    float BdotH = dot(B, H);
    float NdotH = dot(N, H);
    float NdotL = saturate(dot(N, lightDirWS));
    float NdotV = saturate(dot(N, viewDirWS)) + 1e-4;
    float TdotV = dot(T, viewDirWS), BdotV = dot(B, viewDirWS);
    float TdotL = dot(T, lightDirWS), BdotL = dot(B, lightDirWS);

    // Anisotropic roughness: tight along the strand (T), wide across (B).
    float rough = max(1.0 - smoothness, 0.05);
    float roughT = max(rough * (1.0 - anisoAmount), 0.002); // thin vertically
    float roughB = max(rough, 0.02);                        // wide horizontally

    float D = EfDGGXAniso(TdotH, BdotH, NdotH, roughT, roughB);
    float V = EfVGGXAniso(TdotV, BdotV, NdotV, TdotL, BdotL, NdotL, roughT, roughB);
    float spec = min(D * V, ggxClamp) * NdotL;
    return F0 * spec * max(reflec, 0.02);
}

#endif
