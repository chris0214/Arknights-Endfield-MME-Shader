// Endfield MME - body-skin runtime controller parameters.
// All-zero morphs preserve the baked skin shader values exactly.
#ifndef ENDFIELD_SKIN_CONTROLS_INCLUDED
#define ENDFIELD_SKIN_CONTROLS_INCLUDED

#ifndef EF_SKIN_CONTROLLER_NAME
#define EF_SKIN_CONTROLLER_NAME "EndfieldSkin_controller.pmx"
#endif
#ifndef EF_SKIN_CONTROLLER_MAX_MULTIPLIER
#define EF_SKIN_CONTROLLER_MAX_MULTIPLIER 5.0
#endif
#ifndef EF_SKIN_SPECULAR_CONTROLLER_MAX_MULTIPLIER
#define EF_SKIN_SPECULAR_CONTROLLER_MAX_MULTIPLIER 25.0
#endif
#ifndef EF_SKIN_LIGHT_CURVE_MIN
#define EF_SKIN_LIGHT_CURVE_MIN 0.1
#endif
#ifndef EF_SKIN_LIGHT_CURVE_MAX
#define EF_SKIN_LIGHT_CURVE_MAX 5.0
#endif
#ifndef EF_SKIN_SSS_RANGE_MAX
#define EF_SKIN_SSS_RANGE_MAX 5.0
#endif
#ifndef EF_SKIN_SHADOW_SMOOTHNESS_MIN
#define EF_SKIN_SHADOW_SMOOTHNESS_MIN 0.02
#endif
#ifndef EF_SKIN_SHADOW_SMOOTHNESS_MAX
#define EF_SKIN_SHADOW_SMOOTHNESS_MAX 2.0
#endif
#ifndef EF_SKIN_RIM_AREA_MIN
#define EF_SKIN_RIM_AREA_MIN 0.02
#endif
#ifndef EF_SKIN_RIM_AREA_MAX
#define EF_SKIN_RIM_AREA_MAX 1.0
#endif
#ifndef EF_SKIN_RIM_CONTRAST_MIN
#define EF_SKIN_RIM_CONTRAST_MIN 0.25
#endif
#ifndef EF_SKIN_RIM_CONTRAST_MAX
#define EF_SKIN_RIM_CONTRAST_MAX 8.0
#endif

// Skin Tone
float EfSkinLightP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "”ç•†—º•”+"; >;
float EfSkinLightM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "”ç•†—º•”-"; >;
float EfSkinDarkP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "”ç•†ˆÃ•”+"; >;
float EfSkinDarkM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "”ç•†ˆÃ•”-"; >;
float EfSkinRampCurveP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "–¾ˆÃ‹Èü+"; >;
float EfSkinRampCurveM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "–¾ˆÃ‹Èü-"; >;
float EfSkinRdColorP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "RDF‹­+"; >;
float EfSkinRdColorM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "RDF‹­-"; >;
float EfSkinLutP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "LUT‹­+"; >;
float EfSkinLutM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "LUT‹­-"; >;

// Skin SSS
float EfSkinSssRangeP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSS”ÍˆÍ+"; >;
float EfSkinSssRangeM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSS”ÍˆÍ-"; >;
float EfSkinSssStrengthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSS‹­+"; >;
float EfSkinSssStrengthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSS‹­-"; >;
float EfSkinSssRP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSSÔ+"; >;
float EfSkinSssRM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSSÔ-"; >;
float EfSkinSssGP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSS—Î+"; >;
float EfSkinSssGM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSS—Î-"; >;
float EfSkinSssBP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSSÂ+"; >;
float EfSkinSssBM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "SSSÂ-"; >;

// Skin Shadow
float EfSkinShadowStrengthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "‰A‰e‹­+"; >;
float EfSkinShadowStrengthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "‰A‰e‹­-"; >;
float EfSkinShadowSoftnessP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "‰A‰e_+"; >;
float EfSkinShadowSoftnessM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "‰A‰e_-"; >;
float EfSkinShadowCenterP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "‰A‰eˆÊ’u+"; >;
float EfSkinShadowCenterM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "‰A‰eˆÊ’u-"; >;

// Skin Specular
float EfSkinSpecStrengthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "”÷‚Œõ‹­+"; >;
float EfSkinSpecStrengthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "”÷‚Œõ‹­-"; >;

// Skin Rim
float EfSkinRimStrengthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõ‹­+"; >;
float EfSkinRimStrengthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõ‹­-"; >;
float EfSkinRimWidthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõ•+"; >;
float EfSkinRimWidthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõ•-"; >;
float EfSkinRimRP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõÔ+"; >;
float EfSkinRimRM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõÔ-"; >;
float EfSkinRimGP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõ—Î+"; >;
float EfSkinRimGM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõ—Î-"; >;
float EfSkinRimBP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõÂ+"; >;
float EfSkinRimBM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõÂ-"; >;
float EfSkinScreenRimStrengthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "› –‹•ÓŒõ‹­+"; >;
float EfSkinScreenRimStrengthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "› –‹•ÓŒõ‹­-"; >;
float EfSkinScreenRimWidthP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "› –‹•ÓŒõ•+"; >;
float EfSkinScreenRimWidthM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "› –‹•ÓŒõ•-"; >;
float EfSkinRimColorMode : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõFØ"; >;
float EfSkinRimContrastP : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõd+"; >;
float EfSkinRimContrastM : CONTROLOBJECT < string name = EF_SKIN_CONTROLLER_NAME; string item = "•ÓŒõd-"; >;

float EfSkinControllerSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float EfSkinControllerBounded(
    float bakedValue, float positive, float negative,
    float minimumValue, float maximumValue)
{
    float neutral = clamp(bakedValue, minimumValue, maximumValue);
    float control = EfSkinControllerSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue, maximumValue);
}

float EfSkinControllerMultiplier(
    float bakedValue, float positive, float negative)
{
    float control = EfSkinControllerSigned(positive, negative);
    float multiplier = 1.0
        + (max(EF_SKIN_CONTROLLER_MAX_MULTIPLIER, 1.0) - 1.0)
            * max(control, 0.0)
        - max(-control, 0.0);
    return max(bakedValue, 0.0) * max(multiplier, 0.0);
}

float3 EfSkinControllerRgb(
    float3 bakedColor, float3 positive, float3 negative)
{
    return float3(
        EfSkinControllerBounded(
            bakedColor.r, positive.r, negative.r, 0.0, 1.0),
        EfSkinControllerBounded(
            bakedColor.g, positive.g, negative.g, 0.0, 1.0),
        EfSkinControllerBounded(
            bakedColor.b, positive.b, negative.b, 0.0, 1.0));
}

float EfSkinControllerLightStrength(float bakedValue)
{
    return EfSkinControllerMultiplier(bakedValue, EfSkinLightP, EfSkinLightM);
}

float EfSkinControllerDarkStrength(float bakedValue)
{
    return EfSkinControllerMultiplier(bakedValue, EfSkinDarkP, EfSkinDarkM);
}

float EfSkinControllerLightCurve(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinRampCurveP, EfSkinRampCurveM,
        EF_SKIN_LIGHT_CURVE_MIN, EF_SKIN_LIGHT_CURVE_MAX);
}

float EfSkinControllerRdColor(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinRdColorP, EfSkinRdColorM, 0.0, 1.0);
}

float EfSkinControllerLut(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinLutP, EfSkinLutM, 0.0, 1.0);
}

float EfSkinControllerSssRange(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinSssRangeP, EfSkinSssRangeM,
        0.0, EF_SKIN_SSS_RANGE_MAX);
}

float EfSkinControllerSssStrength(float bakedValue)
{
    return EfSkinControllerMultiplier(
        bakedValue, EfSkinSssStrengthP, EfSkinSssStrengthM);
}

float3 EfSkinControllerSssColor(float3 bakedColor)
{
    return EfSkinControllerRgb(
        bakedColor,
        float3(EfSkinSssRP, EfSkinSssGP, EfSkinSssBP),
        float3(EfSkinSssRM, EfSkinSssGM, EfSkinSssBM));
}

float EfSkinControllerShadowStrength(float bakedValue)
{
    return EfSkinControllerMultiplier(
        bakedValue, EfSkinShadowStrengthP, EfSkinShadowStrengthM);
}

float EfSkinControllerShadowSoftness(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinShadowSoftnessP, EfSkinShadowSoftnessM,
        EF_SKIN_SHADOW_SMOOTHNESS_MIN,
        EF_SKIN_SHADOW_SMOOTHNESS_MAX);
}

float EfSkinControllerShadowCenter(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinShadowCenterP, EfSkinShadowCenterM, 0.0, 1.0);
}

float EfSkinControllerSpecularStrength(float bakedValue)
{
    float control = EfSkinControllerSigned(
        EfSkinSpecStrengthP, EfSkinSpecStrengthM);
    float multiplier = 1.0
        + (max(EF_SKIN_SPECULAR_CONTROLLER_MAX_MULTIPLIER, 1.0) - 1.0)
            * max(control, 0.0)
        - max(-control, 0.0);
    return max(bakedValue, 0.0) * max(multiplier, 0.0);
}

float EfSkinControllerRimStrength(float bakedValue)
{
    return EfSkinControllerMultiplier(
        bakedValue, EfSkinRimStrengthP, EfSkinRimStrengthM);
}

float EfSkinControllerRimArea(float bakedValue)
{
    return EfSkinControllerBounded(
        bakedValue, EfSkinRimWidthP, EfSkinRimWidthM,
        EF_SKIN_RIM_AREA_MIN, EF_SKIN_RIM_AREA_MAX);
}

float3 EfSkinControllerRimColor(float3 edgeColor, float3 bakedColor)
{
    float3 manualColor = EfSkinControllerRgb(
        bakedColor,
        float3(EfSkinRimRP, EfSkinRimGP, EfSkinRimBP),
        float3(EfSkinRimRM, EfSkinRimGM, EfSkinRimBM));
    return lerp(
        saturate(edgeColor), manualColor,
        saturate(EfSkinRimColorMode));
}

float EfSkinControllerRimContrast()
{
    float control = EfSkinControllerSigned(
        EfSkinRimContrastP, EfSkinRimContrastM);
    return clamp(
        1.0
            + (EF_SKIN_RIM_CONTRAST_MAX - 1.0) * max(control, 0.0)
            - (1.0 - EF_SKIN_RIM_CONTRAST_MIN) * max(-control, 0.0),
        EF_SKIN_RIM_CONTRAST_MIN,
        EF_SKIN_RIM_CONTRAST_MAX);
}

float EfSkinControllerScreenRimStrength(float bakedValue)
{
    return EfSkinControllerMultiplier(
        bakedValue,
        EfSkinScreenRimStrengthP,
        EfSkinScreenRimStrengthM);
}

float EfSkinControllerScreenRimWidth(float bakedValue)
{
    return EfSkinControllerMultiplier(
        bakedValue,
        EfSkinScreenRimWidthP,
        EfSkinScreenRimWidthM);
}

#endif
