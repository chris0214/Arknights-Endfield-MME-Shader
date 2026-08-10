#ifndef ENDFIELD_HIDDEN_INCLUDED
#define ENDFIELD_HIDDEN_INCLUDED

float4x4 EfHiddenWorldViewProjection : WORLDVIEWPROJECTION;

struct EfHiddenVaryings {
    float4 positionCS : POSITION;
};

EfHiddenVaryings EfHiddenVS(float4 positionOS : POSITION)
{
    EfHiddenVaryings output;
    output.positionCS = mul(positionOS, EfHiddenWorldViewProjection);
    return output;
}

float4 EfHiddenPS(EfHiddenVaryings input) : COLOR0
{
    clip(-1.0);
    return 0.0;
}

#define EF_HIDDEN_TECHNIQUE(name, passName) \
    technique name < string MMDPass = passName; > { \
        pass DrawObject { \
            ZEnable = false; \
            ZWriteEnable = false; \
            CullMode = NONE; \
            AlphaTestEnable = false; \
            AlphaBlendEnable = false; \
            VertexShader = compile vs_3_0 EfHiddenVS(); \
            PixelShader = compile ps_3_0 EfHiddenPS(); \
        } \
    }

EF_HIDDEN_TECHNIQUE(EfHiddenObject, "object")
EF_HIDDEN_TECHNIQUE(EfHiddenObjectSs, "object_ss")

technique EfHiddenEdge < string MMDPass = "edge"; > { }
technique EfHiddenShadow < string MMDPass = "shadow"; > { }
technique EfHiddenZPlot < string MMDPass = "zplot"; > { }

#endif
