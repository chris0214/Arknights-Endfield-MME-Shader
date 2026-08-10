// Endfield MME - eye runtime controls hosted by EndfieldFace_controller.pmx.
// Zeroed morphs preserve every baked eye parameter exactly.
#ifndef ENDFIELD_EYE_CONTROLS_INCLUDED
#define ENDFIELD_EYE_CONTROLS_INCLUDED

#ifndef EF_EYE_CONTROLLER_NAME
#define EF_EYE_CONTROLLER_NAME "EndfieldFace_controller.pmx"
#endif
#ifndef EF_EYE_CONTROLLER_MAX_MULTIPLIER
#define EF_EYE_CONTROLLER_MAX_MULTIPLIER 5.0
#endif

float EfEyeIrisBrightnessP : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "“ø–Œ—º“x+";
>;
float EfEyeIrisBrightnessM : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "“ø–Œ—º“x-";
>;
float EfEyeIrisSaturationP : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "“ø–Œ–O˜a+";
>;
float EfEyeIrisSaturationM : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "“ø–Œ–O˜a-";
>;
float EfEyeIrisParallaxP : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "“µEŽ‹·+";
>;
float EfEyeIrisParallaxM : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "“µEŽ‹·-";
>;
float EfEyeMatcap05P : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá”½ŽË05+";
>;
float EfEyeMatcap05M : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá”½ŽË05-";
>;
float EfEyeMatcap07P : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá”½ŽË07+";
>;
float EfEyeMatcap07M : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá”½ŽË07-";
>;
float EfEyeHighlightP : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá‚Œõ+";
>;
float EfEyeHighlightM : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá‚Œõ-";
>;
float EfEyeWhiteBrightnessP : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá”’—º“x+";
>;
float EfEyeWhiteBrightnessM : CONTROLOBJECT <
    string name = EF_EYE_CONTROLLER_NAME;
    string item = "Šá”’—º“x-";
>;

float EfEyeControllerRangeMultiplier(float positive, float negative)
{
    float upper = max(EF_EYE_CONTROLLER_MAX_MULTIPLIER, 1.0);
    float control = saturate(positive) - saturate(negative);
    return lerp(1.0, upper, max(control, 0.0))
        * (1.0 - max(-control, 0.0));
}

float EfEyeControllerIrisBrightness(float bakedValue)
{
    return max(0.0, bakedValue * EfEyeControllerRangeMultiplier(
        EfEyeIrisBrightnessP, EfEyeIrisBrightnessM));
}

float EfEyeControllerIrisSaturation(float bakedValue)
{
    return max(0.0, bakedValue * EfEyeControllerRangeMultiplier(
        EfEyeIrisSaturationP, EfEyeIrisSaturationM));
}

float EfEyeControllerIrisParallax(float bakedValue)
{
    return max(0.0, bakedValue * EfEyeControllerRangeMultiplier(
        EfEyeIrisParallaxP, EfEyeIrisParallaxM));
}

float EfEyeControllerMatcap05(float bakedValue)
{
    return max(0.0, bakedValue * EfEyeControllerRangeMultiplier(
        EfEyeMatcap05P, EfEyeMatcap05M));
}

float EfEyeControllerMatcap07(float bakedValue)
{
    return max(0.0, bakedValue * EfEyeControllerRangeMultiplier(
        EfEyeMatcap07P, EfEyeMatcap07M));
}

float EfEyeControllerHighlight(float bakedValue)
{
    float control = saturate(EfEyeHighlightP)
        - saturate(EfEyeHighlightM);
    float upper = max(EF_EYE_CONTROLLER_MAX_MULTIPLIER, 1.0);
    return max(0.0, bakedValue
        * lerp(1.0, upper, max(control, 0.0)));
}

float EfEyeControllerHighlightVisibility()
{
    float control = saturate(EfEyeHighlightP)
        - saturate(EfEyeHighlightM);
    return 1.0 - max(-control, 0.0);
}

float EfEyeControllerWhiteBrightness(float bakedValue)
{
    return max(0.0, bakedValue * EfEyeControllerRangeMultiplier(
        EfEyeWhiteBrightnessP, EfEyeWhiteBrightnessM));
}

#endif
