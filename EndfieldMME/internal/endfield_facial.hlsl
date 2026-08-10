#ifndef ENDFIELD_FACIAL_INCLUDED
#define ENDFIELD_FACIAL_INCLUDED

// Small facial-material core for MMD/Direct3D 9. Eye/brow overlay copies use
// their own duplicated geometry as the eye-domain test, then read only the
// opaque-hair stencil bit to identify pixels covered by the real fringe.

#ifndef EF_FACIAL_MAIN_TEXTURE_RESOURCE
#define EF_FACIAL_MAIN_TEXTURE_RESOURCE \
    "textures/character/facial_base.png"
#endif
#ifndef EF_FACIAL_BASE_COLOR
#define EF_FACIAL_BASE_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_FACIAL_BASE_COLOR_POW
#define EF_FACIAL_BASE_COLOR_POW 1.0
#endif
#ifndef EF_FACIAL_COLOR_GAIN
#define EF_FACIAL_COLOR_GAIN 1.0
#endif
#ifndef EF_FACIAL_COLOR_SATURATION
#define EF_FACIAL_COLOR_SATURATION 1.0
#endif
#ifndef EF_FACIAL_COLOR_CONTRAST
#define EF_FACIAL_COLOR_CONTRAST 1.0
#endif
#ifndef EF_FACIAL_COLOR_LIFT
#define EF_FACIAL_COLOR_LIFT float3(0.0, 0.0, 0.0)
#endif
#ifndef EF_FACIAL_SOFT_EXPOSURE
#define EF_FACIAL_SOFT_EXPOSURE 1.0
#endif
#ifndef EF_FACIAL_CULL_MODE
#define EF_FACIAL_CULL_MODE NONE
#endif
#ifndef EF_FACIAL_ALPHA_CUTOFF
#define EF_FACIAL_ALPHA_CUTOFF 0.01
#endif
#ifndef EF_FACIAL_USE_TEXTURE_ALPHA
// Face D.A is AO and Iris D.A is a local emission mask; neither is coverage.
// Enable this only for assets with authored cutout coverage alpha.
#define EF_FACIAL_USE_TEXTURE_ALPHA 0
#endif
#ifndef EF_FACIAL_EYE_WHITE_ENABLED
#define EF_FACIAL_EYE_WHITE_ENABLED 0
#endif
#ifndef EF_FACIAL_IRIS_ENABLED
#define EF_FACIAL_IRIS_ENABLED 0
#endif
#ifndef EF_FACIAL_OVERLAY_ENABLED
#define EF_FACIAL_OVERLAY_ENABLED 0
#endif
#ifndef EF_FACIAL_OVERLAY_ALPHA
#define EF_FACIAL_OVERLAY_ALPHA 0.62
#endif
#ifndef EF_FACIAL_OVERLAY_COLOR_GAIN
#define EF_FACIAL_OVERLAY_COLOR_GAIN 1.0
#endif
#ifndef EF_FACIAL_OVERLAY_SIDE_FADE_END
#define EF_FACIAL_OVERLAY_SIDE_FADE_END 0.18
#endif
#ifndef EF_FACIAL_OVERLAY_SIDE_FADE_START
#define EF_FACIAL_OVERLAY_SIDE_FADE_START 0.55
#endif
#ifndef EF_FACIAL_OVERLAY_STENCIL_REF
#define EF_FACIAL_OVERLAY_STENCIL_REF 2
#endif
#ifndef EF_FACIAL_OVERLAY_STENCIL_MASK
#define EF_FACIAL_OVERLAY_STENCIL_MASK 2
#endif
#ifndef EF_FACIAL_OVERLAY_STENCIL_ENABLED
#define EF_FACIAL_OVERLAY_STENCIL_ENABLED 1
#endif
#ifndef EF_FACIAL_OVERLAY_ZFUNC
// Region intersection is handled by stencil. Do not use scene depth as a
// hair classifier: any nearer face/eye geometry would otherwise qualify.
#define EF_FACIAL_OVERLAY_ZFUNC ALWAYS
#endif
#ifndef EF_FACIAL_OVERLAY_DEPTH_FADE_ENABLED
#define EF_FACIAL_OVERLAY_DEPTH_FADE_ENABLED 0
#endif
#ifndef EF_FACIAL_OVERLAY_DEPTH_MAP
#define EF_FACIAL_OVERLAY_DEPTH_MAP ZMDshadow_ViewportMap2
#endif
#ifndef EF_FACIAL_OVERLAY_DEPTH_CONTROLLER_NAME
#define EF_FACIAL_OVERLAY_DEPTH_CONTROLLER_NAME "ZMDshadow.x"
#endif
#ifndef EF_FACIAL_OVERLAY_DEPTH_FADE_START
#define EF_FACIAL_OVERLAY_DEPTH_FADE_START 0.05
#endif
#ifndef EF_FACIAL_OVERLAY_DEPTH_FADE_END
#define EF_FACIAL_OVERLAY_DEPTH_FADE_END 3.0
#endif
#ifndef EF_FACIAL_OVERLAY_DEPTH_BIAS
#define EF_FACIAL_OVERLAY_DEPTH_BIAS 0.02
#endif
#ifndef EF_FACIAL_BASE_STENCIL_ENABLED
#define EF_FACIAL_BASE_STENCIL_ENABLED 0
#endif
#ifndef EF_FACIAL_BASE_STENCIL_REF
#define EF_FACIAL_BASE_STENCIL_REF 0
#endif
#ifndef EF_FACIAL_BASE_STENCIL_WRITE_MASK
#define EF_FACIAL_BASE_STENCIL_WRITE_MASK 0
#endif

#include "internal/endfield_global_controls.inc"

float4x4 EfFacialWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 EfFacialWorld : WORLD;
#if EF_FACIAL_IRIS_ENABLED
float4x4 EfFacialView : VIEW;
#endif
float3 EfFacialCameraPosition : POSITION < string Object = "Camera"; >;
float4 EfFacialMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
#if EF_FACIAL_EYE_WHITE_ENABLED
float3 EfFacialMmdLightDirection : DIRECTION < string Object = "Light"; >;
float3 EfFacialMmdLightColor : SPECULAR < string Object = "Light"; >;
#endif

#if EF_FACIAL_IRIS_ENABLED
#include "internal/endfield_eye.hlsl"

float3 EfFacialIrisNeutralViewDirection()
{
    float3 forwardAxis = EfFacialHeadBone._31_32_33;
    float axisLengthSq = dot(forwardAxis, forwardAxis);
    return (axisLengthSq > 1e-8)
        ? -forwardAxis * rsqrt(axisLengthSq)
        : float3(0.0, 0.0, -1.0);
}
#endif

// CP932 bytes for the standard MMD head bone name are injected by each public
// wrapper. Keeping the declaration there avoids putting non-ASCII in core code.

texture2D EfFacialMainTexture <
    string ResourceName = EF_FACIAL_MAIN_TEXTURE_RESOURCE;
>;
sampler2D EfFacialMainSampler = sampler_state {
    texture = <EfFacialMainTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

#if EF_FACIAL_OVERLAY_DEPTH_FADE_ENABLED
shared texture2D EF_FACIAL_OVERLAY_DEPTH_MAP : RENDERCOLORTARGET;
sampler2D EfFacialOverlayDepthSampler = sampler_state {
    texture = <EF_FACIAL_OVERLAY_DEPTH_MAP>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
float2 EfFacialViewportSize : VIEWPORTPIXELSIZE;
bool EfFacialOverlayDepthValid : CONTROLOBJECT <
    string name = EF_FACIAL_OVERLAY_DEPTH_CONTROLLER_NAME;
>;
#endif

struct EfFacialAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct EfFacialVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float4 screenPosition : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
};

EfFacialVaryings EfFacialVS(EfFacialAttributes input)
{
    EfFacialVaryings output = (EfFacialVaryings)0;
    output.positionCS = mul(input.positionOS,
        EfFacialWorldViewProjection);
    output.uv = input.texcoord0;
    output.positionWS = mul(input.positionOS, EfFacialWorld).xyz;
    output.screenPosition = output.positionCS;
    output.normalWS = normalize(mul(input.normalOS, (float3x3)EfFacialWorld));
    return output;
}

float3 EfFacialSrgbBase(float3 textureColor)
{
    return pow(max(textureColor * max(EF_FACIAL_BASE_COLOR, 0.0), 1e-5),
        max(EF_FACIAL_BASE_COLOR_POW, 1e-4));
}

float3 EfFacialAdjustBaseColor(float3 color)
{
    float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
    color = lerp(
        float3(luminance, luminance, luminance),
        color,
        max(EF_FACIAL_COLOR_SATURATION, 0.0));
    color = (color - 0.5) * max(EF_FACIAL_COLOR_CONTRAST, 0.0) + 0.5;
    color = color * max(EF_FACIAL_COLOR_GAIN, 0.0)
        + max(EF_FACIAL_COLOR_LIFT, 0.0);
    return saturate(color);
}

float3 EfFacialApplySoftExposure(float3 color)
{
    float exposure = max(EF_FACIAL_SOFT_EXPOSURE, 0.0);
    float3 linearColor = pow(max(color, 1e-5), 2.2);
    linearColor = linearColor * exposure /
        max(1.0 + linearColor * (exposure - 1.0), 1e-4);
    return pow(saturate(linearColor), 1.0 / 2.2);
}

#if EF_FACIAL_OVERLAY_ENABLED
float EfFacialHeadFacing(float3 positionWS)
{
    float3 forwardAxis = EfFacialHeadBone._31_32_33;
    float axisLengthSq = dot(forwardAxis, forwardAxis);
    float3 headFront = (axisLengthSq > 1e-8)
        ? -forwardAxis * rsqrt(axisLengthSq)
        : float3(0.0, 0.0, -1.0);
    float3 viewVector = EfFacialCameraPosition - positionWS;
    float viewLengthSq = dot(viewVector, viewVector);
    float3 viewDirection = (viewLengthSq > 1e-8)
        ? viewVector * rsqrt(viewLengthSq)
        : headFront;
    return saturate(dot(headFront, viewDirection));
}
#endif

#if EF_FACIAL_OVERLAY_DEPTH_FADE_ENABLED
float EfFacialOverlayDepthFade(EfFacialVaryings input)
{
    if (!EfFacialOverlayDepthValid
        || abs(input.screenPosition.w) < 1e-6) {
        return 1.0;
    }

    float2 ndc = input.screenPosition.xy / input.screenPosition.w;
    float2 screenUv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    screenUv += 0.5 / max(EfFacialViewportSize, 1.0);

    float sceneDepth = tex2D(
        EfFacialOverlayDepthSampler, screenUv).g;
    // CONTROLOBJECT only proves that ZMDshadow.x exists. Some MMD/MME draw
    // paths still expose the shared render target as black, so a zero depth
    // must fail open instead of erasing the entire eye/brow overlay. Stencil
    // remains the authoritative hair-coverage gate in that case.
    if (sceneDepth <= 1e-4) {
        return 1.0;
    }
    float featureDepth = length(
        EfFacialCameraPosition - input.positionWS);
    float depthDelta = max(
        featureDepth - sceneDepth
            - max(EF_FACIAL_OVERLAY_DEPTH_BIAS, 0.0),
        0.0);
    float fadeStart = max(EF_FACIAL_OVERLAY_DEPTH_FADE_START, 0.0);
    float fadeEnd = max(
        EF_FACIAL_OVERLAY_DEPTH_FADE_END,
        fadeStart + 1e-4);
    return 1.0 - smoothstep(fadeStart, fadeEnd, depthDelta);
}
#endif

float4 EfFacialPS(EfFacialVaryings input,
    uniform bool useTexture) : COLOR0
{
    float4 texel = float4(saturate(EfFacialMaterialDiffuse.rgb), 1.0);
    float2 sampleUv = input.uv;
    if (useTexture) {
#if EF_FACIAL_IRIS_ENABLED
        sampleUv = EfEyeIrisParallaxUv(
            input.uv,
            input.positionWS,
            input.normalWS,
            EfFacialCameraPosition,
            EfFacialIrisNeutralViewDirection());
#endif
        texel = tex2D(EfFacialMainSampler, sampleUv);
    }
    float coverage = saturate(EfFacialMaterialDiffuse.a);
#if EF_FACIAL_USE_TEXTURE_ALPHA
    coverage *= saturate(texel.a);
#endif
    clip(coverage - EF_FACIAL_ALPHA_CUTOFF);

#if EF_FACIAL_EYE_WHITE_ENABLED
    float3 color = EfEyeWhiteEvaluate(
        texel.rgb,
        EfFacialMaterialDiffuse.rgb,
        input.normalWS,
        EfFacialMmdLightDirection,
        EfFacialMmdLightColor);
#else
    float3 color = EfFacialAdjustBaseColor(EfFacialSrgbBase(texel.rgb))
        * saturate(EfFacialMaterialDiffuse.rgb);
#if EF_FACIAL_IRIS_ENABLED
    color = EfEyeIrisApplyMatcap05(
        color, input.normalWS, EfFacialView);
    color = EfEyeIrisApplyAlphaEmission(color, texel.a);
    if (useTexture) {
        color = EfEyeIrisApplyMatcap07(color, sampleUv);
    }
#endif
    color = EfFacialApplySoftExposure(color);
#if EF_FACIAL_IRIS_ENABLED
    color = EfEyeIrisApplyFinalOutput(color);
#endif
#endif
    color = EfApplyGlobalColorGrade(color);
#if EF_FACIAL_OVERLAY_ENABLED
    // Zhihu/Unity side fade, adapted to the already-opaque MMD hair path.
    // Duplicated eye/brow geometry defines the facial feature domain, while
    // Hair stencil 2 identifies real fringe pixels. The optional ZMD depth
    // gate then rejects fringe surfaces that are too far from the feature.
    float facing = EfFacialHeadFacing(input.positionWS);
    float sideFade = smoothstep(
        EF_FACIAL_OVERLAY_SIDE_FADE_END,
        max(EF_FACIAL_OVERLAY_SIDE_FADE_START,
            EF_FACIAL_OVERLAY_SIDE_FADE_END + 1e-4),
        facing);
    color *= max(EF_FACIAL_OVERLAY_COLOR_GAIN, 0.0);
    float depthFade = 1.0;
#if EF_FACIAL_OVERLAY_DEPTH_FADE_ENABLED
    depthFade = EfFacialOverlayDepthFade(input);
#endif
    float alpha = saturate(
        coverage * EF_FACIAL_OVERLAY_ALPHA * sideFade * depthFade);
    clip(alpha - 1e-4);
    return float4(saturate(color), alpha);
#else
    return float4(saturate(color), 1.0);
#endif
}

#ifndef EF_NO_TECHNIQUES
#if EF_FACIAL_OVERLAY_ENABLED
#define EF_FACIAL_PASS_STATES \
    ZEnable = true; \
    ZWriteEnable = false; \
    ZFunc = EF_FACIAL_OVERLAY_ZFUNC; \
    AlphaTestEnable = false; \
    AlphaBlendEnable = true; \
    SrcBlend = SRCALPHA; \
    DestBlend = INVSRCALPHA; \
    BlendOp = ADD; \
    StencilEnable = EF_FACIAL_OVERLAY_STENCIL_ENABLED; \
    StencilFunc = EQUAL; \
    StencilRef = EF_FACIAL_OVERLAY_STENCIL_REF; \
    StencilMask = EF_FACIAL_OVERLAY_STENCIL_MASK; \
    StencilWriteMask = 0; \
    StencilFail = KEEP; \
    StencilZFail = KEEP; \
    StencilPass = KEEP;
#else
#define EF_FACIAL_PASS_STATES \
    ZEnable = true; \
    ZWriteEnable = true; \
    ZFunc = LESSEQUAL; \
    AlphaTestEnable = false; \
    AlphaBlendEnable = false; \
    StencilEnable = EF_FACIAL_BASE_STENCIL_ENABLED; \
    StencilFunc = ALWAYS; \
    StencilRef = EF_FACIAL_BASE_STENCIL_REF; \
    StencilWriteMask = EF_FACIAL_BASE_STENCIL_WRITE_MASK; \
    StencilFail = KEEP; \
    StencilZFail = KEEP; \
    StencilPass = REPLACE;
#endif

#define EF_FACIAL_TECHNIQUE(name, passName, useTextureValue) \
    technique name < \
        string MMDPass = passName; \
        bool UseTexture = useTextureValue; \
        bool UseSphereMap = false; \
        bool UseSelfShadow = false; \
    > { \
        pass DrawObject { \
            EF_FACIAL_PASS_STATES \
            CullMode = EF_FACIAL_CULL_MODE; \
            VertexShader = compile vs_3_0 EfFacialVS(); \
            PixelShader = compile ps_3_0 \
                EfFacialPS(useTextureValue); \
        } \
    }

EF_FACIAL_TECHNIQUE(EfFacialObjectNoTexture, "object", false)
EF_FACIAL_TECHNIQUE(EfFacialObjectTexture, "object", true)
EF_FACIAL_TECHNIQUE(EfFacialObjectShadowNoTexture, "object_ss", false)
EF_FACIAL_TECHNIQUE(EfFacialObjectShadowTexture, "object_ss", true)
#endif

#ifdef EF_NO_TECHNIQUES
float4 EfFacialProbePS(EfFacialVaryings input) : COLOR0
{
    return EfFacialPS(input, true);
}
#endif

#endif
