// Endfield MME - hair-only runtime controller parameters.
// The dedicated PMX keeps hair look-dev controls independent from lighting.
#ifndef ENDFIELD_HAIR_CONTROLS_INCLUDED
#define ENDFIELD_HAIR_CONTROLS_INCLUDED

#ifndef EF_HAIR_CONTROLLER_NAME
#define EF_HAIR_CONTROLLER_NAME "EndfieldHair_controller_Range5.pmx"
#endif
#ifndef EF_HAIR_CONTROLLER_RANGE5_ENABLED
#define EF_HAIR_CONTROLLER_RANGE5_ENABLED 0
#endif
#ifndef EF_HAIR_CONTROLLER_MAX_MULTIPLIER
#define EF_HAIR_CONTROLLER_MAX_MULTIPLIER 5.0
#endif
#ifndef EF_HAIR_CONTROLLER_OFFSET_SCALE
#define EF_HAIR_CONTROLLER_OFFSET_SCALE 5.0
#endif

// Highlight shape and intensity.
float EfHairHighlightIntensityP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ‹­+"; >;
float EfHairHighlightIntensityM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ‹­-"; >;
float EfHairHighlightUp         : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚ŒõãˆÚ"; >;
float EfHairHighlightDown       : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ‰ºˆÚ"; >;
float EfHairUpperRatioP         : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘w”ä+"; >;
float EfHairUpperRatioM         : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘w”ä-"; >;
float EfHairUpperSharpnessP     : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘wd+"; >;
float EfHairUpperSharpnessM     : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘wd-"; >;
float EfHairLowerSoftnessP      : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‰º‘w_+"; >;
float EfHairLowerSoftnessM      : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‰º‘w_-"; >;
float EfHairLayerBlendP         : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ª‘w¬+"; >;
float EfHairLayerBlendM         : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ª‘w¬-"; >;
float EfHairHighlightWarmthP    : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ’g+"; >;
float EfHairHighlightWarmthM    : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "‚Œõ’g-"; >;
float EfHairMiddleSaturationP   : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘w–O˜a+"; >;
float EfHairMiddleSaturationM   : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘w–O˜a-"; >;

// Upper and middle highlight color channels. Each +/- pair spans [0, 1]
// around the baked reference color while preserving a neutral zero state.
float EfHairUpperRP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘wÔ+"; >;
float EfHairUpperRM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘wÔ-"; >;
float EfHairUpperGP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘w—Î+"; >;
float EfHairUpperGM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘w—Î-"; >;
float EfHairUpperBP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘wÂ+"; >;
float EfHairUpperBM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ã‘wÂ-"; >;
float EfHairMiddleRP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘wÔ+"; >;
float EfHairMiddleRM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘wÔ-"; >;
float EfHairMiddleGP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘w—Î+"; >;
float EfHairMiddleGM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘w—Î-"; >;
float EfHairMiddleBP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘wÂ+"; >;
float EfHairMiddleBM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "’†‘wÂ-"; >;

// Diffuse/base hair grade and hair-only rim strength.
float EfHairBaseRP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîFÔ+"; >;
float EfHairBaseRM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîFÔ-"; >;
float EfHairBaseGP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF—Î+"; >;
float EfHairBaseGM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF—Î-"; >;
float EfHairBaseBP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîFÂ+"; >;
float EfHairBaseBM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîFÂ-"; >;
float EfHairBaseSaturationP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF–O˜a+"; >;
float EfHairBaseSaturationM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF–O˜a-"; >;
float EfHairBaseBrightnessP : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF—º“x+"; >;
float EfHairBaseBrightnessM : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF—º“x-"; >;
float EfHairBaseExposureP   : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF”˜Œõ+"; >;
float EfHairBaseExposureM   : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "ŠîF”˜Œõ-"; >;
float EfHairRimStrengthP    : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõ‹­+"; >;
float EfHairRimStrengthM    : CONTROLOBJECT < string name = EF_HAIR_CONTROLLER_NAME; string item = "•ÓŒõ‹­-"; >;

float EfHairControllerSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
float EfHairControllerPositiveMultiplier(float control)
{
    return lerp(
        1.0, max(EF_HAIR_CONTROLLER_MAX_MULTIPLIER, 1.0),
        saturate(control));
}

float EfHairControllerRangeMultiplier(float positive, float negative)
{
    return EfHairControllerPositiveMultiplier(positive)
        * (1.0 - saturate(negative));
}
#endif

float EfHairControllerHighlightIntensity(float bakedIntensity)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return max(
        0.0,
        bakedIntensity * EfHairControllerRangeMultiplier(
            EfHairHighlightIntensityP, EfHairHighlightIntensityM));
#else
    float control = EfHairControllerSigned(
        EfHairHighlightIntensityP, EfHairHighlightIntensityM);
    return max(0.0, bakedIntensity * (1.0 + control));
#endif
}

float EfHairControllerHeightOffset()
{
    float offsetScale = 1.0;
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    offsetScale = EF_HAIR_CONTROLLER_OFFSET_SCALE;
#endif
    return 0.25 * offsetScale
        * EfHairControllerSigned(EfHairHighlightUp, EfHairHighlightDown);
}

float EfHairControllerUpperCutSoftness(float bakedSoftness)
{
    float sharper = saturate(EfHairUpperSharpnessP);
    float softer = saturate(EfHairUpperSharpnessM);
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float minimumSoftness = 0.001 / max(EF_HAIR_CONTROLLER_OFFSET_SCALE, 1.0);
    float maximumSoftness = 0.1 * max(EF_HAIR_CONTROLLER_OFFSET_SCALE, 1.0);
    return clamp(
        bakedSoftness - (bakedSoftness - minimumSoftness) * sharper
            + (maximumSoftness - bakedSoftness) * softer,
        minimumSoftness, maximumSoftness);
#else
    return clamp(
        bakedSoftness - (bakedSoftness - 0.001) * sharper
            + (0.1 - bakedSoftness) * softer,
        0.001, 0.1);
#endif
}

float EfHairControllerLowerFadePower(float bakedPower)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float rangeScale = max(EF_HAIR_CONTROLLER_OFFSET_SCALE, 1.0);
    return clamp(
        bakedPower - 0.4 * rangeScale * saturate(EfHairLowerSoftnessP)
            + 0.5 * rangeScale * saturate(EfHairLowerSoftnessM),
        0.2 / rangeScale, 1.5 * rangeScale);
#else
    return clamp(
        bakedPower - 0.4 * saturate(EfHairLowerSoftnessP)
            + 0.5 * saturate(EfHairLowerSoftnessM),
        0.2, 1.5);
#endif
}

float EfHairControllerUpperRatioOffset()
{
    float offsetScale = 1.0;
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    offsetScale = EF_HAIR_CONTROLLER_OFFSET_SCALE;
#endif
    return 0.15 * offsetScale
        * EfHairControllerSigned(EfHairUpperRatioP, EfHairUpperRatioM);
}

float EfHairControllerLayerHalfWidth(float bakedMin, float bakedMax)
{
    float bakedHalfWidth = 0.5 * max(bakedMax - bakedMin, 0.001);
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float rangeScale = max(EF_HAIR_CONTROLLER_OFFSET_SCALE, 1.0);
    return clamp(
        bakedHalfWidth + 0.1 * rangeScale * EfHairControllerSigned(
            EfHairLayerBlendP, EfHairLayerBlendM),
        0.02 / rangeScale, 0.5);
#else
    return clamp(
        bakedHalfWidth + 0.1 * EfHairControllerSigned(
            EfHairLayerBlendP, EfHairLayerBlendM),
        0.02, 0.3);
#endif
}

float EfHairControllerWarmth(float bakedWarmth)
{
    return saturate(
        bakedWarmth + (1.0 - bakedWarmth) * saturate(EfHairHighlightWarmthP)
            - bakedWarmth * saturate(EfHairHighlightWarmthM));
}

float3 EfHairControllerAdjustRgb(
    float3 color, float3 positive, float3 negative)
{
    return saturate(color + (1.0 - color) * saturate(positive)
        - color * saturate(negative));
}

float3 EfHairControllerMiddleColor(float3 color)
{
    float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float saturation = EfHairControllerRangeMultiplier(
        EfHairMiddleSaturationP, EfHairMiddleSaturationM);
#else
    float saturation = clamp(
        1.0 + EfHairControllerSigned(
            EfHairMiddleSaturationP, EfHairMiddleSaturationM),
        0.0, 2.0);
#endif
    float3 saturatedColor = lerp(luminance.xxx, color, saturation);
    return EfHairControllerAdjustRgb(
        saturatedColor,
        float3(EfHairMiddleRP, EfHairMiddleGP, EfHairMiddleBP),
        float3(EfHairMiddleRM, EfHairMiddleGM, EfHairMiddleBM));
}

float3 EfHairControllerUpperColor(float3 color)
{
    return EfHairControllerAdjustRgb(
        color,
        float3(EfHairUpperRP, EfHairUpperGP, EfHairUpperBP),
        float3(EfHairUpperRM, EfHairUpperGM, EfHairUpperBM));
}

float3 EfHairControllerApplyBaseGrade(float3 color)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float3 tint = max(float3(
        EfHairControllerRangeMultiplier(EfHairBaseRP, EfHairBaseRM),
        EfHairControllerRangeMultiplier(EfHairBaseGP, EfHairBaseGM),
        EfHairControllerRangeMultiplier(EfHairBaseBP, EfHairBaseBM)), 0.0);
#else
    float3 tint = max(float3(
        1.0 + EfHairControllerSigned(EfHairBaseRP, EfHairBaseRM),
        1.0 + EfHairControllerSigned(EfHairBaseGP, EfHairBaseGM),
        1.0 + EfHairControllerSigned(EfHairBaseBP, EfHairBaseBM)), 0.0);
#endif
    float3 graded = max(color * tint, 0.0);
    float luminance = dot(graded, float3(0.2126, 0.7152, 0.0722));
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float saturation = EfHairControllerRangeMultiplier(
        EfHairBaseSaturationP, EfHairBaseSaturationM);
    float brightness = EfHairControllerRangeMultiplier(
        EfHairBaseBrightnessP, EfHairBaseBrightnessM);
    float exposureStops = EF_HAIR_CONTROLLER_OFFSET_SCALE
        * EfHairControllerSigned(EfHairBaseExposureP, EfHairBaseExposureM);
#else
    float saturation = clamp(
        1.0 + EfHairControllerSigned(
            EfHairBaseSaturationP, EfHairBaseSaturationM),
        0.0, 2.0);
    float brightness = clamp(
        1.0 + EfHairControllerSigned(
            EfHairBaseBrightnessP, EfHairBaseBrightnessM),
        0.0, 2.0);
    float exposureStops = EfHairControllerSigned(
        EfHairBaseExposureP, EfHairBaseExposureM);
#endif
    return max(
        lerp(luminance.xxx, graded, saturation)
            * brightness * exp2(exposureStops),
        0.0);
}

// C6 can evaluate controller-only grade parameters per vertex and interpolate
// their constant result. This preserves the exact pixel-grade math while
// removing uniform exp2 and range mapping from the ps_3_0 budget.
void EfHairControllerBaseGradeParameters(
    out float3 tintGain, out float saturation)
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    float3 tint = max(float3(
        EfHairControllerRangeMultiplier(EfHairBaseRP, EfHairBaseRM),
        EfHairControllerRangeMultiplier(EfHairBaseGP, EfHairBaseGM),
        EfHairControllerRangeMultiplier(EfHairBaseBP, EfHairBaseBM)), 0.0);
    saturation = EfHairControllerRangeMultiplier(
        EfHairBaseSaturationP, EfHairBaseSaturationM);
    float brightness = EfHairControllerRangeMultiplier(
        EfHairBaseBrightnessP, EfHairBaseBrightnessM);
    float exposureStops = EF_HAIR_CONTROLLER_OFFSET_SCALE
        * EfHairControllerSigned(EfHairBaseExposureP, EfHairBaseExposureM);
#else
    float3 tint = max(float3(
        1.0 + EfHairControllerSigned(EfHairBaseRP, EfHairBaseRM),
        1.0 + EfHairControllerSigned(EfHairBaseGP, EfHairBaseGM),
        1.0 + EfHairControllerSigned(EfHairBaseBP, EfHairBaseBM)), 0.0);
    saturation = clamp(
        1.0 + EfHairControllerSigned(
            EfHairBaseSaturationP, EfHairBaseSaturationM),
        0.0, 2.0);
    float brightness = clamp(
        1.0 + EfHairControllerSigned(
            EfHairBaseBrightnessP, EfHairBaseBrightnessM),
        0.0, 2.0);
    float exposureStops = EfHairControllerSigned(
        EfHairBaseExposureP, EfHairBaseExposureM);
#endif
    tintGain = tint * brightness * exp2(exposureStops);
}

float EfHairControllerRimMultiplier()
{
#if EF_HAIR_CONTROLLER_RANGE5_ENABLED
    return EfHairControllerRangeMultiplier(
        EfHairRimStrengthP, EfHairRimStrengthM);
#else
    return clamp(
        1.0 + EfHairControllerSigned(EfHairRimStrengthP, EfHairRimStrengthM),
        0.0, 2.0);
#endif
}

#endif
