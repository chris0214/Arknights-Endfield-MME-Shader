// Goo Blender hair-band position probe. This intentionally stops before LUT
// coloring so position/width can be approved independently.
#ifndef ENDFIELD_HAIR_GOO_POSITION_INCLUDED
#define ENDFIELD_HAIR_GOO_POSITION_INCLUDED

float3 EfGooUnpackHNormal(float2 packedXY, float strength)
{
    // DecodeNormal in the reference blend reconstructs Z before the Blender
    // Normal Map node applies its 0.75 strength.
    float2 xy = packedXY * 2.0 - 1.0;
    float z = sqrt(max(0.0, 1.0 - saturate(dot(xy, xy))));
    return float3(xy * strength, z);
}

float EfGooReverseSmoothstep(float edge, float x)
{
    float t = saturate((edge - x) / max(edge, 1e-6));
    return t * t * (3.0 - 2.0 * t);
}

float EfGooHairBandFromBinormal(
    float3 HN, float3 hairB, float3 viewDir, float4 pTex,
    float position, float length, float3 upWS)
{
    float3 shiftedIncoming = normalize(lerp(
        viewDir + upWS * position, viewDir, saturate(pTex.r)));
    float signedBand = dot(shiftedIncoming, hairB);
    float band = EfGooReverseSmoothstep(length, abs(signedBand));

    // Exact Goo mask chain after the width SmoothStep: P.g, NoV^5 and P.a.
    float noV5 = pow(saturate(dot(viewDir, HN)), 5.0);
    return band * saturate(pTex.g) * noV5 * saturate(pTex.a);
}

float3 EfGooCameraFlatBinormal(float3 HN, float3 cameraForward, float3 upWS)
{
    // MyZmd's flatten trick removes the camera-right component so separate
    // hair cards share a coherent screen-horizontal direction field.
    float3 cameraRight = normalize(cross(upWS, cameraForward) + float3(1e-6, 0.0, 0.0));
    float3 flatHN = normalize(HN - cameraRight * dot(HN, cameraRight));
    float3 fakeTangent = normalize(cross(upWS, flatHN));
    return normalize(cross(flatHN, fakeTangent));
}

float EfGooHairBandMask(
    float3 positionWS, float3 HN, float3 uvTangentWS, float uvValid,
    float3 viewDir, float4 pTex, float position, float length,
    float3 radialAxisWS, float3 radialCenterWS)
{
    float3 axis = normalize(radialAxisWS);
    float3 fromAxis = positionWS - radialCenterWS;
    fromAxis -= axis * dot(fromAxis, axis);

    // Blender Tangent(RADIAL, Z) maps to a Y-axis radial tangent in MMD.
    // The sign is immaterial to abs(dot), but the same cross order is retained.
    float3 radialRaw = cross(axis, fromAxis);
    float3 fallback = cross(axis, float3(0.0, 0.0, 1.0));
    radialRaw += fallback * (dot(radialRaw, radialRaw) < 1e-8 ? 1.0 : 0.0);
    float3 radialT = normalize(radialRaw);

    // Tangent(UV_MAP) in Blender is the UV-U tangent. Do not sign-align it:
    // the reference node performs a literal P.r mix between both tangents.
    float3 uvT = normalize(uvTangentWS * uvValid + radialT * (1.0 - uvValid));
    float3 hairT = normalize(lerp(radialT, uvT, saturate(pTex.r)));
    float3 hairB = normalize(cross(hairT, HN));

    // Geometry.Incoming in the inspected Eevee scene points surface-to-camera.
    // FHighLightPos offsets Blender Z; that maps to world Y in MMD.
    return EfGooHairBandFromBinormal(
        HN, hairB, viewDir, pTex, position, length, axis);
}

#endif
