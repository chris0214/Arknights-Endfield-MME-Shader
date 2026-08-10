////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgShadow.fx 高品位(かもしれない)影生成エフェクト
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

// HgShadowのパラメータを取り込む
#include "HgShadow_Header.fxh"

#ifndef MIKUMIKUMOVING

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsRy : CONTROLOBJECT < string name = "(self)"; string item = "Ry"; >;
static float Scale = AcsSi * 0.1f;
static float OcclLenParam = AcsTr;

#else
// MMM入力パラメータの受け渡し用

#if (ShadowMapType == CLSPSM)
shared float HgShadow_MMM_ShadowViewNear <
    string UIName = "Near値";
    string UIHelp = "シャドウマップを参照できるカメラ視錐台の最近値";
    string UIWidget = "Numeric";
    bool UIVisible =  true;
    float UIMin = 1.0;
    float UIMax = 7000.0;
> = ShadowViewNear;
#endif

shared float HgShadow_MMM_ShadowViewFar <
    #if (ShadowMapType == CLSPSM)
    string UIName = "Far値";
    string UIHelp = "シャドウマップを参照できるカメラ視錐台の最遠値";
    #else
    string UIName = "マップ範囲";
    string UIHelp = "シャドウマップを参照できる範囲";
    #endif
    string UIWidget = "Numeric";
    bool UIVisible =  true;
    float UIMin = 10.0;
    float UIMax = 9999.0;
> = ShadowViewFar;

shared float HgShadow_MMM_CascadedParam <
    string UIName = "CascadParam";
    string UIHelp = "CLSPSMのシャドウマップ分割調整パラメータ";
    string UIWidget = "Slider";
    bool UIVisible =  true;
    float UIMin = -1.0;
    float UIMax = 1.0;
> = float( 0.0 );

#if (ShadowMapType == CLSPSM)
shared float HgShadow_MMM_PerspectiveParam <
    string UIName = "PersParam";
    string UIHelp = "CLSPSMのシャドウマップパース調整パラメータ";
    string UIWidget = "Slider";
    bool UIVisible =  true;
    float UIMin = -20.0;
    float UIMax = 20.0;
> = float( 0.0 );
#endif

shared float HgShadow_MMM_BlurPower <
    string UIName = "影ぼかし";
    string UIHelp = "ソ\フトシャドウのぼかし度";
    string UIWidget = "Slider";
    bool UIVisible =  true;
    float UIMin = 0.0;
    float UIMax = 5.0;
> = float( 1.0 );

shared float HgShadow_MMM_Density <
    string UIName = "影濃度";
    string UIWidget = "Slider";
    bool UIVisible =  true;
    float UIMin = 0.0;
    float UIMax = 5.0;
> = float( 1.0 );

float MMM_OcclLengthParam <
    string UIName = "遮蔽距離調整";
    string UIHelp = "遮蔽距離によってぼかしの強さを変える度合いをここで調整します";
    string UIWidget = "Slider";
    bool UIVisible =  true;
    float UIMin = 0.0;
    float UIMax = 1.0;
> = float( 1.0 );

shared float HgShadow_MMM_NearDistParam <
    string UIName = "近傍影調整";
    string UIHelp = "遮蔽距離が極端に短い影のちらつきを抑えるための調整値\n大きくしすぎると近傍影が消えてしまいます";
    string UIWidget = "Slider";
    bool UIVisible =  true;
    #if (ShadowMapType == CLSPSM)
    float UIMin = -1.0;
    #else
    float UIMin = 0.0;
    #endif
    float UIMax = 1.0;
> = float( 0.0 );

static float Scale = HgShadow_MMM_BlurPower;
static float OcclLenParam = MMM_OcclLengthParam;

#endif


////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// シャドウマップバッファサイズ
#define SMAPSIZE_WIDTH   ShadowMapSize
#define SMAPSIZE_HEIGHT  ShadowMapSize

#define TEX_FORMAT_SMAP  "D3DFMT_R32F"
#define TEX_MIPLEVELS  1

#if BufferFmtQuality == 1
    #define TEX_FORMAT_VMAP  "D3DFMT_A32B32G32R32F"
    #define TEX_FORMAT_WMAP  "D3DFMT_G32R32F"
#else
    #define TEX_FORMAT_VMAP  "D3DFMT_A16B16G16R16F"
    #define TEX_FORMAT_WMAP  "D3DFMT_G16R16F"
#endif

#if BufferAntiAlias == 1
    #define TEX_AASET  true
#else
    #define TEX_AASET  false
#endif



#ifndef MIKUMIKUMOVING
// オフスクリーン影生成用画面データマップ作成バッファ(MME用)
texture ZMDshadow_VMap : OFFSCREENRENDERTARGET <
    string Description = "HgShadow.fxの影生成マップバッファ";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT_VMAP;
    bool AntiAlias = TEX_AASET;
    int Miplevels = TEX_MIPLEVELS;
    string DefaultEffect = 
        "self = hide;"
        "* = ZMDshadow_ViewportMap.fxsub;"
        ;
>;
#endif

// オフスクリーンシャドウマップバッファ
shared texture ZMDshadow_SMap : OFFSCREENRENDERTARGET <
    string Description = "HgShadow.fxのシャドウマップバッファ";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT_SMAP;
    bool AntiAlias = false;
    int Miplevels = TEX_MIPLEVELS;
    string DefaultEffect = 
        "self = hide;"
        "* = ZMDshadow_ShadowMap.fxsub;"
        ;
>;

#ifdef MIKUMIKUMOVING
// オフスクリーン影生成用画面データマップ作成バッファ(MMM用)
texture ZMDshadow_VMap : OFFSCREENRENDERTARGET <
    string Description = "HgShadow.fxの画面マップバッファ";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT_VMAP;
    bool AntiAlias = TEX_AASET;
    int Miplevels = TEX_MIPLEVELS;
    string DefaultEffect = 
        "self = hide;"
        "* = ZMDshadow_ViewportMap.fxsub;"
        ;
>;
#endif

sampler ViewportMapSamp = sampler_state {
    texture = <ZMDshadow_VMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// レンダリングターゲットのクリア値
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0f;

// シャドウ描画編集用のレンダーターゲット
texture2D ZMDshadow_ViewportMap1 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT_WMAP;
>;
sampler2D WorkMapSamp1 = sampler_state {
    texture = <ZMDshadow_ViewportMap1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// シャドウ描画編集用のレンダーターゲット2
shared texture2D ZMDshadow_ViewportMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT_WMAP;
>;
sampler2D WorkMapSamp2 = sampler_state {
    texture = <ZMDshadow_ViewportMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// シャドウ描画に用いる深度ステンシルバッファ
texture2D ZMDshadow_DepthStencilBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D3DFMT_D24S8";
>;


// JitteredSampling用乱数テクスチャ
texture RandomTex <
    string ResourceName = "JitteredSamp.png";
    int MipLevels = 1;
>;
sampler RandomSmp = sampler_state {
    texture = <RandomTex>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV  = WRAP;
};


#ifndef MIKUMIKUMOVING
#if WithVolumeShadow==1

// シャドウボリューム制御パラメータ
bool VolumeShadow_Valid  : CONTROLOBJECT < string name = "VolumeShadow.x"; >;
float VolumeShadow_Levels  : CONTROLOBJECT < string name = "VolumeShadow.x"; string item = "Tr"; >;

// シャドウボリュームの描画結果を記録するためのレンダーターゲット
shared texture2D VolumeShadow_VolumeMap : RENDERCOLORTARGET;
sampler2D VolumeShadow_VolumeMapSamp = sampler_state {
    texture = <VolumeShadow_VolumeMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

#endif
#endif

#ifdef MIKUMIKUMOVING
// オリジナルの描画結果を記録するためのレンダーターゲット
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_A8R8G8B8";
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// ピクセルシェーダ
float4 PS_ScrDraw( float2 Tex: TEXCOORD0 ) : COLOR
{
    return tex2D( ScnSamp, Tex );
}
#endif


// スクリーンサイズ・サンプリング幅
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5,0.5) / ViewportSize;
static float2 SampStep = float2(1,1) / ViewportSize;
static float2 BlurSampStep = float2(1.0f/720.0f, ViewportSize.x/ViewportSize.y/720.0f);

static float2 SampStep2[9] = { float2(0.0f, 0.0f),
                               float2(-SampStep.x, 0.0f)*1.5f,
                               float2( SampStep.x, 0.0f)*1.5f,
                               float2( 0.0f,-SampStep.y)*1.5f,
                               float2( 0.0f, SampStep.y)*1.5f,
                               float2(-SampStep.x,-SampStep.y)*1.5f,
                               float2( SampStep.x, SampStep.y)*1.5f,
                               float2(-SampStep.x, SampStep.y)*1.5f,
                               float2( SampStep.x,-SampStep.y)*1.5f };


////////////////////////////////////////////////////////////////////////////////////////////////
// 共通の頂点シェーダ

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Common(float4 Pos : POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// 作業用のビューポートマップを作成

float4 PS_ShadowDraw( float2 Tex: TEXCOORD0 ) : COLOR
{
    // 遮蔽率・遮蔽距離
    float4 viewportData = tex2D( ViewportMapSamp, Tex );
    float2 data = viewportData.xy;

    // ボリュームシャドウを供用する場合は追加
    #ifndef MIKUMIKUMOVING
    #if WithVolumeShadow==1
    if(VolumeShadow_Valid){
        float comp = tex2Dlod( VolumeShadow_VolumeMapSamp, float4(Tex, 0, 1.0f-VolumeShadow_Levels) ).r;
        if( comp > data.x ){
            data = float2( comp, data.y+3.0f );
        }
    }
    #endif
    #endif

    #if SoftShadowQuality == 0
    float zmdSceneDepth = viewportData.z > 0.0f ? viewportData.z : 65504.0f;
    return float4(data.x, zmdSceneDepth, 0, 1);
    #else
    return float4(data, 0, 1);
    #endif
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ぼかしに使うパラメータ

float4x4 ProjMatrix : PROJECTION;
float DepthThreshold  = 0.5;    // 深度の閾値
float NormalThreshold = 0.1;    // 法線の閾値

// ぼかしサンプリング範囲の境界判定
bool IsSameArea(float2 edge0, float2 edge1)
{
    float edgeDepthThreshold = min(DepthThreshold + 0.05f * max(edge0.x-40.0f, 0.0f), 50.0f);
    return (abs(edge0.x - edge1.x) < edgeDepthThreshold && abs(edge0.y - edge1.y) < NormalThreshold);
}


#if SoftShadowQuality > 1

// ぼかし強度の基準値
static float OcclBlurPower = InitBlurPower * Scale;
static float DistBlurPower = OcclBlurPower * ViewportMapSampCount * 0.3f;

// 半径1円内のランダム座標を得る(Jittered Sampling)
float2 CalcRandomCoord(int index, int rCount, float seed)
{
    float4 rand = tex2D( RandomSmp, float2((index-0.5f)/64.0f, seed) );
    float x = ((rand.x * 256.0f + rand.y) * 255.0f) / 2048.0f - 16.0f;
    float y = ((rand.z * 256.0f + rand.w) * 255.0f) / 2048.0f - 16.0f;
    return (float2(x, y) / float(rCount));
}

////////////////////////////////////////////////////////////////////////////////////////////////
// 遮蔽距離のぼかし

#if SoftShadowQuality == 3
float4 PS_BlurDistance( float2 Tex: TEXCOORD0, uniform sampler2D Samp, uniform float stepLength ) : COLOR
{
    float4 Color0 = tex2D( Samp, Tex );

    // data.x:深度, data.y:ライトと法線のなす角
    float2 data = tex2D( ViewportMapSamp, Tex ).zw;

    // 近傍フィルタリングで周辺を平均化する
    float dist = Color0.y + Color0.y;
    float weight = 2.0f;
    int rCount = ceil(float(ViewportMapSampCount-1)/4.0f);
    float seed = 1234.5f*Tex.x + 1357.9f*Tex.y;
    #if ViewportMapSampCount < 17
    [unroll]
    #endif
    for(int i=1; i<ViewportMapSampCount; i++){
        // サンプリング位置
        float2 texCoord = Tex + BlurSampStep * CalcRandomCoord(i, rCount, seed) * stepLength * DistBlurPower;
        // 深度と角度差から境界を判定
        float2 edge0 = data;
        float2 edge1 = tex2D( ViewportMapSamp, texCoord ).zw;
        // 境界の外側はサンプリングしない
        if( IsSameArea(edge0, edge1)){
            float dist1 = tex2D( Samp, texCoord ).y;
            //if(Color0.y <= dist1){
                dist += dist1;
                weight += 1.0f;
            //}
        }
    }
    dist /= weight;  // 平均化

    return float4(Color0.x, dist, 0, 1);
}
#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// 影のぼかし

float4 PS_BlurShadow( float2 Tex: TEXCOORD0, uniform sampler2D Samp, uniform float stepLength ) : COLOR
{
    float4 Color0 = tex2D( Samp, Tex );

    // data.x:深度, data.y:ライトと法線のなす角
    float2 data = tex2D( ViewportMapSamp, Tex ).zw;
    // ぼかしの強さ(遮蔽距離,深度,ライト法線角度,視野角を考慮に入れてぼかす強さを決定する)
    float OcclLen = min(lerp(3.0f, Color0.y+1.0f, OcclLenParam), Color0.y+1.0f);
    float BlurPower = OcclBlurPower * max(ProjMatrix._22 * OcclLen / (pow(data.x+1.0f, 0.75f) * (abs(data.y)+0.2f)), 1.0f);

    // 近傍フィルタリングで周辺を平均化する
    float comp = Color0.x + Color0.x;
    float weight = 2.0f;
    int rCount = ceil(float(ViewportMapSampCount-1)/4.0f);
    float seed = 1234.5f*Tex.x + 1357.9f*Tex.y;
    #if ViewportMapSampCount < 17
    [unroll]
    #endif
    for(int i=1; i<ViewportMapSampCount; i++){
        // サンプリング位置
        float2 texCoord = Tex + BlurSampStep * CalcRandomCoord(i, rCount, seed) * stepLength * BlurPower;
        if( !any( saturate(texCoord) - texCoord ) ) {
            // 深度と角度差から境界を判定
            float2 edge0 = data;
            float2 edge1 = tex2D( ViewportMapSamp, texCoord ).zw;
            // 境界の外側はサンプリングしない
            if( IsSameArea(edge0, edge1)){
                comp += tex2D( Samp, texCoord ).x;
                weight += 1.0f;
            }
        }
    }
    comp /= weight;  // 平均化

    return float4(comp, Color0.y, 0, 1);
}
#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// 最後に9点サンプリングでぼかしのざらつきを整える

#if SoftShadowQuality > 0

#if SoftShadowQuality > 1
    #define  BLUR_OCCRATE  (Color0.y+1.0f)
    #define  BLUR_DEPRATE  pow(data.x+1.0f, 0.7f)
    #define  BLUR_RATE  1.0
#else
    #define  BLUR_OCCRATE  2.0f
    #define  BLUR_DEPRATE  (data.x+1.0f)
    #define  BLUR_RATE  (Scale * 2.0f)
#endif

float4 PS_BlurShadow2( float2 Tex: TEXCOORD0, uniform sampler2D Samp ) : COLOR
{
    float4 Color0 = tex2D( Samp, Tex );

    // data.x:深度, data.y:ライトと法線のなす角
    float2 data = tex2D( ViewportMapSamp, Tex ).zw;
    // ぼかしの強さ(遮蔽距離,深度,ライト法線角度,視野角を考慮に入れてぼかす強さを決定する)
    float BlurPower = clamp(ProjMatrix._22 * BLUR_OCCRATE / (BLUR_DEPRATE * (abs(data.y)+0.2f)), 0.5f, 1.5f) * min(Scale, 1.0f);

    // 9点サンプリング
    float comp = Color0.x;
    float weight = 1.0f;
    [unroll]
    for(int i=1; i<9; i++){
        // 深度と角度差から境界を判定
        float2 edge0 = data;
        float2 edge1 = tex2D( ViewportMapSamp, Tex+SampStep2[i]*BlurPower*BLUR_RATE ).zw;
        // 境界の外側はサンプリングしない
        if( IsSameArea(edge0, edge1)){
            comp += tex2D( Samp, Tex+SampStep2[i]*BlurPower*BLUR_RATE ).x;
            weight += 1.0f;
        }
    }
    comp /= weight;  // 平均化

    // R remains HgShadow visibility; G exports linear camera depth for DepthRim.
    float zmdSceneDepth = data.x > 0.0f ? data.x : 65504.0f;
    return float4(comp, zmdSceneDepth, 0, 1);
}

#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// テスト表示

//#define TestView

#ifdef TestView
float4 PS_TestView( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 Color = tex2D( WorkMapSamp2, Tex );
    //float4 Color = tex2D( ViewportMapSamp, Tex );
    Color.x = 1.0f - Color.x;
    return float4(Color.x,Color.x,Color.x,1);
}
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// テクニック

technique MainTech < string MMDPass = "object";
    string Script = 
        #if SoftShadowQuality > 0
        "RenderColorTarget0=ZMDshadow_ViewportMap1;"
        #else
        "RenderColorTarget0=ZMDshadow_ViewportMap2;"
        #endif
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=DrawShadow;"

        #if SoftShadowQuality > 1
        #if SoftShadowQuality == 3
        "RenderColorTarget0=ZMDshadow_ViewportMap2;"
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurDistance1;"
        "RenderColorTarget0=ZMDshadow_ViewportMap1;"
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurDistance2;"
        #endif

        "RenderColorTarget0=ZMDshadow_ViewportMap2;"
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurShadow1;"
        "RenderColorTarget0=ZMDshadow_ViewportMap1;"
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurShadow2;"
        #endif

        #if SoftShadowQuality > 0
        "RenderColorTarget0=ZMDshadow_ViewportMap2;"
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BlurShadow3;"
        #endif

        #ifndef MIKUMIKUMOVING
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "ScriptExternal=Color;"
        #else
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=ZMDshadow_DepthStencilBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=ScrDrawPass;"
        #endif

            #ifdef TestView
            "Pass=TestShadowView;"
            #endif

    ;
> {
    pass DrawShadow < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_ShadowDraw();
    }

    #if SoftShadowQuality > 1
    #if SoftShadowQuality == 3
    pass BlurDistance1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BlurDistance(WorkMapSamp1, 1.0f);
    }
    pass BlurDistance2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BlurDistance(WorkMapSamp2, 0.5f);
    }
    #endif
    pass BlurShadow1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BlurShadow(WorkMapSamp1, 1.0f);
    }

    pass BlurShadow2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BlurShadow(WorkMapSamp2, 0.2f);
    }
    #endif

    #if SoftShadowQuality > 0
    pass BlurShadow3 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BlurShadow2(WorkMapSamp1);
    }
    #endif

    #ifdef MIKUMIKUMOVING
    pass ScrDrawPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_ScrDraw();
    }
    #endif

    #ifdef TestView
    pass TestShadowView < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_TestView();
    }
    #endif
}


////////////////////////////////////////////////////////////////////////////////////////////////

// 地面影は描画しない
technique ShadowTec < string MMDPass = "shadow"; > { }
// Zプロットは描画しない
technique ZplotTec < string MMDPass = "zplot"; > { }

