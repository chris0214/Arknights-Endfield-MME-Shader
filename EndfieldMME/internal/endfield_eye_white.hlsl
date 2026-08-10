#ifndef ENDFIELD_EYE_WHITE_INCLUDED
#define ENDFIELD_EYE_WHITE_INCLUDED

#include "internal/endfield_eye_controls.inc"

// Shared sclera response for the visible material and EyeThrough capture.
// Keep it soft: the authored atlas carries the local color, while MMD's main
// light contributes only a restrained broad value/tint change.
#ifndef EF_EYE_WHITE_BASE_COLOR
#define EF_EYE_WHITE_BASE_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_EYE_WHITE_BASE_POW
#define EF_EYE_WHITE_BASE_POW 1.0
#endif
#ifndef EF_EYE_WHITE_COLOR_GAIN
#define EF_EYE_WHITE_COLOR_GAIN 1.02
#endif
#ifndef EF_EYE_WHITE_COLOR_SATURATION
#define EF_EYE_WHITE_COLOR_SATURATION 0.88
#endif
#ifndef EF_EYE_WHITE_COLOR_CONTRAST
#define EF_EYE_WHITE_COLOR_CONTRAST 0.96
#endif
#ifndef EF_EYE_WHITE_COLOR_LIFT
#define EF_EYE_WHITE_COLOR_LIFT float3(0.004, 0.003, 0.002)
#endif
#ifndef EF_EYE_WHITE_DARK_VALUE
#define EF_EYE_WHITE_DARK_VALUE 0.86
#endif
#ifndef EF_EYE_WHITE_LIGHT_VALUE
#define EF_EYE_WHITE_LIGHT_VALUE 1.03
#endif
#ifndef EF_EYE_WHITE_LIGHT_CURVE
#define EF_EYE_WHITE_LIGHT_CURVE 0.72
#endif
#ifndef EF_EYE_WHITE_LIGHT_TINT
#define EF_EYE_WHITE_LIGHT_TINT 0.12
#endif
#ifndef EF_EYE_WHITE_SOFT_EXPOSURE
#define EF_EYE_WHITE_SOFT_EXPOSURE 1.0
#endif
#ifndef EF_EYE_WHITE_FINAL_GAIN
#define EF_EYE_WHITE_FINAL_GAIN 1.0
#endif

float3 EfEyeWhiteAdjustColor(float3 textureColor, float3 materialColor)
{
    float3 color = pow(
        max(textureColor * max(EF_EYE_WHITE_BASE_COLOR, 0.0), 1e-5),
        max(EF_EYE_WHITE_BASE_POW, 1e-4));
    color *= saturate(materialColor);

    float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
    color = lerp(
        float3(luminance, luminance, luminance),
        color,
        max(EF_EYE_WHITE_COLOR_SATURATION, 0.0));
    color = (color - 0.5) * max(EF_EYE_WHITE_COLOR_CONTRAST, 0.0)
        + 0.5;
    color = color * max(EF_EYE_WHITE_COLOR_GAIN, 0.0)
        + max(EF_EYE_WHITE_COLOR_LIFT, 0.0);
    return saturate(color);
}

float3 EfEyeWhiteEvaluate(
    float3 textureColor,
    float3 materialColor,
    float3 normalWS,
    float3 mmdLightDirection,
    float3 mmdLightColor)
{
    float3 color = EfEyeWhiteAdjustColor(textureColor, materialColor);

    float normalLengthSq = dot(normalWS, normalWS);
    float3 N = (normalLengthSq > 1e-8)
        ? normalWS * rsqrt(normalLengthSq)
        : float3(0.0, 0.0, -1.0);
    float lightLengthSq = dot(mmdLightDirection, mmdLightDirection);
    float3 L = (lightLengthSq > 1e-8)
        ? -mmdLightDirection * rsqrt(lightLengthSq)
        : N;

    float halfLambert = saturate(dot(N, L) * 0.5 + 0.5);
    halfLambert = pow(halfLambert, max(EF_EYE_WHITE_LIGHT_CURVE, 1e-4));
    float value = lerp(
        max(EF_EYE_WHITE_DARK_VALUE, 0.0),
        max(EF_EYE_WHITE_LIGHT_VALUE, 0.0),
        halfLambert);
    float3 lightTint = lerp(
        float3(1.0, 1.0, 1.0),
        saturate(mmdLightColor),
        saturate(EF_EYE_WHITE_LIGHT_TINT));
    float3 litColor = saturate(color * value * lightTint);
    float exposure = max(EF_EYE_WHITE_SOFT_EXPOSURE, 0.0);
    float3 linearColor = pow(max(litColor, 1e-5), 2.2);
    linearColor = linearColor * exposure /
        max(1.0 + linearColor * (exposure - 1.0), 1e-4);
    float3 outputColor = pow(saturate(linearColor), 1.0 / 2.2);
    return saturate(outputColor * EfEyeControllerWhiteBrightness(
        EF_EYE_WHITE_FINAL_GAIN));
}

#endif
