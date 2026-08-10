#ifndef ENDFIELD_SKIN_INCLUDED
#define ENDFIELD_SKIN_INCLUDED

// Body-skin core. The accepted D/RD/LUT/SSS/shadow/rim chain can optionally
// add a broad direct-light GGX micro-specular; the geometric outline remains
// deferred until the material response is visually locked.

#ifndef EF_SKIN_MAIN_TEXTURE_RESOURCE
#define EF_SKIN_MAIN_TEXTURE_RESOURCE \
    "textures/chen/T_actor_chen_body_01_D.png"
#endif
#ifndef EF_SKIN_CULL_MODE
#define EF_SKIN_CULL_MODE NONE
#endif
#ifndef EF_SKIN_RD_TEXTURE_RESOURCE
#define EF_SKIN_RD_TEXTURE_RESOURCE \
    "textures/chen/T_actor_common_body_01_RD.png"
#endif
#ifndef EF_SKIN_LUT_TEXTURE_RESOURCE
#define EF_SKIN_LUT_TEXTURE_RESOURCE \
    "textures/chen/T_actor_common_femaleskincolor02_lut_D.png"
#endif
#ifndef EF_SKIN_LUT_STRENGTH
#define EF_SKIN_LUT_STRENGTH 0.35
#endif
#ifndef EF_SKIN_LUT_USE_BRG
#define EF_SKIN_LUT_USE_BRG 1
#endif
#ifndef EF_SKIN_SSS_ENABLED
#define EF_SKIN_SSS_ENABLED 0
#endif
#ifndef EF_SKIN_SSS_RANGE
#define EF_SKIN_SSS_RANGE 0.5
#endif
#ifndef EF_SKIN_SSS_STRENGTH
#define EF_SKIN_SSS_STRENGTH 1.0
#endif
#ifndef EF_SKIN_SSS_COLOR
// Scene-linear warm skin transmission color validated by the face preset.
#define EF_SKIN_SSS_COLOR float3(0.822936177, 0.669170380, 0.648408771)
#endif
#ifndef EF_SKIN_SPECULAR_ENABLED
#define EF_SKIN_SPECULAR_ENABLED 0
#endif
#ifndef EF_SKIN_SPECULAR_STRENGTH
#define EF_SKIN_SPECULAR_STRENGTH 0.65
#endif
#ifndef EF_SKIN_SPECULAR_ROUGHNESS
#define EF_SKIN_SPECULAR_ROUGHNESS 0.58
#endif
#ifndef EF_SKIN_SPECULAR_REFLECTIVITY
#define EF_SKIN_SPECULAR_REFLECTIVITY 0.50
#endif
#ifndef EF_SKIN_SPECULAR_COLOR
#define EF_SKIN_SPECULAR_COLOR float3(1.0, 0.94, 0.92)
#endif
#ifndef EF_SKIN_SPECULAR_LIGHT_END
#define EF_SKIN_SPECULAR_LIGHT_END 0.30
#endif
#ifndef EF_SKIN_ZMD_SHADOW_ENABLED
#define EF_SKIN_ZMD_SHADOW_ENABLED 0
#endif
#ifndef EF_SKIN_SHADOW_VIEWPORT_MAP
#define EF_SKIN_SHADOW_VIEWPORT_MAP ZMDshadow_ViewportMap2
#endif
#ifndef EF_SKIN_SHADOW_CONTROLLER_NAME
#define EF_SKIN_SHADOW_CONTROLLER_NAME "ZMDshadow.x"
#endif
#ifndef EF_SKIN_SHADOW_CENTER
#define EF_SKIN_SHADOW_CENTER 0.5
#endif
#ifndef EF_SKIN_SHADOW_SMOOTHNESS
#define EF_SKIN_SHADOW_SMOOTHNESS 0.35
#endif
#ifndef EF_SKIN_SHADOW_OFFSET
#define EF_SKIN_SHADOW_OFFSET 0.0
#endif
#ifndef EF_SKIN_SHADOW_STRENGTH
#define EF_SKIN_SHADOW_STRENGTH 1.0
#endif
#ifndef EF_SKIN_USE_SELF_SHADOW
#if EF_SKIN_ZMD_SHADOW_ENABLED
#define EF_SKIN_USE_SELF_SHADOW true
#else
#define EF_SKIN_USE_SELF_SHADOW false
#endif
#endif
#ifndef EF_SKIN_RIM_ENABLED
#define EF_SKIN_RIM_ENABLED 0
#endif
#ifndef EF_SKIN_RIM_AREA
#define EF_SKIN_RIM_AREA 0.45
#endif
#ifndef EF_SKIN_RIM_STRENGTH
#define EF_SKIN_RIM_STRENGTH 0.30
#endif
#ifndef EF_SKIN_RIM_COLOR
#define EF_SKIN_RIM_COLOR float3(1.0, 0.82, 0.78)
#endif
#ifndef EF_SKIN_RIM_DIFFUSE_EFFECT
#define EF_SKIN_RIM_DIFFUSE_EFFECT 0.5
#endif
#ifndef EF_SKIN_SCREEN_RIM_ENABLED
#define EF_SKIN_SCREEN_RIM_ENABLED 0
#endif
#ifndef EF_SKIN_SCREEN_RIM_WIDTH_X
#define EF_SKIN_SCREEN_RIM_WIDTH_X 0.041847
#endif
#ifndef EF_SKIN_SCREEN_RIM_WIDTH_Y
#define EF_SKIN_SCREEN_RIM_WIDTH_Y 0.019108
#endif
#ifndef EF_SKIN_SCREEN_RIM_VIEW_SCALE
#define EF_SKIN_SCREEN_RIM_VIEW_SCALE 0.1
#endif
#ifndef EF_SKIN_SCREEN_RIM_MODEL_SCALE
#define EF_SKIN_SCREEN_RIM_MODEL_SCALE 10.0
#endif
#ifndef EF_SKIN_SCREEN_RIM_DEPTH_SCALE
#define EF_SKIN_SCREEN_RIM_DEPTH_SCALE 0.8
#endif
#ifndef EF_SKIN_SCREEN_RIM_DEPTH_MAX
#define EF_SKIN_SCREEN_RIM_DEPTH_MAX 4.0
#endif
#ifndef EF_SKIN_SCREEN_RIM_FRESNEL_POWER
#define EF_SKIN_SCREEN_RIM_FRESNEL_POWER 3.0
#endif
#ifndef EF_SKIN_SCREEN_RIM_LIGHT_START
#define EF_SKIN_SCREEN_RIM_LIGHT_START 0.0
#endif
#ifndef EF_SKIN_SCREEN_RIM_LIGHT_END
#define EF_SKIN_SCREEN_RIM_LIGHT_END 0.2
#endif
#ifndef EF_SKIN_SCREEN_RIM_STRENGTH
#define EF_SKIN_SCREEN_RIM_STRENGTH 0.7
#endif
#ifndef EF_SKIN_SCREEN_RIM_COLOR
#define EF_SKIN_SCREEN_RIM_COLOR EF_SKIN_RIM_COLOR
#endif
#ifndef EF_SKIN_OUTLINE_ENABLED
#define EF_SKIN_OUTLINE_ENABLED 0
#endif
#ifndef EF_SKIN_OUTLINE_WIDTH
#define EF_SKIN_OUTLINE_WIDTH 0.5
#endif
#ifndef EF_SKIN_OUTLINE_ZBIAS
#define EF_SKIN_OUTLINE_ZBIAS 0.001
#endif
#ifndef EF_SKIN_OUTLINE_COLOR
#define EF_SKIN_OUTLINE_COLOR float3(0.08, 0.045, 0.04)
#endif
#ifndef EF_SKIN_OUTLINE_BASE_COLOR
#define EF_SKIN_OUTLINE_BASE_COLOR EF_SKIN_OUTLINE_COLOR
#endif
#ifndef EF_SKIN_OUTLINE_STRENGTH
#define EF_SKIN_OUTLINE_STRENGTH 1.0
#endif
#ifndef EF_SKIN_OUTLINE_ZMIN_REFINE
#define EF_SKIN_OUTLINE_ZMIN_REFINE 0.4
#endif
#ifndef EF_SKIN_OUTLINE_LIGHT_FLOOR
#define EF_SKIN_OUTLINE_LIGHT_FLOOR 0.7
#endif
#ifndef EF_SKIN_CONTROLLER_ENABLED
#define EF_SKIN_CONTROLLER_ENABLED 0
#endif

#if EF_SKIN_OUTLINE_ENABLED
#include "internal/endfield_outline.hlsl"
#endif
#if EF_SKIN_RIM_ENABLED || EF_SKIN_SCREEN_RIM_ENABLED
#include "internal/endfield_specular.hlsl"
#include "internal/endfield_global_controls.inc"
#endif
#ifndef EF_SKIN_RD_COLOR_STRENGTH
#define EF_SKIN_RD_COLOR_STRENGTH 0.35
#endif
#ifndef EF_SKIN_LIGHT_CURVE
#define EF_SKIN_LIGHT_CURVE 1.0
#endif
#ifndef EF_SKIN_RD_DARK_STRENGTH
#define EF_SKIN_RD_DARK_STRENGTH 0.72
#endif
#ifndef EF_SKIN_RD_LIGHT_STRENGTH
#define EF_SKIN_RD_LIGHT_STRENGTH 1.12
#endif

#if EF_SKIN_CONTROLLER_ENABLED
#include "internal/endfield_skin_controls.inc"
#endif

float4x4 EfSkinWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 EfSkinWorld : WORLD;
#if EF_SKIN_SCREEN_RIM_ENABLED
float4x4 EfSkinView : VIEW;
float4x4 EfSkinProjection : PROJECTION;
#endif
float4 EfSkinMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float4 EfSkinMaterialEdgeColor : EDGECOLOR;
float3 EfSkinMmdLightDirection : DIRECTION < string Object = "Light"; >;
#if EF_SKIN_SSS_ENABLED || EF_SKIN_SPECULAR_ENABLED || EF_SKIN_RIM_ENABLED || EF_SKIN_SCREEN_RIM_ENABLED
float3 EfSkinCameraPosition : POSITION < string Object = "Camera"; >;
#endif
#if EF_SKIN_SPECULAR_ENABLED || EF_SKIN_RIM_ENABLED
float3 EfSkinMmdLightColor : SPECULAR < string Object = "Light"; >;
#endif

texture2D EfSkinMainTexture <
    string ResourceName = EF_SKIN_MAIN_TEXTURE_RESOURCE;
>;
sampler2D EfSkinMainSampler = sampler_state {
    texture = <EfSkinMainTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D EfSkinRdTexture <
    string ResourceName = EF_SKIN_RD_TEXTURE_RESOURCE;
>;
sampler2D EfSkinRdSampler = sampler_state {
    texture = <EfSkinRdTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D EfSkinLutTexture <
    string ResourceName = EF_SKIN_LUT_TEXTURE_RESOURCE;
>;
sampler2D EfSkinLutSampler = sampler_state {
    texture = <EfSkinLutTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

#if EF_SKIN_ZMD_SHADOW_ENABLED || EF_SKIN_SCREEN_RIM_ENABLED
shared texture2D EF_SKIN_SHADOW_VIEWPORT_MAP : RENDERCOLORTARGET;
sampler2D EfSkinZmdShadowSampler = sampler_state {
    texture = <EF_SKIN_SHADOW_VIEWPORT_MAP>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
bool EfSkinZmdShadowValid : CONTROLOBJECT <
    string name = EF_SKIN_SHADOW_CONTROLLER_NAME;
>;
#endif
#if EF_SKIN_ZMD_SHADOW_ENABLED || EF_SKIN_SCREEN_RIM_ENABLED || EF_SKIN_OUTLINE_ENABLED
float2 EfSkinViewportSize : VIEWPORTPIXELSIZE;
#endif
#if EF_SKIN_ZMD_SHADOW_ENABLED
float EfSkinZmdShadowRotation : CONTROLOBJECT <
    string name = EF_SKIN_SHADOW_CONTROLLER_NAME;
    string item = "Rx";
>;
float EfSkinShadowDensityUp : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen+";
>;
float EfSkinShadowDensityDown : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen-";
>;
#endif

struct EfSkinAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct EfSkinVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
#if EF_SKIN_SSS_ENABLED || EF_SKIN_SPECULAR_ENABLED || EF_SKIN_RIM_ENABLED
    float3 positionWS : TEXCOORD2;
#endif
#if EF_SKIN_ZMD_SHADOW_ENABLED
    float4 screenPosition : TEXCOORD3;
#endif
};

EfSkinVaryings EfSkinVS(EfSkinAttributes input)
{
    EfSkinVaryings output = (EfSkinVaryings)0;
    output.positionCS = mul(input.positionOS, EfSkinWorldViewProjection);
    output.uv = input.texcoord0;
    output.normalWS = normalize(mul(input.normalOS, (float3x3)EfSkinWorld));
#if EF_SKIN_SSS_ENABLED || EF_SKIN_SPECULAR_ENABLED || EF_SKIN_RIM_ENABLED
    output.positionWS = mul(input.positionOS, EfSkinWorld).xyz;
#endif
#if EF_SKIN_ZMD_SHADOW_ENABLED
    output.screenPosition = output.positionCS;
#endif
    return output;
}

float3 EfSkinSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 EfSkinLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

float EfSkinLuminance(float3 color)
{
    return dot(color, float3(0.2126, 0.7152, 0.0722));
}

float3 EfSkinDirectGGX(
    float3 normalWS,
    float3 lightDirWS,
    float3 viewDirWS,
    float roughness,
    float reflectivity)
{
    float3 halfVector = lightDirWS + viewDirWS;
    float halfLengthSq = dot(halfVector, halfVector);
    float3 halfDirWS = halfLengthSq > 1e-8
        ? halfVector * rsqrt(halfLengthSq)
        : normalWS;

    float noH = saturate(dot(normalWS, halfDirWS));
    float noV = saturate(dot(normalWS, viewDirWS));
    float roughness2 = max(roughness * roughness, 0.0078125);
    float alpha2 = roughness2 * roughness2;
    float denominator = (noH * alpha2 - noH) * noH + 1.0;
    float distribution = alpha2
        / max(denominator * denominator, 1e-5);
    float visibility = 0.5
        / max(noV * 2.0 + roughness2, 1e-5);
    float dv = min(distribution * visibility, 20.0);
    float f0 = 0.04 * saturate(reflectivity);
    return dv * f0;
}

float3 EfSkinSampleLut(float3 albedoSrgb)
{
    albedoSrgb = saturate(albedoSrgb);
#if EF_SKIN_LUT_USE_BRG
    albedoSrgb = albedoSrgb.brg;
#endif

    // The 1024x32 LUT contains 32 horizontal 32x32 slices.
    float2 lutUv = albedoSrgb.xz * float2(31.0, 0.96875);
    float lutFloorX = floor(lutUv.x);
    float2 lutUvYZ = albedoSrgb.yz *
        float2(0.0302734375, 0.96875) +
        float2(0.00048828125, 0.015625);
    float2 lutUvFinal = float2(
        lutFloorX * 0.03125 + lutUvYZ.x,
        1.0 - lutUvYZ.y);
    float lutTileLerp = albedoSrgb.x * 31.0 - lutFloorX;
    float3 lutColor0 = tex2D(EfSkinLutSampler, lutUvFinal).rgb;
    float3 lutColor1 = tex2D(EfSkinLutSampler,
        lutUvFinal + float2(0.03125, 0.0)).rgb;
    return lerp(lutColor0, lutColor1, lutTileLerp);
}

#if EF_SKIN_ZMD_SHADOW_ENABLED
float EfSkinSampleZmdShadow(float4 screenPosition)
{
    if (!EfSkinZmdShadowValid || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }

    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 screenUv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    screenUv += 0.5 / max(EfSkinViewportSize, 1.0);
    float shadowAmount = saturate(
        tex2D(EfSkinZmdShadowSampler, screenUv).r);
    float visibility = 1.0 - shadowAmount;

    float density = max(
        (degrees(EfSkinZmdShadowRotation)
            + 5.0 * EfSkinShadowDensityUp + 1.0)
            * (1.0 - EfSkinShadowDensityDown),
        0.0);
    return 1.0 - (1.0 - visibility) * min(density, 1.0);
}

float EfSkinComputeZmdShadowEffect(float4 screenPosition)
{
    float visibility = EfSkinSampleZmdShadow(screenPosition);
    float shadowCenter = EF_SKIN_SHADOW_CENTER;
    float shadowSoftness = EF_SKIN_SHADOW_SMOOTHNESS;
    float shadowControl = 1.0;
#if EF_SKIN_CONTROLLER_ENABLED
    shadowCenter = EfSkinControllerShadowCenter(shadowCenter);
    shadowSoftness = EfSkinControllerShadowSoftness(shadowSoftness);
    shadowControl = EfSkinControllerShadowStrength(shadowControl);
#endif
    float shadowT = (visibility - shadowCenter)
        / max(shadowSoftness, 1e-6);
    float shadowScene = 1.0 / (1.0 + exp(-shadowT));
    float baseVisibility = saturate(
        (shadowScene + EF_SKIN_SHADOW_OFFSET)
            * EF_SKIN_SHADOW_STRENGTH);
    return 1.0 - saturate((1.0 - baseVisibility) * shadowControl);
}
#endif

float4 EfSkinPS(EfSkinVaryings input, uniform bool useTexture) : COLOR0
{
    float3 color = saturate(EfSkinMaterialDiffuse.rgb);
    if (useTexture) {
        color = tex2D(EfSkinMainSampler, input.uv).rgb;
    }

    float normalLengthSq = dot(input.normalWS, input.normalWS);
    float3 N = normalLengthSq > 1e-8
        ? input.normalWS * rsqrt(normalLengthSq)
        : float3(0.0, 1.0, 0.0);
    float3 L = EfMmdSurfaceToLightWS(
        EfSkinMmdLightDirection,
        N);
    float lightCurve = EF_SKIN_LIGHT_CURVE;
    float rdColorStrength = EF_SKIN_RD_COLOR_STRENGTH;
    float lutStrength = EF_SKIN_LUT_STRENGTH;
    float darkStrength = EF_SKIN_RD_DARK_STRENGTH;
    float lightStrength = EF_SKIN_RD_LIGHT_STRENGTH;
#if EF_SKIN_CONTROLLER_ENABLED
    lightCurve = EfSkinControllerLightCurve(lightCurve);
    rdColorStrength = EfSkinControllerRdColor(rdColorStrength);
    lutStrength = EfSkinControllerLut(lutStrength);
    darkStrength = EfSkinControllerDarkStrength(darkStrength);
    lightStrength = EfSkinControllerLightStrength(lightStrength);
#endif
    float halfLambert = saturate(dot(N, L) * 0.5 + 0.5);
    halfLambert = pow(halfLambert, max(lightCurve, 1e-4));
    float4 rd = tex2D(EfSkinRdSampler, float2(halfLambert, 0.5));
    // RD alpha selects the light/dark branch. RGB contributes chroma only:
    // neutral black/gray/white samples must not multiply skin toward black.
    float3 rdColorSrgb = saturate(rd.rgb);
    float rdColorMax = max(max(rdColorSrgb.r, rdColorSrgb.g), rdColorSrgb.b);
    float rdColorMin = min(min(rdColorSrgb.r, rdColorSrgb.g), rdColorSrgb.b);
    float rdChroma = saturate(rdColorMax - rdColorMin);
    float3 rdTintSrgb = rdColorSrgb * rdChroma + 1.0 - rdChroma;
    rdTintSrgb = lerp(
        float3(1.0, 1.0, 1.0),
        rdTintSrgb,
        saturate(rdColorStrength));
    float3 lutDarkSrgb = lerp(
        color,
        EfSkinSampleLut(color),
        saturate(lutStrength));
    float diffuseWeight = saturate(rd.a);
#if EF_SKIN_ZMD_SHADOW_ENABLED
    diffuseWeight = min(
        diffuseWeight,
        EfSkinComputeZmdShadowEffect(input.screenPosition));
#endif
    float3 diffuseAlbedoSrgb = lerp(
        lutDarkSrgb,
        color,
        diffuseWeight);
    float lightValue = lerp(
        max(darkStrength, 0.0),
        max(lightStrength, 0.0),
        diffuseWeight);
    float3 diffuseLinear = EfSkinSrgbToLinear(diffuseAlbedoSrgb)
        * lightValue;
    float3 rdTintedLinear = diffuseLinear
        * EfSkinSrgbToLinear(rdTintSrgb);
    float rdLuminanceCompensation = clamp(
        EfSkinLuminance(diffuseLinear)
            / max(EfSkinLuminance(rdTintedLinear), 0.01),
        0.0,
        1.5);
    float3 litColor = rdTintedLinear * rdLuminanceCompensation;
#if EF_SKIN_SSS_ENABLED || EF_SKIN_SPECULAR_ENABLED || EF_SKIN_RIM_ENABLED
    float3 viewVectorWS = EfSkinCameraPosition - input.positionWS;
    float viewLengthSq = dot(viewVectorWS, viewVectorWS);
    float3 viewDirWS = viewLengthSq > 1e-8
        ? viewVectorWS * rsqrt(viewLengthSq)
        : N;
    float noV = saturate(dot(N, viewDirWS));
#endif
#if EF_SKIN_SSS_ENABLED
    float sssRange = EF_SKIN_SSS_RANGE;
    float sssStrength = EF_SKIN_SSS_STRENGTH;
    float3 sssColor = EF_SKIN_SSS_COLOR;
#if EF_SKIN_CONTROLLER_ENABLED
    sssRange = EfSkinControllerSssRange(sssRange);
    sssStrength = EfSkinControllerSssStrength(sssStrength);
    sssColor = EfSkinControllerSssColor(sssColor);
#endif
    // Match the reference's compressed Fresnel range so grazing skin stays bright.
    float sssNoV = noV * 0.85 + 0.15;
    float sssArea = saturate(max(sssRange, 0.0)
        * (1.0 - sssNoV));
    sssArea = saturate(sssArea * max(sssStrength, 0.0));
    float3 sssColorEffect = lerp(
        float3(1.0, 1.0, 1.0),
        max(sssColor, 0.0),
        sssArea);
    litColor *= sssColorEffect;
#endif
#if EF_SKIN_SPECULAR_ENABLED
    float specularStrength = EF_SKIN_SPECULAR_STRENGTH;
#if EF_SKIN_CONTROLLER_ENABLED
    specularStrength = EfSkinControllerSpecularStrength(specularStrength);
#endif
    float noL = dot(N, L);
    float lightSideMask = smoothstep(
        0.0,
        max(EF_SKIN_SPECULAR_LIGHT_END, 1e-4),
        noL);
    float specularVisibility = lightSideMask * diffuseWeight;
    float3 skinSpecular = EfSkinDirectGGX(
        N,
        L,
        viewDirWS,
        saturate(EF_SKIN_SPECULAR_ROUGHNESS),
        saturate(EF_SKIN_SPECULAR_REFLECTIVITY));
    litColor += skinSpecular
        * max(EF_SKIN_SPECULAR_COLOR, 0.0)
        * max(EfSkinMmdLightColor, 0.0)
        * max(specularStrength, 0.0)
        * specularVisibility;
#endif
#if EF_SKIN_RIM_ENABLED
    float rimArea = EF_SKIN_RIM_AREA;
    float rimStrength = EF_SKIN_RIM_STRENGTH;
    float3 edgeColor = EfSkinSrgbToLinear(
        saturate(EfSkinMaterialEdgeColor.rgb));
    float3 rimColor = edgeColor;
    float rimContrast = 1.0;
#if EF_SKIN_CONTROLLER_ENABLED
    rimArea = EfSkinControllerRimArea(rimArea);
    rimStrength = EfSkinControllerRimStrength(rimStrength);
    rimColor = EfSkinControllerRimColor(edgeColor, EF_SKIN_RIM_COLOR);
    rimContrast = EfSkinControllerRimContrast();
#endif
    float3 rimLinear = EfFresnelRimContrast(
        noV,
        litColor,
        1.0,
        saturate(rimArea),
        max(rimColor, 0.0),
        max(rimStrength, 0.0),
        saturate(EF_SKIN_RIM_DIFFUSE_EFFECT),
        rimContrast);
    litColor += rimLinear * max(EfSkinMmdLightColor, 0.0);
#endif
    litColor = EfApplyGlobalMaterialGrade(litColor, diffuseWeight);
    return float4(max(EfSkinLinearToSrgb(litColor), 0.0), 1.0);
}

#if EF_SKIN_SCREEN_RIM_ENABLED
struct EfSkinScreenRimVaryings {
    float4 positionCS : POSITION;
    float3 positionWS : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float4 screenPosition : TEXCOORD2;
};

EfSkinScreenRimVaryings EfSkinScreenRimVS(EfSkinAttributes input)
{
    EfSkinScreenRimVaryings output = (EfSkinScreenRimVaryings)0;
    output.positionCS = mul(input.positionOS, EfSkinWorldViewProjection);
    output.positionWS = mul(input.positionOS, EfSkinWorld).xyz;
    output.normalWS = normalize(mul(input.normalOS, (float3x3)EfSkinWorld));
    output.screenPosition = output.positionCS;
    return output;
}

float2 EfSkinViewportUvFromClip(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / clipPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    return uv + 0.5 / max(EfSkinViewportSize, 1.0);
}

float EfSkinScreenDepthRim(
    float3 positionWS,
    float3 geometryNormalWS,
    float4 screenPosition,
    float widthMultiplier)
{
    if (!EfSkinZmdShadowValid || abs(screenPosition.w) < 1e-6) {
        return 0.0;
    }

    float3 positionVS = mul(float4(positionWS, 1.0), EfSkinView).xyz;
    float3 normalVS = normalize(
        mul(geometryNormalWS, (float3x3)EfSkinView) + 1e-6);
    float3 rimOffsetVS = float3(
        normalVS.x * EF_SKIN_SCREEN_RIM_WIDTH_X
            * EF_SKIN_SCREEN_RIM_VIEW_SCALE
            * EF_SKIN_SCREEN_RIM_MODEL_SCALE
            * widthMultiplier,
        normalVS.y * EF_SKIN_SCREEN_RIM_WIDTH_Y
            * EF_SKIN_SCREEN_RIM_VIEW_SCALE
            * EF_SKIN_SCREEN_RIM_MODEL_SCALE
            * widthMultiplier,
        0.0);
    float4 offsetClip = mul(
        float4(positionVS + rimOffsetVS, 1.0),
        EfSkinProjection);
    if (abs(offsetClip.w) < 1e-6) {
        return 0.0;
    }

    float centerDepth = tex2D(
        EfSkinZmdShadowSampler,
        EfSkinViewportUvFromClip(screenPosition)).g;
    float offsetDepth = tex2D(
        EfSkinZmdShadowSampler,
        EfSkinViewportUvFromClip(offsetClip)).g;
    return clamp(
        (offsetDepth - centerDepth) * EF_SKIN_SCREEN_RIM_DEPTH_SCALE,
        0.0,
        EF_SKIN_SCREEN_RIM_DEPTH_MAX);
}

float4 EfSkinScreenRimPS(
    EfSkinScreenRimVaryings input,
    float facing : VFACE) : COLOR0
{
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometryNormalWS = normalize(input.normalWS);
    float3 normalWS = geometryNormalWS * faceSign;
    float widthMultiplier = 1.0;
    float rimStrength = EF_SKIN_SCREEN_RIM_STRENGTH;
    float3 edgeColor = EfSkinSrgbToLinear(
        saturate(EfSkinMaterialEdgeColor.rgb));
    float3 rimColor = edgeColor;
    float rimContrast = 1.0;
#if EF_SKIN_CONTROLLER_ENABLED
    widthMultiplier = EfSkinControllerScreenRimWidth(widthMultiplier);
    rimStrength = EfSkinControllerScreenRimStrength(rimStrength);
    rimColor = EfSkinControllerRimColor(
        edgeColor, EF_SKIN_SCREEN_RIM_COLOR);
    rimContrast = EfSkinControllerRimContrast();
#endif

    float depthRim = EfSkinScreenDepthRim(
        input.positionWS,
        geometryNormalWS,
        input.screenPosition,
        widthMultiplier);
    float3 viewVectorWS = EfSkinCameraPosition - input.positionWS;
    float viewLengthSq = dot(viewVectorWS, viewVectorWS);
    float3 viewDirWS = viewLengthSq > 1e-8
        ? viewVectorWS * rsqrt(viewLengthSq)
        : normalWS;
    float noV = saturate(dot(normalWS, viewDirWS));
    float fresnel = pow(
        saturate(1.0 - noV),
        max(EF_SKIN_SCREEN_RIM_FRESNEL_POWER, 1e-4));
    float3 lightWS = EfMmdSurfaceToLightWS(
        EfSkinMmdLightDirection,
        normalWS);
    float noL = dot(normalWS, lightWS);
    // Strict art-direction rule: the dark-facing hemisphere receives no rim.
    float lightMask = smoothstep(
        EF_SKIN_SCREEN_RIM_LIGHT_START,
        max(EF_SKIN_SCREEN_RIM_LIGHT_END,
            EF_SKIN_SCREEN_RIM_LIGHT_START + 1e-4),
        noL);
    float rimMask = EfRimApplyContrast(
        saturate(depthRim * fresnel * lightMask),
        rimContrast);
    return float4(
        max(rimColor, 0.0) * max(rimStrength, 0.0)
            * rimMask * EfGlobalBrightnessMul(),
        0.0);
}

#define EF_SKIN_SCREEN_RIM_PASS \
    pass DrawSkinScreenRim { \
        ZEnable = true; \
        ZWriteEnable = false; \
        ZFunc = LESSEQUAL; \
        CullMode = EF_SKIN_CULL_MODE; \
        AlphaTestEnable = false; \
        AlphaBlendEnable = true; \
        SrcBlend = ONE; \
        DestBlend = ONE; \
        BlendOp = ADD; \
        VertexShader = compile vs_3_0 EfSkinScreenRimVS(); \
        PixelShader = compile ps_3_0 EfSkinScreenRimPS(); \
    }
#define EF_SKIN_OBJECT_SCRIPT \
    "RenderColorTarget0=;Pass=DrawObject;Pass=DrawSkinScreenRim;"
#else
#define EF_SKIN_SCREEN_RIM_PASS
#define EF_SKIN_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;"
#endif

#if EF_SKIN_OUTLINE_ENABLED
struct EfSkinOutlineVaryings {
    float4 positionCS : POSITION;
    float3 normalWS : TEXCOORD0;
};

EfSkinOutlineVaryings EfSkinOutlineVS(EfSkinAttributes input)
{
    EfSkinOutlineVaryings output = (EfSkinOutlineVaryings)0;
    float4 positionCS = mul(input.positionOS, EfSkinWorldViewProjection);
    float3 normalWS = normalize(mul(input.normalOS, (float3x3)EfSkinWorld));

    output.positionCS = positionCS;
    output.normalWS = normalWS;
    return output;
}

float4 EfSkinOutlinePS(EfSkinOutlineVaryings input) : COLOR0
{
    float4 edgeColor = saturate(EfSkinMaterialEdgeColor);
    clip(edgeColor.a - 1e-4);
    return edgeColor;
}

#define EF_SKIN_OUTLINE_OBJECT_PASS
#endif
#ifndef EF_SKIN_OUTLINE_OBJECT_PASS
#define EF_SKIN_OUTLINE_OBJECT_PASS
#endif
#define EF_SKIN_OUTLINE_EDGE_TECHNIQUE

#define EF_SKIN_PASS_STATES \
    AlphaTestEnable = false; \
    AlphaBlendEnable = false; \
    ZEnable = true; \
    ZWriteEnable = true; \
    ZFunc = LESSEQUAL;

#define EF_SKIN_TECHNIQUE(name, passName, useTextureValue) \
    technique name < \
        string MMDPass = passName; \
        string Script = EF_SKIN_OBJECT_SCRIPT; \
        bool UseTexture = useTextureValue; \
        bool UseSphereMap = false; \
        bool UseSelfShadow = EF_SKIN_USE_SELF_SHADOW; \
    > { \
        pass DrawObject { \
            EF_SKIN_PASS_STATES \
            CullMode = EF_SKIN_CULL_MODE; \
            VertexShader = compile vs_3_0 EfSkinVS(); \
            PixelShader = compile ps_3_0 EfSkinPS(useTextureValue); \
        } \
        EF_SKIN_OUTLINE_OBJECT_PASS \
        EF_SKIN_SCREEN_RIM_PASS \
    }

EF_SKIN_TECHNIQUE(EfSkinObjectNoTexture, "object", false)
EF_SKIN_TECHNIQUE(EfSkinObjectTexture, "object", true)
EF_SKIN_TECHNIQUE(EfSkinObjectShadowNoTexture, "object_ss", false)
EF_SKIN_TECHNIQUE(EfSkinObjectShadowTexture, "object_ss", true)
EF_SKIN_OUTLINE_EDGE_TECHNIQUE

#endif
