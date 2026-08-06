////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgShadow_CLSPSM.fxh : HgShadow シャドウマップ基本計算
//  分割ライト空間透視シャドウマップ CLSPSM(Cascaded Light Space Perspective Shadow Maps) の作成
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

// 座標変換行列
float4x4 HgShadow_WorldMatrix   : WORLD;
float4x4 HgShadow_ViewMatrix    : VIEW;
float4x4 HgShadow_ProjMatrix    : PROJECTION;
float4x4 HgShadow_InvViewMatrix : VIEWINVERSE;

// カメラ位置
float3 HgShadow_CameraPosition  : POSITION  < string Object = "Camera"; >;

// カメラ方向(正規化済み)
float3 HgShadow_CameraDirection : DIRECTION < string Object = "Camera"; >;

// ライト方向(正規化済み)
float3 HgShadow_LightDirection  : DIRECTION < string Object = "Light"; >;

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


#ifndef MIKUMIKUMOVING

// コントロールパラメータ(MME)
#ifdef HGSHADOW_TEST
    #define CTRLFILENAME  "HgShadow.x"
#else
    #define CTRLFILENAME  "(OffscreenOwner)"
#endif
float HgShadow_NearZ : CONTROLOBJECT < string name = CTRLFILENAME; string item = "X"; >;     // Near位置調整値
float HgShadow_FarZ  : CONTROLOBJECT < string name = CTRLFILENAME; string item = "Y"; >;     // Nar位置調整値
float HgShadow_CSMParam  : CONTROLOBJECT < string name = CTRLFILENAME; string item = "Z"; >; // CSM分割式パラメータ
float HgShadow_LtLen : CONTROLOBJECT < string name = CTRLFILENAME; string item = "Rz"; >;    // LightSpaceパース調整値

static float HgShadow_NearAll = max(ShadowViewNear + HgShadow_NearZ, 1.0f);
static float HgShadow_FarAll  = max(ShadowViewFar + HgShadow_FarZ, HgShadow_NearAll+1.0f);
static float HgShadow_Lamda   = clamp(0.97f - 0.97f*HgShadow_CSMParam, 0.0f, 1.0f);
static float HgShadow_Lamda2  = 1.0f + saturate(-HgShadow_CSMParam);
static float HgShadow_NearLen = degrees(HgShadow_LtLen);

#else

// コントロールパラメータ(MMM)
shared float HgShadow_MMM_ShadowViewNear;
shared float HgShadow_MMM_ShadowViewFar;
shared float HgShadow_MMM_CascadedParam;
shared float HgShadow_MMM_PerspectiveParam;
static float HgShadow_NearAll = HgShadow_MMM_ShadowViewNear;
static float HgShadow_FarAll  = HgShadow_MMM_ShadowViewFar;
static float HgShadow_Lamda   = clamp(0.97f - 0.97f*HgShadow_MMM_CascadedParam, 0.0f, 1.0f);
static float HgShadow_Lamda2  = 1.0f + saturate(-HgShadow_MMM_CascadedParam);
static float HgShadow_NearLen = HgShadow_MMM_PerspectiveParam;

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
   if( !any(viewX) ) viewX = HgShadow_ViewMatrix._11_21_31;
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
// CLSPSMによるライト方向のビュー射影変換

float4 HgShadow_CLSPSM_GetLightProjPosition(float4 WPos, int mapIndex)
{
    float3 effectiveLightDirection = HgShadow_GetEffectiveLightDirection();
    // カメラ方向とライト方向のなす角
    float cosAng = dot(HgShadow_CameraDirection, effectiveLightDirection);
    float sinAng = sqrt(1.0f - cosAng * cosAng);

    // ライト方向のビュー変換行列
    float4x4 ltViewMat = HgShadow_CreateViewMatrix(HgShadow_CameraPosition, effectiveLightDirection, HgShadow_CameraDirection);

    // ワールド座標へ戻す+ライト方向のビュー変換行列
    float4x4 InvView_ltViewMat = mul(HgShadow_InvViewMatrix, ltViewMat);

    // 分割したカメラ視錐台のNearとFarの位置(CSM法による分割)
    float nearAll = HgShadow_NearAll;
    float farAll  = HgShadow_FarAll;
    float lamda   = HgShadow_Lamda;
    float lamda2  = HgShadow_Lamda2;
    float ixn = pow(float(mapIndex)/float(HgShadow_MapCount), lamda2);
    float ixf = pow(float(mapIndex+1)/float(HgShadow_MapCount), lamda2);
    float camNear = lamda * nearAll * pow(farAll/nearAll, ixn)
                  + (1.0f-lamda) * (nearAll + (float(mapIndex)/float(HgShadow_MapCount)) * (farAll-nearAll));
    float camFar  = lamda * nearAll * pow(farAll/nearAll, ixf)
                  + (1.0f-lamda) * (nearAll + (float(mapIndex+1)/float(HgShadow_MapCount)) * (farAll-nearAll));
    float2 nearPos = float2(camNear / HgShadow_ProjMatrix._11, camNear / HgShadow_ProjMatrix._22 );
    float2 farPos  = float2(camFar / HgShadow_ProjMatrix._11, camFar / HgShadow_ProjMatrix._22 );

    // コントロールパラメータによるNear調整値
    float ixf0 = pow(1.0f/float(HgShadow_MapCount), lamda2);
    float camFar0  = lamda * nearAll * pow(farAll/nearAll, ixf0)
                  + (1.0f-lamda) * (nearAll + (1.0f/float(HgShadow_MapCount)) * (farAll-nearAll));
    float offsetNear = HgShadow_NearLen * (camFar-camNear) / (camFar0-nearAll);

    // カメラ視錐台の頂点ビュー座標
    float4 VFrustumPos[8] = { float4(-nearPos.x,  nearPos.y, camNear, 1.0f),
                              float4(-nearPos.x, -nearPos.y, camNear, 1.0f),
                              float4( nearPos.x, -nearPos.y, camNear, 1.0f),
                              float4( nearPos.x,  nearPos.y, camNear, 1.0f),
                              float4(-farPos.x,   farPos.y,  camFar,  1.0f),
                              float4(-farPos.x,  -farPos.y,  camFar,  1.0f),
                              float4( farPos.x,  -farPos.y,  camFar,  1.0f),
                              float4( farPos.x,   farPos.y,  camFar,  1.0f) };

    // ワールド座標へ戻す+ライト方向の座標
    [unroll]
    for(int i=0; i<8; i++){
        VFrustumPos[i] = mul( VFrustumPos[i], InvView_ltViewMat );
    }

    // 視錐台のAABB(Axis Aligned Bounding Box)を作成
    float3 minAABB = float3( 1e30,  1e30,  1e30);
    float3 maxAABB = float3(-1e30, -1e30, -1e30);
    [unroll]
    for(int j=0; j<8; j++){
        minAABB = min( VFrustumPos[j].xyz, minAABB );
        maxAABB = max( VFrustumPos[j].xyz, maxAABB );
    }

    // マップ分割境界のリニアを読まないようにするための縮小係数
    float2 sc = float2( (0.5f*SMAPSIZE_WIDTH - HgShadow_SCParam) / (0.5f*SMAPSIZE_WIDTH),
                        (0.5f*SMAPSIZE_HEIGHT - HgShadow_SCParam) / (0.5f*SMAPSIZE_HEIGHT) );

    float4 PPos;  // ライト方向のワールドビュー射影変換座標

    if(sinAng > 0.00001f){
    // カメラ方向とライト方向のなす角が 0°,180°でない場合

        // LightSpaceのNearとFar
        //float lsNear = max( camNear + sqrt(camNear*camFar) + offsetNear, 1.0f ) / sinAng; // LSPSM元論文の方法
        float lsNear = max( camNear + sqrt(nearAll*camFar) + offsetNear, 1.0f ) / sinAng;  // CSMではこの方がパースバランスが良さげ
        float lsFar = lsNear + maxAABB.y - minAABB.y;

        // LightSpaceの視点位置
        float3 lsPos = float3(0.0f, minAABB.y - lsNear, (maxAABB.z + minAABB.z)*0.5f);

        // LightSpace視点のビュー変換行列
        float4x4 lsViewMat = HgShadow_CreateViewMatrix(lsPos, float3(0,1,0), float3(0,0,-1));

        // 視錐台のLightSpace視点のビュー座標
        [unroll]
        for(int i=0; i<8; i++){
            VFrustumPos[i] = mul( VFrustumPos[i], lsViewMat );
        }

        // 最大視野角tan(a/2)
        float2 maxViewAng = float2(0.0f, 0.0f);
        [unroll]
        for(int j=0; j<8; j++){
            maxViewAng = max( abs(VFrustumPos[j].xy/VFrustumPos[j].z), maxViewAng );
        }

        // 射影変換後の無限平面位置
        float InfZ = lsFar / (lsFar - lsNear);

        // LightSpace視点の射影変換行列
        float4x4 lsProjMat = float4x4( 1.0f/maxViewAng.x,              0.0f,         0.0f,  0.0f,
                                                    0.0f, 1.0f/maxViewAng.y,         0.0f,  0.0f,
                                                    0.0f,              0.0f,         InfZ,  1.0f,
                                                    0.0f,              0.0f, -lsNear*InfZ,  0.0f );

        // LightSpace視点の射影座標をライト方向の射影座標に変換するための行列
        const float4x4 ltTransMat = float4x4( 1.0f,  0.0f,  0.0f,  0.0f,
                                              0.0f,  0.0f, -0.5f,  0.0f,
                                              0.0f,  2.0f,  0.0f,  0.0f,
                                              0.0f, -1.0f,  0.5f,  1.0f );

        // 変換行列を合成
        float4x4 lightViewProjMatrix = mul( mul( mul(ltViewMat, lsViewMat), lsProjMat ), ltTransMat );
        lightViewProjMatrix._11_21_31_41 *= sc.x;
        lightViewProjMatrix._12_22_32_42 *= sc.y;

        // ライト方向の射影変換座標
        PPos = mul( WPos, lightViewProjMatrix );

        // Z値にはパースを掛けない(独自仕様)
        float Z = mul( WPos, mul(ltViewMat, lsViewMat)).y;
        PPos.z = -Z * 0.0001f + 0.5f;  // 深度-5000～+5000の範囲を射影空間の視錐台内に納める

    }else{
    // カメラ方向とライト方向のなす角が 0°,180°の場合はパースなしのシャドウマップ

        // ライト方向のビュー変換行列
        float4x4 LtViewMat = float4x4( ltViewMat[0],
                                       ltViewMat[1],
                                       ltViewMat[2],
                                      -float3( (minAABB.x+maxAABB.x)*0.5f, (minAABB.y+maxAABB.y)*0.5f, (minAABB.z+maxAABB.z)*0.5f ), 1 );

        // ライト方向の射影変換行列
        float4x4 LtProjMat = float4x4( 2.0f*sc.x/(maxAABB.x-minAABB.x),  0,       0, 0,
                                       0,  2.0f*sc.y/(maxAABB.y-minAABB.y),       0, 0,
                                       0,  0,                               0.0001f, 0,
                                       0,  0,                                  0.5f, 1 );

        // ライト方向の射影変換座標
        PPos = mul( WPos, mul(LtViewMat, LtProjMat) );
    }

    return PPos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 複数のマップから精度の良い上位2マップのテクスチャ座標と深度を選び出す

struct HgShadow_SMapDat {
    float4 Tex1;   // 1番精度がよいZCalcTex(xy:マップ座標, z:ZPlot, w:マップ番号)
    float4 Tex2;   // 2番目に精度がよいZCalcTex(xy:マップ座標, z:ZPlot, w:マップ番号)
    float Weight;  // Tex1が占めるウエイト
};

HgShadow_SMapDat HgShadow_CLSPSM_GetTexCoord(float4 ZCalcTex0, float4 ZCalcTex1, float4 ZCalcTex2, float4 ZCalcTex3, float4 MMD_ZCalcTex)
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


