////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgShadow_Header.fxh : HgShadow シャドウマップ作成に必要な基本パラメータ定義ヘッダファイル
//  ここのパラメータを他のエフェクトファイルで #include して使用します。
//  作成: 針金P
//
//  ※このファイルを更新してもMMEによる自動更新は行われません。
//  ※ファイル更新後に｢MMEffect｣→｢全て更新｣で参照しているエフェクトファイルを更新する必要があります。
//  ※MMMではHgShadow.fxロード前に変更してください。変更内容が反映されない場合はMMMのCacheフォルダ内を全て削除して再トライ。
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください


////////////////////// シャドウマップ関連のパラメータ ////////////////////////

// シャドウマップの種類選択( 0:CFSUSM, 1:CLSPSM )
#define ShadowMapType  0
// CFSUSM(Cascaded Fixation Space Uniform Shadow Maps)分割空間固定正方シャドウマップについて
//   1つのオフスクリーンを4分割して,パースのないマップをそれぞれ近景用から遠景用に空間固定で配置したシャドウマップです。
//   空間固定なのでカメラ操作による影境界のちらつきが起こりません。ただマップ中心位置から離れると影の精度が悪くなります。
//   パラメータ調整がしやすく初心者向けのマップです。
// CLSPSM(Cascaded Light Space Perspective Shadow Maps)分割ライト空間透視シャドウマップについて
//   1つのオフスクリーンを4分割して,CSM法に基づきカメラ視錐台を分割して,それぞれを近景用から遠景用に
//   LSPSM法に基づくパース掛けしたマップを配置したシャドウマップです。
//   パースのバランスが良く近景,遠景共に良好な影が得られる高精度なマップですが、シーンに応じて適切なパラメータを与えないと
//   エイリアス(影境界のギザギザ)が発生してカメラ操作によるちらつきが目立ってしまします。
//   パラメータ調整にはコツが必要で,中・上級者向けのマップになります。


// シャドウマップバッファサイズ
#define ShadowMapSize   4096


// CFSUSMではシャドウマップCSM分割における最近値
// CLSPSMではシャドウマップ参照範囲内になるカメラ視錐台の最近値(MMDの｢X｣, MMMの｢Near値｣で調整可)
#define ShadowViewNear  2.0


// CFSUSMではシャドウマップ参照範囲内になる最遠値(MMDの｢Rz｣, MMMの｢マップ範囲｣で調整可)
// CLSPSMではシャドウマップ参照範囲内になるカメラ視錐台の最遠値(MMDの｢Y｣, MMMの｢Far値｣で調整可)
#define ShadowViewFar   1000.0


// シャドウマップで考慮する半透明材質のα透過値に対する閾値
#define ShadowAlphaThreshold   0.5


// シャドウマップでエッジの深度を考慮するかどうか
#define DrawShadowMapEdge  1
// 0 : 考慮しない
// 1 : 考慮する


// MMD標準シャドウマップの使用
#define UseMMDShadowMap   2
// 0 : 使用しない
// 1 : 最近景のマップとして使用する
// 2 : 最遠景のマップとして使用する
// ※MMMでは標準シャドウマップは使わないので設定不用


////////////////////// ソフトシャドウ関連のパラメータ ////////////////////////

// ソフトシャドウのクオリティモード(0～3で選択, 数字が上がるほど重くなります)
#define SoftShadowQuality  3
// 0 : ソフトシャドウ無し
// 1 : 簡易的なソフトシャドウ(シャドウマップの簡易マルチサンプル＋画面上の9点サンプリングのみ)
// 2 : 少し凝ったソフトシャドウ(1の方法＋画面マップの近傍フィルタリング追加)
// 3 : さらに凝ったソフトシャドウ(2の方法＋遮蔽距離によるぼかし度合いの調整機能追加)


// シャドウマップマルチサンプルのサンプリング数(1～13で選択)
#define ShadowMapSampCount  9


// 近傍フィルタリングのサンプリング数(5～65で選択, 大きくするほどぼかしが綺麗になり,かつ重くなる)
#define ViewportMapSampCount  13
// 強いぼかしを掛けた時にここの値が小さいとぼかしにムラが出ます


// ソフトシャドウのぼかし強度基準値(大きくすると初期状態のぼかしが強くなる)
#define InitBlurPower  2.0


////////////////////// その他の制御スイッチパラメータ ////////////////////////

// VolumeShadow.fx との供用をするかどうか
#define WithVolumeShadow  0
// 0 : 供用しない
// 1 : 供用する
// ※MMMでは未対応なので設定不用


// 影生成バッファのアンチエイリアスのon/off
#define BufferAntiAlias   1
// 0 : off
// 1 : on
// 通常はonにしておきますが,対応していないグラボがあるため,うまく動作しない場合はoffにしてください


// 影生成バッファフォーマットの浮動小数精度
#define BufferFmtQuality  1
// 0 : 16bit
// 1 : 32bit


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////

#define CFSUSM  0
#define CLSPSM  1

#ifdef HGSHADOW_MAPDRAW

#if (ShadowMapType == CLSPSM)
    #include "HgShadow_CLSPSM.fxh"
    #define HgShadow_GetShadowMapLightProjPosition  HgShadow_CLSPSM_GetLightProjPosition
    #define HgShadow_GetShadowMapTexCoord  HgShadow_CLSPSM_GetTexCoord
#else
    #include "HgShadow_CFSUSM.fxh"
    #define HgShadow_GetShadowMapLightProjPosition  HgShadow_CFSUSM_GetLightProjPosition
    #define HgShadow_GetShadowMapTexCoord  HgShadow_CFSUSM_GetTexCoord
#endif

#endif

#ifdef HGSHADOW_TEST

#if (ShadowMapType == CLSPSM)
    #include "../HgShadow_CLSPSM.fxh"
    #define HgShadow_GetShadowMapLightProjPosition  HgShadow_CLSPSM_GetLightProjPosition
    #define HgShadow_GetShadowMapTexCoord  HgShadow_CLSPSM_GetTexCoord
#else
    #include "../HgShadow_CFSUSM.fxh"
    #define HgShadow_GetShadowMapLightProjPosition  HgShadow_CFSUSM_GetLightProjPosition
    #define HgShadow_GetShadowMapTexCoord  HgShadow_CFSUSM_GetTexCoord
#endif

#endif

