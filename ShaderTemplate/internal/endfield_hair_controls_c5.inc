// Endfield MME - C5 hair shape and diffuse refinement controls.
// Included after endfield_hair_controls.inc; C4 keeps using the original file.
#ifndef ENDFIELD_HAIR_CONTROLS_C5_INCLUDED
#define ENDFIELD_HAIR_CONTROLS_C5_INCLUDED

#ifndef ENDFIELD_HAIR_CONTROLS_INCLUDED
#include "internal/endfield_hair_controls.inc"
#endif

float EfHairOuterHNormalP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠO‘w–@ü+"; >;
float EfHairOuterHNormalM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠO‘w–@ü-"; >;
float EfHairHighlightScaleXP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ‰¡•+"; >;
float EfHairHighlightScaleXM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ‰¡•-"; >;
float EfHairHighlightScaleYP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚ŒõcŒú+"; >;
float EfHairHighlightScaleYM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚ŒõcŒú-"; >;
float EfHairJaggednessP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‹˜Ž•‹­+"; >;
float EfHairJaggednessM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‹˜Ž•‹­-"; >;
float EfHairJaggedFrequencyXP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‹˜Ž•–§“x+"; >;
float EfHairJaggedFrequencyXM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‹˜Ž•–§“x-"; >;
float EfHairTopLightP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’¸Œõ‹­+"; >;
float EfHairTopLightM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’¸Œõ‹­-"; >;
float EfHairTopLightOffsetP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’¸ŒõˆÊ’u+"; >;
float EfHairTopLightOffsetM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’¸ŒõˆÊ’u-"; >;
float EfHairDarkLineStrengthP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ˆÃü‹­+"; >;
float EfHairDarkLineStrengthM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ˆÃü‹­-"; >;
float EfHairDarkLineSaturationP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ˆÃü–O˜a+"; >;
float EfHairDarkLineSaturationM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ˆÃü–O˜a-"; >;
float EfHairFaceShadowLeft  : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e¶ˆÚ"; >;
float EfHairFaceShadowRight : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e‰EˆÚ"; >;
float EfHairFaceShadowUp    : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰eãˆÚ"; >;
float EfHairFaceShadowDown  : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e‰ºˆÚ"; >;
float EfHairFaceShadowStrengthP   : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e‹­+"; >;
float EfHairFaceShadowStrengthM   : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e‹­-"; >;
float EfHairFaceShadowBrightnessP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e—º+"; >;
float EfHairFaceShadowBrightnessM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e—º-"; >;
float EfHairFaceShadowRP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰eÔ+"; >;
float EfHairFaceShadowRM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰eÔ-"; >;
float EfHairFaceShadowGP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e—Î+"; >;
float EfHairFaceShadowGM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰e—Î-"; >;
float EfHairFaceShadowBP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰eÂ+"; >;
float EfHairFaceShadowBM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "”¯‰eÂ-"; >;

// Hair edge-light controls. Color mode 0 reads PMX EDGECOLOR; mode 1 uses
// the manual RGB channels below.
float EfHairRimWidthP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõ•+"; >;
float EfHairRimWidthM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõ•-"; >;
float EfHairRimContrastP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõd+"; >;
float EfHairRimContrastM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõd-"; >;
float EfHairRimColorMode : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõFØ"; >;
float EfHairRimRP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõÔ+"; >;
float EfHairRimRM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõÔ-"; >;
float EfHairRimGP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõ—Î+"; >;
float EfHairRimGM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõ—Î-"; >;
float EfHairRimBP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõÂ+"; >;
float EfHairRimBM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõÂ-"; >;

float EfHairControllerScale(float bakedScale, float positive, float negative)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float maximumScale = max(EF_HAIR_CONTROLLER_MAX_MULTIPLIER, 1.0);
    float positiveScale = EfHairControllerPositiveMultiplier(positive);
    float negativeScale = lerp(
        1.0, 1.0 / maximumScale, saturate(negative));
    return max(0.05, bakedScale * positiveScale * negativeScale);
#else
    return max(
        0.25,
        bakedScale * (1.0 + EfHairControllerSigned(positive, negative)));
#endif
}

float EfHairControllerOuterHnBlend(float bakedBlend)
{
    float positive = saturate(EfHairOuterHNormalP);
    float negative = saturate(EfHairOuterHNormalM);
    return saturate(
        bakedBlend + (1.0 - bakedBlend) * positive - bakedBlend * negative);
}

float EfHairControllerHighlightScaleX(float bakedScale)
{
    return EfHairControllerScale(
        bakedScale, EfHairHighlightScaleXP, EfHairHighlightScaleXM);
}

float EfHairControllerHighlightScaleY(float bakedScale)
{
    return EfHairControllerScale(
        bakedScale, EfHairHighlightScaleYP, EfHairHighlightScaleYM);
}

float EfHairControllerJaggedness(float bakedStrength)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return max(
        0.0,
        bakedStrength * EfHairControllerRangeMultiplier(
            EfHairJaggednessP, EfHairJaggednessM));
#else
    return max(
        0.0,
        bakedStrength + 0.20 * saturate(EfHairJaggednessP)
            - bakedStrength * saturate(EfHairJaggednessM));
#endif
}

float EfHairControllerJaggedFrequencyX(float bakedFrequency)
{
    return EfHairControllerScale(
        bakedFrequency,
        EfHairJaggedFrequencyXP,
        EfHairJaggedFrequencyXM);
}

float EfHairControllerTopLightStrength(float bakedStrength)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return max(
        0.0,
        bakedStrength * EfHairControllerRangeMultiplier(
            EfHairTopLightP, EfHairTopLightM));
#else
    return max(
        0.0,
        bakedStrength
            * (1.0 + EfHairControllerSigned(EfHairTopLightP, EfHairTopLightM)));
#endif
}

float EfHairControllerTopLightOffset(float bakedOffset)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return clamp(
        bakedOffset + 0.15 * EF_HAIR_CONTROLLER_OFFSET_SCALE
            * EfHairControllerSigned(
                EfHairTopLightOffsetP, EfHairTopLightOffsetM),
        -0.75, 0.75);
#else
    return clamp(
        bakedOffset + 0.25 * EfHairControllerSigned(
            EfHairTopLightOffsetP, EfHairTopLightOffsetM),
        -0.5, 0.5);
#endif
}

float EfHairControllerDarkLineStrength(float bakedStrength)
{
    float positive = saturate(EfHairDarkLineStrengthP);
    float negative = saturate(EfHairDarkLineStrengthM);
    return saturate(
        bakedStrength + (1.0 - bakedStrength) * positive
            - bakedStrength * negative);
}

float EfHairControllerDarkLineSaturation(float bakedSaturation)
{
    float positive = saturate(EfHairDarkLineSaturationP);
    float negative = saturate(EfHairDarkLineSaturationM);
    return saturate(
        bakedSaturation + (1.0 - bakedSaturation) * positive
            - bakedSaturation * negative);
}

float2 EfHairControllerFaceShadowOffset()
{
    float offsetScale = 1.0;
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    offsetScale = EF_HAIR_CONTROLLER_OFFSET_SCALE;
#endif
    return float2(
        EF_HAIR_FACE_SHADOW_CONTROLLER_STEP_X * offsetScale
            * EfHairControllerSigned(
                EfHairFaceShadowRight, EfHairFaceShadowLeft),
        EF_HAIR_FACE_SHADOW_CONTROLLER_STEP_Y * offsetScale
            * EfHairControllerSigned(
                EfHairFaceShadowUp, EfHairFaceShadowDown));
}

float EfHairControllerFaceShadowStrength()
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return EfHairControllerRangeMultiplier(
        EfHairFaceShadowStrengthP, EfHairFaceShadowStrengthM);
#else
    return max(
        0.0,
        1.0 + EfHairControllerSigned(
            EfHairFaceShadowStrengthP, EfHairFaceShadowStrengthM));
#endif
}

float EfHairControllerFaceShadowBrightness()
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return EfHairControllerRangeMultiplier(
        EfHairFaceShadowBrightnessP, EfHairFaceShadowBrightnessM);
#else
    return max(
        0.0,
        1.0 + EfHairControllerSigned(
            EfHairFaceShadowBrightnessP, EfHairFaceShadowBrightnessM));
#endif
}

float3 EfHairControllerFaceShadowColor(float3 bakedColor)
{
    return EfHairControllerAdjustRgb(
        bakedColor,
        float3(EfHairFaceShadowRP, EfHairFaceShadowGP, EfHairFaceShadowBP),
        float3(EfHairFaceShadowRM, EfHairFaceShadowGM, EfHairFaceShadowBM));
}

float EfHairControllerRimWidth()
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return EfHairControllerRangeMultiplier(
        EfHairRimWidthP, EfHairRimWidthM);
#else
    return max(
        0.05,
        1.0 + EfHairControllerSigned(
            EfHairRimWidthP, EfHairRimWidthM));
#endif
}

float EfHairControllerRimContrast()
{
    float neutral = 1.0;
    float control = EfHairControllerSigned(
        EfHairRimContrastP, EfHairRimContrastM);
    return clamp(
        neutral + 7.0 * max(control, 0.0)
            - 0.75 * max(-control, 0.0),
        0.25, 8.0);
}

float3 EfHairControllerRimColor(
    float3 edgeColor, float3 manualColor)
{
    float3 adjustedManual = EfHairControllerAdjustRgb(
        manualColor,
        float3(EfHairRimRP, EfHairRimGP, EfHairRimBP),
        float3(EfHairRimRM, EfHairRimGM, EfHairRimBM));
    return lerp(
        saturate(edgeColor), adjustedManual,
        saturate(EfHairRimColorMode));
}

#endif
