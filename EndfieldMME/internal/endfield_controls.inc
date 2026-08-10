// Endfield MME - runtime controller parameters (Endfield_controller.pmx morphs)
// and their +/++/- multiplier helpers. All item names are ASCII for M1, so this
// Labels use CP932-safe Chinese-readable Han characters. A missing controller
// model makes every morph
// read 0, which leaves each helper at its neutral default.
#ifndef ENDFIELD_CONTROLS_INCLUDED
#define ENDFIELD_CONTROLS_INCLUDED

#include "internal/endfield_global_controls.inc"

// „Ÿ„Ÿ Light „Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ
float EfLightIntensityP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“”Œõ‹­+"; >;
float EfLightIntensityPP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“”Œõ‹­++"; >;
float EfLightIntensityM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“”Œõ‹­-"; >;
float EfLightRP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“”ŒõÔ+"; >;
float EfLightGP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“”Œõ—Î+"; >;
float EfLightBP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“”ŒõÂ+"; >;
// Day / weather blend. Defaults to sunny (1.0) via the +/- pair below.
float EfDayP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“úŒõ‹­+"; >;
float EfDayM : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "“úŒõ‹­-"; >;

// „Ÿ„Ÿ Tone / shadow „Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ
float EfRampP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "–¾ˆÃü+"; >;
float EfRampM : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "–¾ˆÃü-"; >;
float EfShadowP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‰A‰e‹­+"; >;
float EfShadowM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‰A‰e‹­-"; >;
float EfSelfShadowP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "Ž©‰A‰e+"; >;
float EfSelfShadowPP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "Ž©‰A‰e++"; >;
float EfSelfShadowM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "Ž©‰A‰e-"; >;

// „Ÿ„Ÿ Specular / rim „Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ
float EfSpecularP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‘S‹Ç‚Œõ+"; >;
float EfSpecularPP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‘S‹Ç‚Œõ++"; >;
float EfSpecularM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‘S‹Ç‚Œõ-"; >;
float EfRimP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‘S‹Ç•ÓŒõ+"; >;
float EfRimM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "‘S‹Ç•ÓŒõ-"; >;
// Hair highlight vertical shift (view-dir Y offset). Up raises the band.
float EfHairSpecShiftP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯‚ŒõãˆÚ"; >;
float EfHairSpecShiftM : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯‚Œõ‰ºˆÚ"; >;

// „Ÿ„Ÿ Hair color grade „Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ„Ÿ
float EfHairSaturationP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯–O˜a+"; >;
float EfHairSaturationM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯–O˜a-"; >;
float EfHairBrightnessP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯—º“x+"; >;
float EfHairBrightnessM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯—º“x-"; >;
float EfHairExposureP    : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯”˜Œõ+"; >;
float EfHairExposureM    : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "”¯”˜Œõ-"; >;

// „Ÿ„Ÿ Multiplier helpers (neutral = 1.0 when all morphs are 0) „Ÿ„Ÿ„Ÿ„Ÿ
float EfSelfShadowCtrl() { return clamp(1.0 + EfSelfShadowP + 2.0 * EfSelfShadowPP - EfSelfShadowM, 0.0, 4.0); }
float EfRimMul()         { return clamp(1.0 + EfRimP - EfRimM, 0.0, 4.0); }
// Controller delta added to the baked highlight Y offset. +-1 morph => +-0.5.
float EfHairSpecShift()  { return 0.5 * (saturate(EfHairSpecShiftP) - saturate(EfHairSpecShiftM)); }

float EfSpecularMul()
{
    float positive = lerp(1.0, 10.0, saturate(EfSpecularP)) + 10.0 * saturate(EfSpecularPP);
    return lerp(positive, 0.0, saturate(EfSpecularM));
}

// Day strength in [0,1]; defaults to 1.0 (sunny) with no morph input. Day-
// blends toward the cloudy (0) state; Day+ is kept for symmetry/headroom.
float EfDayStrength() { return saturate(1.0 + saturate(EfDayP) - saturate(EfDayM)); }

float3 EfControlledLightColor()
{
    float3 color = max(LightColor, 0.0);
    float maxC = max(max(EfLightRP, EfLightGP), EfLightBP);
    float minC = min(min(EfLightRP, EfLightGP), EfLightBP);
    float range = maxC - minC;
    if (range > 1e-5) {
        float3 ratio = (float3(EfLightRP, EfLightGP, EfLightBP) - minC) / range;
        color *= ratio * range + 1.0 - range;
    }
    float positiveIntensity = lerp(1.0, 10.0, saturate(EfLightIntensityP)) + 10.0 * saturate(EfLightIntensityPP);
    float intensity = lerp(positiveIntensity, 0.0, saturate(EfLightIntensityM));
    return color * intensity;
}

float3 EfApplyColorGrade(float3 color, float saturation, float brightness, float exposure)
{
    float3 graded = max(color, 0.0);
    float luminance = dot(graded, float3(0.2126, 0.7152, 0.0722));
    graded = lerp(luminance.xxx, graded, saturation);
    graded *= brightness * exposure;
    return max(graded, 0.0);
}

float3 EfApplyHairColorGrade(float3 color)
{
    float sat  = clamp(1.0 + EfHairSaturationP - EfHairSaturationM, 0.0, 4.0);
    float brt  = clamp(1.0 + EfHairBrightnessP - EfHairBrightnessM, 0.0, 4.0);
    float stops = clamp(EfHairExposureP - EfHairExposureM, -2.0, 3.0);
    return EfApplyColorGrade(color, sat, brt, exp2(stops));
}

#endif
