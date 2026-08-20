// Endfield eye-through-hair compositor for MMD/MME.
// The offscreen target captures only facial features. Hair is depth-shifted
// in the capture effect, then this pass blends the result over the scene.

float EndfieldEyeThroughStrength <
    string UIName = "Eye Through Strength";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.01;
> = 0.38;

float EndfieldEyeThroughColorGain <
    string UIName = "Eye Through Color Gain";
    string UIWidget = "Slider";
    float UIMin = 0.5;
    float UIMax = 2.0;
    float UIStep = 0.01;
> = 1.05;

float4 EndfieldEyeThroughClearColor = float4(0.0, 0.0, 0.0, 0.0);
float EndfieldEyeThroughClearDepth = 1.0;

texture2D EndfieldEyeThrough_RT : OFFSCREENRENDERTARGET <
    string Description = "Endfield facial-feature capture";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0.0, 0.0, 0.0, 0.0};
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 1;
    string DefaultEffect =
        "self = hide;"
        "*controller*.pmx = hide;"
        "ZMDshadow*.x = hide;"
        "EndfieldPost*.x = hide;"
        "EndfieldEyeThrough*.x = hide;"
        "*Endfield*.pmx = EndfieldEyeThrough_Capture.fxsub;"
        "*.pmd = EndfieldEyeThrough_Mask.fxsub;"
        "*.pmx = EndfieldEyeThrough_Mask.fxsub;"
        "*.x = EndfieldEyeThrough_Mask.fxsub;"
        "* = EndfieldEyeThrough_Mask.fxsub;"
        ;
>;

// Camera-visible hair depth encoded into RGB so material effects can sample it.
// MME depth-stencil targets are not sampleable after their capture pass.
shared texture2D EndfieldHairVisibility_RT : OFFSCREENRENDERTARGET <
    string Description = "Endfield camera-visible hair depth";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {1.0, 1.0, 1.0, 0.0};
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    string DefaultEffect = "* = EndfieldHairVisibility_Capture.fxsub;";
>;

// Face-only depth. Alpha is an explicit validity bit, allowing the hair
// shadow pass to require a real face surface behind the candidate caster.
shared texture2D EndfieldFaceDepth_RT : OFFSCREENRENDERTARGET <
    string Description = "Endfield face-only packed depth";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {1.0, 1.0, 1.0, 0.0};
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    string DefaultEffect = "* = EndfieldFaceDepth_Capture.fxsub;";
>;

sampler2D EndfieldEyeThroughSampler = sampler_state {
    texture = <EndfieldEyeThrough_RT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float EndfieldEyeThroughScript : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float4 EndfieldEyeThroughMaterialDiffuse : DIFFUSE <
    string Object = "Geometry";
>;
float2 EndfieldEyeThroughViewportSize : VIEWPORTPIXELSIZE;

struct EndfieldEyeThroughQuadVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
};

EndfieldEyeThroughQuadVaryings EndfieldEyeThroughQuadVS(
    float4 positionCS : POSITION,
    float2 uv : TEXCOORD0)
{
    EndfieldEyeThroughQuadVaryings output;
    output.positionCS = positionCS;
    output.uv = uv + 0.5 / max(EndfieldEyeThroughViewportSize, 1.0);
    return output;
}

float4 EndfieldEyeThroughCompositePS(
    EndfieldEyeThroughQuadVaryings input) : COLOR0
{
    float4 feature = tex2D(EndfieldEyeThroughSampler, input.uv);
    feature.rgb = saturate(feature.rgb
        * max(EndfieldEyeThroughColorGain, 0.0));
    feature.a *= saturate(EndfieldEyeThroughStrength)
        * saturate(EndfieldEyeThroughMaterialDiffuse.a);
    return feature;
}

technique EndfieldEyeThroughComposite <
    string MMDPass = "object";
    string Script =
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=EndfieldEyeThroughClearColor;"
        "ClearSetDepth=EndfieldEyeThroughClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Composite;";
> {
    pass Composite < string Script = "Draw=Buffer;"; > {
        ZEnable = false;
        ZWriteEnable = false;
        CullMode = NONE;
        AlphaTestEnable = false;
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        BlendOp = ADD;
        VertexShader = compile vs_3_0 EndfieldEyeThroughQuadVS();
        PixelShader = compile ps_3_0 EndfieldEyeThroughCompositePS();
    }
}
