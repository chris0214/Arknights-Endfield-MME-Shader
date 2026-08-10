#ifndef ENDFIELD_EYE_HIGHLIGHT_INCLUDED
#define ENDFIELD_EYE_HIGHLIGHT_INCLUDED

#include "internal/endfield_eye_controls.inc"
#include "internal/endfield_global_controls.inc"

// The authored Eye HL geometry samples the lower-left highlight island from
// the iris D texture. It is a separate emissive alpha layer, not the dynamic
// cornea MatCap used by the main iris material.
#ifndef EF_EYE_HL_TEXTURE_RESOURCE
#define EF_EYE_HL_TEXTURE_RESOURCE \
    "textures/chen/T_actor_chen_iris_01_D.png"
#endif
#ifndef EF_EYE_HL_COLOR_GAIN
#define EF_EYE_HL_COLOR_GAIN 1.05
#endif
#ifndef EF_EYE_HL_SATURATION
#define EF_EYE_HL_SATURATION 0.92
#endif
#ifndef EF_EYE_HL_EMISSION
// Goo's independent alpha layer uses an emission strength of 1.4.
#define EF_EYE_HL_EMISSION 1.4
#endif
#ifndef EF_EYE_HL_ALPHA_OFFSET
// Matches Chen Qianyu's primary Goo Eye Alpha material.
#define EF_EYE_HL_ALPHA_OFFSET 0.70
#endif
#ifndef EF_EYE_HL_EYES_MASK
// Goo multiplies the view fade by (1 - Eyes vertex attribute). The PMX has no
// equivalent custom attribute, so the authored Eye HL mesh itself supplies
// the eye-domain mask and the neutral fallback is one.
#define EF_EYE_HL_EYES_MASK 1.0
#endif
#ifndef EF_EYE_HL_FACING_MIN
#define EF_EYE_HL_FACING_MIN -0.50
#endif
#ifndef EF_EYE_HL_FACING_MAX
#define EF_EYE_HL_FACING_MAX 1.00
#endif
#ifndef EF_EYE_HL_ALPHA_SCALE
#define EF_EYE_HL_ALPHA_SCALE 1.0
#endif
#ifndef EF_EYE_HL_ALPHA_CUTOFF
#define EF_EYE_HL_ALPHA_CUTOFF 0.001
#endif
#ifndef EF_EYE_HL_DEPTH_BIAS
// Keep the authored overlay consistently in front of the adjacent iris and
// sclera meshes. The PMX highlight crosses their boundary and otherwise risks
// a material-order seam when the later sclera pass writes the same depth.
#define EF_EYE_HL_DEPTH_BIAS 0.0005
#endif

float4x4 EfEyeHlWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 EfEyeHlWorld : WORLD;
float3 EfEyeHlCameraPosition : POSITION < string Object = "Camera"; >;
float4 EfEyeHlMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;

texture2D EfEyeHlTexture <
    string ResourceName = EF_EYE_HL_TEXTURE_RESOURCE;
>;
sampler2D EfEyeHlSampler = sampler_state {
    texture = <EfEyeHlTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

struct EfEyeHlAttributes {
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct EfEyeHlVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float facing : TEXCOORD1;
};

float3 EfEyeHlHeadFront()
{
    float3 forwardAxis = EfEyeHlHeadBone._31_32_33;
    float lengthSq = dot(forwardAxis, forwardAxis);
    return (lengthSq > 1e-8)
        ? -forwardAxis * rsqrt(lengthSq)
        : float3(0.0, 0.0, -1.0);
}

EfEyeHlVaryings EfEyeHlVS(EfEyeHlAttributes input)
{
    EfEyeHlVaryings output = (EfEyeHlVaryings)0;
    float3 positionWS = mul(input.positionOS, EfEyeHlWorld).xyz;
    output.positionCS = mul(input.positionOS,
        EfEyeHlWorldViewProjection);
    output.uv = input.uv;

    float3 toCamera = EfEyeHlCameraPosition - positionWS;
    float toCameraLengthSq = dot(toCamera, toCamera);
    float3 viewDirection = (toCameraLengthSq > 1e-8)
        ? toCamera * rsqrt(toCameraLengthSq)
        : EfEyeHlHeadFront();
    output.facing = dot(EfEyeHlHeadFront(), viewDirection);
    // Eye HL is an authored emissive decal. Keep its layer ordering stable at
    // every view angle; visibility must not be used to hide geometry issues.
    output.positionCS.z -= EF_EYE_HL_DEPTH_BIAS * output.positionCS.w;
    return output;
}

float EfEyeHlDepthBiasVisibility(float facing)
{
    return 1.0;
}

float EfEyeHlCoverageValue(float facing, float materialAlpha)
{
    // Fixed emissive coverage: camera rotation must not dim or remove Eye HL.
    // Keep the legacy facing parameters declared for preset compatibility,
    // but do not apply them to this authored geometry layer.
    float alpha = 1.0;
    return saturate(
        alpha * EF_EYE_HL_ALPHA_SCALE
        * materialAlpha
        * saturate(EF_EYE_HL_EYES_MASK)
        * EfEyeControllerHighlightVisibility());
}

float EfEyeHlCoverage(float facing)
{
    return EfEyeHlCoverageValue(
        facing, EfEyeHlMaterialDiffuse.a);
}

float3 EfEyeHlColor(float3 textureColor)
{
    float luminance = dot(textureColor,
        float3(0.2126, 0.7152, 0.0722));
    float3 color = lerp(
        luminance.xxx,
        textureColor,
        max(EF_EYE_HL_SATURATION, 0.0));
    color *= max(EF_EYE_HL_COLOR_GAIN, 0.0)
        * EfEyeControllerHighlight(EF_EYE_HL_EMISSION);
    return saturate(color);
}

float4 EfEyeHlPS(EfEyeHlVaryings input) : COLOR0
{
    float3 textureColor = tex2D(EfEyeHlSampler, input.uv).rgb;
    float alpha = EfEyeHlCoverage(input.facing);
    clip(alpha - EF_EYE_HL_ALPHA_CUTOFF);
    float3 highlightColor = EfApplyGlobalColorGrade(
        EfEyeHlColor(textureColor));
    return float4(highlightColor, alpha);
}

#ifndef EF_EYE_HL_NO_TECHNIQUES
#define EF_EYE_HL_TECHNIQUE(name, passName) \
    technique name < \
        string MMDPass = passName; \
        bool UseTexture = true; \
        bool UseSphereMap = false; \
        bool UseSelfShadow = false; \
    > { \
        pass DrawObject { \
            ZEnable = true; \
            /* Eye HL is material 2 and sclera is material 3. The authored */ \
            /* highlight geometry must write depth so the later sclera pass */ \
            /* cannot erase the part of the highlight crossing the eye white. */ \
            ZWriteEnable = true; \
            ZFunc = LESSEQUAL; \
            CullMode = NONE; \
            AlphaTestEnable = false; \
            AlphaBlendEnable = true; \
            SrcBlend = SRCALPHA; \
            DestBlend = INVSRCALPHA; \
            BlendOp = ADD; \
            VertexShader = compile vs_3_0 EfEyeHlVS(); \
            PixelShader = compile ps_3_0 EfEyeHlPS(); \
        } \
    }

EF_EYE_HL_TECHNIQUE(EfEyeHlObject, "object")
EF_EYE_HL_TECHNIQUE(EfEyeHlObjectSs, "object_ss")
#endif

#endif
