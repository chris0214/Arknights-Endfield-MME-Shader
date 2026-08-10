// Endfield MME - rim terms shared by all domains. Ported from Perlica
// ZmdToonSpecular.hlsl. The analytic GGX + IBL DFG fit lives here too for reuse
// by Body (M2); hair does not call it, so it stays behind EF_USE_GGX.
#ifndef ENDFIELD_SPECULAR_INCLUDED
#define ENDFIELD_SPECULAR_INCLUDED

// Rim-mask contrast. A value of 1 preserves the authored mask, values above
// 1 tighten it, and values below 1 broaden/soften it while preserving 0 and 1.
float EfRimApplyContrast(float mask, float contrast)
{
    return pow(saturate(mask), max(contrast, 1e-4));
}

// MMD exposes the direction in which light travels. Rim and highlight
// direction tests use the opposite, surface-to-light vector consistently
// across hair, skin, face, and cloth.
float3 EfMmdSurfaceToLightWS(float3 mmdLightDirection, float3 fallback)
{
    float lengthSquared = dot(mmdLightDirection, mmdLightDirection);
    return lengthSquared > 1e-8
        ? -mmdLightDirection * rsqrt(lengthSquared)
        : fallback;
}

// ── Fresnel Rim ─────────────────────────────────────────
float3 EfFresnelRimContrast(float NoV, float3 diffLight, float ao,
    float rimArea, float3 rimColor, float rimStrength,
    float rimDiffuseEffect, float rimContrast)
{
    float rStart = rimArea * -0.6 + 0.8;
    float rEnd   = rimArea * -0.4 + 0.9;
    float rt     = saturate(((1.0 - NoV) - rStart) / max(rEnd - rStart, 1e-5));
    float rArea  = rt * rt * (3.0 - 2.0 * rt); // smoothstep
    rArea = EfRimApplyContrast(rArea, rimContrast);
    float3 rLight = rArea * rimColor * rimStrength;
    float3 rEff   = rLight * (ao * 0.5 + 0.5);
    float3 rBRDF  = (diffLight - 0.25) * rimDiffuseEffect + 0.25;
    return rBRDF * rEff;
}

float3 EfFresnelRim(float NoV, float3 diffLight, float ao,
    float rimArea, float3 rimColor, float rimStrength, float rimDiffuseEffect)
{
    return EfFresnelRimContrast(
        NoV, diffLight, ao, rimArea, rimColor, rimStrength,
        rimDiffuseEffect, 1.0);
}

// ── NoLxz Rim (directional highlight along light XZ) ────
float3 EfNoLxzRim(float3 N, float3 mainLightDir_xz, float NoV, float3 mainLightColor,
    float mainLightIntensity, float3 diffLight, float ao, float dayStrength, float noLxzStrength)
{
    float3 rimColor = lerp(1.0, mainLightColor * mainLightIntensity, dayStrength);
    float NoLxz = dot(N, mainLightDir_xz);
    float NoLxzRef = (0.5 - (0.5 * NoLxz - 1.0) * NoLxz) * dayStrength;
    float t = saturate(5.0 * (0.4 - NoV));
    float NoVMask = smoothstep(0.0, 1.0, t);
    return rimColor * NoLxzRef * NoVMask * (ao * 0.5 + 0.5) * max(0.15, diffLight) * noLxzStrength;
}

#endif
