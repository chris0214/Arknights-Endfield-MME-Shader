// Endfield MME - Kajiya-Kay hair specular. Ported from Perlica HairToonShader
// (the LUT specular block). Returns finalF0 = lutF0*gain + backF0, i.e. the
// specular color before the lightFinal * selfAo multiply the caller applies.
//
// HN         : smooth (cylinder) normal, world space
// strandTanWS: surface cross-strand tangent used to derive the hair axis
//
// The Unity original builds the LUT binormal from i.tangentWS.yzx (an authored
// mesh tangent whose .yzx swizzle is calibrated to Unity's tangent basis). PMX
// has no authored tangent, so a ddx/ddy tangent + that swizzle points nowhere
// meaningful and the anisotropic band collapses into broad faceted blobs.
// Instead we build the strand-perpendicular axis cleanly as cross(HN, strand),
// where strand is the along-hair UV-gradient direction chosen by the caller.
#ifndef ENDFIELD_HAIR_SPECULAR_INCLUDED
#define ENDFIELD_HAIR_SPECULAR_INCLUDED

float3 EfHairKajiyaKayF0(
    float3 HN, float3 strandTanWS, float3 camFwd, float3 viewDir, float3 hairVD,
    float3 L, float3 F0, float reflec, float smoothness, float ormX,
    sampler2D hairSpecSampler,
    float specularTrickFlatten, float specularPowStrength, float lutVPowStrength,
    float3 specularBackF0, float specularBackF0ToHPow, float biNormalOffset,
    float lutGain)
{
    // Cylinder-flattened normal toward camera-right plane.
    float3 worldUp  = float3(0.0, 1.0, 0.0);
    float3 camRight = normalize(cross(worldUp, camFwd) + float3(1e-6, 0.0, 0.0));
    float  dotRight = dot(HN, camRight);
    float3 cylN     = normalize(HN - dotRight * camRight);
    float3 flatHN   = normalize(lerp(HN, cylN, specularTrickFlatten));

    // Along-strand anisotropy axis derived from the UV/radial cross-strand
    // tangent (re-orthogonalized against HN first).
    float3 strandOrtho = strandTanWS - HN * dot(HN, strandTanWS);
    float3 strandDir   = dot(strandOrtho, strandOrtho) > 1e-8
        ? normalize(strandOrtho) : strandTanWS;
    float3 hariBin  = normalize(cross(HN, strandDir));
    // View-cylinder fallback where the hair mask is low. Canonical MyZmd uses
    // this exact direction: mask 0 -> camera-flat, mask 1 -> strand binormal.
    float3 fakeTan  = normalize(cross(float3(0.0, 1.0, 0.0), flatHN));
    float3 hairBFlat= normalize(cross(flatHN, fakeTan));
    float3 hairBase = lerp(hairBFlat, hariBin, saturate(ormX));
    float3 hairBLut = normalize(hairBase + HN * biNormalOffset);

    float3 halfDir = normalize(hairVD + L);
    float  ToH_lut = dot(halfDir, hairBLut);

    // LUT U: angular sharpness, exp2(pow*log2(sin)) * reflec.
    float lutU = 1.0 - ToH_lut * ToH_lut;
    lutU = max(0.0001, sqrt(lutU));
    lutU = specularPowStrength * log2(lutU);
    lutU = saturate(exp2(lutU) * reflec);

    // LUT V: view/HN projection, gated to the light-facing lobe.
    float2 vdProj = float2(dot(viewDir, camRight), dot(viewDir, camFwd));
    float2 hnProj = float2(dot(HN, camRight), dot(HN, camFwd));
    float  VoHN   = saturate(dot(vdProj, hnProj));
    VoHN = pow(VoHN, lutVPowStrength);
    float  lutV   = VoHN * VoHN * step(0.0, ToH_lut);

    float4 lutSpec = tex2D(hairSpecSampler, float2(lutU, lutV));
    float3 lutF0   = lutSpec.xyz * F0;

    // Back-light rim lobe (rear highlight, driven by smoothness).
    float3 backF0 = specularBackF0 * smoothness
        * pow(sqrt(max(0.0, 1.0 - ToH_lut * ToH_lut)), specularPowStrength * specularBackF0ToHPow);

    return lutF0 * lutGain + backF0;
}

#endif
