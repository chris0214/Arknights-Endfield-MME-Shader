// Endfield MME - clothing runtime controller parameters.
// All-zero morphs preserve the baked clothing shader values exactly.
#ifndef ENDFIELD_CLOTH_CONTROLS_INCLUDED
#define ENDFIELD_CLOTH_CONTROLS_INCLUDED

#ifndef EF_CLOTH_CONTROLLER_NAME
#define EF_CLOTH_CONTROLLER_NAME "EndfieldCloth_controller.pmx"
#endif
#ifndef EF_CLOTH_CONTROLLER_MAX_MULTIPLIER
#define EF_CLOTH_CONTROLLER_MAX_MULTIPLIER 5.0
#endif
#ifndef EF_CLOTH_RIM_CONTRAST_MIN
#define EF_CLOTH_RIM_CONTRAST_MIN 0.25
#endif
#ifndef EF_CLOTH_RIM_CONTRAST_MAX
#define EF_CLOTH_RIM_CONTRAST_MAX 8.0
#endif

// Tone
float EfClothLightP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆß•ž—º•”+"; >;
float EfClothLightM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆß•ž—º•”-"; >;
float EfClothDarkP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆß•žˆÃ•”+"; >;
float EfClothDarkM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆß•žˆÃ•”-"; >;
float EfClothRampCurveP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "–¾ˆÃ‹Èü+"; >;
float EfClothRampCurveM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "–¾ˆÃ‹Èü-"; >;
float EfClothRdColorP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "RDF‹­+"; >;
float EfClothRdColorM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "RDF‹­-"; >;
float EfClothLutP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "LUT‹­+"; >;
float EfClothLutM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "LUT‹­-"; >;

// AO
float EfClothAoDarkP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÃ•”AO+"; >;
float EfClothAoDarkM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÃ•”AO-"; >;
float EfClothAoLightP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "—º•”AO+"; >;
float EfClothAoLightM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "—º•”AO-"; >;

// Surface
float EfClothMetallicP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‹à‘®“x+"; >;
float EfClothMetallicM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‹à‘®“x-"; >;
float EfClothRoughnessP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‘e“x+"; >;
float EfClothRoughnessM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‘e“x-"; >;
float EfClothReflectivityP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "”½ŽË“x+"; >;
float EfClothReflectivityM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "”½ŽË“x-"; >;
float EfClothRsP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "RS‹­+"; >;
float EfClothRsM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "RS‹­-"; >;
float EfClothNormalStrengthP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "–@ü‹­+"; >;
float EfClothNormalStrengthM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "–@ü‹­-"; >;
float EfClothNormalFlipY : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "–@üY”½Œü"; >;

// Direct and directional specular
float EfClothSpecularP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‚Œõ‹­+"; >;
float EfClothSpecularM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‚Œõ‹­-"; >;
float EfClothBroadSpecularP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "Lˆæ‚Œõ+"; >;
float EfClothBroadSpecularM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "Lˆæ‚Œõ-"; >;
float EfClothAnisoSpecularP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•û‚Œõ+"; >;
float EfClothAnisoSpecularM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•û‚Œõ-"; >;
float EfClothAnisoAmountP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•û’ö“x+"; >;
float EfClothAnisoAmountM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•û’ö“x-"; >;
float EfClothAnisoAxisP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•ûŽ²+"; >;
float EfClothAnisoAxisM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•ûŽ²-"; >;
float EfClothAnisoRoughnessP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•û‘e“x+"; >;
float EfClothAnisoRoughnessM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ˆÙ•û‘e“x-"; >;

// Environment
float EfClothEnvMode : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«–ÍŽ®"; >;
float EfClothFgdOff : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "FGD•Â"; >;
float EfClothEnvSpecularP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«‚Œõ+"; >;
float EfClothEnvSpecularM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«‚Œõ-"; >;
float EfClothMatcapBlurP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "”½ŽË–ÍŒÐ+"; >;
float EfClothMatcapBlurM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "”½ŽË–ÍŒÐ-"; >;
float EfClothEnvRotationP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«ù“]+"; >;
float EfClothEnvRotationM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«ù“]-"; >;
float EfClothEnvAoP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«AO+"; >;
float EfClothEnvAoM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«AO-"; >;
float EfClothEnvRP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«Ô+"; >;
float EfClothEnvRM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«Ô-"; >;
float EfClothEnvGP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«—Î+"; >;
float EfClothEnvGM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«—Î-"; >;
float EfClothEnvBP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«Â+"; >;
float EfClothEnvBM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«Â-"; >;

// Rim
float EfClothRimStrengthP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõ‹­+"; >;
float EfClothRimStrengthM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõ‹­-"; >;
float EfClothRimWidthP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõ•+"; >;
float EfClothRimWidthM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõ•-"; >;
float EfClothScreenRimStrengthP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "› –‹•ÓŒõ‹­+"; >;
float EfClothScreenRimStrengthM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "› –‹•ÓŒõ‹­-"; >;
float EfClothScreenRimWidthP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "› –‹•ÓŒõ•+"; >;
float EfClothScreenRimWidthM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "› –‹•ÓŒõ•-"; >;
float EfClothRimContrastP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõd+"; >;
float EfClothRimContrastM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõd-"; >;
float EfClothRimColorMode : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõFØ"; >;
float EfClothRimRP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõÔ+"; >;
float EfClothRimRM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõÔ-"; >;
float EfClothRimGP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõ—Î+"; >;
float EfClothRimGM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõ—Î-"; >;
float EfClothRimBP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõÂ+"; >;
float EfClothRimBM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "•ÓŒõÂ-"; >;

// Shadow
float EfClothShadowStrengthP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‰A‰e‹­+"; >;
float EfClothShadowStrengthM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‰A‰e‹­-"; >;
float EfClothShadowSoftnessP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‰A‰e_+"; >;
float EfClothShadowSoftnessM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‰A‰e_-"; >;
float EfClothShadowCenterP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‰A‰eˆÊ’u+"; >;
float EfClothShadowCenterM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "‰A‰eˆÊ’u-"; >;
float EfClothDirectShadowFloorP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "’¼ŽË‰A‰e’ê+"; >;
float EfClothDirectShadowFloorM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "’¼ŽË‰A‰e’ê-"; >;
float EfClothEnvShadowP : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«‰A‰e+"; >;
float EfClothEnvShadowM : CONTROLOBJECT < string name = EF_CLOTH_CONTROLLER_NAME; string item = "ŠÂ‹«‰A‰e-"; >;

float EfClothControllerSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float EfClothControllerBounded(
    float bakedValue, float positive, float negative,
    float minimumValue, float maximumValue)
{
    float neutral = clamp(bakedValue, minimumValue, maximumValue);
    float control = EfClothControllerSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue,
        maximumValue);
}

float EfClothControllerMultiplier(
    float bakedValue, float positive, float negative)
{
    float control = EfClothControllerSigned(positive, negative);
    float multiplier = 1.0
        + (max(EF_CLOTH_CONTROLLER_MAX_MULTIPLIER, 1.0) - 1.0)
            * max(control, 0.0)
        - max(-control, 0.0);
    return max(bakedValue, 0.0) * max(multiplier, 0.0);
}

float3 EfClothControllerRgb(
    float3 bakedColor, float3 positive, float3 negative)
{
    return float3(
        EfClothControllerBounded(bakedColor.r, positive.r, negative.r, 0.0, 1.0),
        EfClothControllerBounded(bakedColor.g, positive.g, negative.g, 0.0, 1.0),
        EfClothControllerBounded(bakedColor.b, positive.b, negative.b, 0.0, 1.0));
}

float EfClothControllerLight(float value) { return EfClothControllerMultiplier(value, EfClothLightP, EfClothLightM); }
float EfClothControllerDark(float value) { return EfClothControllerMultiplier(value, EfClothDarkP, EfClothDarkM); }
float EfClothControllerRampCurve(float value) { return EfClothControllerBounded(value, EfClothRampCurveP, EfClothRampCurveM, 0.1, 5.0); }
float EfClothControllerRdColor(float value) { return EfClothControllerBounded(value, EfClothRdColorP, EfClothRdColorM, 0.0, 1.0); }
float EfClothControllerLut(float value) { return EfClothControllerBounded(value, EfClothLutP, EfClothLutM, 0.0, 1.0); }
float EfClothControllerAoDark(float value) { return EfClothControllerBounded(value, EfClothAoDarkP, EfClothAoDarkM, 0.0, 1.0); }
float EfClothControllerAoLight(float value) { return EfClothControllerBounded(value, EfClothAoLightP, EfClothAoLightM, 0.0, 1.0); }
float EfClothControllerMetallic(float value) { return EfClothControllerBounded(value, EfClothMetallicP, EfClothMetallicM, 0.0, 1.0); }
float EfClothControllerRoughness(float value) { return EfClothControllerMultiplier(value, EfClothRoughnessP, EfClothRoughnessM); }
float EfClothControllerReflectivity(float value) { return EfClothControllerBounded(value, EfClothReflectivityP, EfClothReflectivityM, 0.0, 1.0); }
float EfClothControllerRs(float value) { return EfClothControllerBounded(value, EfClothRsP, EfClothRsM, 0.0, 1.0); }
float EfClothControllerNormalStrength(float value) { return EfClothControllerMultiplier(value, EfClothNormalStrengthP, EfClothNormalStrengthM); }
float EfClothControllerNormalYSign() { return lerp(1.0, -1.0, saturate(EfClothNormalFlipY)); }
float EfClothControllerSpecular(float value) { return EfClothControllerMultiplier(value, EfClothSpecularP, EfClothSpecularM); }
float EfClothControllerBroadSpecular(float value) { return EfClothControllerMultiplier(value, EfClothBroadSpecularP, EfClothBroadSpecularM); }
float EfClothControllerAnisoSpecular(float value) { return EfClothControllerMultiplier(value, EfClothAnisoSpecularP, EfClothAnisoSpecularM); }
float EfClothControllerAnisoAmount(float value) { return EfClothControllerBounded(value, EfClothAnisoAmountP, EfClothAnisoAmountM, 0.0, 1.0); }
float EfClothControllerAnisoAxis(float value) { return EfClothControllerBounded(value, EfClothAnisoAxisP, EfClothAnisoAxisM, 0.0, 1.0); }
float EfClothControllerAnisoRoughness(float value) { return EfClothControllerBounded(value, EfClothAnisoRoughnessP, EfClothAnisoRoughnessM, 0.02, 1.0); }
float EfClothControllerEnvMode() { return saturate(EfClothEnvMode); }
float EfClothControllerFgdStrength() { return 1.0 - saturate(EfClothFgdOff); }
float EfClothControllerEnvSpecular(float value) { return EfClothControllerMultiplier(value, EfClothEnvSpecularP, EfClothEnvSpecularM); }
float EfClothControllerMatcapLodScale(float value) { return EfClothControllerMultiplier(value, EfClothMatcapBlurP, EfClothMatcapBlurM); }
float EfClothControllerEnvRotation(float value) { return clamp(value + 180.0 * EfClothControllerSigned(EfClothEnvRotationP, EfClothEnvRotationM), -180.0, 180.0); }
float EfClothControllerEnvAo(float value) { return EfClothControllerBounded(value, EfClothEnvAoP, EfClothEnvAoM, 0.0, 1.0); }
float3 EfClothControllerEnvColor(float3 value) { return EfClothControllerRgb(value, float3(EfClothEnvRP, EfClothEnvGP, EfClothEnvBP), float3(EfClothEnvRM, EfClothEnvGM, EfClothEnvBM)); }
float EfClothControllerRimStrength(float value) { return EfClothControllerMultiplier(value, EfClothRimStrengthP, EfClothRimStrengthM); }
float EfClothControllerRimWidth(float value) { return EfClothControllerBounded(value, EfClothRimWidthP, EfClothRimWidthM, 0.02, 1.0); }
float EfClothControllerScreenRimStrength(float value) { return EfClothControllerMultiplier(value, EfClothScreenRimStrengthP, EfClothScreenRimStrengthM); }
float EfClothControllerScreenRimWidth(float value) { return EfClothControllerMultiplier(value, EfClothScreenRimWidthP, EfClothScreenRimWidthM); }
float EfClothControllerRimContrast() { return EfClothControllerBounded(1.0, EfClothRimContrastP, EfClothRimContrastM, EF_CLOTH_RIM_CONTRAST_MIN, EF_CLOTH_RIM_CONTRAST_MAX); }
float3 EfClothControllerRimColor(float3 edgeColor, float3 bakedColor)
{
    float3 manualColor = EfClothControllerRgb(
        bakedColor,
        float3(EfClothRimRP, EfClothRimGP, EfClothRimBP),
        float3(EfClothRimRM, EfClothRimGM, EfClothRimBM));
    return lerp(saturate(edgeColor), manualColor, saturate(EfClothRimColorMode));
}
float EfClothControllerShadowStrength(float value) { return EfClothControllerMultiplier(value, EfClothShadowStrengthP, EfClothShadowStrengthM); }
float EfClothControllerShadowSoftness(float value) { return EfClothControllerBounded(value, EfClothShadowSoftnessP, EfClothShadowSoftnessM, 0.02, 2.0); }
float EfClothControllerShadowCenter(float value) { return EfClothControllerBounded(value, EfClothShadowCenterP, EfClothShadowCenterM, 0.0, 1.0); }
float EfClothControllerDirectShadowFloor(float value) { return EfClothControllerBounded(value, EfClothDirectShadowFloorP, EfClothDirectShadowFloorM, 0.0, 1.0); }
float EfClothControllerEnvShadow(float value) { return EfClothControllerBounded(value, EfClothEnvShadowP, EfClothEnvShadowM, 0.0, 1.0); }

#endif
