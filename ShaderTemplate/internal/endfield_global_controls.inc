// Endfield MME - shared character-wide grading controls.
// All-zero morphs preserve every material's baked result.
#ifndef ENDFIELD_GLOBAL_CONTROLS_INCLUDED
#define ENDFIELD_GLOBAL_CONTROLS_INCLUDED

#ifndef EF_GLOBAL_CONTROLLER_NAME
#define EF_GLOBAL_CONTROLLER_NAME "Endfield_controller.pmx"
#endif

// Lit and shadow branch brightness.
float EfBrightP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "—º•”+"; >;
float EfBrightPP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "—º•”++"; >;
float EfBrightM : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "—º•”-"; >;
float EfDarkP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "ˆÃ•”+"; >;
float EfDarkPP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "ˆÃ•”++"; >;
float EfDarkM : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "ˆÃ•”-"; >;

// Whole-character final grade.
float EfGlobalSaturationP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "‘S‹Ç–O˜a+"; >;
float EfGlobalSaturationPP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "‘S‹Ç–O˜a++"; >;
float EfGlobalSaturationM : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "‘S‹Ç–O˜a-"; >;
float EfGlobalBrightnessP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "‘S‹Ç—º“x+"; >;
float EfGlobalBrightnessPP : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "‘S‹Ç—º“x++"; >;
float EfGlobalBrightnessM : CONTROLOBJECT < string name = EF_GLOBAL_CONTROLLER_NAME; string item = "‘S‹Ç—º“x-"; >;

float EfGlobalRange5(
    float positive, float positiveExtreme, float negative)
{
    float multiplier = 1.0
        + saturate(positive)
        + 3.0 * saturate(positiveExtreme);
    return lerp(multiplier, 0.0, saturate(negative));
}

float EfBrightMul()
{
    return EfGlobalRange5(EfBrightP, EfBrightPP, EfBrightM);
}

float EfDarkMul()
{
    return EfGlobalRange5(EfDarkP, EfDarkPP, EfDarkM);
}

float EfGlobalSaturationMul()
{
    return EfGlobalRange5(
        EfGlobalSaturationP,
        EfGlobalSaturationPP,
        EfGlobalSaturationM);
}

float EfGlobalBrightnessMul()
{
    return EfGlobalRange5(
        EfGlobalBrightnessP,
        EfGlobalBrightnessPP,
        EfGlobalBrightnessM);
}

float3 EfApplyGlobalColorGrade(float3 color)
{
    float3 graded = max(color, 0.0);
    float luminance = dot(
        graded,
        float3(0.2126, 0.7152, 0.0722));
    graded = lerp(
        luminance.xxx,
        graded,
        EfGlobalSaturationMul());
    graded *= EfGlobalBrightnessMul();
    return max(graded, 0.0);
}

float3 EfApplyGlobalMaterialGrade(float3 color, float lightWeight)
{
    float branchBrightness = lerp(
        EfDarkMul(),
        EfBrightMul(),
        saturate(lightWeight));
    return EfApplyGlobalColorGrade(max(color, 0.0) * branchBrightness);
}

#endif
