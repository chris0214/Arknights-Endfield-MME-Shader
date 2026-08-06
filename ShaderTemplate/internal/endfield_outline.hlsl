// Endfield MME - shared geometric-outline controls and math.
#ifndef ENDFIELD_OUTLINE_INCLUDED
#define ENDFIELD_OUTLINE_INCLUDED

#define EF_OUTLINE_DOMAIN_HAIR 1
#define EF_OUTLINE_DOMAIN_FACE 2
#define EF_OUTLINE_DOMAIN_SKIN 3
#define EF_OUTLINE_DOMAIN_CLOTH 4

#ifndef EF_OUTLINE_CONTROLLER_ENABLED
#define EF_OUTLINE_CONTROLLER_ENABLED 0
#endif
#ifndef EF_OUTLINE_CONTROLLER_NAME
#define EF_OUTLINE_CONTROLLER_NAME "EndfieldOutline_controller.pmx"
#endif
#ifndef EF_OUTLINE_CONTROLLER_MAX_MULTIPLIER
#define EF_OUTLINE_CONTROLLER_MAX_MULTIPLIER 5.0
#endif
#ifndef EF_OUTLINE_DOMAIN
#define EF_OUTLINE_DOMAIN EF_OUTLINE_DOMAIN_HAIR
#endif
#ifndef EF_OUTLINE_CULL_MODE
#define EF_OUTLINE_CULL_MODE CW
#endif

#include "internal/endfield_outline_controls.cp932"

float EfOutlineSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float EfOutlineCloseControllerStrength()
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    return saturate(EfOutlineCloseStrength);
#else
    return 0.0;
#endif
}

float EfOutlineCloseControllerRadius()
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    // Closing range is intentionally positive-priority. Users commonly raise
    // both +/- morphs while testing; cancelling them here made the attachment
    // appear broken and left the search at one pixel.
    float positive = saturate(EfOutlineCloseRadiusP);
    float negative = saturate(EfOutlineCloseRadiusM) * (1.0 - positive);
    return positive > 1e-4
        ? lerp(1.0, 4.0, positive)
        : lerp(1.0, 0.25, negative);
#else
    return 1.0;
#endif
}

float EfOutlineControllerScale(float bakedValue, float positive, float negative)
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    float control = EfOutlineSigned(positive, negative);
    float scale = control >= 0.0
        ? lerp(1.0, max(EF_OUTLINE_CONTROLLER_MAX_MULTIPLIER, 1.0), control)
        : 1.0 + control;
    return max(0.0, bakedValue * scale);
#else
    return max(0.0, bakedValue);
#endif
}

float EfOutlineControllerStrength(float bakedStrength)
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    return EfOutlineControllerScale(
        bakedStrength, EfOutlineStrengthP, EfOutlineStrengthM);
#else
    return max(0.0, bakedStrength);
#endif
}

float EfOutlineControllerWidth(float bakedWidth)
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    return EfOutlineControllerScale(
        bakedWidth, EfOutlineWidthP, EfOutlineWidthM);
#else
    return max(0.0, bakedWidth);
#endif
}

float EfOutlineControllerContrast()
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    float control = EfOutlineSigned(
        EfOutlineContrastP, EfOutlineContrastM);
    return clamp(
        1.0 + 7.0 * max(control, 0.0)
            - 0.75 * max(-control, 0.0),
        0.25, 8.0);
#else
    return 1.0;
#endif
}

float3 EfOutlineControllerColor(float3 baseColor, float3 manualColor)
{
#if EF_OUTLINE_CONTROLLER_ENABLED
    float3 selectedColor = lerp(
        saturate(baseColor), saturate(manualColor),
        saturate(EfOutlineColorMode));
    float3 positive = float3(EfOutlineRP, EfOutlineGP, EfOutlineBP);
    float3 negative = float3(EfOutlineRM, EfOutlineGM, EfOutlineBM);
    return saturate(
        selectedColor
        + (1.0 - selectedColor) * saturate(positive)
        - selectedColor * saturate(negative));
#else
    return saturate(baseColor);
#endif
}

float EfOutlineStrengthToOpacity(float strength)
{
    return saturate(1.0 - exp2(-2.0 * max(strength, 0.0)));
}

float EfOutlineLightShade(float noL, float shadowFloor)
{
    float shade = lerp(saturate(shadowFloor), 1.0, saturate(noL));
    return pow(saturate(shade), EfOutlineControllerContrast());
}

float2 EfOutlineClipOffset(
    float4 positionOS,
    float4 positionCS,
    float3 normalOS,
    float4x4 worldViewProjection,
    float2 viewportSize,
    float bakedWidth,
    float farScale)
{
    float2 safeViewport = max(viewportSize, 1.0);
    float normalLengthSq = dot(normalOS, normalOS);
    float3 unitNormalOS = normalLengthSq > 1e-8
        ? normalOS * rsqrt(normalLengthSq)
        : float3(0.0, 0.0, 0.0);
    float probeDistance = min(
        max(abs(positionCS.w) * 1e-3, 1e-3),
        0.1);
    float4 probeCS = mul(
        float4(positionOS.xyz + unitNormalOS * probeDistance, 1.0),
        worldViewProjection);
    float baseInvW = rcp(max(abs(positionCS.w), 1e-6))
        * (positionCS.w < 0.0 ? -1.0 : 1.0);
    float probeInvW = rcp(max(abs(probeCS.w), 1e-6))
        * (probeCS.w < 0.0 ? -1.0 : 1.0);
    float2 baseNdc = positionCS.xy * baseInvW;
    float2 probeNdc = probeCS.xy * probeInvW;
    float2 pixelDelta = (probeNdc - baseNdc) * safeViewport;
    float pixelLengthSq = dot(pixelDelta, pixelDelta);
    float2 pixelDirection = pixelLengthSq > 1e-8
        ? pixelDelta * rsqrt(pixelLengthSq)
        : float2(0.0, 0.0);
    float distanceScale = lerp(
        1.0,
        saturate(farScale),
        smoothstep(1.0, 12.0, positionCS.w));
    float widthPixels = EfOutlineControllerWidth(bakedWidth)
        * distanceScale;
    return pixelDirection
        * (2.0 * widthPixels / safeViewport)
        * positionCS.w;
}

#endif
