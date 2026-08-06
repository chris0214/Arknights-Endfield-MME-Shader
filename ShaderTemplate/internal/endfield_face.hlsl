#ifndef ENDFIELD_FACE_INCLUDED
#define ENDFIELD_FACE_INCLUDED

// Face shading core. The optional stencil state only marks visible face pixels;
// the hair material remains responsible for drawing its projected fringe shadow.

#ifndef EF_FACE_BASE_COLOR
#define EF_FACE_BASE_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_FACE_BASE_COLOR_POW
#define EF_FACE_BASE_COLOR_POW 1.0
#endif
#ifndef EF_FACE_AO_STRENGTH
#define EF_FACE_AO_STRENGTH 1.0
#endif
#ifndef EF_FACE_D_RGB_DEBUG
#define EF_FACE_D_RGB_DEBUG 0
#endif
#ifndef EF_FACE_CULL_MODE
#define EF_FACE_CULL_MODE NONE
#endif
#ifndef EF_FACE_OUTLINE_ENABLED
#define EF_FACE_OUTLINE_ENABLED 0
#endif
#ifndef EF_FACE_OUTLINE_WIDTH
#define EF_FACE_OUTLINE_WIDTH 0.75
#endif
#ifndef EF_FACE_OUTLINE_ZBIAS
#define EF_FACE_OUTLINE_ZBIAS 0.0005
#endif
#ifndef EF_FACE_OUTLINE_COLOR
#define EF_FACE_OUTLINE_COLOR float3(0.12, 0.075, 0.07)
#endif
#ifndef EF_FACE_OUTLINE_BASE_COLOR
#define EF_FACE_OUTLINE_BASE_COLOR EF_FACE_OUTLINE_COLOR
#endif
#ifndef EF_FACE_OUTLINE_STRENGTH
#define EF_FACE_OUTLINE_STRENGTH 0.85
#endif
#ifndef EF_FACE_OUTLINE_FAR_SCALE
#define EF_FACE_OUTLINE_FAR_SCALE 0.45
#endif
#ifndef EF_FACE_OUTLINE_LIGHT_FLOOR
#define EF_FACE_OUTLINE_LIGHT_FLOOR 0.72
#endif
#ifndef EF_FACE_STENCIL_WRITE_ENABLED
#define EF_FACE_STENCIL_WRITE_ENABLED 0
#endif
#ifndef EF_FACE_STENCIL_REF
#define EF_FACE_STENCIL_REF 1
#endif
#ifndef EF_FACE_STENCIL_WRITE_MASK
#define EF_FACE_STENCIL_WRITE_MASK 1
#endif
#ifndef EF_FACE_SHADOW_RECEIVER_MASK_ENABLED
#define EF_FACE_SHADOW_RECEIVER_MASK_ENABLED 1
#endif
#ifndef EF_FACE_SHADOW_RECEIVER_ST_ENABLED
#define EF_FACE_SHADOW_RECEIVER_ST_ENABLED 0
#endif
#ifndef EF_FACE_SHADOW_RECEIVER_ST_THRESHOLD
#define EF_FACE_SHADOW_RECEIVER_ST_THRESHOLD 0.05
#endif
#ifndef EF_FACE_SHADOW_RECEIVER_NORMAL_START
#define EF_FACE_SHADOW_RECEIVER_NORMAL_START -0.05
#endif
#ifndef EF_FACE_SHADOW_RECEIVER_NORMAL_END
#define EF_FACE_SHADOW_RECEIVER_NORMAL_END 0.25
#endif
#ifndef EF_FACE_HEAD_BASIS_DEBUG
#define EF_FACE_HEAD_BASIS_DEBUG 0
#endif
#ifndef EF_FACE_HEAD_BASIS_DEBUG_MODE
// 0 = Front, 1 = Right, 2 = Up, 3 = alignment confidence.
#define EF_FACE_HEAD_BASIS_DEBUG_MODE 0
#endif
#ifndef EF_FACE_SDF_ENABLED
#define EF_FACE_SDF_ENABLED 0
#endif
#ifndef EF_FACE_SDF_RAW_DEBUG
#define EF_FACE_SDF_RAW_DEBUG 0
#endif
#ifndef EF_FACE_SDF_RAW_DEBUG_CHANNEL
// 0 = R, 1 = G, 2 = B, 3 = A.
#define EF_FACE_SDF_RAW_DEBUG_CHANNEL 0
#endif
#ifndef EF_FACE_SDF_MIRROR_FLAG_DEBUG
#define EF_FACE_SDF_MIRROR_FLAG_DEBUG 0
#endif
#ifndef EF_FACE_SDF_MIRRORED_R_DEBUG
#define EF_FACE_SDF_MIRRORED_R_DEBUG 0
#endif
#ifndef EF_FACE_SDF_CHANNEL_SELECT_DEBUG
#define EF_FACE_SDF_CHANNEL_SELECT_DEBUG 0
#endif
#ifndef EF_FACE_SDF_THRESHOLD_DEBUG
#define EF_FACE_SDF_THRESHOLD_DEBUG 0
#endif
#ifndef EF_FACE_SDF_SOFTNESS
#define EF_FACE_SDF_SOFTNESS 0.03
#endif
#ifndef EF_FACE_SDF_GOO_ANGLE_DEBUG
#define EF_FACE_SDF_GOO_ANGLE_DEBUG 0
#endif
#ifndef EF_FACE_SDF_GOO_CENTER
#define EF_FACE_SDF_GOO_CENTER 0.1
#endif
#ifndef EF_FACE_SDF_GOO_SHARP
#define EF_FACE_SDF_GOO_SHARP 0.5
#endif
#ifndef EF_FACE_SDF_GOO_BASE
#define EF_FACE_SDF_GOO_BASE 100000.0
#endif
#ifndef EF_FACE_SDF_GOO_FORWARD_SIGN
// Explicitly separates Goo's head-forward convention from MMD's light vector.
// MMD front/back probing confirmed that surface-to-light uses headFront here.
#define EF_FACE_SDF_GOO_FORWARD_SIGN 1.0
#endif
#ifndef EF_FACE_CMM_RAW_DEBUG
#define EF_FACE_CMM_RAW_DEBUG 0
#endif
#ifndef EF_FACE_CMM_RAW_DEBUG_CHANNEL
// 0 = R, 1 = G, 2 = B, 3 = A.
#define EF_FACE_CMM_RAW_DEBUG_CHANNEL 1
#endif
#ifndef EF_FACE_SDF_CMM_BLEND_DEBUG
#define EF_FACE_SDF_CMM_BLEND_DEBUG 0
#endif
#ifndef EF_FACE_RD_RESPONSE_DEBUG
#define EF_FACE_RD_RESPONSE_DEBUG 0
#endif
#ifndef EF_FACE_RD_ALPHA_DEBUG
#define EF_FACE_RD_ALPHA_DEBUG 0
#endif
#ifndef EF_FACE_SKIN_LUT_DEBUG
#define EF_FACE_SKIN_LUT_DEBUG 0
#endif
#ifndef EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG
#define EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG 0
#endif
#ifndef EF_FACE_LUT_RD_COLOR_DEBUG
#define EF_FACE_LUT_RD_COLOR_DEBUG 0
#endif
#ifndef EF_FACE_LUT_RD_COLOR_AO_DEBUG
#define EF_FACE_LUT_RD_COLOR_AO_DEBUG 0
#endif
#ifndef EF_FACE_LUT_RD_COLOR_AO_RAMP_DEBUG
#define EF_FACE_LUT_RD_COLOR_AO_RAMP_DEBUG 0
#endif
#ifndef EF_FACE_FINAL_BRIGHTNESS_DEBUG
#define EF_FACE_FINAL_BRIGHTNESS_DEBUG 0
#endif
#ifndef EF_FACE_FINAL_BRIGHTNESS
#define EF_FACE_FINAL_BRIGHTNESS 1.0
#endif
#ifndef EF_FACE_FINAL_SOFT_EXPOSURE_ENABLED
#define EF_FACE_FINAL_SOFT_EXPOSURE_ENABLED 0
#endif
#ifndef EF_FACE_FINAL_SOFT_EXPOSURE
#define EF_FACE_FINAL_SOFT_EXPOSURE 1.0
#endif
#ifndef EF_FACE_SSS_ENABLED
#define EF_FACE_SSS_ENABLED 0
#endif
#ifndef EF_FACE_SSS_MASK_DEBUG
#define EF_FACE_SSS_MASK_DEBUG 0
#endif
#ifndef EF_FACE_SSS_AREA
// MyZmd face-shader default. This is a multiplier, not a threshold.
#define EF_FACE_SSS_AREA 0.5
#endif
#ifndef EF_FACE_SSS_COLOR
// Goo-style "Front R Color", stored as a scene-linear color.
#define EF_FACE_SSS_COLOR float3(0.822936177, 0.669170380, 0.648408771)
#endif
#ifndef EF_FACE_LIP_SPECULAR_ENABLED
#define EF_FACE_LIP_SPECULAR_ENABLED 0
#endif
#ifndef EF_FACE_LIP_SPECULAR_MASK_DEBUG
#define EF_FACE_LIP_SPECULAR_MASK_DEBUG 0
#endif
#ifndef EF_FACE_LIP_SPECULAR_UV_OFFSET
// Zhihu reference: dot(viewDirWS, faceRightDir) * 0.05.
#define EF_FACE_LIP_SPECULAR_UV_OFFSET 0.05
#endif
#ifndef EF_FACE_LIP_SPECULAR_STRENGTH
// Zhihu combines the lip mask at 2x before applying the specular color.
#define EF_FACE_LIP_SPECULAR_STRENGTH 2.0
#endif
#ifndef EF_FACE_LIP_SPECULAR_LIGHT_FADE
// Fade from side light (sdf_dot=0) to fully front-lit instead of using the
// article's binary step. A value of 0.2 spans roughly twelve light degrees.
#define EF_FACE_LIP_SPECULAR_LIGHT_FADE 0.2
#endif
#ifndef EF_FACE_LIP_SPECULAR_COLOR
#define EF_FACE_LIP_SPECULAR_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_FACE_RIM_ENABLED
#define EF_FACE_RIM_ENABLED 0
#endif
#ifndef EF_FACE_RIM_MASK_DEBUG
#define EF_FACE_RIM_MASK_DEBUG 0
#endif
#ifndef EF_FACE_RIM_INTENSITY
// The article leaves only 0.25 at full front. A 1x response keeps Chen
// Qianyu's cheek and nose accents below clipping in MMD's non-HDR target.
#define EF_FACE_RIM_INTENSITY 1.0
#endif
#ifndef EF_FACE_RIM_WIDTH
// Intuitive authored-mask width multiplier. The controller maps 0.2x..5x;
// the shader converts it to a reciprocal power over cm_M.a.
#define EF_FACE_RIM_WIDTH 1.0
#endif
#ifndef EF_FACE_RIM_NOV_THRESHOLD
// Zhihu reference: saturate(faceNoV - 0.75).
#define EF_FACE_RIM_NOV_THRESHOLD 0.75
#endif
#ifndef EF_FACE_RIM_COLOR
#define EF_FACE_RIM_COLOR float3(1.0, 1.0, 1.0)
#endif
#if EF_FACE_LUT_RD_COLOR_AO_DEBUG && EF_FACE_LUT_RD_COLOR_AO_RAMP_DEBUG
#error Face AO multiply and AO/Ramp blend diagnostics are mutually exclusive.
#endif
#ifndef EF_FACE_RD_COLOR_STRENGTH
#define EF_FACE_RD_COLOR_STRENGTH 0.4
#endif
#ifndef EF_FACE_SKIN_LUT_USE_BRG
// MyZmd's face LUT contract reorders the display-space albedo as BRG.
#define EF_FACE_SKIN_LUT_USE_BRG 1
#endif
#ifndef EF_FACE_SKIN_LUT_NEXT_SLICE_V_OFFSET
// The 1024x32 atlas stores 32 horizontal slices; the next slice moves in U only.
#define EF_FACE_SKIN_LUT_NEXT_SLICE_V_OFFSET 0.0
#endif
#ifndef EF_FACE_ZMD_SHADOW_ENABLED
#define EF_FACE_ZMD_SHADOW_ENABLED 0
#endif
#ifndef EF_FACE_ZMD_SHADOW_RAW_DEBUG
#define EF_FACE_ZMD_SHADOW_RAW_DEBUG 0
#endif
#ifndef EF_FACE_SHADOW_VIEWPORT_MAP
#define EF_FACE_SHADOW_VIEWPORT_MAP ZMDshadow_ViewportMap2
#endif
#ifndef EF_FACE_SHADOW_CONTROLLER_NAME
#define EF_FACE_SHADOW_CONTROLLER_NAME "ZMDshadow.x"
#endif
#ifndef EF_FACE_SHADOW_CENTER
#define EF_FACE_SHADOW_CENTER 0.5
#endif
#ifndef EF_FACE_SHADOW_SMOOTHNESS
#define EF_FACE_SHADOW_SMOOTHNESS 0.35
#endif
#ifndef EF_FACE_SHADOW_OFFSET
#define EF_FACE_SHADOW_OFFSET 0.0
#endif
#ifndef EF_FACE_SHADOW_STRENGTH
#define EF_FACE_SHADOW_STRENGTH 1.0
#endif
#ifndef EF_FACE_USE_SELF_SHADOW
#if EF_FACE_ZMD_SHADOW_ENABLED
#define EF_FACE_USE_SELF_SHADOW true
#else
#define EF_FACE_USE_SELF_SHADOW false
#endif
#endif

#if EF_FACE_OUTLINE_ENABLED
#include "internal/endfield_outline.hlsl"
#endif
#include "internal/endfield_global_controls.inc"
#include "internal/endfield_global_shadow_scale.hlsl"
#if EF_FACE_RIM_ENABLED
#include "internal/endfield_specular.hlsl"
#endif
#if EF_FACE_SDF_GOO_ANGLE_DEBUG || EF_FACE_LUT_RD_COLOR_DEBUG || EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
#include "internal/endfield_face_controls.inc"
#endif

#if EF_FACE_CMM_RAW_DEBUG || EF_FACE_SDF_CMM_BLEND_DEBUG || EF_FACE_SSS_ENABLED || EF_FACE_ZMD_SHADOW_ENABLED || EF_FACE_RIM_ENABLED
texture2D EfFaceCmmTexture <
    string ResourceName = EF_FACE_CMM_TEXTURE_RESOURCE;
>;
sampler2D EfFaceCmmSampler = sampler_state {
    texture = <EfFaceCmmTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if EF_FACE_STENCIL_WRITE_ENABLED && EF_FACE_SHADOW_RECEIVER_ST_ENABLED
texture2D EfFaceShadowReceiverStTexture <
    string ResourceName = EF_FACE_SHADOW_RECEIVER_ST_TEXTURE_RESOURCE;
>;
sampler2D EfFaceShadowReceiverStSampler = sampler_state {
    texture = <EfFaceShadowReceiverStTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
#endif

#if EF_FACE_ZMD_SHADOW_ENABLED
shared texture2D EF_FACE_SHADOW_VIEWPORT_MAP : RENDERCOLORTARGET;
sampler2D EfFaceZmdShadowSampler = sampler_state {
    texture = <EF_FACE_SHADOW_VIEWPORT_MAP>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU = CLAMP; AddressV = CLAMP;
};
bool EfFaceZmdShadowValid : CONTROLOBJECT <
    string name = EF_FACE_SHADOW_CONTROLLER_NAME;
>;
float EfFaceZmdShadowRotation : CONTROLOBJECT <
    string name = EF_FACE_SHADOW_CONTROLLER_NAME;
    string item = "Rx";
>;
float EfFaceShadowDensityUp : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen+";
>;
float EfFaceShadowDensityDown : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen-";
>;
#endif
#if EF_FACE_ZMD_SHADOW_ENABLED || EF_FACE_OUTLINE_ENABLED
float2 EfFaceViewportSize : VIEWPORTPIXELSIZE;
#endif

#if EF_FACE_RD_RESPONSE_DEBUG || EF_FACE_RD_ALPHA_DEBUG || EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG || EF_FACE_LUT_RD_COLOR_DEBUG
texture2D EfFaceRdTexture <
    string ResourceName = EF_FACE_RD_TEXTURE_RESOURCE;
>;
sampler2D EfFaceRdSampler = sampler_state {
    texture = <EfFaceRdTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if EF_FACE_SKIN_LUT_DEBUG || EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG || EF_FACE_LUT_RD_COLOR_DEBUG
texture2D EfFaceSkinLutTexture <
    string ResourceName = EF_FACE_SKIN_LUT_TEXTURE_RESOURCE;
>;
sampler2D EfFaceSkinLutSampler = sampler_state {
    texture = <EfFaceSkinLutTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU = CLAMP; AddressV = CLAMP;
};
#endif

#if EF_FACE_LIP_SPECULAR_ENABLED
#ifdef EF_FACE_LIP_SPECULAR_TEXTURE_RESOURCE
texture2D EfFaceLipSpecularTexture <
    string ResourceName = EF_FACE_LIP_SPECULAR_TEXTURE_RESOURCE;
>;
sampler2D EfFaceLipSpecularSampler = sampler_state {
    texture = <EfFaceLipSpecularTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = CLAMP; AddressV = CLAMP;
};
#endif
#ifdef EF_FACE_ST_TEXTURE_RESOURCE
texture2D EfFaceStTexture <
    string ResourceName = EF_FACE_ST_TEXTURE_RESOURCE;
>;
sampler2D EfFaceStSampler = sampler_state {
    texture = <EfFaceStTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = CLAMP; AddressV = CLAMP;
};
#endif
#endif

// MME semantic globals used by the opaque object/object_ss variants.
float4x4 matWorldViewProject : WORLDVIEWPROJECTION;
float4x4 matWorld : WORLD;
float4 MaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float4 EfFaceMaterialEdgeColor : EDGECOLOR;
#if EF_FACE_SSS_ENABLED || EF_FACE_ZMD_SHADOW_ENABLED || EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
float3 CameraPosition : POSITION < string Object = "Camera"; >;
#endif
#if EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
float3 EfFaceMmdLightColor : SPECULAR < string Object = "Light"; >;
#endif

#ifdef EF_FACE_MAIN_TEXTURE_RESOURCE
texture2D EfFaceMainTexture <
    string ResourceName = EF_FACE_MAIN_TEXTURE_RESOURCE;
>;
#else
texture2D EfFaceMainTexture : MATERIALTEXTURE <
    string Format = "A8R8G8B8";
>;
#endif
sampler2D EfFaceMainSampler = sampler_state {
    texture = <EfFaceMainTexture>;
    MinFilter = ANISOTROPIC; MagFilter = ANISOTROPIC; MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = CLAMP; AddressV = CLAMP;
};

#if EF_FACE_SDF_ENABLED || EF_FACE_SDF_RAW_DEBUG || EF_FACE_SDF_MIRRORED_R_DEBUG || EF_FACE_SDF_CHANNEL_SELECT_DEBUG || EF_FACE_SDF_THRESHOLD_DEBUG || EF_FACE_SDF_GOO_ANGLE_DEBUG
texture2D EfFaceSdfTexture <
    string ResourceName = EF_FACE_SDF_TEXTURE_RESOURCE;
>;
sampler2D EfFaceSdfSampler = sampler_state {
    texture = <EfFaceSdfTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = CLAMP; AddressV = CLAMP;
};
#endif

float3 EfFaceSrgbToLinear(float3 color)
{
    return pow(max(color, 1e-5), 2.2);
}

float3 EfFaceLinearToSrgb(float3 color)
{
    return pow(max(color, 1e-5), 1.0 / 2.2);
}

#if EF_FACE_SKIN_LUT_DEBUG || EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG || EF_FACE_LUT_RD_COLOR_DEBUG
float3 EfFaceSampleSkinLut(float3 albedoSrgb)
{
    albedoSrgb = saturate(albedoSrgb);
#if EF_FACE_SKIN_LUT_USE_BRG
    albedoSrgb = albedoSrgb.brg;
#endif

    // MyZmd's 1024x32 LUT is laid out as 32 horizontal 32x32 tiles.
    float2 lutUv = albedoSrgb.xz * float2(31.0, 0.96875);
    float lutFloorX = floor(lutUv.x);
    float2 lutUvYZ = albedoSrgb.yz *
        float2(0.0302734375, 0.96875) +
        float2(0.00048828125, 0.015625);
    float lutUvX = lutFloorX * 0.03125 + lutUvYZ.x;
    float2 lutUvFinal = float2(lutUvX, 1.0 - lutUvYZ.y);
    float lutTileLerp = albedoSrgb.x * 31.0 - lutFloorX;
    float3 lutColor0 = tex2D(EfFaceSkinLutSampler, lutUvFinal).rgb;
    float3 lutColor1 = tex2D(EfFaceSkinLutSampler,
        lutUvFinal + float2(0.03125,
            EF_FACE_SKIN_LUT_NEXT_SLICE_V_OFFSET)).rgb;
    return lerp(lutColor0, lutColor1, lutTileLerp);
}
#endif

#if EF_FACE_LUT_RD_COLOR_DEBUG
float EfFaceLuminance(float3 color)
{
    return dot(color, float3(0.212672904, 0.715152204, 0.0721750036));
}

float3 EfFaceApplyRdColor(float3 diffuseColor, float3 rdColor)
{
    // MyZmd derives tint strength from channel spread. Black/gray/white RD
    // samples therefore remain neutral instead of multiplying skin to black.
    float rdMax = max(max(rdColor.r, rdColor.g), rdColor.b);
    float rdMin = min(min(rdColor.r, rdColor.g), rdColor.b);
    float rdChroma = saturate(rdMax - rdMin);
    float3 rdTint = rdColor * rdChroma + 1.0 - rdChroma;
    float rdColorStrength = EfFaceControllerRdColorStrength(
        EF_FACE_RD_COLOR_STRENGTH);
    rdTint = lerp(float3(1.0, 1.0, 1.0), rdTint,
        rdColorStrength);

    float3 tintedDiffuse = diffuseColor * rdTint;
    float sourceLuminance = EfFaceLuminance(diffuseColor);
    float tintedLuminance = EfFaceLuminance(tintedDiffuse);
    float luminanceCompensation = clamp(sourceLuminance /
        max(tintedLuminance, 0.01), 0.0, 1.5);
    return tintedDiffuse * luminanceCompensation;
}
#endif

#if EF_FACE_HEAD_BASIS_DEBUG || EF_FACE_SDF_MIRROR_FLAG_DEBUG || EF_FACE_SDF_MIRRORED_R_DEBUG || EF_FACE_SDF_CHANNEL_SELECT_DEBUG || EF_FACE_SDF_THRESHOLD_DEBUG || EF_FACE_SDF_GOO_ANGLE_DEBUG || EF_FACE_SSS_ENABLED || EF_FACE_ZMD_SHADOW_ENABLED || EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED || EF_FACE_STENCIL_WRITE_ENABLED
void EfFaceGetHeadBasis(out float3 headFront, out float3 headRight,
    out float3 headUp, out float valid)
{
    float3 forwardAxis = EfFaceHeadBone._31_32_33;
    float3 rightAxis = EfFaceHeadBone._11_12_13;
    float forwardLengthSq = dot(forwardAxis, forwardAxis);
    float rightLengthSq = dot(rightAxis, rightAxis);

    valid = (forwardLengthSq > 1e-8 && rightLengthSq > 1e-8) ? 1.0 : 0.0;
    if (valid < 0.5) {
        headFront = float3(0.0, 0.0, -1.0);
        headRight = float3(-1.0, 0.0, 0.0);
        headUp = float3(0.0, 1.0, 0.0);
        return;
    }

    // MMDStarRail4Fun and HS_Snow both use -row3 as face forward and
    // -row1 as face right for the standard MMD head-bone convention.
    headFront = -normalize(forwardAxis);
    headRight = -normalize(rightAxis);
    float3 upAxis = cross(headFront, headRight);
    float upLengthSq = dot(upAxis, upAxis);
    if (upLengthSq < 1e-8) {
        valid = 0.0;
        headUp = float3(0.0, 1.0, 0.0);
        return;
    }

    headUp = normalize(upAxis);
    headRight = normalize(cross(headUp, headFront));
}
#endif

#if EF_FACE_ZMD_SHADOW_ENABLED
float EfFaceSampleZmdShadow(float4 screenPosition)
{
    if (!EfFaceZmdShadowValid || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }

    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 screenUv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    screenUv += 0.5 / max(EfFaceViewportSize, 1.0);
    float shadowAmount = saturate(
        tex2D(EfFaceZmdShadowSampler, screenUv).r);
    float visibility = 1.0 - shadowAmount;

    // Match the HgShadow/HS_Snow density contract already validated by Hair.
    float density = max(
        (degrees(EfFaceZmdShadowRotation)
            + 5.0 * EfFaceShadowDensityUp + 1.0)
            * (1.0 - EfFaceShadowDensityDown),
        0.0);
    return 1.0 - (1.0 - visibility) * min(density, 1.0);
}

float EfFaceComputeZmdShadowEffect(float2 uv, float4 screenPosition,
    float3 headFront, float3 headRight)
{
    float visibility = EfFaceSampleZmdShadow(screenPosition);
    float shadowT = (visibility - EF_FACE_SHADOW_CENTER)
        / max(EF_FACE_SHADOW_SMOOTHNESS, 1e-6);
    float shadowScene = 1.0 / (1.0 + exp(-shadowT));
    shadowScene = saturate(
        (shadowScene + EF_FACE_SHADOW_OFFSET)
            * EF_FACE_SHADOW_STRENGTH);

    float3 headOriginWS = EfFaceHeadBone._41_42_43;
    float3 cameraForwardWS = CameraPosition - headOriginWS;
    float cameraForwardLengthSq = dot(cameraForwardWS, cameraForwardWS);
    cameraForwardWS = (cameraForwardLengthSq > 1e-8)
        ? cameraForwardWS * rsqrt(cameraForwardLengthSq)
        : headFront;
    float cameraRightFace = dot(cameraForwardWS, headRight);
    float cameraFrontFace = dot(cameraForwardWS, headFront);
    float cameraHorizontalLengthSq = cameraRightFace * cameraRightFace
        + cameraFrontFace * cameraFrontFace;
    float headFrontDotCameraForward = (cameraHorizontalLengthSq > 1e-8)
        ? cameraFrontFace * rsqrt(cameraHorizontalLengthSq)
        : 1.0;

    // MyZmd: smoothstep(saturate(-2 * cameraForwardFace.z)) * cm_M.b,
    // then cm_M.g always protects the geometric/non-face transition region.
    float cameraShadowArea = saturate(-2.0 * headFrontDotCameraForward);
    cameraShadowArea = cameraShadowArea * cameraShadowArea
        * (3.0 - 2.0 * cameraShadowArea);
    float4 cmmShadow = tex2D(EfFaceCmmSampler, uv);
    float shadowArea = max(
        saturate(cmmShadow.g),
        cameraShadowArea * saturate(cmmShadow.b));
    return lerp(1.0, shadowScene, saturate(shadowArea));
}
#endif

struct EfFaceAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct EfFaceVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
#if EF_FACE_SSS_ENABLED || EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
    float3 positionWS : TEXCOORD2;
#endif
#if EF_FACE_ZMD_SHADOW_ENABLED
    float4 screenPosition : TEXCOORD3;
#endif
};

EfFaceVaryings EfFaceVS(EfFaceAttributes input)
{
    EfFaceVaryings output = (EfFaceVaryings)0;
    output.positionCS = mul(input.positionOS, matWorldViewProject);
    output.uv = input.texcoord0;
    output.normalWS = normalize(mul(input.normalOS, (float3x3)matWorld));
#if EF_FACE_SSS_ENABLED || EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
    output.positionWS = mul(input.positionOS, matWorld).xyz;
#endif
#if EF_FACE_ZMD_SHADOW_ENABLED
    output.screenPosition = output.positionCS;
#endif
    return output;
}

#if EF_FACE_SSS_ENABLED
float EfFaceComputeSssArea(EfFaceVaryings input, float3 headFront,
    float3 headRight)
{
    float4 cmmSss = tex2D(EfFaceCmmSampler, input.uv);
    float3 viewDirWS = normalize(CameraPosition - input.positionWS);
    float3 headOriginWS = EfFaceHeadBone._41_42_43;
    float3 cameraForwardWS = CameraPosition - headOriginWS;
    float cameraForwardLengthSq = dot(cameraForwardWS, cameraForwardWS);
    cameraForwardWS = (cameraForwardLengthSq > 1e-8)
        ? cameraForwardWS * rsqrt(cameraForwardLengthSq)
        : viewDirWS;

    float cameraRightFace = dot(cameraForwardWS, headRight);
    float cameraFrontFace = dot(cameraForwardWS, headFront);
    float cameraHorizontalLengthSq = cameraRightFace * cameraRightFace
        + cameraFrontFace * cameraFrontFace;
    float headFrontDotCameraForward = (cameraHorizontalLengthSq > 1e-8)
        ? cameraFrontFace * rsqrt(cameraHorizontalLengthSq)
        : 1.0;

    float viewSssStrength = lerp(
        saturate(headFrontDotCameraForward + 0.5), 1.0,
        saturate(cmmSss.g)) * saturate(cmmSss.r);
    float sssNoV = saturate(dot(input.normalWS, viewDirWS));
    sssNoV = sssNoV * 0.85 + 0.15;
    return saturate(max(EF_FACE_SSS_AREA, 0.0)
        * viewSssStrength * (1.0 - sssNoV));
}
#endif

float4 EfFacePS(EfFaceVaryings input, uniform bool useTexture) : COLOR0
{
#if EF_FACE_HEAD_BASIS_DEBUG || EF_FACE_SDF_MIRROR_FLAG_DEBUG || EF_FACE_SDF_MIRRORED_R_DEBUG || EF_FACE_SDF_CHANNEL_SELECT_DEBUG || EF_FACE_SDF_THRESHOLD_DEBUG || EF_FACE_SDF_GOO_ANGLE_DEBUG || EF_FACE_SSS_ENABLED || EF_FACE_ZMD_SHADOW_ENABLED || EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
    float3 headFront;
    float3 headRight;
    float3 headUp;
    float headBasisValid;
    EfFaceGetHeadBasis(headFront, headRight, headUp, headBasisValid);
    if (headBasisValid < 0.5) {
        return float4(1.0, 0.0, 1.0, 1.0);
    }
#endif

#if EF_FACE_ZMD_SHADOW_RAW_DEBUG
    if (!EfFaceZmdShadowValid) {
        return float4(1.0, 0.0, 1.0, 1.0);
    }
    float zmdShadowAmount = 1.0 - EfFaceSampleZmdShadow(
        input.screenPosition);
    return float4(saturate(zmdShadowAmount).xxx, 1.0);
#endif

#if EF_FACE_SSS_MASK_DEBUG
    float sssMaskDebug = EfFaceComputeSssArea(input, headFront, headRight);
    return float4(sssMaskDebug.xxx, 1.0);
#endif

#if EF_FACE_HEAD_BASIS_DEBUG
#if EF_FACE_HEAD_BASIS_DEBUG_MODE == 0
    float3 headBasisDebug = headFront * 0.5 + 0.5;
#elif EF_FACE_HEAD_BASIS_DEBUG_MODE == 1
    float3 headBasisDebug = headRight * 0.5 + 0.5;
#elif EF_FACE_HEAD_BASIS_DEBUG_MODE == 2
    float3 headBasisDebug = headUp * 0.5 + 0.5;
#else
    // Expected neutral convention: Right=-X, Up=+Y, Front=-Z.
    float3 headBasisDebug = saturate(float3(
        dot(headRight, float3(-1.0, 0.0, 0.0)),
        dot(headUp, float3(0.0, 1.0, 0.0)),
        dot(headFront, float3(0.0, 0.0, -1.0))));
#endif
    return float4(saturate(headBasisDebug), 1.0);
#endif

#if EF_FACE_SDF_MIRROR_FLAG_DEBUG || EF_FACE_SDF_MIRRORED_R_DEBUG || EF_FACE_SDF_CHANNEL_SELECT_DEBUG || EF_FACE_SDF_THRESHOLD_DEBUG || EF_FACE_SDF_GOO_ANGLE_DEBUG
    // MMD's DIRECTION semantic is the ray-travel direction. Negate it to get
    // the surface-to-light vector used by the face-local SDF convention.
    float lightLengthSq = dot(EfFaceMmdLightDirection,
        EfFaceMmdLightDirection);
    if (lightLengthSq < 1e-8) {
        return float4(1.0, 1.0, 0.0, 1.0);
    }

    float3 lightWS = -EfFaceMmdLightDirection * rsqrt(lightLengthSq);
    float3 projectedLight = lightWS - dot(lightWS, headUp) * headUp;
    float projectedLengthSq = dot(projectedLight, projectedLight);
    if (projectedLengthSq < 1e-8) {
        // A vertical light has no stable left/right side on the face plane.
        return float4(1.0, 1.0, 0.0, 1.0);
    }

    projectedLight *= rsqrt(projectedLengthSq);
    float side = dot(projectedLight, headRight);
    float mirrorFlag = step(0.0, side);
#if EF_FACE_SDF_MIRROR_FLAG_DEBUG
    return float4(mirrorFlag.xxx, 1.0);
#else
    // Right-side light keeps U; left-side light uses 1-U.
    float2 mirroredSdfUV = input.uv;
    mirroredSdfUV.x = lerp(1.0 - input.uv.x, input.uv.x, mirrorFlag);
    float4 mirroredSdf = tex2D(EfFaceSdfSampler, mirroredSdfUV);
#if EF_FACE_SDF_MIRRORED_R_DEBUG
    float mirroredSdfR = mirroredSdf.r;
    return float4(saturate(mirroredSdfR).xxx, 1.0);
#elif EF_FACE_SDF_CHANNEL_SELECT_DEBUG
    // Article/Unity contract: front light uses G, back light uses R. Keep the
    // values raw here; response thresholds and front/back smoothing come next.
    float faceLightDot = dot(projectedLight, headFront);
    float frontChannelFlag = step(0.0, faceLightDot);
    float selectedSdf = lerp(mirroredSdf.r, mirroredSdf.g,
        frontChannelFlag);
    return float4(saturate(selectedSdf).xxx, 1.0);
#elif EF_FACE_SDF_THRESHOLD_DEBUG
    // Article/Unity threshold response. The source uses reversed smoothstep
    // edges; write the equivalent 1-smoothstep form so DX9 behavior is defined.
    float faceLightDot = dot(projectedLight, headFront);
    float softShadow = max(0.01, EF_FACE_SDF_SOFTNESS);

    float frontEdgeLow = max(faceLightDot - softShadow, 0.0);
    float frontEdgeHigh = faceLightDot + softShadow;
    float frontShadow = 1.0 - smoothstep(frontEdgeLow, frontEdgeHigh,
        1.0 - mirroredSdf.g);

    // Preserve the article implementation for the first visual pass. On the
    // back half this maps faceLightDot [-1,0] to [0,0.5].
    float backDotRemap = saturate(faceLightDot * 0.5 + 0.5);
    float backEdgeLow = backDotRemap - softShadow;
    float backEdgeHigh = min(backDotRemap + softShadow, 1.0);
    float backShadow = 1.0 - smoothstep(backEdgeLow, backEdgeHigh,
        1.0 - mirroredSdf.r);

    float backChannelBlend = 1.0 - smoothstep(-softShadow, softShadow,
        faceLightDot);
    float sdfShadow = saturate(lerp(frontShadow, backShadow,
        backChannelBlend));
    return float4(sdfShadow.xxx, 1.0);
#else
// Goo-style contract: one continuous angular threshold over the
    // full light orbit, with the two authored SDF channels averaged together.
    // Keep the longitudinal sign explicit: Goo and MMD expose opposite light
    // vector contracts, so the correct host convention must be probed directly.
    float sX = side;
    float sZ = dot(projectedLight,
        headFront * EF_FACE_SDF_GOO_FORWARD_SIGN);
    float angle01 = abs(atan2(sX, sZ)) * (1.0 / 3.14159265);
    float sdfAngleThreshold = saturate(angle01);
    float sdfAverage = saturate(0.5 * (mirroredSdf.r + mirroredSdf.g));

    float gooCenter = sdfAngleThreshold + EF_FACE_SDF_GOO_CENTER;
    float gooSharpness = EfFaceControllerSdfSharpness(
        EF_FACE_SDF_GOO_SHARP);
    float gooExponent = -3.0 * gooSharpness *
        (sdfAverage - gooCenter);
    float gooDenominator = 1.0 + pow(EF_FACE_SDF_GOO_BASE, gooExponent);
    float gooMask = saturate(1.0 / max(gooDenominator, 1e-4));
#if EF_FACE_SDF_CMM_BLEND_DEBUG
    float cmmBlend = tex2D(EfFaceCmmSampler, input.uv).g;
    float geometricNoL = saturate(dot(input.normalWS, lightWS));
    float blendedMask = lerp(gooMask, geometricNoL, saturate(cmmBlend));
#if EF_FACE_RD_RESPONSE_DEBUG || EF_FACE_RD_ALPHA_DEBUG || EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG || EF_FACE_LUT_RD_COLOR_DEBUG
    float4 rdColor = tex2D(EfFaceRdSampler, float2(blendedMask, 0.5));
#if EF_FACE_RD_ALPHA_DEBUG
    return float4(saturate(rdColor.a).xxx, 1.0);
#elif EF_FACE_LUT_RD_ALPHA_BLEND_DEBUG || EF_FACE_LUT_RD_COLOR_DEBUG
    // RD.a alone chooses between LUT dark skin and authored D RGB. The color
    // and AO diagnostics may refine that blend below; light/shadows stay out.
    float4 authoredFace = tex2D(EfFaceMainSampler, input.uv);
    float3 authoredBright = authoredFace.rgb;
    float3 lutDark = EfFaceSampleSkinLut(authoredBright);
#if EF_FACE_SSS_ENABLED
    // MyZmd applies this view-dependent 3S refinement only to the bright
    // albedo. The LUT dark color above deliberately remains unmodified.
    float sssArea = EfFaceComputeSssArea(input, headFront, headRight);
    float3 sssColorEffect = lerp(float3(1.0, 1.0, 1.0),
        max(EF_FACE_SSS_COLOR, 0.0), sssArea);
    float3 authoredBrightLinear = EfFaceSrgbToLinear(
        saturate(authoredBright));
    authoredBright = EfFaceLinearToSrgb(
        max(authoredBrightLinear * sssColorEffect, 0.0));
#endif
    float diffuseWeight = saturate(rdColor.a);
#if EF_FACE_LUT_RD_COLOR_AO_DEBUG || EF_FACE_LUT_RD_COLOR_AO_RAMP_DEBUG
    float aoStrength = EfFaceControllerAoStrength(EF_FACE_AO_STRENGTH);
    float faceAo = pow(max(saturate(authoredFace.a), 1e-5),
        max(aoStrength, 0.0));
#endif
#if EF_FACE_LUT_RD_COLOR_AO_RAMP_DEBUG
    // Article/MyZmd contract: AO limits the Ramp alpha light/dark blend. It
    // selects the authored dark color instead of multiplying the result black.
    diffuseWeight = min(diffuseWeight, faceAo);
#endif
#if EF_FACE_ZMD_SHADOW_ENABLED
    // Scene shadow joins RD.a and AO as another light/dark selector. It moves
    // affected pixels toward the verified LUT dark color instead of multiplying
    // the already-shaded face toward black.
    float faceShadowEffect = EfFaceComputeZmdShadowEffect(
        input.uv, input.screenPosition, headFront, headRight);
    diffuseWeight = min(diffuseWeight, faceShadowEffect);
#endif
    float3 diffuseBlend = lerp(lutDark, authoredBright, diffuseWeight);
#if EF_FACE_LUT_RD_COLOR_DEBUG
    diffuseBlend = EfFaceApplyRdColor(diffuseBlend, saturate(rdColor.rgb));
#endif
#if EF_FACE_LUT_RD_COLOR_AO_DEBUG
    // Match the validated D/AO baseline: Alpha is linear control data and AO
    // modulates diffuse energy in linear space, not display/sRGB space.
    float3 diffuseLinear = EfFaceSrgbToLinear(saturate(diffuseBlend));
    diffuseBlend = EfFaceLinearToSrgb(max(diffuseLinear * faceAo, 0.0));
#endif
#if EF_FACE_FINAL_BRIGHTNESS_DEBUG
// Goo-style Face Final brightness is applied to scene-linear
    // diffuse after the complete authored color/AO chain.
    float3 finalDiffuseLinear = EfFaceSrgbToLinear(saturate(diffuseBlend));
    finalDiffuseLinear *= max(EF_FACE_FINAL_BRIGHTNESS, 0.0);
    diffuseBlend = EfFaceLinearToSrgb(max(finalDiffuseLinear, 0.0));
#endif
#if EF_FACE_FINAL_SOFT_EXPOSURE_ENABLED
    // Lift dark and middle values without driving the already-bright skin
    // directly into white. Exposure 1.0 is an exact neutral operation.
    float faceSoftExposure = max(EF_FACE_FINAL_SOFT_EXPOSURE, 0.0);
    float3 faceExposureLinear = EfFaceSrgbToLinear(saturate(diffuseBlend));
    faceExposureLinear = faceExposureLinear * faceSoftExposure /
        max(1.0 + faceExposureLinear * (faceSoftExposure - 1.0), 1e-4);
    diffuseBlend = EfFaceLinearToSrgb(saturate(faceExposureLinear));
#endif
#if EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
    float3 faceSpecularLinear = float3(0.0, 0.0, 0.0);
#endif
#if EF_FACE_LIP_SPECULAR_ENABLED
    // Zhihu face contract: the authored hl_M red channel slides horizontally
    // with view direction and disappears when the main light is behind the face.
    float3 lipViewDirWS = normalize(CameraPosition - input.positionWS);
    float lipUvOffset = EfFaceControllerLipUvOffset(
        EF_FACE_LIP_SPECULAR_UV_OFFSET);
    float lipSpaceOffset = dot(lipViewDirWS, headRight)
        * lipUvOffset;
    float2 lipSpecularUv = float2(input.uv.x + lipSpaceOffset, input.uv.y);
    float lipSpecularMask = 0.0;
#ifdef EF_FACE_LIP_SPECULAR_TEXTURE_RESOURCE
    lipSpecularMask = tex2D(EfFaceLipSpecularSampler,
        lipSpecularUv).r;
#elif defined(EF_FACE_ST_TEXTURE_RESOURCE)
    // Generic fallback: use a selected Face ST mask when the model has one.
    lipSpecularMask = tex2D(EfFaceStSampler, lipSpecularUv).r;
#else
    // Last-resort fallback: opaque MATERIALTEXTURE alpha naturally produces
    // no highlight, while authored alpha masks remain usable.
    lipSpecularMask = tex2D(EfFaceMainSampler, lipSpecularUv).a;
#endif
    float lipSdfDot = dot(projectedLight, headFront);
    float lipLightFade = EfFaceControllerLipLightFade(
        EF_FACE_LIP_SPECULAR_LIGHT_FADE);
    float lipFrontLight = smoothstep(0.0,
        max(lipLightFade, 1e-5), lipSdfDot);
    lipSpecularMask *= lipFrontLight;
#if EF_FACE_LIP_SPECULAR_MASK_DEBUG
    return float4(saturate(lipSpecularMask).xxx, 1.0);
#endif
    float lipSpecularStrength = EfFaceControllerLipSpecularStrength(
        EF_FACE_LIP_SPECULAR_STRENGTH);
    faceSpecularLinear += lipSpecularMask
        * lipSpecularStrength
        * max(EF_FACE_LIP_SPECULAR_COLOR, 0.0)
        * max(EfFaceMmdLightColor, 0.0);
#endif
#if EF_FACE_RIM_ENABLED
    // Zhihu face rim: cm_M.a supplies the authored region, the light side
    // selects one UV half, and head-facing NoV fades the painted rim at profile.
// The validated MMD face UV/right-axis pairing is mirrored relative to the
    // article asset, so use the verified SDF mirror direction for the lit half.
    float faceHalfMask = step(input.uv.x, 0.5);
    float litHalfFlag = step(0.0, side);
    faceHalfMask = lerp(1.0 - faceHalfMask, faceHalfMask,
        litHalfFlag);
    float3 rimViewDirWS = normalize(CameraPosition - input.positionWS);
    float faceNoV = saturate(dot(headFront, rimViewDirWS));
    float rimIntensity = EfFaceControllerRimStrength(
        EF_FACE_RIM_INTENSITY);
    float rimViewMask = rimIntensity
        * saturate(faceNoV - EF_FACE_RIM_NOV_THRESHOLD);
    float rimFrontLight = saturate(dot(projectedLight, headFront));
    float rimAuthoredMask = tex2D(EfFaceCmmSampler, input.uv).a;
    float rimWidth = EfFaceControllerRimWidth(EF_FACE_RIM_WIDTH);
    rimAuthoredMask = pow(saturate(rimAuthoredMask),
        1.0 / max(rimWidth, 0.05));
    float faceRimMask = saturate(rimAuthoredMask * faceHalfMask
        * rimViewMask * rimFrontLight);
    faceRimMask = EfRimApplyContrast(
        faceRimMask, EfFaceControllerRimContrast());
#if EF_FACE_RIM_MASK_DEBUG
    return float4(faceRimMask.xxx, 1.0);
#endif
    float3 faceRimColor = EfFaceControllerRimColor(
        EfFaceSrgbToLinear(saturate(EfFaceMaterialEdgeColor.rgb)),
        EF_FACE_RIM_COLOR);
    faceSpecularLinear += faceRimMask
        * max(faceRimColor, 0.0)
        * max(EfFaceMmdLightColor, 0.0);
#endif
#if EF_FACE_LIP_SPECULAR_ENABLED || EF_FACE_RIM_ENABLED
    float3 faceWithSpecularLinear =
        EfFaceSrgbToLinear(saturate(diffuseBlend))
        + faceSpecularLinear;
    diffuseBlend = EfFaceLinearToSrgb(max(faceWithSpecularLinear, 0.0));
#endif
    float3 globalFaceLinear = EfFaceSrgbToLinear(
        saturate(diffuseBlend));
    globalFaceLinear = EfApplyGlobalMaterialGradeScaled(
        globalFaceLinear,
        diffuseWeight);
    return float4(
        saturate(EfFaceLinearToSrgb(globalFaceLinear)),
        1.0);
#else
    return float4(saturate(rdColor.rgb), 1.0);
#endif
#else
    return float4(blendedMask.xxx, 1.0);
#endif
#else
    return float4(gooMask.xxx, 1.0);
#endif
#endif
#endif
#endif

#if EF_FACE_CMM_RAW_DEBUG
    // cm_M is authored linear control data. G blends the face SDF response
    // toward geometric NoL in MyZmd and protects non-face/neck transitions.
    float4 cmmData = tex2D(EfFaceCmmSampler, input.uv);
#if EF_FACE_CMM_RAW_DEBUG_CHANNEL == 0
    float cmmDebug = cmmData.r;
#elif EF_FACE_CMM_RAW_DEBUG_CHANNEL == 1
    float cmmDebug = cmmData.g;
#elif EF_FACE_CMM_RAW_DEBUG_CHANNEL == 2
    float cmmDebug = cmmData.b;
#else
    float cmmDebug = cmmData.a;
#endif
    return float4(saturate(cmmDebug).xxx, 1.0);
#endif

#if EF_FACE_SDF_RAW_DEBUG
    // SDF is authored linear data. Display one channel directly without
    // albedo, AO, mirroring, thresholding, light, or display gamma changes.
    float4 sdfData = tex2D(EfFaceSdfSampler, input.uv);
#if EF_FACE_SDF_RAW_DEBUG_CHANNEL == 0
    float sdfDebug = sdfData.r;
#elif EF_FACE_SDF_RAW_DEBUG_CHANNEL == 1
    float sdfDebug = sdfData.g;
#elif EF_FACE_SDF_RAW_DEBUG_CHANNEL == 2
    float sdfDebug = sdfData.b;
#else
    float sdfDebug = sdfData.a;
#endif
    return float4(saturate(sdfDebug).xxx, 1.0);
#endif

    float4 texel = float4(saturate(MaterialDiffuse.rgb), 1.0);
    if (useTexture) {
        texel = tex2D(EfFaceMainSampler, input.uv);
    }

#if EF_FACE_D_RGB_DEBUG
    // Raw authored display-space color. No AO, LUT, SDF, RD or lighting.
    return float4(saturate(texel.rgb), 1.0);
#endif

#if EF_FACE_SKIN_LUT_DEBUG
    // This diagnostic intentionally returns only the LUT's dark-color result;
    // RD/AO/SDF/light are kept out so the sampling contract can be verified.
    float3 lutDarkColor = EfFaceSampleSkinLut(texel.rgb);
    return float4(saturate(lutDarkColor), 1.0);
#endif

    // D RGB is authored in display/sRGB space; Alpha is an AO mask, not
    // material opacity. Keep the pass opaque and do not feed AO to blending.
    float3 albedoLinear = EfFaceSrgbToLinear(texel.rgb);
    albedoLinear = pow(max(albedoLinear * EF_FACE_BASE_COLOR, 1e-5),
        EF_FACE_BASE_COLOR_POW);
    float ao = pow(saturate(texel.a), max(EF_FACE_AO_STRENGTH, 0.0));
    float3 resultLinear = max(albedoLinear * ao, 0.0);
    resultLinear = EfApplyGlobalColorGrade(resultLinear);
    return float4(EfFaceLinearToSrgb(resultLinear), 1.0);
}

#if EF_FACE_STENCIL_WRITE_ENABLED
float4 EfFaceShadowReceiverMaskPS(
    EfFaceVaryings input,
    float facing : VFACE) : COLOR0
{
#if EF_FACE_SHADOW_RECEIVER_MASK_ENABLED
    // Face ST.g is the shared soft eye/upper-face region across Endfield
    // characters. It excludes ear and mouth islands before stencil writing.
    float authoredFace = 1.0;
#if EF_FACE_SHADOW_RECEIVER_ST_ENABLED
    authoredFace = tex2D(
        EfFaceShadowReceiverStSampler, input.uv).g;
#endif
    float3 headFront;
    float3 headRight;
    float3 headUp;
    float headBasisValid;
    EfFaceGetHeadBasis(
        headFront, headRight, headUp, headBasisValid);

    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 normalWS = normalize(input.normalWS) * faceSign;
    float normalFacing = smoothstep(
        EF_FACE_SHADOW_RECEIVER_NORMAL_START,
        max(EF_FACE_SHADOW_RECEIVER_NORMAL_END,
            EF_FACE_SHADOW_RECEIVER_NORMAL_START + 1e-4),
        dot(normalWS, headFront));
    normalFacing = lerp(1.0, normalFacing, saturate(headBasisValid));
    float receiverMask = authoredFace * normalFacing;
    clip(receiverMask - EF_FACE_SHADOW_RECEIVER_ST_THRESHOLD);
#endif
    return 0.0;
}
#endif

#if EF_FACE_OUTLINE_ENABLED
struct EfFaceOutlineVaryings {
    float4 positionCS : POSITION;
    float3 normalWS : TEXCOORD0;
};

EfFaceOutlineVaryings EfFaceOutlineVS(EfFaceAttributes input)
{
    EfFaceOutlineVaryings output = (EfFaceOutlineVaryings)0;
    float4 positionCS = mul(input.positionOS, matWorldViewProject);
    float3 normalWS = normalize(
        mul(input.normalOS, (float3x3)matWorld));
    output.positionCS = positionCS;
    output.normalWS = normalWS;
    return output;
}

float4 EfFaceOutlinePS(EfFaceOutlineVaryings input) : COLOR0
{
    float4 edgeColor = saturate(EfFaceMaterialEdgeColor);
    clip(edgeColor.a - 1e-4);
    return edgeColor;
}

#define EF_FACE_OUTLINE_OBJECT_PASS
#endif
#ifndef EF_FACE_OUTLINE_OBJECT_PASS
#define EF_FACE_OUTLINE_OBJECT_PASS
#endif
#define EF_FACE_OUTLINE_EDGE_TECHNIQUE

#ifndef EF_NO_TECHNIQUES
#if EF_FACE_STENCIL_WRITE_ENABLED
#define EF_FACE_OBJECT_SCRIPT \
    "RenderColorTarget0=;Pass=WriteHairShadowMask;Pass=DrawObject;"
#define EF_FACE_STENCIL_OBJECT_PASS \
        pass WriteHairShadowMask { \
            AlphaTestEnable = false; \
            AlphaBlendEnable = false; \
            ColorWriteEnable = 0; \
            ZEnable = true; \
            ZWriteEnable = true; \
            ZFunc = LESSEQUAL; \
            CullMode = EF_FACE_CULL_MODE; \
            StencilEnable = true; \
            StencilFunc = ALWAYS; \
            StencilRef = EF_FACE_STENCIL_REF; \
            StencilWriteMask = EF_FACE_STENCIL_WRITE_MASK; \
            StencilFail = KEEP; \
            StencilZFail = KEEP; \
            StencilPass = REPLACE; \
            VertexShader = compile vs_3_0 EfFaceVS(); \
            PixelShader = compile ps_3_0 EfFaceShadowReceiverMaskPS(); \
        }
#else
#define EF_FACE_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;"
#define EF_FACE_STENCIL_OBJECT_PASS
#endif

#define EF_FACE_PASS_STATES \
    AlphaTestEnable = false; \
    AlphaBlendEnable = false; \
    ColorWriteEnable = 15; \
    ZEnable = true; \
    ZWriteEnable = true; \
    ZFunc = LESSEQUAL; \
    StencilEnable = false;

#define EF_FACE_TECHNIQUE(name, passName, useTextureValue) \
    technique name < \
        string MMDPass = passName; \
        string Script = EF_FACE_OBJECT_SCRIPT; \
        bool UseTexture = useTextureValue; \
        bool UseSphereMap = false; \
        bool UseSelfShadow = EF_FACE_USE_SELF_SHADOW; \
    > { \
        EF_FACE_STENCIL_OBJECT_PASS \
        pass DrawObject { \
            EF_FACE_PASS_STATES \
            CullMode = EF_FACE_CULL_MODE; \
            VertexShader = compile vs_3_0 EfFaceVS(); \
            PixelShader = compile ps_3_0 EfFacePS(useTextureValue); \
        } \
        EF_FACE_OUTLINE_OBJECT_PASS \
    }

EF_FACE_TECHNIQUE(EfFaceObjectNoTexture, "object", false)
EF_FACE_TECHNIQUE(EfFaceObjectTexture, "object", true)
EF_FACE_TECHNIQUE(EfFaceObjectShadowNoTexture, "object_ss", false)
EF_FACE_TECHNIQUE(EfFaceObjectShadowTexture, "object_ss", true)
EF_FACE_OUTLINE_EDGE_TECHNIQUE
#endif

#ifdef EF_NO_TECHNIQUES
float4 EfFaceProbePS(EfFaceVaryings input) : COLOR0
{
    return EfFacePS(input, true);
}
#endif

#endif
