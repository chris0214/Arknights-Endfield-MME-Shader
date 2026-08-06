// Endfield MME - post-processing controller parameters.
// This file is converted to CP932 after editing for legacy MME compatibility.
#ifndef ENDFIELD_POST_CONTROLS_INCLUDED
#define ENDFIELD_POST_CONTROLS_INCLUDED

#ifndef EF_POST_CONTROLLER_NAME
#define EF_POST_CONTROLLER_NAME "EndfieldPost_controller.pmx"
#endif

// Mode controls. All zero selects Log2. Multiple active modes blend.
float EfPostModeGt : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "GT–ÍŽ®"; >;
float EfPostModeAgx : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "AgX–ÍŽ®"; >;
float EfPostModeNeutral : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Neutral–ÍŽ®"; >;
float EfPostModeAces : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "ACES–ÍŽ®"; >;
float EfPostModeOriginal : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Œ´F–ÍŽ®"; >;

// Common grade.
float EfPostExposureP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "”˜Œõ+"; >;
float EfPostExposureM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "”˜Œõ-"; >;
float EfPostContrastP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "‘Î”ä+"; >;
float EfPostContrastM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "‘Î”ä-"; >;
float EfPostSaturationP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "–O˜a+"; >;
float EfPostSaturationM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "–O˜a-"; >;

// Curve-specific controls.
float EfPostLog2StrengthP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Log2‹Èü+"; >;
float EfPostLog2StrengthM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Log2‹Èü-"; >;
float EfPostGtContrastP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "GT‘Î”ä+"; >;
float EfPostGtContrastM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "GT‘Î”ä-"; >;
float EfPostGtShoulderP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "GTŒ¨•”+"; >;
float EfPostGtShoulderM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "GTŒ¨•”-"; >;
float EfPostAgxContrastP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "AgX‘Î”ä+"; >;
float EfPostAgxContrastM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "AgX‘Î”ä-"; >;
float EfPostAgxSaturationP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "AgX–O˜a+"; >;
float EfPostAgxSaturationM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "AgX–O˜a-"; >;
float EfPostNeutralShoulderP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "NeutralŒ¨•”+"; >;
float EfPostNeutralShoulderM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "NeutralŒ¨•”-"; >;
float EfPostNeutralDesaturationP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Neutral’EF+"; >;
float EfPostNeutralDesaturationM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Neutral’EF-"; >;
float EfPostAcesWhitePointP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "ACES”’“_+"; >;
float EfPostAcesWhitePointM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "ACES”’“_-"; >;

// Bloom controls.
float EfPostBloomIntensityP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom‹­+"; >;
float EfPostBloomIntensityM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom‹­-"; >;
float EfPostBloomThresholdP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloomè‡’l+"; >;
float EfPostBloomThresholdM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloomè‡’l-"; >;
float EfPostBloomSoftKneeP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom_+"; >;
float EfPostBloomSoftKneeM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom_-"; >;
float EfPostBloomRadiusP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom”¼Œa+"; >;
float EfPostBloomRadiusM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom”¼Œa-"; >;
float EfPostBloomScatterP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom”ÍˆÍ+"; >;
float EfPostBloomScatterM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom”ÍˆÍ-"; >;
float EfPostBloomTintRP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "BloomÔ+"; >;
float EfPostBloomTintRM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "BloomÔ-"; >;
float EfPostBloomTintGP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom—Î+"; >;
float EfPostBloomTintGM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom—Î-"; >;
float EfPostBloomTintBP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom—•+"; >;
float EfPostBloomTintBM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Bloom—•-"; >;
float EfPostBloomView : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "BloomŠm”F"; >;

// Final-output controls.
float EfPostDitherStrengthP : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Dither‹­+"; >;
float EfPostDitherStrengthM : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "Dither‹­-"; >;

// White balance and optional output sharpening. These were appended to keep
// every existing controller morph index stable.
float EfPostWhiteBalanceWarm : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "F‰·’g"; >;
float EfPostWhiteBalanceCool : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "F‰·—â"; >;
float EfPostWhiteBalanceGreen : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "F•Î—Î"; >;
float EfPostWhiteBalanceMagenta : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "F•ÎŽ‡"; >;
float EfPostSharpenStrength : CONTROLOBJECT < string name = EF_POST_CONTROLLER_NAME; string item = "‰s‰»‹­"; >;

float EfPostControllerSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float EfPostControllerBounded(
    float bakedValue, float positive, float negative,
    float minimumValue, float maximumValue)
{
    float neutral = clamp(bakedValue, minimumValue, maximumValue);
    float control = EfPostControllerSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue, maximumValue);
}

float EfPostControllerExposure(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostExposureP, EfPostExposureM, -3.0, 3.0);
}

float EfPostControllerContrast(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostContrastP, EfPostContrastM, 0.5, 2.0);
}

float EfPostControllerSaturation(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostSaturationP, EfPostSaturationM, 0.0, 2.0);
}

float EfPostControllerLog2Strength(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostLog2StrengthP, EfPostLog2StrengthM, 0.05, 8.0);
}

float EfPostControllerGtContrast(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostGtContrastP, EfPostGtContrastM, 0.5, 2.0);
}

float EfPostControllerGtShoulder(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostGtShoulderP, EfPostGtShoulderM, 0.10, 0.85);
}

float EfPostControllerAgxContrast(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostAgxContrastP, EfPostAgxContrastM, 0.6, 1.6);
}

float EfPostControllerAgxSaturation(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostAgxSaturationP, EfPostAgxSaturationM, 0.0, 2.0);
}

float EfPostControllerNeutralShoulder(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue,
        EfPostNeutralShoulderP,
        EfPostNeutralShoulderM,
        0.35, 0.95);
}

float EfPostControllerNeutralDesaturation(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue,
        EfPostNeutralDesaturationP,
        EfPostNeutralDesaturationM,
        0.0, 1.0);
}

float EfPostControllerAcesWhitePoint(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostAcesWhitePointP, EfPostAcesWhitePointM, 1.0, 16.0);
}

float EfPostControllerBloomIntensity(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostBloomIntensityP, EfPostBloomIntensityM, 0.0, 3.0);
}

float EfPostControllerBloomThreshold(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostBloomThresholdP, EfPostBloomThresholdM, 0.0, 1.5);
}

float EfPostControllerBloomSoftKnee(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostBloomSoftKneeP, EfPostBloomSoftKneeM, 0.01, 0.50);
}

float EfPostControllerBloomRadius(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostBloomRadiusP, EfPostBloomRadiusM, 0.25, 3.0);
}

float EfPostControllerBloomScatter(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue, EfPostBloomScatterP, EfPostBloomScatterM, 0.0, 0.95);
}

float3 EfPostControllerBloomTint(float3 bakedColor)
{
    return float3(
        EfPostControllerBounded(
            bakedColor.r, EfPostBloomTintRP, EfPostBloomTintRM, 0.0, 2.0),
        EfPostControllerBounded(
            bakedColor.g, EfPostBloomTintGP, EfPostBloomTintGM, 0.0, 2.0),
        EfPostControllerBounded(
            bakedColor.b, EfPostBloomTintBP, EfPostBloomTintBM, 0.0, 2.0));
}

float EfPostControllerDitherStrength(float bakedValue)
{
    return EfPostControllerBounded(
        bakedValue,
        EfPostDitherStrengthP,
        EfPostDitherStrengthM,
        0.0, 2.0);
}

float EfPostControllerWhiteBalanceTemperature(float bakedValue)
{
    return clamp(
        bakedValue + EfPostControllerSigned(
            EfPostWhiteBalanceWarm,
            EfPostWhiteBalanceCool),
        -1.0, 1.0);
}

float EfPostControllerWhiteBalanceTint(float bakedValue)
{
    return clamp(
        bakedValue + EfPostControllerSigned(
            EfPostWhiteBalanceGreen,
            EfPostWhiteBalanceMagenta),
        -1.0, 1.0);
}

float EfPostControllerSharpenStrength(float bakedValue)
{
    return clamp(
        bakedValue + saturate(EfPostSharpenStrength) * 1.5,
        0.0, 1.5);
}

#endif
