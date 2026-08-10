#ifndef ENDFIELD_EYE_INCLUDED
#define ENDFIELD_EYE_INCLUDED

#include "internal/endfield_eye_controls.inc"

// Shared iris-only helpers. PMX does not expose a reliable Unity-style
// tangent stream, so the pixel shader reconstructs the UV basis from screen
// derivatives. This also preserves the mirrored mapping of the two eyes.
#ifndef EF_EYE_IRIS_PARALLAX_DEPTH
#define EF_EYE_IRIS_PARALLAX_DEPTH 0.0
#endif
#ifndef EF_EYE_IRIS_PARALLAX_SCALE_X
#define EF_EYE_IRIS_PARALLAX_SCALE_X 1.0
#endif
#ifndef EF_EYE_IRIS_PARALLAX_SCALE_Y
#define EF_EYE_IRIS_PARALLAX_SCALE_Y 0.25
#endif
#ifndef EF_EYE_IRIS_PARALLAX_DIRECTION
// Matches the stable MyZmd path: finalUV = uv - offset.
#define EF_EYE_IRIS_PARALLAX_DIRECTION -1.0
#endif
#ifndef EF_EYE_IRIS_PARALLAX_MASK_INNER
#define EF_EYE_IRIS_PARALLAX_MASK_INNER 0.22
#endif
#ifndef EF_EYE_IRIS_PARALLAX_MASK_OUTER
#define EF_EYE_IRIS_PARALLAX_MASK_OUTER 0.50
#endif
#ifndef EF_EYE_IRIS_PARALLAX_MAX_OFFSET
#define EF_EYE_IRIS_PARALLAX_MAX_OFFSET 0.035
#endif
#ifndef EF_EYE_IRIS_ALPHA_EMISSION_ENABLED
#define EF_EYE_IRIS_ALPHA_EMISSION_ENABLED 1
#endif
#ifndef EF_EYE_IRIS_ALPHA_BASE_BRIGHTNESS
#define EF_EYE_IRIS_ALPHA_BASE_BRIGHTNESS 1.5
#endif
#ifndef EF_EYE_IRIS_ALPHA_HIGHLIGHT_BRIGHTNESS
// Goo's 6.0 input is multiplied by a maximum 0.5 angle term, so its
// front-facing effective endpoint is 3.0 before D.A blends the two values.
#define EF_EYE_IRIS_ALPHA_HIGHLIGHT_BRIGHTNESS 3.0
#endif
#ifndef EF_EYE_IRIS_MATCAP05_ENABLED
#define EF_EYE_IRIS_MATCAP05_ENABLED 1
#endif
#ifndef EF_EYE_IRIS_MATCAP05_TEXTURE
#define EF_EYE_IRIS_MATCAP05_TEXTURE \
    "textures/chen/T_actor_common_matcap_05_D.png"
#endif
#ifndef EF_EYE_IRIS_MATCAP05_STRENGTH
// Goo's Add-color Mix node uses 0.5666667 as the factor for D * MatCap 05.
#define EF_EYE_IRIS_MATCAP05_STRENGTH 0.5666667
#endif
#ifndef EF_EYE_IRIS_MATCAP07_ENABLED
#define EF_EYE_IRIS_MATCAP07_ENABLED 1
#endif
#ifndef EF_EYE_IRIS_MATCAP07_TEXTURE
#define EF_EYE_IRIS_MATCAP07_TEXTURE \
    "textures/chen/T_actor_common_matcap_07_D.png"
#endif
#ifndef EF_EYE_IRIS_MATCAP07_EMISSION
// Goo uses 0.7 before its own output chain. The MMD iris subsequently passes
// through 3x soft exposure; 0.08 keeps the authored UV-fixed layer subtle
// enough to preserve the iris' red/gray saturation and lower-ring detail.
#define EF_EYE_IRIS_MATCAP07_EMISSION 0.08
#endif
#ifndef EF_EYE_IRIS_FINAL_OUTPUT_GAIN
// Final display-space iris gain. The accepted 0.80 candidate receives the
// requested additional 10% brightness while retaining highlight headroom.
#define EF_EYE_IRIS_FINAL_OUTPUT_GAIN 0.88
#endif
#ifndef EF_EYE_IRIS_FINAL_SATURATION
// Final iris-only saturation adjustment; does not affect sclera or Eye HL.
#define EF_EYE_IRIS_FINAL_SATURATION 1.10
#endif

#if EF_EYE_IRIS_MATCAP05_ENABLED
texture2D EfEyeIrisMatcap05Texture <
    string ResourceName = EF_EYE_IRIS_MATCAP05_TEXTURE;
>;
sampler2D EfEyeIrisMatcap05Sampler = sampler_state {
    texture = <EfEyeIrisMatcap05Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
#endif

#if EF_EYE_IRIS_MATCAP07_ENABLED
texture2D EfEyeIrisMatcap07Texture <
    string ResourceName = EF_EYE_IRIS_MATCAP07_TEXTURE;
>;
sampler2D EfEyeIrisMatcap07Sampler = sampler_state {
    texture = <EfEyeIrisMatcap07Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};
#endif

float3 EfEyeIrisNormalizeOr(float3 value, float3 fallback)
{
    float lengthSq = dot(value, value);
    return (lengthSq > 1e-8) ? value * rsqrt(lengthSq) : fallback;
}

float EfEyeIrisRadialMask(float2 uv)
{
    float radius = length(uv - 0.5);
    float innerRadius = max(EF_EYE_IRIS_PARALLAX_MASK_INNER, 0.0);
    float outerRadius = max(
        EF_EYE_IRIS_PARALLAX_MASK_OUTER,
        innerRadius + 1e-4);
    return 1.0 - smoothstep(innerRadius, outerRadius, radius);
}

float3 EfEyeIrisApplyAlphaEmission(float3 color, float alphaMask)
{
#if EF_EYE_IRIS_ALPHA_EMISSION_ENABLED
    float baseBrightness = max(EF_EYE_IRIS_ALPHA_BASE_BRIGHTNESS, 1e-4);
    float highlightBrightness = max(
        EF_EYE_IRIS_ALPHA_HIGHLIGHT_BRIGHTNESS, 0.0);
    float emissionScale = lerp(
        baseBrightness,
        highlightBrightness,
        saturate(alphaMask)) / baseBrightness;
    return max(color, 0.0) * emissionScale;
#else
    return color;
#endif
}

float3 EfEyeIrisApplyMatcap05(
    float3 color,
    float3 normalWS,
    float4x4 viewMatrix)
{
#if EF_EYE_IRIS_MATCAP05_ENABLED
    // Goo: Normal (world) -> Camera, XY * 0.5 + 0.5. MME/Direct3D's
    // texture V axis is opposite Blender's image-texture convention.
    float3 normalVS = EfEyeIrisNormalizeOr(
        mul(normalWS, (float3x3)viewMatrix),
        float3(0.0, 0.0, 1.0));
    float2 matcapUv = saturate(
        normalVS.xy * float2(0.5, -0.5) + 0.5);
    float3 matcap = tex2D(EfEyeIrisMatcap05Sampler, matcapUv).rgb;
    float strength = EfEyeControllerMatcap05(
        EF_EYE_IRIS_MATCAP05_STRENGTH);
    return max(color, 0.0) *
        (1.0 + max(matcap, 0.0) *
            strength);
#else
    return color;
#endif
}

float3 EfEyeIrisApplyMatcap07(float3 color, float2 irisUv)
{
#if EF_EYE_IRIS_MATCAP07_ENABLED
    float3 emissiveLayer = tex2D(
        EfEyeIrisMatcap07Sampler, irisUv).rgb;
    return max(color, 0.0) + max(emissiveLayer, 0.0)
        * EfEyeControllerMatcap07(EF_EYE_IRIS_MATCAP07_EMISSION);
#else
    return color;
#endif
}

float3 EfEyeIrisApplyFinalOutput(float3 color)
{
    float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
    color = lerp(
        luminance.xxx,
        color,
        EfEyeControllerIrisSaturation(EF_EYE_IRIS_FINAL_SATURATION));
    return saturate(color * EfEyeControllerIrisBrightness(
        EF_EYE_IRIS_FINAL_OUTPUT_GAIN));
}

float2 EfEyeIrisParallaxUv(
    float2 uv,
    float3 positionWS,
    float3 normalWS,
    float3 cameraPositionWS,
    float3 neutralViewDirectionWS)
{
    float depth = EfEyeControllerIrisParallax(
        EF_EYE_IRIS_PARALLAX_DEPTH);
    if (depth <= 1e-6) {
        return uv;
    }

    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    if (abs(determinant) <= 1e-8) {
        return uv;
    }

    float inverseDeterminant = 1.0 / determinant;
    float3 tangentRaw =
        (dpdx * duvdy.y - dpdy * duvdx.y) * inverseDeterminant;
    float3 bitangentRaw =
        (dpdy * duvdx.x - dpdx * duvdy.x) * inverseDeterminant;

    float3 normal = EfEyeIrisNormalizeOr(
        normalWS, float3(0.0, 0.0, -1.0));
    float3 tangent = tangentRaw - normal * dot(normal, tangentRaw);
    tangent = EfEyeIrisNormalizeOr(tangent, float3(1.0, 0.0, 0.0));
    float3 bitangentAxis = EfEyeIrisNormalizeOr(
        cross(normal, tangent), float3(0.0, 1.0, 0.0));
    float handedness = (dot(bitangentAxis, bitangentRaw) < 0.0)
        ? -1.0
        : 1.0;
    float3 bitangent = bitangentAxis * handedness;

    float3 viewDirection = EfEyeIrisNormalizeOr(
        cameraPositionWS - positionWS, normal);
    float3 neutralViewDirection = EfEyeIrisNormalizeOr(
        neutralViewDirectionWS, normal);
    float3 viewDirectionTS = float3(
        dot(viewDirection, tangent),
        dot(viewDirection, bitangent),
        dot(viewDirection, normal));
    float3 neutralViewDirectionTS = float3(
        dot(neutralViewDirection, tangent),
        dot(neutralViewDirection, bitangent),
        dot(neutralViewDirection, normal));

    // Anchor the authored texture at the head's frontal view. Without this
    // subtraction the slanted iris mesh normals create a non-zero offset even
    // in a straight-on camera, which samples the brighter lower iris region.
    float2 offset = (viewDirectionTS.xy - neutralViewDirectionTS.xy)
        * depth * float2(
        max(EF_EYE_IRIS_PARALLAX_SCALE_X, 0.0),
        max(EF_EYE_IRIS_PARALLAX_SCALE_Y, 0.0));
    float offsetLength = length(offset);
    float maxOffset = EfEyeControllerIrisParallax(
        EF_EYE_IRIS_PARALLAX_MAX_OFFSET);
    if (offsetLength > maxOffset && offsetLength > 1e-6) {
        offset *= maxOffset / offsetLength;
    }

    float mask = EfEyeIrisRadialMask(uv);
    return uv + offset * mask * EF_EYE_IRIS_PARALLAX_DIRECTION;
}

#endif
