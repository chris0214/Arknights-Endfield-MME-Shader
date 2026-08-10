////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgShadow_CFSUSM.fxh : HgShadow シャドウマップ基本計算
//  分割空間固定正方シャドウマップ CFSUSM(Cascaded Fixation Space Uniform Shadow Maps)の作成
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

// シャドウマップバッファサイズ
#define SMAPSIZE_WIDTH   ShadowMapSize
#define SMAPSIZE_HEIGHT  ShadowMapSize

// シャドウマップの分割数(変更不可)
#define HgShadow_MapCount  4

// 分割境界の余白テクセル数
#define HgShadow_SCParam  4

// ライト方向(正規化済み)
float3 HgShadow_LightDirection  : DIRECTION < string Object = "Light"; >;
float3 HgShadow_CameraDirection : DIRECTION < string Object = "Camera"; >;

#include "internal/snow_camera_light.hlsl"

float3 HgShadow_GetEffectiveLightDirection()
{
    if (SnowCameraLight >= 0.5f) {
        return SnowGetCameraRelativeLightRayWS(HgShadow_CameraDirection);
    }
    return SnowCameraLightNormalizeOr(
        HgShadow_LightDirection,
        float3(0.0f, -0.70710678f, 0.70710678f)
    );
}

#ifdef HGSHADOW_TEST
    #define CTRLFILENAME  "HgShadow.x"
#else
    #define CTRLFILENAME  "(OffscreenOwner)"
#endif

// シャドウマップの中心座標
float3 HgShadow_Org : CONTROLOBJECT < string Name = CTRLFILENAME; >;
static float3 HgShadow_SMapOrg = HgShadow_Org + float3(0.0f, 12.0f, 0.0f);


#ifndef MIKUMIKUMOVING

// コントロールパラメータ(MME)
float HgShadow_FarZ  : CONTROLOBJECT < string name = CTRLFILENAME; string item = "Rz"; >;   // マップ範囲調整値
float HgShadow_CSMParam  : CONTROLOBJECT < string name = CTRLFILENAME; string item = "Ry"; >; // CSM分割式パラメータ

static float HgShadow_NearAll = ShadowViewNear;
static float HgShadow_FarAll  = max(ShadowViewFar + degrees(HgShadow_FarZ), HgShadow_NearAll+1.0f);
static float HgShadow_Lamda   = clamp(0.97f - 0.97f*degrees(HgShadow_CSMParam), 0.0f, 1.0f);
static float HgShadow_Lamda2  = 1.0f + saturate(-degrees(HgShadow_CSMParam));

#else

// コントロールパラメータ(MMM)
shared float HgShadow_MMM_ShadowViewFar;
shared float HgShadow_MMM_CascadedParam;
static float HgShadow_NearAll = ShadowViewNear;
static float HgShadow_FarAll  = HgShadow_MMM_ShadowViewFar;
static float HgShadow_Lamda   = clamp(0.97f - 0.97f*HgShadow_MMM_CascadedParam, 0.0f, 1.0f);
static float HgShadow_Lamda2  = 1.0f + saturate(-HgShadow_MMM_CascadedParam);

#endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ビュー変換行列の作成(LookPos:視点位置, LookDir:視点方向, LookUpDir:視点上向き)

float4x4 HgShadow_CreateViewMatrix(float3 LookPos, float3 LookDir, float3 LookUpDir)
{
   // z軸方向ベクトル
   float3 viewZ = LookDir;

   // x軸方向ベクトル
   float3 viewX = cross( LookUpDir, LookDir ); 

   // x軸方向ベクトルの正規化(LookDirとLookUpDirの方向が一致する場合は特異値となる)
   if( !any(viewX) ) viewX = float3(1.0f, 0.0f, 0.0f);
   viewX = normalize(viewX);

   // y軸方向ベクトル
   float3 viewY = cross( viewZ, viewX );  // 共に垂直なのでこれで正規化

   // ビュー座標変換の回転行列
   float3x3 viewRot = float3x3( viewX.x, viewY.x, viewZ.x,
                                viewX.y, viewY.y, viewZ.y,
                                viewX.z, viewY.z, viewZ.z );

   // ビュー変換行列
   return float4x4( viewRot[0],  0.0f,
                    viewRot[1],  0.0f,
                    viewRot[2],  0.0f,
                   -mul( LookPos, viewRot ), 1.0f );
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CFSUSMによるライト方向のビュー射影変換

float4 HgShadow_CFSUSM_GetLightProjPosition(float4 WPos, int mapIndex)
{
    // ライト方向のビュー変換行列
    float3 effectiveLightDirection = HgShadow_GetEffectiveLightDirection();
    float4x4 LtViewMat = HgShadow_CreateViewMatrix(HgShadow_SMapOrg, effectiveLightDirection, float3(0.0f, 1.0f, 0.0f));

    // 分割したマップの範囲(マップ中心からの距離に応じたCSM法と同じ分割)
    float nearAll = HgShadow_NearAll;
    float farAll  = HgShadow_FarAll;
    float lamda   = HgShadow_Lamda;
    float lamda2  = HgShadow_Lamda2;
    float ixf = pow(float(mapIndex+1)/float(HgShadow_MapCount), lamda2);
    float MapLen  = lamda * nearAll * pow(farAll/nearAll, ixf)
                  + (1.0f-lamda) * (nearAll + (float(mapIndex+1)/float(HgShadow_MapCount)) * (farAll-nearAll));

    // マップ分割境界のリニアを読まないようにするための縮小係数
    float2 sc = float2( (0.5f*SMAPSIZE_WIDTH - HgShadow_SCParam) / (0.5f*SMAPSIZE_WIDTH),
                        (0.5f*SMAPSIZE_HEIGHT - HgShadow_SCParam) / (0.5f*SMAPSIZE_HEIGHT) );

    // ライト方向の射影変換行列
    float4x4 LtProjMat = float4x4( sc.x/MapLen, 0,           0,       0,
                                   0,           sc.y/MapLen, 0,       0,
                                   0,           0,           0.0001f, 0,
                                   0,           0,           0.5f,    1 );

    // ライト方向の射影変換座標
    float4 PPos = mul( WPos, mul(LtViewMat, LtProjMat) );

    return PPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 複数のマップから精度の良い上位2マップのテクスチャ座標と深度を選び出す

struct HgShadow_SMapDat {
    float4 Tex1;   // 1番精度がよいZCalcTex(xy:マップ座標, z:ZPlot, w:マップ番号)
    float4 Tex2;   // 2番目に精度がよいZCalcTex(xy:マップ座標, z:ZPlot, w:マップ番号)
    float Weight;  // Tex1が占めるウエイト
};

HgShadow_SMapDat HgShadow_CFSUSM_GetTexCoord(float4 ZCalcTex0, float4 ZCalcTex1, float4 ZCalcTex2, float4 ZCalcTex3, float4 MMD_ZCalcTex)
{
    HgShadow_SMapDat Out;
    Out.Tex1 = float4(-10.0f, -10.0f, 1.0f, 999.0f);
    Out.Tex2 = float4(-10.0f, -10.0f, 1.0f, 999.0f);
    Out.Weight = 0.0f;

    // 縮小した分の補正値
    float2 sc = float2( (0.5f*SMAPSIZE_WIDTH) / (0.5f*SMAPSIZE_WIDTH - HgShadow_SCParam),
                        (0.5f*SMAPSIZE_HEIGHT) / (0.5f*SMAPSIZE_HEIGHT - HgShadow_SCParam) );

    // テクスチャ座標に変換
    ZCalcTex0.xy /= ZCalcTex0.w;
    ZCalcTex1.xy /= ZCalcTex1.w;
    ZCalcTex2.xy /= ZCalcTex2.w;
    ZCalcTex3.xy /= ZCalcTex3.w;
    MMD_ZCalcTex /= MMD_ZCalcTex.w;
    float4 TransTexCoord;
    float2 TransTexCoord0;
    float2 TransTexCoord1;
    float2 TransTexCoord2;
    float2 TransTexCoord3;
    float2 TransTexCoord4;
    TransTexCoord0.x = (1.0f + sc.x*ZCalcTex0.x)*0.5f;
    TransTexCoord0.y = (1.0f - sc.y*ZCalcTex0.y)*0.5f;
    TransTexCoord1.x = (1.0f + sc.x*ZCalcTex1.x)*0.5f;
    TransTexCoord1.y = (1.0f - sc.y*ZCalcTex1.y)*0.5f;
    TransTexCoord2.x = (1.0f + sc.x*ZCalcTex2.x)*0.5f;
    TransTexCoord2.y = (1.0f - sc.y*ZCalcTex2.y)*0.5f;
    TransTexCoord3.x = (1.0f + sc.x*ZCalcTex3.x)*0.5f;
    TransTexCoord3.y = (1.0f - sc.y*ZCalcTex3.y)*0.5f;
    TransTexCoord4.x = (1.0f + MMD_ZCalcTex.x)*0.5f;
    TransTexCoord4.y = (1.0f - MMD_ZCalcTex.y)*0.5f;

    // 遠景→近景の順にマップ内にあるか調べて書き出す(wは使われるマップ番号)
    #ifndef MIKUMIKUMOVING
    #if UseMMDShadowMap==2
    if( SnowCameraLight < 0.5f && !any( saturate(TransTexCoord4) - TransTexCoord4 ) ) {
        // CLSPSMマップ範囲外なら最遠景マップとしてMMD標準マップを使用する
        Out.Tex1 = float4( TransTexCoord4.xy,
                           MMD_ZCalcTex.z,
                           4.0f );
        Out.Weight = 1.0f;
    }
    #endif
    #endif

    if( !any( saturate(TransTexCoord3) - TransTexCoord3 ) ) {
        TransTexCoord3.x = (1.0f + ZCalcTex3.x)*0.5f;
        TransTexCoord3.y = (1.0f - ZCalcTex3.y)*0.5f;

        Out.Tex2 = Out.Tex1;
        Out.Tex1 = float4( (TransTexCoord3.x + 1.0f) * 0.5f,
                           (TransTexCoord3.y + 1.0f) * 0.5f,
                           ZCalcTex3.z,
                           3.0f );
        Out.Weight = clamp(10.0f*(1.0f - max(abs(ZCalcTex3.x), abs(ZCalcTex3.y))), 0.0f, 1.0f);
    }

    if( !any( saturate(TransTexCoord2) - TransTexCoord2 ) ) {
        TransTexCoord2.x = (1.0f + ZCalcTex2.x)*0.5f;
        TransTexCoord2.y = (1.0f - ZCalcTex2.y)*0.5f;

        Out.Tex2 = Out.Tex1;
        Out.Tex1 = float4( TransTexCoord2.x * 0.5f,
                           (TransTexCoord2.y + 1.0f) * 0.5f,
                           ZCalcTex2.z,
                           2.0f );
        Out.Weight = clamp(10.0f*(1.0f - max(abs(ZCalcTex2.x), abs(ZCalcTex2.y))), 0.0f, 1.0f);
    }

    if( !any( saturate(TransTexCoord1) - TransTexCoord1 ) ) {
        TransTexCoord1.x = (1.0f + ZCalcTex1.x)*0.5f;
        TransTexCoord1.y = (1.0f - ZCalcTex1.y)*0.5f;

        Out.Tex2 = Out.Tex1;
        Out.Tex1 = float4( (TransTexCoord1.x + 1.0f) * 0.5f,
                           TransTexCoord1.y * 0.5f,
                           ZCalcTex1.z,
                           1.0f );
        Out.Weight = clamp(10.0f*(1.0f - max(abs(ZCalcTex1.x), abs(ZCalcTex1.y))), 0.0f, 1.0f);
    }

    if( !any( saturate(TransTexCoord0) - TransTexCoord0 ) ) {
        TransTexCoord0.x = (1.0f + ZCalcTex0.x)*0.5f;
        TransTexCoord0.y = (1.0f - ZCalcTex0.y)*0.5f;

        Out.Tex2 = Out.Tex1;
        Out.Tex1 = float4( TransTexCoord0.x * 0.5f,
                           TransTexCoord0.y * 0.5f,
                           ZCalcTex0.z,
                           0.0f );
        Out.Weight = clamp(10.0f*(1.0f - max(abs(ZCalcTex0.x), abs(ZCalcTex0.y))), 0.0f, 1.0f);
    }

    #ifndef MIKUMIKUMOVING
    #if UseMMDShadowMap==1
    if( SnowCameraLight < 0.5f && !any( saturate(TransTexCoord4) - TransTexCoord4 ) ) {
        // 最近景マップとしてMMD標準マップを使用する
        Out.Tex2 = Out.Tex1;
        Out.Tex1 = float4( TransTexCoord4.xy,
                           MMD_ZCalcTex.z,
                           4.0f );
        Out.Weight = clamp(10.0f*(1.0f - max(abs(MMD_ZCalcTex.x), abs(MMD_ZCalcTex.y))), 0.0f, 1.0f);
    }
    #endif
    #endif

    if(Out.Tex2.w > 4.5f) Out.Weight = 1.0f;  // 1つのマップしか参照していない場合

    return Out;
}


