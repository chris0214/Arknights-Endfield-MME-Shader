// Endfield MME - face-only runtime controller parameters.
// All-zero morphs preserve the baked face shader values exactly.
#ifndef ENDFIELD_FACE_CONTROLS_INCLUDED
#define ENDFIELD_FACE_CONTROLS_INCLUDED

#ifndef EF_FACE_CONTROLLER_NAME
#define EF_FACE_CONTROLLER_NAME "EndfieldFace_controller.pmx"
#endif
#ifndef EF_FACE_SDF_SHARPNESS_MIN
#define EF_FACE_SDF_SHARPNESS_MIN 0.05
#endif
#ifndef EF_FACE_SDF_SHARPNESS_MAX
#define EF_FACE_SDF_SHARPNESS_MAX 5.0
#endif
#ifndef EF_FACE_RD_COLOR_MIN
#define EF_FACE_RD_COLOR_MIN 0.0
#endif
#ifndef EF_FACE_RD_COLOR_MAX
#define EF_FACE_RD_COLOR_MAX 1.0
#endif
#ifndef EF_FACE_AO_STRENGTH_MIN
#define EF_FACE_AO_STRENGTH_MIN 0.0
#endif
#ifndef EF_FACE_AO_STRENGTH_MAX
#define EF_FACE_AO_STRENGTH_MAX 5.0
#endif
#ifndef EF_FACE_LIP_SPECULAR_STRENGTH_MIN
#define EF_FACE_LIP_SPECULAR_STRENGTH_MIN 0.0
#endif
#ifndef EF_FACE_LIP_SPECULAR_STRENGTH_MAX
#define EF_FACE_LIP_SPECULAR_STRENGTH_MAX 10.0
#endif
#ifndef EF_FACE_LIP_UV_OFFSET_MIN
#define EF_FACE_LIP_UV_OFFSET_MIN 0.0
#endif
#ifndef EF_FACE_LIP_UV_OFFSET_MAX
#define EF_FACE_LIP_UV_OFFSET_MAX 0.25
#endif
#ifndef EF_FACE_LIP_LIGHT_FADE_MIN
#define EF_FACE_LIP_LIGHT_FADE_MIN 0.0
#endif
#ifndef EF_FACE_LIP_LIGHT_FADE_MAX
#define EF_FACE_LIP_LIGHT_FADE_MAX 1.0
#endif
#ifndef EF_FACE_RIM_WIDTH_MIN
#define EF_FACE_RIM_WIDTH_MIN 0.2
#endif
#ifndef EF_FACE_RIM_WIDTH_MAX
#define EF_FACE_RIM_WIDTH_MAX 5.0
#endif
#ifndef EF_FACE_RIM_STRENGTH_MIN
#define EF_FACE_RIM_STRENGTH_MIN 0.0
#endif
#ifndef EF_FACE_RIM_STRENGTH_MAX
#define EF_FACE_RIM_STRENGTH_MAX 5.0
#endif
#ifndef EF_FACE_RIM_CONTRAST_MIN
#define EF_FACE_RIM_CONTRAST_MIN 0.25
#endif
#ifndef EF_FACE_RIM_CONTRAST_MAX
#define EF_FACE_RIM_CONTRAST_MAX 8.0
#endif

float EfFaceSdfSharpnessP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "SDF‰s“x+";
>;
float EfFaceSdfSharpnessM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "SDF‰s“x-";
>;
float EfFaceRdColorP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "RDF‹­+";
>;
float EfFaceRdColorM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "RDF‹­-";
>;
float EfFaceAoP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "AO‹­+";
>;
float EfFaceAoM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "AO‹­-";
>;
float EfFaceLipSpecularP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "O‚Œõ+";
>;
float EfFaceLipSpecularM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "O‚Œõ-";
>;
float EfFaceLipMoveP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "O‚ŒõˆÚ+";
>;
float EfFaceLipMoveM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "O‚ŒõˆÚ-";
>;
float EfFaceLipFadeP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "O‚Œõ’W+";
>;
float EfFaceLipFadeM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "O‚Œõ’W-";
>;
float EfFaceRimWidthP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõ•+";
>;
float EfFaceRimWidthM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõ•-";
>;
float EfFaceRimStrengthP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõ‹­+";
>;
float EfFaceRimStrengthM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõ‹­-";
>;
float EfFaceRimContrastP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõd+";
>;
float EfFaceRimContrastM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõd-";
>;
float EfFaceRimColorMode : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõFØ";
>;
float EfFaceRimRP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõÔ+";
>;
float EfFaceRimRM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõÔ-";
>;
float EfFaceRimGP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõ—Î+";
>;
float EfFaceRimGM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõ—Î-";
>;
float EfFaceRimBP : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõÂ+";
>;
float EfFaceRimBM : CONTROLOBJECT <
    string name = EF_FACE_CONTROLLER_NAME;
    string item = "•ÓŒõÂ-";
>;

float EfFaceControllerSdfSharpness(float bakedSharpness)
{
    float neutral = clamp(bakedSharpness,
        EF_FACE_SDF_SHARPNESS_MIN, EF_FACE_SDF_SHARPNESS_MAX);
    float control = saturate(EfFaceSdfSharpnessP)
        - saturate(EfFaceSdfSharpnessM);
    float sharper = max(control, 0.0);
    float softer = max(-control, 0.0);
    return clamp(
        neutral
            + (EF_FACE_SDF_SHARPNESS_MAX - neutral) * sharper
            - (neutral - EF_FACE_SDF_SHARPNESS_MIN) * softer,
        EF_FACE_SDF_SHARPNESS_MIN,
        EF_FACE_SDF_SHARPNESS_MAX);
}

float EfFaceControllerRdColorStrength(float bakedStrength)
{
    float neutral = clamp(bakedStrength,
        EF_FACE_RD_COLOR_MIN, EF_FACE_RD_COLOR_MAX);
    float control = saturate(EfFaceRdColorP)
        - saturate(EfFaceRdColorM);
    float stronger = max(control, 0.0);
    float weaker = max(-control, 0.0);
    return clamp(
        neutral
            + (EF_FACE_RD_COLOR_MAX - neutral) * stronger
            - (neutral - EF_FACE_RD_COLOR_MIN) * weaker,
        EF_FACE_RD_COLOR_MIN,
        EF_FACE_RD_COLOR_MAX);
}

float EfFaceControllerAoStrength(float bakedStrength)
{
    float neutral = clamp(bakedStrength,
        EF_FACE_AO_STRENGTH_MIN, EF_FACE_AO_STRENGTH_MAX);
    float control = saturate(EfFaceAoP) - saturate(EfFaceAoM);
    float stronger = max(control, 0.0);
    float weaker = max(-control, 0.0);
    return clamp(
        neutral
            + (EF_FACE_AO_STRENGTH_MAX - neutral) * stronger
            - (neutral - EF_FACE_AO_STRENGTH_MIN) * weaker,
        EF_FACE_AO_STRENGTH_MIN,
        EF_FACE_AO_STRENGTH_MAX);
}

float EfFaceControllerLipSpecularStrength(float bakedStrength)
{
    float neutral = clamp(bakedStrength,
        EF_FACE_LIP_SPECULAR_STRENGTH_MIN,
        EF_FACE_LIP_SPECULAR_STRENGTH_MAX);
    float control = saturate(EfFaceLipSpecularP)
        - saturate(EfFaceLipSpecularM);
    return clamp(
        neutral
            + (EF_FACE_LIP_SPECULAR_STRENGTH_MAX - neutral)
                * max(control, 0.0)
            - (neutral - EF_FACE_LIP_SPECULAR_STRENGTH_MIN)
                * max(-control, 0.0),
        EF_FACE_LIP_SPECULAR_STRENGTH_MIN,
        EF_FACE_LIP_SPECULAR_STRENGTH_MAX);
}

float EfFaceControllerLipUvOffset(float bakedOffset)
{
    float neutral = clamp(bakedOffset,
        EF_FACE_LIP_UV_OFFSET_MIN, EF_FACE_LIP_UV_OFFSET_MAX);
    float control = saturate(EfFaceLipMoveP)
        - saturate(EfFaceLipMoveM);
    return clamp(
        neutral
            + (EF_FACE_LIP_UV_OFFSET_MAX - neutral)
                * max(control, 0.0)
            - (neutral - EF_FACE_LIP_UV_OFFSET_MIN)
                * max(-control, 0.0),
        EF_FACE_LIP_UV_OFFSET_MIN, EF_FACE_LIP_UV_OFFSET_MAX);
}

float EfFaceControllerLipLightFade(float bakedFade)
{
    float neutral = clamp(bakedFade,
        EF_FACE_LIP_LIGHT_FADE_MIN, EF_FACE_LIP_LIGHT_FADE_MAX);
    float control = saturate(EfFaceLipFadeP)
        - saturate(EfFaceLipFadeM);
    return clamp(
        neutral
            + (EF_FACE_LIP_LIGHT_FADE_MAX - neutral)
                * max(control, 0.0)
            - (neutral - EF_FACE_LIP_LIGHT_FADE_MIN)
                * max(-control, 0.0),
        EF_FACE_LIP_LIGHT_FADE_MIN, EF_FACE_LIP_LIGHT_FADE_MAX);
}

float EfFaceControllerRimWidth(float bakedWidth)
{
    float neutral = clamp(bakedWidth,
        EF_FACE_RIM_WIDTH_MIN, EF_FACE_RIM_WIDTH_MAX);
    float control = saturate(EfFaceRimWidthP)
        - saturate(EfFaceRimWidthM);
    return clamp(
        neutral
            + (EF_FACE_RIM_WIDTH_MAX - neutral)
                * max(control, 0.0)
            - (neutral - EF_FACE_RIM_WIDTH_MIN)
                * max(-control, 0.0),
        EF_FACE_RIM_WIDTH_MIN, EF_FACE_RIM_WIDTH_MAX);
}

float EfFaceControllerRimStrength(float bakedStrength)
{
    float neutral = clamp(bakedStrength,
        EF_FACE_RIM_STRENGTH_MIN, EF_FACE_RIM_STRENGTH_MAX);
    float control = saturate(EfFaceRimStrengthP)
        - saturate(EfFaceRimStrengthM);
    return clamp(
        neutral
            + (EF_FACE_RIM_STRENGTH_MAX - neutral)
                * max(control, 0.0)
            - (neutral - EF_FACE_RIM_STRENGTH_MIN)
                * max(-control, 0.0),
        EF_FACE_RIM_STRENGTH_MIN, EF_FACE_RIM_STRENGTH_MAX);
}

float EfFaceControllerRimContrast()
{
    float control = saturate(EfFaceRimContrastP)
        - saturate(EfFaceRimContrastM);
    return clamp(
        1.0
            + (EF_FACE_RIM_CONTRAST_MAX - 1.0) * max(control, 0.0)
            - (1.0 - EF_FACE_RIM_CONTRAST_MIN) * max(-control, 0.0),
        EF_FACE_RIM_CONTRAST_MIN,
        EF_FACE_RIM_CONTRAST_MAX);
}

float3 EfFaceControllerRimColor(
    float3 edgeColor, float3 manualColor)
{
    float3 adjustedManual = saturate(manualColor
        + (1.0 - manualColor)
            * float3(EfFaceRimRP, EfFaceRimGP, EfFaceRimBP)
        - manualColor
            * float3(EfFaceRimRM, EfFaceRimGM, EfFaceRimBM));
    return lerp(
        saturate(edgeColor), adjustedManual,
        saturate(EfFaceRimColorMode));
}

#endif
