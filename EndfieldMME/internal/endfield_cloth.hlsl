#ifndef ENDFIELD_CLOTH_INCLUDED
#define ENDFIELD_CLOTH_INCLUDED

// Clothing stage 15: direct/anisotropic GGX, broad sheen, runtime MatCap/HDR
// environment blending, screen rim, ZMD receive/self shadow, controller and
// the shared geometric-outline pass.
#ifndef EF_CLOTH_MAIN_TEXTURE_RESOURCE
#define EF_CLOTH_MAIN_TEXTURE_RESOURCE \
    "textures/character/cloth_base.png"
#endif
#ifndef EF_CLOTH_CULL_MODE
#define EF_CLOTH_CULL_MODE NONE
#endif
#ifndef EF_CLOTH_OUTLINE_ENABLED
#define EF_CLOTH_OUTLINE_ENABLED 0
#endif
#ifndef EF_CLOTH_OUTLINE_WIDTH
#define EF_CLOTH_OUTLINE_WIDTH 1.0
#endif
#ifndef EF_CLOTH_OUTLINE_ZBIAS
#define EF_CLOTH_OUTLINE_ZBIAS 0.0005
#endif
#ifndef EF_CLOTH_OUTLINE_COLOR
#define EF_CLOTH_OUTLINE_COLOR float3(0.065, 0.06, 0.075)
#endif
#ifndef EF_CLOTH_OUTLINE_BASE_COLOR
#define EF_CLOTH_OUTLINE_BASE_COLOR EF_CLOTH_OUTLINE_COLOR
#endif
#ifndef EF_CLOTH_OUTLINE_STRENGTH
#define EF_CLOTH_OUTLINE_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_OUTLINE_FAR_SCALE
#define EF_CLOTH_OUTLINE_FAR_SCALE 0.45
#endif
#ifndef EF_CLOTH_OUTLINE_LIGHT_FLOOR
#define EF_CLOTH_OUTLINE_LIGHT_FLOOR 0.68
#endif
#ifndef EF_CLOTH_NORMAL_TEXTURE_RESOURCE
#define EF_CLOTH_NORMAL_TEXTURE_RESOURCE \
    "textures/character/cloth_normal.png"
#endif
#ifndef EF_CLOTH_NORMAL_STRENGTH
#define EF_CLOTH_NORMAL_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_PROPERTY_TEXTURE_RESOURCE
#define EF_CLOTH_PROPERTY_TEXTURE_RESOURCE \
    "textures/character/cloth_property.png"
#endif
#ifndef EF_CLOTH_AO_DARK_STRENGTH
#define EF_CLOTH_AO_DARK_STRENGTH 0.65
#endif
#ifndef EF_CLOTH_AO_LIGHT_STRENGTH
#define EF_CLOTH_AO_LIGHT_STRENGTH 0.25
#endif
#ifndef EF_CLOTH_AO_DEBUG
#define EF_CLOTH_AO_DEBUG 0
#endif
#ifndef EF_CLOTH_RD_TEXTURE_RESOURCE
#define EF_CLOTH_RD_TEXTURE_RESOURCE \
    "textures/common/T_actor_common_cloth_04_RD.png"
#endif
#ifndef EF_CLOTH_RD_COLOR_STRENGTH
#define EF_CLOTH_RD_COLOR_STRENGTH 0.35
#endif
#ifndef EF_CLOTH_LUT_TEXTURE_RESOURCE
#define EF_CLOTH_LUT_TEXTURE_RESOURCE \
    "textures/common/T_actor_common_cloth_lut_01_D.png"
#endif
#ifndef EF_CLOTH_LUT_STRENGTH
#define EF_CLOTH_LUT_STRENGTH 0.35
#endif
#ifndef EF_CLOTH_RS_TEXTURE_RESOURCE
#define EF_CLOTH_RS_TEXTURE_RESOURCE \
    "textures/common/T_actor_common_cloth_04_RS.png"
#endif
#ifndef EF_CLOTH_METALLIC_STRENGTH
#define EF_CLOTH_METALLIC_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_ROUGHNESS_STRENGTH
#define EF_CLOTH_ROUGHNESS_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_RAIN_AMOUNT
#define EF_CLOTH_RAIN_AMOUNT 0.0
#endif
#ifndef EF_CLOTH_WET_TARGET_ROUGHNESS
#define EF_CLOTH_WET_TARGET_ROUGHNESS 0.12
#endif
#ifndef EF_CLOTH_RAIN_ENABLED
#define EF_CLOTH_RAIN_ENABLED 0
#endif
#ifndef EF_CLOTH_RAIN_TEXTURE_RESOURCE
#define EF_CLOTH_RAIN_TEXTURE_RESOURCE \
    "textures/common/rain/T_actor_common_rain_02_M.png"
#endif
#ifndef EF_CLOTH_RAIN_DROP_ENABLED
#define EF_CLOTH_RAIN_DROP_ENABLED 0
#endif
#ifndef EF_CLOTH_RAIN_DROP_TEXTURE_RESOURCE
#define EF_CLOTH_RAIN_DROP_TEXTURE_RESOURCE \
    "textures/common/rain/rain_drops.png"
#endif
#ifndef EF_CLOTH_RAIN_DROP_PHASE_TEXTURE_RESOURCE
#define EF_CLOTH_RAIN_DROP_PHASE_TEXTURE_RESOURCE \
    "textures/common/rain/rain_drops_phase.png"
#endif
#ifndef EF_CLOTH_RAIN_DROP_TILING
#define EF_CLOTH_RAIN_DROP_TILING 3.5
#endif
#ifndef EF_CLOTH_RAIN_DROP_INTENSITY
#define EF_CLOTH_RAIN_DROP_INTENSITY 1.0
#endif
#ifndef EF_CLOTH_RAIN_DROP_SPEED
#define EF_CLOTH_RAIN_DROP_SPEED 0.25
#endif
#ifndef EF_CLOTH_RAIN_DROP_LIFETIME
#define EF_CLOTH_RAIN_DROP_LIFETIME 0.65
#endif
#ifndef EF_CLOTH_RAIN_DROP_NORMAL_OFFSET
#define EF_CLOTH_RAIN_DROP_NORMAL_OFFSET 0.0
#endif
#ifndef EF_CLOTH_RAIN_DROP_EDGE_SMOOTHNESS
#define EF_CLOTH_RAIN_DROP_EDGE_SMOOTHNESS 5.0
#endif
#ifndef EF_CLOTH_RAIN_DROP_OMNI_COVERAGE
#define EF_CLOTH_RAIN_DROP_OMNI_COVERAGE 0.0
#endif
#ifndef EF_CLOTH_RAIN_DROP_NORMAL_STRENGTH
#define EF_CLOTH_RAIN_DROP_NORMAL_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_RAIN_UV_SCALE
#define EF_CLOTH_RAIN_UV_SCALE 2.3
#endif
#ifndef EF_CLOTH_RAIN_NORMAL_STRENGTH
#define EF_CLOTH_RAIN_NORMAL_STRENGTH 0.7
#endif
#ifndef EF_CLOTH_RAIN_SECONDARY_ENABLED
#define EF_CLOTH_RAIN_SECONDARY_ENABLED 0
#endif
#ifndef EF_CLOTH_RAIN_SECONDARY_SCALE_OFFSET
#define EF_CLOTH_RAIN_SECONDARY_SCALE_OFFSET 5.0
#endif
#ifndef EF_CLOTH_RAIN_SECONDARY_STRENGTH
#define EF_CLOTH_RAIN_SECONDARY_STRENGTH 0.55
#endif
#ifndef EF_CLOTH_RAIN_FLOW_SPEED
#define EF_CLOTH_RAIN_FLOW_SPEED 0.08
#endif
#ifndef EF_CLOTH_RAIN_WORLD_SCALE
#define EF_CLOTH_RAIN_WORLD_SCALE 0.10
#endif
#ifndef EF_CLOTH_RAIN_PROJECTION_SHARPNESS
#define EF_CLOTH_RAIN_PROJECTION_SHARPNESS 8.0
#endif
#ifndef EF_CLOTH_RAIN_COAT_ENABLED
#define EF_CLOTH_RAIN_COAT_ENABLED 0
#endif
#ifndef EF_CLOTH_RAIN_COAT_STRENGTH
#define EF_CLOTH_RAIN_COAT_STRENGTH 0.65
#endif
#ifndef EF_CLOTH_RAIN_COAT_ENV_STRENGTH
#define EF_CLOTH_RAIN_COAT_ENV_STRENGTH 0.35
#endif
#ifndef EF_CLOTH_RAIN_COAT_ROUGHNESS
#define EF_CLOTH_RAIN_COAT_ROUGHNESS 0.10
#endif
#ifndef EF_CLOTH_RAIN_COAT_F0
#define EF_CLOTH_RAIN_COAT_F0 0.02
#endif
#ifndef EF_CLOTH_RAIN_MATERIAL_RESPONSE_STRENGTH
#define EF_CLOTH_RAIN_MATERIAL_RESPONSE_STRENGTH 0.65
#endif
#ifndef EF_CLOTH_RAIN_ALBEDO_DARKEN
#define EF_CLOTH_RAIN_ALBEDO_DARKEN 0.08
#endif
#ifndef EF_CLOTH_RAIN_SATURATION_BOOST
#define EF_CLOTH_RAIN_SATURATION_BOOST 0.08
#endif
#ifndef EF_CLOTH_RAIN_CHANNEL_DEBUG
#define EF_CLOTH_RAIN_CHANNEL_DEBUG 0
#endif
#ifndef EF_CLOTH_RAIN_NORMAL_X_SIGN
#define EF_CLOTH_RAIN_NORMAL_X_SIGN -1.0
#endif
#ifndef EF_CLOTH_RAIN_NORMAL_Y_SIGN
#define EF_CLOTH_RAIN_NORMAL_Y_SIGN -1.0
#endif
#ifndef EF_CLOTH_REFLECTIVITY_STRENGTH
#define EF_CLOTH_REFLECTIVITY_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_DIELECTRIC_F0
#define EF_CLOTH_DIELECTRIC_F0 0.06
#endif
#ifndef EF_CLOTH_RS_STRENGTH
#define EF_CLOTH_RS_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_SPECULAR_STRENGTH
#define EF_CLOTH_SPECULAR_STRENGTH 0.35
#endif
#ifndef EF_CLOTH_SPECULAR_MAX
#define EF_CLOTH_SPECULAR_MAX 1.5
#endif
#ifndef EF_CLOTH_PRIMARY_SPECULAR_THRESHOLD_DEBUG
#define EF_CLOTH_PRIMARY_SPECULAR_THRESHOLD_DEBUG 0
#endif
#ifndef EF_CLOTH_PRIMARY_SPECULAR_DEBUG_THRESHOLD
#define EF_CLOTH_PRIMARY_SPECULAR_DEBUG_THRESHOLD 0.05
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_THRESHOLD_DEBUG
#define EF_CLOTH_BROAD_SPECULAR_THRESHOLD_DEBUG 0
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_DEBUG_THRESHOLD
#define EF_CLOTH_BROAD_SPECULAR_DEBUG_THRESHOLD 0.08
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_GRAYSCALE_DEBUG
#define EF_CLOTH_BROAD_SPECULAR_GRAYSCALE_DEBUG 0
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_DEBUG_EXPOSURE
#define EF_CLOTH_BROAD_SPECULAR_DEBUG_EXPOSURE 6.0
#endif
#ifndef EF_CLOTH_MATERIAL_CLASS_DEBUG
#define EF_CLOTH_MATERIAL_CLASS_DEBUG 0
#endif
#ifndef EF_CLOTH_MATERIAL_CLASS_SMOOTH_START
#define EF_CLOTH_MATERIAL_CLASS_SMOOTH_START 0.45
#endif
#ifndef EF_CLOTH_MATERIAL_CLASS_SMOOTH_END
#define EF_CLOTH_MATERIAL_CLASS_SMOOTH_END 0.75
#endif
#ifndef EF_CLOTH_LAYERED_DIELECTRIC_ENABLED
#define EF_CLOTH_LAYERED_DIELECTRIC_ENABLED 0
#endif
#ifndef EF_CLOTH_LAYER_ROUGH_START
#define EF_CLOTH_LAYER_ROUGH_START 0.35
#endif
#ifndef EF_CLOTH_LAYER_ROUGH_END
#define EF_CLOTH_LAYER_ROUGH_END 0.78
#endif
#ifndef EF_CLOTH_LAYER_SMOOTH_START
#define EF_CLOTH_LAYER_SMOOTH_START 0.12
#endif
#ifndef EF_CLOTH_LAYER_SMOOTH_END
#define EF_CLOTH_LAYER_SMOOTH_END 0.62
#endif
#ifndef EF_CLOTH_LAYER_NORMAL_DETAIL_SCALE
#define EF_CLOTH_LAYER_NORMAL_DETAIL_SCALE 10.0
#endif
#ifndef EF_CLOTH_LAYER_BROAD_ROUGH_ENERGY_FLOOR
#define EF_CLOTH_LAYER_BROAD_ROUGH_ENERGY_FLOOR 0.85
#endif
#ifndef EF_CLOTH_LAYER_COAT_STRENGTH
#define EF_CLOTH_LAYER_COAT_STRENGTH 0.30
#endif
#ifndef EF_CLOTH_LAYER_COAT_FLOOR
#define EF_CLOTH_LAYER_COAT_FLOOR 0.22
#endif
#ifndef EF_CLOTH_LAYER_COAT_ROUGHNESS_ROUGH
#define EF_CLOTH_LAYER_COAT_ROUGHNESS_ROUGH 0.32
#endif
#ifndef EF_CLOTH_LAYER_COAT_ROUGHNESS_SMOOTH
#define EF_CLOTH_LAYER_COAT_ROUGHNESS_SMOOTH 0.14
#endif
#ifndef EF_CLOTH_SPECULAR_VIEW_LOCK
#define EF_CLOTH_SPECULAR_VIEW_LOCK 0.65
#endif
#ifndef EF_CLOTH_SPECULAR_LIGHT_FLOOR
#define EF_CLOTH_SPECULAR_LIGHT_FLOOR 0.05
#endif
#ifndef EF_CLOTH_DIRECT_METAL_TINT_STRENGTH
#define EF_CLOTH_DIRECT_METAL_TINT_STRENGTH 0.08
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_STRENGTH
#define EF_CLOTH_BROAD_SPECULAR_STRENGTH 0.65
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_ROUGHNESS
#define EF_CLOTH_BROAD_SPECULAR_ROUGHNESS 0.50
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_NORMAL_SMOOTHING
#define EF_CLOTH_BROAD_SPECULAR_NORMAL_SMOOTHING 0.85
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_TINT_STRENGTH
#define EF_CLOTH_BROAD_SPECULAR_TINT_STRENGTH 0.08
#endif
#ifndef EF_CLOTH_BROAD_SPECULAR_METALLIC_REJECTION
#define EF_CLOTH_BROAD_SPECULAR_METALLIC_REJECTION 2.0
#endif
#ifndef EF_CLOTH_ANISO_SPECULAR_STRENGTH
#define EF_CLOTH_ANISO_SPECULAR_STRENGTH 0.55
#endif
#ifndef EF_CLOTH_ANISO_AMOUNT
#define EF_CLOTH_ANISO_AMOUNT 0.55
#endif
#ifndef EF_CLOTH_ANISO_AXIS
#define EF_CLOTH_ANISO_AXIS 1.0
#endif
#ifndef EF_CLOTH_ANISO_ROUGHNESS_FLOOR
#define EF_CLOTH_ANISO_ROUGHNESS_FLOOR 0.28
#endif
#ifndef EF_CLOTH_ANISO_NORMAL_SMOOTHING
#define EF_CLOTH_ANISO_NORMAL_SMOOTHING 0.65
#endif
#ifndef EF_CLOTH_ANISO_TINT_STRENGTH
#define EF_CLOTH_ANISO_TINT_STRENGTH 0.08
#endif
#ifndef EF_CLOTH_ANISO_METALLIC_REJECTION
#define EF_CLOTH_ANISO_METALLIC_REJECTION 2.0
#endif
#ifndef EF_CLOTH_ANISO_FACING_START
#define EF_CLOTH_ANISO_FACING_START 0.15
#endif
#ifndef EF_CLOTH_ANISO_FACING_END
#define EF_CLOTH_ANISO_FACING_END 0.45
#endif
#ifndef EF_CLOTH_ANISO_THRESHOLD_DEBUG
#define EF_CLOTH_ANISO_THRESHOLD_DEBUG 0
#endif
#ifndef EF_CLOTH_ANISO_DEBUG_THRESHOLD
#define EF_CLOTH_ANISO_DEBUG_THRESHOLD 0.003
#endif
#ifndef EF_CLOTH_RIM_STRENGTH
#define EF_CLOTH_RIM_STRENGTH 0.55
#endif
#ifndef EF_CLOTH_RIM_WIDTH
#define EF_CLOTH_RIM_WIDTH 0.30
#endif
#ifndef EF_CLOTH_RIM_SOFTNESS
#define EF_CLOTH_RIM_SOFTNESS 0.08
#endif
#ifndef EF_CLOTH_RIM_LIGHT_START
#define EF_CLOTH_RIM_LIGHT_START 0.05
#endif
#ifndef EF_CLOTH_RIM_LIGHT_END
#define EF_CLOTH_RIM_LIGHT_END 0.45
#endif
#ifndef EF_CLOTH_RIM_NORMAL_SMOOTHING
#define EF_CLOTH_RIM_NORMAL_SMOOTHING 0.90
#endif
#ifndef EF_CLOTH_RIM_ALBEDO_BLEND
#define EF_CLOTH_RIM_ALBEDO_BLEND 0.20
#endif
#ifndef EF_CLOTH_RIM_COLOR
#define EF_CLOTH_RIM_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_CLOTH_RIM_METAL_RETENTION
#define EF_CLOTH_RIM_METAL_RETENTION 0.55
#endif
#ifndef EF_CLOTH_SCREEN_RIM_ENABLED
#define EF_CLOTH_SCREEN_RIM_ENABLED 0
#endif
#ifndef EF_CLOTH_SHADOW_VIEWPORT_MAP
#define EF_CLOTH_SHADOW_VIEWPORT_MAP ZMDshadow_ViewportMap2
#endif
#ifndef EF_CLOTH_SHADOW_CONTROLLER_NAME
#define EF_CLOTH_SHADOW_CONTROLLER_NAME "ZMDshadow.x"
#endif
#ifndef EF_CLOTH_SCREEN_RIM_WIDTH_X
#define EF_CLOTH_SCREEN_RIM_WIDTH_X 0.041847
#endif
#ifndef EF_CLOTH_SCREEN_RIM_WIDTH_Y
#define EF_CLOTH_SCREEN_RIM_WIDTH_Y 0.019108
#endif
#ifndef EF_CLOTH_SCREEN_RIM_VIEW_SCALE
#define EF_CLOTH_SCREEN_RIM_VIEW_SCALE 0.1
#endif
#ifndef EF_CLOTH_SCREEN_RIM_MODEL_SCALE
#define EF_CLOTH_SCREEN_RIM_MODEL_SCALE 10.0
#endif
#ifndef EF_CLOTH_SCREEN_RIM_DEPTH_SCALE
#define EF_CLOTH_SCREEN_RIM_DEPTH_SCALE 0.8
#endif
#ifndef EF_CLOTH_SCREEN_RIM_DEPTH_MAX
#define EF_CLOTH_SCREEN_RIM_DEPTH_MAX 4.0
#endif
#ifndef EF_CLOTH_SCREEN_RIM_FRESNEL_POWER
#define EF_CLOTH_SCREEN_RIM_FRESNEL_POWER 3.0
#endif
#ifndef EF_CLOTH_SCREEN_RIM_LIGHT_START
#define EF_CLOTH_SCREEN_RIM_LIGHT_START 0.0
#endif
#ifndef EF_CLOTH_SCREEN_RIM_LIGHT_END
#define EF_CLOTH_SCREEN_RIM_LIGHT_END 0.2
#endif
#ifndef EF_CLOTH_SCREEN_RIM_STRENGTH
#define EF_CLOTH_SCREEN_RIM_STRENGTH 0.45
#endif
#ifndef EF_CLOTH_SCREEN_RIM_COLOR
#define EF_CLOTH_SCREEN_RIM_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_CLOTH_SCREEN_RIM_METAL_RETENTION
#define EF_CLOTH_SCREEN_RIM_METAL_RETENTION 0.55
#endif
#ifndef EF_CLOTH_ZMD_SHADOW_ENABLED
#define EF_CLOTH_ZMD_SHADOW_ENABLED 0
#endif
#ifndef EF_CLOTH_SHADOW_CENTER
#define EF_CLOTH_SHADOW_CENTER 0.5
#endif
#ifndef EF_CLOTH_SHADOW_SMOOTHNESS
#define EF_CLOTH_SHADOW_SMOOTHNESS 0.35
#endif
#ifndef EF_CLOTH_SHADOW_OFFSET
#define EF_CLOTH_SHADOW_OFFSET 0.0
#endif
#ifndef EF_CLOTH_SHADOW_STRENGTH
#define EF_CLOTH_SHADOW_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_DIRECT_SHADOW_FLOOR
#define EF_CLOTH_DIRECT_SHADOW_FLOOR 0.02
#endif
#ifndef EF_CLOTH_ENV_SHADOW_STRENGTH
#define EF_CLOTH_ENV_SHADOW_STRENGTH 0.75
#endif
#ifndef EF_CLOTH_RIM_SHADOW_STRENGTH
#define EF_CLOTH_RIM_SHADOW_STRENGTH 0.75
#endif
#ifndef EF_CLOTH_SHADOW_DEBUG
#define EF_CLOTH_SHADOW_DEBUG 0
#endif
#ifndef EF_CLOTH_CONTROLLER_ENABLED
#define EF_CLOTH_CONTROLLER_ENABLED 0
#endif
#ifndef EF_CLOTH_CONTROLLER_NAME
#define EF_CLOTH_CONTROLLER_NAME "EndfieldCloth_controller.pmx"
#endif
#ifndef EF_CLOTH_CONTROLLER_MAX_MULTIPLIER
#define EF_CLOTH_CONTROLLER_MAX_MULTIPLIER 5.0
#endif
#ifndef EF_CLOTH_USE_SELF_SHADOW
#if EF_CLOTH_ZMD_SHADOW_ENABLED
#define EF_CLOTH_USE_SELF_SHADOW true
#else
#define EF_CLOTH_USE_SELF_SHADOW false
#endif
#endif
#ifndef EF_CLOTH_ENV_TEXTURE_RESOURCE
#define EF_CLOTH_ENV_TEXTURE_RESOURCE \
    "textures/common/cloth_environment_current.dds"
#endif
#ifndef EF_CLOTH_MATCAP_ENABLED
#define EF_CLOTH_MATCAP_ENABLED 0
#endif
#ifndef EF_CLOTH_MATCAP_TEXTURE_RESOURCE
#define EF_CLOTH_MATCAP_TEXTURE_RESOURCE \
    "textures/common/Eff_MatCap_019.png"
#endif
#ifndef EF_CLOTH_MATCAP_MANUAL_LOD_ENABLED
#define EF_CLOTH_MATCAP_MANUAL_LOD_ENABLED 0
#endif
#ifndef EF_CLOTH_MATCAP_MANUAL_TEXTURE_RESOURCE
#define EF_CLOTH_MATCAP_MANUAL_TEXTURE_RESOURCE \
    "textures/common/Eff_MatCap_019_manual_lod.png"
#endif
#ifndef EF_CLOTH_MATCAP_SOURCE_SIZE
#define EF_CLOTH_MATCAP_SOURCE_SIZE 256.0
#endif
#ifndef EF_CLOTH_MATCAP_MANUAL_LOD_COUNT
#define EF_CLOTH_MATCAP_MANUAL_LOD_COUNT 8.0
#endif
#ifndef EF_CLOTH_MATCAP_LOD_SCALE
#define EF_CLOTH_MATCAP_LOD_SCALE 1.0
#endif
#ifndef EF_CLOTH_MATCAP_LOD_BIAS
#define EF_CLOTH_MATCAP_LOD_BIAS 0.0
#endif
#ifndef EF_CLOTH_MATCAP_LOD_OVERRIDE
#define EF_CLOTH_MATCAP_LOD_OVERRIDE -1.0
#endif
#ifndef EF_CLOTH_FGD_TEXTURE_RESOURCE
#define EF_CLOTH_FGD_TEXTURE_RESOURCE \
    "textures/common/PreIntegratedFGD_GGXDisneyDiffuse.png"
#endif
#ifndef EF_CLOTH_FGD_LUT_ENABLED
#define EF_CLOTH_FGD_LUT_ENABLED 0
#endif
#ifndef EF_CLOTH_FGD_STRENGTH
#define EF_CLOTH_FGD_STRENGTH 1.0
#endif
#ifndef EF_CLOTH_ENV_STRENGTH
#define EF_CLOTH_ENV_STRENGTH 0.2
#endif
#ifndef EF_CLOTH_HDR_RELATIVE_STRENGTH
#define EF_CLOTH_HDR_RELATIVE_STRENGTH 0.65
#endif
#ifndef EF_CLOTH_ENV_ROTATION
#define EF_CLOTH_ENV_ROTATION 0.0
#endif
#ifndef EF_CLOTH_ENV_MIP_COUNT
#define EF_CLOTH_ENV_MIP_COUNT 7.0
#endif
#ifndef EF_CLOTH_ENV_RGBM_RANGE
#define EF_CLOTH_ENV_RGBM_RANGE 6.0
#endif
#ifndef EF_CLOTH_ENV_DESATURATION
#define EF_CLOTH_ENV_DESATURATION 1.0
#endif
#ifndef EF_CLOTH_ENV_METAL_TINT_STRENGTH
#define EF_CLOTH_ENV_METAL_TINT_STRENGTH 0.25
#endif
#ifndef EF_CLOTH_ENV_AO_STRENGTH
#define EF_CLOTH_ENV_AO_STRENGTH 0.65
#endif
#ifndef EF_CLOTH_ENV_COLOR
#define EF_CLOTH_ENV_COLOR float3(1.0, 1.0, 1.0)
#endif
#ifndef EF_CLOTH_LUT_USE_BRG
#define EF_CLOTH_LUT_USE_BRG 1
#endif
#ifndef EF_CLOTH_LIGHT_CURVE
#define EF_CLOTH_LIGHT_CURVE 1.0
#endif
#ifndef EF_CLOTH_DARK_STRENGTH
#define EF_CLOTH_DARK_STRENGTH 0.56
#endif
#ifndef EF_CLOTH_LIGHT_STRENGTH
#define EF_CLOTH_LIGHT_STRENGTH 1.12
#endif

#if EF_CLOTH_OUTLINE_ENABLED
#include "internal/endfield_outline.hlsl"
#endif
#include "internal/endfield_global_controls.inc"
#if EF_CLOTH_RAIN_ENABLED
#include "internal/endfield_rain_controls.inc"
#endif
#include "internal/endfield_specular.hlsl"
#if EF_CLOTH_CONTROLLER_ENABLED
#include "internal/endfield_cloth_controls.inc"
#endif

float4x4 EfClothWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 EfClothWorld : WORLD;
#if EF_CLOTH_SCREEN_RIM_ENABLED || EF_CLOTH_MATCAP_ENABLED
float4x4 EfClothView : VIEW;
#endif
#if EF_CLOTH_SCREEN_RIM_ENABLED
float4x4 EfClothProjection : PROJECTION;
#endif
float4 EfClothMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float4 EfClothMaterialEdgeColor : EDGECOLOR;
float3 EfClothMmdLightDirection : DIRECTION < string Object = "Light"; >;
float3 EfClothMmdLightColor : SPECULAR < string Object = "Light"; >;
float3 EfClothCameraPosition : POSITION < string Object = "Camera"; >;
float3 EfClothCameraDirection : DIRECTION < string Object = "Camera"; >;

// Model UV maps may repeat outside 0-1. Override per material for clamp/mirror assets.
// Keep LUT, MatCap and screen-space samplers on their own addressing rules.
#ifndef EF_CLOTH_UV_ADDRESS_MODE
#define EF_CLOTH_UV_ADDRESS_MODE WRAP
#endif

texture2D EfClothMainTexture <
    string ResourceName = EF_CLOTH_MAIN_TEXTURE_RESOURCE;
>;
sampler2D EfClothMainSampler = sampler_state {
    texture = <EfClothMainTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = EF_CLOTH_UV_ADDRESS_MODE;
    AddressV = EF_CLOTH_UV_ADDRESS_MODE;
};

texture2D EfClothNormalTexture <
    string ResourceName = EF_CLOTH_NORMAL_TEXTURE_RESOURCE;
>;
sampler2D EfClothNormalSampler = sampler_state {
    texture = <EfClothNormalTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = EF_CLOTH_UV_ADDRESS_MODE;
    AddressV = EF_CLOTH_UV_ADDRESS_MODE;
};

#if EF_CLOTH_RAIN_ENABLED
texture2D EfClothRainTexture <
    string ResourceName = EF_CLOTH_RAIN_TEXTURE_RESOURCE;
>;
sampler2D EfClothRainSampler = sampler_state {
    texture = <EfClothRainTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = WRAP;
    AddressV = WRAP;
};
#if EF_CLOTH_RAIN_DROP_ENABLED
texture2D EfClothRainDropTexture <
    string ResourceName = EF_CLOTH_RAIN_DROP_TEXTURE_RESOURCE;
>;
sampler2D EfClothRainDropSampler = sampler_state {
    texture = <EfClothRainDropTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = WRAP;
    AddressV = WRAP;
};
texture2D EfClothRainDropPhaseTexture <
    string ResourceName = EF_CLOTH_RAIN_DROP_PHASE_TEXTURE_RESOURCE;
>;
sampler2D EfClothRainDropPhaseSampler = sampler_state {
    texture = <EfClothRainDropPhaseTexture>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = WRAP;
    AddressV = WRAP;
};
#endif
float EfClothRainTime : TIME;
#endif

texture2D EfClothPropertyTexture <
    string ResourceName = EF_CLOTH_PROPERTY_TEXTURE_RESOURCE;
>;
sampler2D EfClothPropertySampler = sampler_state {
    texture = <EfClothPropertyTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 16;
    AddressU = EF_CLOTH_UV_ADDRESS_MODE;
    AddressV = EF_CLOTH_UV_ADDRESS_MODE;
};

texture2D EfClothRdTexture <
    string ResourceName = EF_CLOTH_RD_TEXTURE_RESOURCE;
>;
sampler2D EfClothRdSampler = sampler_state {
    texture = <EfClothRdTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D EfClothLutTexture <
    string ResourceName = EF_CLOTH_LUT_TEXTURE_RESOURCE;
>;
sampler2D EfClothLutSampler = sampler_state {
    texture = <EfClothLutTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D EfClothRsTexture <
    string ResourceName = EF_CLOTH_RS_TEXTURE_RESOURCE;
>;
sampler2D EfClothRsSampler = sampler_state {
    texture = <EfClothRsTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D EfClothEnvTexture <
    string ResourceName = EF_CLOTH_ENV_TEXTURE_RESOURCE;
    int Miplevels = 7;
>;
sampler2D EfClothEnvSampler = sampler_state {
    texture = <EfClothEnvTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = CLAMP;
};

#if EF_CLOTH_MATCAP_ENABLED
texture2D EfClothMatcapTexture <
    string ResourceName = EF_CLOTH_MATCAP_TEXTURE_RESOURCE;
>;
sampler2D EfClothMatcapSampler = sampler_state {
    texture = <EfClothMatcapTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
#if EF_CLOTH_MATCAP_MANUAL_LOD_ENABLED
texture2D EfClothManualMatcapTexture <
    string ResourceName = EF_CLOTH_MATCAP_MANUAL_TEXTURE_RESOURCE;
>;
sampler2D EfClothManualMatcapSampler = sampler_state {
    texture = <EfClothManualMatcapTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
#endif
#endif

#if EF_CLOTH_FGD_LUT_ENABLED
texture2D EfClothFgdTexture <
    string ResourceName = EF_CLOTH_FGD_TEXTURE_RESOURCE;
>;
sampler2D EfClothFgdSampler = sampler_state {
    texture = <EfClothFgdTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
#endif

#if EF_CLOTH_ZMD_SHADOW_ENABLED || EF_CLOTH_SCREEN_RIM_ENABLED
shared texture2D EF_CLOTH_SHADOW_VIEWPORT_MAP : RENDERCOLORTARGET;
sampler2D EfClothZmdShadowSampler = sampler_state {
    texture = <EF_CLOTH_SHADOW_VIEWPORT_MAP>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
bool EfClothZmdShadowValid : CONTROLOBJECT <
    string name = EF_CLOTH_SHADOW_CONTROLLER_NAME;
>;
#endif
#if EF_CLOTH_ZMD_SHADOW_ENABLED || EF_CLOTH_SCREEN_RIM_ENABLED || EF_CLOTH_OUTLINE_ENABLED
float2 EfClothViewportSize : VIEWPORTPIXELSIZE;
#endif
#if EF_CLOTH_ZMD_SHADOW_ENABLED
float EfClothZmdShadowRotation : CONTROLOBJECT <
    string name = EF_CLOTH_SHADOW_CONTROLLER_NAME;
    string item = "Rx";
>;
float EfClothShadowDensityUp : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen+";
>;
float EfClothShadowDensityDown : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen-";
>;
#endif

struct EfClothAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct EfClothVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
#if EF_CLOTH_ZMD_SHADOW_ENABLED
    float4 screenPosition : TEXCOORD3;
    float shadowDensity : TEXCOORD4;
#endif
};

EfClothVaryings EfClothVS(EfClothAttributes input)
{
    EfClothVaryings output = (EfClothVaryings)0;
    output.positionCS = mul(input.positionOS, EfClothWorldViewProjection);
    output.uv = input.texcoord0;
    output.positionWS = mul(input.positionOS, EfClothWorld).xyz;
    output.normalWS = normalize(
        mul(input.normalOS, (float3x3)EfClothWorld));
#if EF_CLOTH_ZMD_SHADOW_ENABLED
    output.screenPosition = output.positionCS;
    output.shadowDensity = max(
        (degrees(EfClothZmdShadowRotation)
            + 5.0 * EfClothShadowDensityUp + 1.0)
            * (1.0 - EfClothShadowDensityDown),
        0.0);
#endif
    return output;
}

float3 EfClothUnpackNormal(float2 packedXY)
{
    float normalStrength = max(EF_CLOTH_NORMAL_STRENGTH, 0.0);
    float normalYSign = 1.0;
#if EF_CLOTH_CONTROLLER_ENABLED
    normalStrength = EfClothControllerNormalStrength(normalStrength);
    normalYSign = EfClothControllerNormalYSign();
#endif
    float2 xy = packedXY * 2.0 - 1.0;
    xy.y *= normalYSign;
    xy *= normalStrength;
    float z = sqrt(1.0 - saturate(dot(xy, xy)));
    return float3(xy, z);
}

bool EfClothReconstructTangentBasis(
    float3 positionWS,
    float3 geometryNormalWS,
    float2 uv,
    out float3 tangentWS,
    out float3 bitangentWS)
{
    tangentWS = float3(1.0, 0.0, 0.0);
    bitangentWS = float3(0.0, 1.0, 0.0);
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    float derivativeScaleSq = max(
        dot(duvdx, duvdx) * dot(duvdy, duvdy),
        1e-20);
    if (abs(determinant) < 1e-12
        || determinant * determinant < derivativeScaleSq * 1e-6) {
        return false;
    }

    float invDeterminant = 1.0 / determinant;
    float3 tangentRaw = (dpdx * duvdy.y - dpdy * duvdx.y)
        * invDeterminant;
    float3 bitangentRaw = (dpdy * duvdx.x - dpdx * duvdy.x)
        * invDeterminant;
    tangentWS = tangentRaw
        - geometryNormalWS * dot(geometryNormalWS, tangentRaw);
    float tangentLengthSq = dot(tangentWS, tangentWS);
    if (tangentLengthSq < 1e-10) {
        return false;
    }
    tangentWS *= rsqrt(tangentLengthSq);
    float handedness = dot(
        cross(geometryNormalWS, tangentWS),
        bitangentRaw) < 0.0 ? -1.0 : 1.0;
    bitangentWS = normalize(cross(geometryNormalWS, tangentWS))
        * handedness;
    return true;
}

float3 EfClothSampleBaseNormalTS(float2 uv)
{
    return EfClothUnpackNormal(
        tex2D(EfClothNormalSampler, uv).rg);
}

#if EF_CLOTH_RAIN_ENABLED
float3 EfClothDecodeNormalRG(float2 packedXY, float strength)
{
    float2 xy = (packedXY * 2.0 - 1.0) * max(strength, 0.0);
    xy.x *= EF_CLOTH_RAIN_NORMAL_X_SIGN;
    xy.y *= EF_CLOTH_RAIN_NORMAL_Y_SIGN;
    float z = sqrt(1.0 - saturate(dot(xy, xy)));
    return normalize(float3(xy, z));
}

float3 EfClothBlendRnm(float3 baseNormalTS, float3 detailNormalTS)
{
    float3 t = baseNormalTS + float3(0.0, 0.0, 1.0);
    float3 u = detailNormalTS * float3(-1.0, -1.0, 1.0);
    return normalize(t * dot(t, u) - u * t.z);
}

float3 EfClothMaskRainNormal(float3 rainNormalTS, float rainMask)
{
    float2 xy = rainNormalTS.xy * saturate(rainMask);
    float z = sqrt(1.0 - saturate(dot(xy, xy)));
    return normalize(float3(xy, z));
}

float4 EfClothSampleRainVerticalProjection(
    float3 positionWS,
    float3 geometryNormalWS,
    float scale,
    float verticalPhase,
    float horizontalOffset)
{
    float3 objectOriginWS = mul(
        float4(0.0, 0.0, 0.0, 1.0),
        EfClothWorld).xyz;
    float3 projectionPosition = (positionWS - objectOriginWS)
        * max(EF_CLOTH_RAIN_WORLD_SCALE, 1e-4);
    float2 rainUvX = projectionPosition.zy * scale;
    float2 rainUvZ = projectionPosition.xy * scale;
    rainUvX.x += horizontalOffset;
    rainUvZ.x += horizontalOffset;

    float2 projectionWeights = pow(
        abs(geometryNormalWS.xz),
        max(EF_CLOTH_RAIN_PROJECTION_SHARPNESS, 1.0));
    float projectionWeightSum = projectionWeights.x + projectionWeights.y;
    if (projectionWeightSum <= 1e-6) {
        return float4(0.5, 0.5, 0.0, 0.0);
    }
    projectionWeights /= projectionWeightSum;

    float4 rainX = tex2D(EfClothRainSampler, rainUvX);
    float4 rainZ = tex2D(EfClothRainSampler, rainUvZ);
    // ZMD reveals stationary drip grooves with a separately animated mask.
    // Reuse this texture's softer A channel for the mask so MME needs no new
    // sampler and the groove itself no longer slides across the garment.
    float2 flowMaskUvX = rainUvX;
    float2 flowMaskUvZ = rainUvZ;
    flowMaskUvX.y += verticalPhase;
    flowMaskUvZ.y += verticalPhase;
    float flowMaskX = sqrt(saturate(
        tex2D(EfClothRainSampler, flowMaskUvX).a));
    float flowMaskZ = sqrt(saturate(
        tex2D(EfClothRainSampler, flowMaskUvZ).a));
    float2 packedNormal = rainX.rg * projectionWeights.x
        + rainZ.rg * projectionWeights.y;
    float animatedMask = rainX.b * flowMaskX * projectionWeights.x
        + rainZ.b * flowMaskZ * projectionWeights.y;
    float staticMask = rainX.b * projectionWeights.x
        + rainZ.b * projectionWeights.y;
    return float4(packedNormal, animatedMask, staticMask);
}

float3 EfClothApplyRainNormal(
    float3 baseNormalTS,
    float3 positionWS,
    float3 geometryNormalWS,
    out float rainCoverage)
{
    rainCoverage = 0.0;
    float rainAmount = EfGlobalRainAmount(EF_CLOTH_RAIN_AMOUNT);
    if (rainAmount <= 0.0) {
        return baseNormalTS;
    }

    float sideMask = saturate((1.0 - abs(geometryNormalWS.y)) * 2.0);
    float rainPhase = EfClothRainTime
        * max(EF_CLOTH_RAIN_FLOW_SPEED, 0.0);
    float4 rainSample0 = EfClothSampleRainVerticalProjection(
        positionWS,
        geometryNormalWS,
        max(EF_CLOTH_RAIN_UV_SCALE, 1e-4),
        rainPhase,
        0.0);
    float rainMask0 = saturate(rainSample0.b * rainAmount * sideMask);
    rainCoverage = rainMask0;
    float3 rainNormal0TS = EfClothDecodeNormalRG(
        rainSample0.rg,
        EF_CLOTH_RAIN_NORMAL_STRENGTH);
    float3 flowNormalTS = EfClothMaskRainNormal(
        rainNormal0TS,
        rainMask0);

#if EF_CLOTH_RAIN_SECONDARY_ENABLED
    float secondaryScale = max(
        EF_CLOTH_RAIN_UV_SCALE + EF_CLOTH_RAIN_SECONDARY_SCALE_OFFSET,
        1e-4);
    float4 rainSample1 = EfClothSampleRainVerticalProjection(
        positionWS,
        geometryNormalWS,
        secondaryScale,
        rainPhase * 1.37,
        0.13);
    float rainMask1 = saturate(
        rainSample1.b
        * rainAmount
        * sideMask
        * max(EF_CLOTH_RAIN_SECONDARY_STRENGTH, 0.0));
    rainCoverage = max(rainCoverage, rainMask1);
    float3 rainNormal1TS = EfClothDecodeNormalRG(
        rainSample1.rg,
        EF_CLOTH_RAIN_NORMAL_STRENGTH);
    rainNormal1TS = EfClothMaskRainNormal(rainNormal1TS, rainMask1);
    flowNormalTS = EfClothBlendRnm(flowNormalTS, rainNormal1TS);
#endif

    return EfClothBlendRnm(baseNormalTS, flowNormalTS);
}

#if EF_CLOTH_RAIN_DROP_ENABLED
float EfClothRainDropSpeed()
{
    return max(EF_CLOTH_RAIN_DROP_SPEED, 0.0);
}

float2 EfClothRainDropEnvelopes(float authoredTiming)
{
    // Work in wrapped phase space so the normal and wet traces share one age
    // calculation. This also keeps the ps_3_0 constant footprint unchanged.
    float dropSpeed = max(EfClothRainDropSpeed(), 1e-4);
    float dropAgePhase = 1.0 - frac(
        authoredTiming - EfClothRainTime * dropSpeed);
    float dropLifetimeSeconds = EfGlobalRainDropLifetime(
        EF_CLOTH_RAIN_DROP_LIFETIME);
    float dropLifetimePhase = max(
        dropLifetimeSeconds * dropSpeed,
        1e-4);
    float normalEnvelope = 1.0 - smoothstep(
        0.0,
        dropLifetimePhase,
        dropAgePhase);
    float wetEnvelope = saturate(
        (dropLifetimePhase + dropLifetimePhase + dropLifetimePhase
            - dropAgePhase)
        / (dropLifetimePhase + dropLifetimePhase));
    return float2(normalEnvelope, wetEnvelope);
}

float3 EfClothSampleRainDropNormal(
    float2 uv,
    float3 geometryNormalWS,
    float rainAmount,
    out float dropCoverage,
    out float wetDropCoverage)
{
    float dropTiling = EfGlobalRainDropTiling(
        EF_CLOTH_RAIN_DROP_TILING);
    float2 dropUv = uv * dropTiling;
    float4 dropSample = tex2D(
        EfClothRainDropSampler,
        dropUv);
    float authoredTiming = tex2D(
        EfClothRainDropPhaseSampler,
        dropUv).r;
    float upwardMask = saturate(
        geometryNormalWS.y + EF_CLOTH_RAIN_DROP_NORMAL_OFFSET);
    upwardMask = saturate(
        (upwardMask - 0.5)
        * max(EF_CLOTH_RAIN_DROP_EDGE_SMOOTHNESS, 0.0)
        + 0.5);
    upwardMask = lerp(
        upwardMask,
        1.0,
        saturate(EF_CLOTH_RAIN_DROP_OMNI_COVERAGE));
    float signedDropMask = dropSample.a * 2.0 - 1.0;
    float positiveDrop = saturate(signedDropMask);
    float negativeDrop = saturate(-signedDropMask);
    float staticDropCoverage = saturate(
        (positiveDrop + negativeDrop)
        * max(EF_CLOTH_RAIN_DROP_INTENSITY, 0.0)
        * upwardMask
        * max(rainAmount, 0.0));
    float2 dropEnvelopes = EfClothRainDropEnvelopes(authoredTiming);
    dropCoverage = saturate(staticDropCoverage * dropEnvelopes.x);
    wetDropCoverage = saturate(staticDropCoverage * dropEnvelopes.y);

    float2 dropXY = (dropSample.rg * 2.0 - 1.0)
        * dropCoverage
        * max(EF_CLOTH_RAIN_DROP_NORMAL_STRENGTH, 0.0);
    dropXY.x *= EF_CLOTH_RAIN_NORMAL_X_SIGN;
    dropXY.y *= EF_CLOTH_RAIN_NORMAL_Y_SIGN;
    float dropZ = sqrt(1.0 - saturate(dot(dropXY, dropXY)));
    return normalize(float3(dropXY, dropZ));
}
#endif
#endif

float3 EfClothTangentToWorld(
    float3 normalTS,
    float3 tangentWS,
    float3 bitangentWS,
    float3 geometryNormalWS)
{
    return normalize(
        normalTS.x * tangentWS
        + normalTS.y * bitangentWS
        + normalTS.z * geometryNormalWS);
}

float EfClothRainAbsorption(float smoothness, float metallic)
{
    float contrastedSmoothness = saturate(
        (smoothness - 0.5) * 1.5 + 0.5);
    return 1.0 - saturate(max(contrastedSmoothness, metallic));
}

float3 EfClothApplyNormalMap(
    float3 positionWS,
    float3 geometryNormalWS,
    float2 uv,
    out float3 tangentWS,
    out float3 bitangentWS,
    out bool tangentBasisValid,
    out float3 specularNormalWS,
    out float rainCoverage,
    out float rainDropCoverage,
    out float persistentWetCoverage)
{
    rainCoverage = 0.0;
    rainDropCoverage = 0.0;
    persistentWetCoverage = 0.0;
    tangentBasisValid = EfClothReconstructTangentBasis(
        positionWS,
        geometryNormalWS,
        uv,
        tangentWS,
        bitangentWS);
    if (!tangentBasisValid) {
        specularNormalWS = geometryNormalWS;
        return geometryNormalWS;
    }
    float3 normalTS = EfClothSampleBaseNormalTS(uv);
    float3 baseNormalWS = EfClothTangentToWorld(
        normalTS,
        tangentWS,
        bitangentWS,
        geometryNormalWS);
    specularNormalWS = baseNormalWS;
#if EF_CLOTH_RAIN_ENABLED
    float3 rainNormalTS = EfClothApplyRainNormal(
        normalTS,
        positionWS,
        geometryNormalWS,
        rainCoverage);
    persistentWetCoverage = rainCoverage;
#if EF_CLOTH_RAIN_DROP_ENABLED
    float rainAmount = EfGlobalRainAmount(EF_CLOTH_RAIN_AMOUNT);
    float rainDropWetCoverage;
    float3 dropNormalTS = EfClothSampleRainDropNormal(
        uv,
        geometryNormalWS,
        rainAmount,
        rainDropCoverage,
        rainDropWetCoverage);
    rainNormalTS = EfClothBlendRnm(rainNormalTS, dropNormalTS);
    float persistentDropCoverage = max(
        rainDropCoverage,
        rainDropWetCoverage);
    persistentWetCoverage = saturate(max(
        persistentWetCoverage,
        persistentDropCoverage));
#endif
    specularNormalWS = EfClothTangentToWorld(
        rainNormalTS,
        tangentWS,
        bitangentWS,
        geometryNormalWS);
#endif
    return baseNormalWS;
}

float3 EfClothSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 EfClothLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

float3 EfClothSampleLut(float3 albedoSrgb)
{
    albedoSrgb = saturate(albedoSrgb);
#if EF_CLOTH_LUT_USE_BRG
    // 32 horizontal slices: B chooses the slice, R/G address its 2D plane.
    albedoSrgb = albedoSrgb.brg;
#endif

    float2 lutUv = albedoSrgb.xz * float2(31.0, 0.96875);
    float lutFloorX = floor(lutUv.x);
    float2 lutUvYZ = albedoSrgb.yz
        * float2(0.0302734375, 0.96875)
        + float2(0.00048828125, 0.015625);
    float2 lutUvFinal = float2(
        lutFloorX * 0.03125 + lutUvYZ.x,
        1.0 - lutUvYZ.y);
    float lutTileLerp = albedoSrgb.x * 31.0 - lutFloorX;
    float3 lutColor0 = tex2D(EfClothLutSampler, lutUvFinal).rgb;
    float3 lutColor1 = tex2D(
        EfClothLutSampler,
        lutUvFinal + float2(0.03125, 0.0)).rgb;
    return lerp(lutColor0, lutColor1, lutTileLerp);
}

float3 EfClothDirectGgx(
    float3 normalWS,
    float3 halfDirWS,
    float3 viewDirWS,
    float roughness,
    float3 f0)
{
    float noH = saturate(dot(normalWS, halfDirWS));
    float noV = saturate(dot(normalWS, viewDirWS));
    float roughness2 = max(roughness * roughness, 0.0078125);
    float a2 = roughness2 * roughness2;
    float denominator = noH * noH * (a2 - 1.0) + 1.0;
    float distribution = a2 / max(
        denominator * denominator,
        1e-5);
    float visibility = 0.5 / max(
        noV * 2.0 + roughness2,
        1e-5);
    float dv = min(
        distribution * visibility,
        max(EF_CLOTH_SPECULAR_MAX, 0.0));
    // The Goo graph and the Zhihu reconstruction both retain a Schlick F
    // term. Omitting it made curved sleeves and grazing metal lose energy.
    float fresnelFactor = pow(1.0 - noV, 5.0);
    float3 fresnel = f0 + (1.0 - f0) * fresnelFactor;
    return dv * fresnel;
}

float3 EfClothPhysicalHalfDirection(
    float3 viewDirWS,
    float3 lightDirWS)
{
    float3 physicalHalfVector = viewDirWS + lightDirWS;
    float physicalHalfLengthSq = dot(
        physicalHalfVector,
        physicalHalfVector);
    float3 physicalHalfDir = physicalHalfLengthSq > 1e-8
        ? physicalHalfVector * rsqrt(physicalHalfLengthSq)
        : viewDirWS;
    return physicalHalfDir;
}

float EfClothSmithJointGgxVisibility(
    float noV,
    float noL,
    float roughness)
{
    noV = max(saturate(noV), 1e-4);
    noL = max(saturate(noL), 1e-4);
    float alpha = max(roughness * roughness, 0.0078125);
    float alpha2 = alpha * alpha;
    float lambdaV = noL * sqrt(max(
        noV * noV * (1.0 - alpha2) + alpha2,
        1e-6));
    float lambdaL = noV * sqrt(max(
        noL * noL * (1.0 - alpha2) + alpha2,
        1e-6));
    return 0.5 / max(lambdaV + lambdaL, 1e-5);
}

float3 EfClothPrimaryDirectGgx(
    float3 normalWS,
    float3 halfDirWS,
    float3 viewDirWS,
    float3 lightDirWS,
    float roughness,
    float3 f0)
{
    float noH = saturate(dot(normalWS, halfDirWS));
    float noV = saturate(dot(normalWS, viewDirWS));
    float noL = saturate(dot(normalWS, lightDirWS));
    float roughness2 = max(roughness * roughness, 0.0078125);
    float a2 = roughness2 * roughness2;
    float denominator = noH * noH * (a2 - 1.0) + 1.0;
    float distribution = a2 / max(
        denominator * denominator,
        1e-5);
    float visibility = EfClothSmithJointGgxVisibility(
        noV,
        noL,
        roughness);
    float dv = min(
        distribution * visibility,
        max(EF_CLOTH_SPECULAR_MAX, 0.0));
    float3 physicalHalfDir = EfClothPhysicalHalfDirection(
        viewDirWS,
        lightDirWS);
    float lDotH = saturate(dot(lightDirWS, physicalHalfDir));
    // H3 keeps the stylized distribution direction but restores the physical
    // Schlick angle so grazing view angles do not behave like a rim light.
    float fresnelFactor = pow(1.0 - lDotH, 5.0);
    float3 fresnel = f0 + (1.0 - f0) * fresnelFactor;
    return dv * fresnel;
}

float EfClothDAnisotropicGgx(
    float tDotH,
    float bDotH,
    float nDotH,
    float roughT,
    float roughB)
{
    const float inversePi = 0.31830988618;
    float roughTB = roughT * roughB;
    float3 distributionVector = float3(
        roughB * tDotH,
        roughT * bDotH,
        roughTB * nDotH);
    float distributionLengthSq = dot(
        distributionVector,
        distributionVector);
    float distributionScale = roughTB
        / max(distributionLengthSq, 1e-6);
    return inversePi * roughTB
        * distributionScale * distributionScale;
}

float EfClothVAnisotropicGgx(
    float tDotV,
    float bDotV,
    float nDotV,
    float tDotL,
    float bDotL,
    float nDotL,
    float roughT,
    float roughB)
{
    float lambdaV = nDotL * length(float3(
        roughT * tDotV,
        roughB * bDotV,
        nDotV));
    float lambdaL = nDotV * length(float3(
        roughT * tDotL,
        roughB * bDotL,
        nDotL));
    return 0.5 / max(lambdaV + lambdaL, 1e-5);
}

float3 EfClothAnisotropicGgx(
    float3 normalWS,
    float3 tangentWS,
    float3 bitangentWS,
    float3 halfDirWS,
    float3 viewDirWS,
    float3 lightDirWS,
    float roughness,
    float3 f0)
{
    float tDotH = dot(tangentWS, halfDirWS);
    float bDotH = dot(bitangentWS, halfDirWS);
    float rawNDotH = dot(normalWS, halfDirWS);
    float nDotH = saturate(rawNDotH);
    float nDotV = saturate(dot(normalWS, viewDirWS)) + 1e-4;
    float rawNDotL = saturate(dot(normalWS, lightDirWS));
    float nDotL = rawNDotL + 1e-4;
    float tDotV = dot(tangentWS, viewDirWS);
    float bDotV = dot(bitangentWS, viewDirWS);
    float tDotL = dot(tangentWS, lightDirWS);
    float bDotL = dot(bitangentWS, lightDirWS);

    float anisotropicRoughnessFloor = EF_CLOTH_ANISO_ROUGHNESS_FLOOR;
    float anisotropy = EF_CLOTH_ANISO_AMOUNT;
    float axis = EF_CLOTH_ANISO_AXIS;
#if EF_CLOTH_CONTROLLER_ENABLED
    anisotropicRoughnessFloor = EfClothControllerAnisoRoughness(
        anisotropicRoughnessFloor);
    anisotropy = EfClothControllerAnisoAmount(anisotropy);
    axis = EfClothControllerAnisoAxis(axis);
#endif
    float baseRoughness = max(
        roughness,
        saturate(anisotropicRoughnessFloor));
    anisotropy = saturate(anisotropy);
    float roughNarrow = max(
        baseRoughness * (1.0 - anisotropy),
        0.02);
    float roughWide = max(
        baseRoughness * (1.0 + anisotropy),
        0.04);
    axis = saturate(axis);
    float roughT = lerp(roughWide, roughNarrow, axis);
    float roughB = lerp(roughNarrow, roughWide, axis);

    float distribution = EfClothDAnisotropicGgx(
        tDotH,
        bDotH,
        nDotH,
        roughT,
        roughB);
    float visibility = EfClothVAnisotropicGgx(
        tDotV,
        bDotV,
        nDotV,
        tDotL,
        bDotL,
        nDotL,
        roughT,
        roughB);
    // N.V Fresnel made this secondary lobe peak at silhouettes. Use the
    // physical V.H Fresnel so it remains a surface highlight instead of rim.
    float vDotH = saturate(dot(viewDirWS, halfDirWS));
    float fresnelFactor = pow(1.0 - vDotH, 5.0);
    float3 fresnel = f0 + (1.0 - f0) * fresnelFactor;
    return min(
        distribution * visibility,
        max(EF_CLOTH_SPECULAR_MAX, 0.0))
        * fresnel
        * rawNDotL
        * step(0.0, rawNDotH);
}

float3 EfClothStylizedHalfDirection(
    float3 viewDirWS,
    float3 lightDirWS)
{
    float3 physicalHalfDir = EfClothPhysicalHalfDirection(
        viewDirWS,
        lightDirWS);
    // MME CameraDirection points into the scene. Negating it gives the same
    // surface-to-camera convention as viewDirWS and keeps the lobe coherent
    // across the whole garment instead of fragmenting on each local normal.
    float cameraDirectionLengthSq = dot(
        EfClothCameraDirection,
        EfClothCameraDirection);
    float3 cameraTowardWS = cameraDirectionLengthSq > 1e-8
        ? -EfClothCameraDirection * rsqrt(cameraDirectionLengthSq)
        : viewDirWS;
    float viewLock = saturate(EF_CLOTH_SPECULAR_VIEW_LOCK);
    float3 stableViewDir = normalize(lerp(
        viewDirWS,
        cameraTowardWS,
        viewLock));
    float3 stylizedHalfVector = stableViewDir * 3.0
        + lightDirWS
        + cameraTowardWS * 2.0;
    float stylizedHalfLengthSq = dot(
        stylizedHalfVector,
        stylizedHalfVector);
    float3 stylizedHalfDir = stylizedHalfLengthSq > 1e-8
        ? stylizedHalfVector * rsqrt(stylizedHalfLengthSq)
        : physicalHalfDir;
    return normalize(lerp(
        physicalHalfDir,
        stylizedHalfDir,
        viewLock));
}

float3 EfClothRefineSpecular(
    float3 f0,
    float metallic,
    float roughness,
    float noH)
{
    float roughness2 = max(roughness * roughness, 0.0078125);
    float denominator = noH * noH * (roughness2 - 1.0) + 1.0;
    float distributionWithoutPi = roughness2
        / max(denominator * denominator, 1e-5);
    float2 rsUv = saturate(float2(
        distributionWithoutPi * (roughness2 + 1e-4),
        (1.0 - metallic) * roughness));
    float3 rsColor = tex2D(EfClothRsSampler, rsUv).rgb;
    float rsStrength = EF_CLOTH_RS_STRENGTH;
#if EF_CLOTH_CONTROLLER_ENABLED
    rsStrength = EfClothControllerRs(rsStrength);
#endif
    return f0 * lerp(
        float3(1.0, 1.0, 1.0),
        saturate(rsColor),
        saturate(rsStrength));
}

float3 EfClothEnvironmentBrdf(
    float roughness,
    float noV,
    float3 f0)
{
    float roughness2 = max(roughness * roughness, 0.0078125);
    float roughness4 = roughness2 * roughness2;
    float roughness6 = roughness4 * roughness2;
    float noV2 = noV * noV;
    float noV3 = noV2 * noV;

    float fitA = 3.32707 * noV + 0.0365463;
    float fitB = -9.04755 * noV + 9.0632;
    float dfgNumerator = fitA + fitB * roughness2;
    float3 noVFactors = float3(
        3.59685 * noV2 - 1.36772 * noV3 + 1.0,
        9.22949 * noV3 - 16.3174 * noV2 + 9.04401,
        -20.2123 * noV3 + 19.7886 * noV2 + 5.56589);
    float dfgDenominator = dot(
        noVFactors,
        float3(1.0, roughness2, roughness6));
    float dfg = dfgNumerator / max(dfgDenominator, 1e-5);

    float scalePart1 = dot(
        float2(-1.28514, 1.0),
        float2(noV, 0.990440011));
    float scalePart2 = dot(
        float2(1.0, -0.75591),
        float2(1.29678, noV));
    float envScale = dot(
        float2(scalePart1, scalePart2),
        float2(1.0, roughness2));
    float biasX = dot(
        float3(2.92338, 59.4188, 1.0),
        float3(noV, noV3, 1.0));
    float biasY = dot(
        float3(1.0, -27.0302, 222.592),
        float3(20.3225, noV, noV3));
    float biasZ = dot(
        float3(626.130, 316.627, 1.0),
        float3(noV, noV3, 121.563004));
    float envBias = envScale / max(
        dot(float3(biasX, biasY, biasZ),
            float3(1.0, roughness2, roughness6)),
        1e-5);

    float3 singleScatter = dfg * f0 + envBias;
    float directionalAlbedo = max(dfg + envBias, 1e-3);
    float energyLoss = max(
        (1.0 - directionalAlbedo) / directionalAlbedo,
        0.0);
    float3 multipleScatter = f0 * energyLoss;
    return max(singleScatter * (1.0 + multipleScatter), 0.0);
}

#if EF_CLOTH_FGD_LUT_ENABLED
float4 EfClothSamplePreIntegratedFgd(
    float roughness,
    float noV,
    float3 f0)
{
    // Unity/Goo LUT contract: X=sqrt(NoV), Y=perceptual roughness. Remap
    // 0..1 into the centers of the 64x64 edge texels before sampling.
    float2 fgdUv = saturate(float2(sqrt(saturate(noV)), roughness));
    fgdUv = fgdUv * (63.0 / 64.0) + (0.5 / 64.0);
    float3 preFgd = tex2D(EfClothFgdSampler, fgdUv).rgb;

    float3 singleScatter = lerp(preFgd.r.xxx, preFgd.g.xxx, saturate(f0));
    float reflectivity = max(preFgd.g, 1e-3);
    float energyLoss = max(1.0 / reflectivity - 1.0, 0.0);
    float3 multipleScatter = f0 * energyLoss;
    float3 specularFgd = max(
        singleScatter * (1.0 + multipleScatter),
        0.0);
    float diffuseFgd = max(preFgd.b + 0.5, 0.0);
    return float4(specularFgd, diffuseFgd);
}
#endif

float2 EfClothEnvironmentUv(float3 reflectionDirWS)
{
    float environmentRotation = EF_CLOTH_ENV_ROTATION;
#if EF_CLOTH_CONTROLLER_ENABLED
    environmentRotation = EfClothControllerEnvRotation(
        environmentRotation);
#endif
    float angle = environmentRotation * 0.0174532925;
    float sineAngle;
    float cosineAngle;
    sincos(angle, sineAngle, cosineAngle);
    float3 rotatedDir = float3(
        reflectionDirWS.x * cosineAngle
            - reflectionDirWS.z * sineAngle,
        reflectionDirWS.y,
        reflectionDirWS.x * sineAngle
            + reflectionDirWS.z * cosineAngle);
    rotatedDir = normalize(rotatedDir);
    const float inversePi = 0.31830988618;
    return float2(
        1.0 - (atan2(rotatedDir.x, rotatedDir.z)
            * inversePi * 0.5 + 0.5),
        acos(clamp(rotatedDir.y, -1.0, 1.0)) * inversePi);
}

float3 EfClothSampleEnvironment(
    float3 reflectionDirWS,
    float roughness)
{
    float2 envUv = EfClothEnvironmentUv(reflectionDirWS);
    float mipLevel = saturate(roughness * roughness)
        * max(EF_CLOTH_ENV_MIP_COUNT - 1.0, 0.0);
    float4 encoded = tex2Dlod(
        EfClothEnvSampler,
        float4(envUv, 0.0, mipLevel));
    float3 environment = encoded.rgb
        * encoded.a
        * max(EF_CLOTH_ENV_RGBM_RANGE, 0.0);
    float luminance = dot(
        environment,
        float3(0.2126, 0.7152, 0.0722));
    return lerp(
        environment,
        luminance.xxx,
        saturate(EF_CLOTH_ENV_DESATURATION));
}

#if EF_CLOTH_MATCAP_ENABLED
float EfClothMatcapLod(float roughness)
{
    float perceptualRoughness = saturate(roughness);
    float mappedRoughness = perceptualRoughness
        * (1.7 - 0.7 * perceptualRoughness);
    float lodScale = EF_CLOTH_MATCAP_LOD_SCALE;
#if EF_CLOTH_CONTROLLER_ENABLED
    lodScale = EfClothControllerMatcapLodScale(lodScale);
#endif
    float computedLod = mappedRoughness
        * max(EF_CLOTH_MATCAP_MANUAL_LOD_COUNT, 0.0)
        * max(lodScale, 0.0)
        + EF_CLOTH_MATCAP_LOD_BIAS;
    return EF_CLOTH_MATCAP_LOD_OVERRIDE >= 0.0
        ? EF_CLOTH_MATCAP_LOD_OVERRIDE
        : computedLod;
}

float2 EfClothManualMatcapUv(float2 matcapUv, float level)
{
    float manualLevel = clamp(
        floor(level),
        0.0,
        EF_CLOTH_MATCAP_MANUAL_LOD_COUNT);
    float mipScale = exp2(-manualLevel);
    float mipPixels = max(EF_CLOTH_MATCAP_SOURCE_SIZE * mipScale, 1.0);
    float halfTexel = 0.5 / mipPixels;
    float2 safeUv = lerp(
        float2(halfTexel, halfTexel),
        float2(1.0 - halfTexel, 1.0 - halfTexel),
        saturate(matcapUv));
    float mipOffsetX = manualLevel < 0.5 ? 0.0 : 1.0;
    float mipOffsetY = manualLevel < 0.5
        ? 0.0
        : 1.0 - 2.0 * mipScale;
    return float2(
        (mipOffsetX + safeUv.x * mipScale) / 1.5,
        mipOffsetY + safeUv.y * mipScale);
}

float3 EfClothSampleMatcap(float3 normalWS, float roughness)
{
    // Goo's PBRToonBase transforms the shaded normal to view space, remaps
    // XY to 0..1, then reads Eff_MatCap_019 as an sRGB reflection source.
    float3 normalVS = normalize(
        mul(normalWS, (float3x3)EfClothView) + 1e-6);
    float2 matcapUv = normalVS.xy * float2(0.5, -0.5) + 0.5;
#if EF_CLOTH_MATCAP_MANUAL_LOD_ENABLED
    float clampedLod = clamp(
        EfClothMatcapLod(roughness),
        0.0,
        EF_CLOTH_MATCAP_MANUAL_LOD_COUNT);
    float lowerLevel = floor(clampedLod);
    float upperLevel = min(
        lowerLevel + 1.0,
        EF_CLOTH_MATCAP_MANUAL_LOD_COUNT);
    float levelBlend = frac(clampedLod);
    float3 lower = EfClothSrgbToLinear(tex2Dlod(
        EfClothManualMatcapSampler,
        float4(EfClothManualMatcapUv(
            matcapUv, lowerLevel), 0.0, 0.0)).rgb);
    float3 upper = EfClothSrgbToLinear(tex2Dlod(
        EfClothManualMatcapSampler,
        float4(EfClothManualMatcapUv(
            matcapUv, upperLevel), 0.0, 0.0)).rgb);
    return lerp(lower, upper, levelBlend);
#else
    return EfClothSrgbToLinear(
        tex2D(EfClothMatcapSampler, saturate(matcapUv)).rgb);
#endif
}
#endif

#if EF_CLOTH_ZMD_SHADOW_ENABLED
float EfClothSampleZmdShadow(
    float4 screenPosition,
    float shadowDensity)
{
    if (!EfClothZmdShadowValid || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }

    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 screenUv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    screenUv += 0.5 / max(EfClothViewportSize, 1.0);
    float shadowAmount = saturate(
        tex2D(EfClothZmdShadowSampler, screenUv).r);
    float visibility = 1.0 - shadowAmount;

    return 1.0 - (1.0 - visibility)
        * min(max(shadowDensity, 0.0), 1.0);
}

float EfClothComputeZmdShadowEffect(
    float4 screenPosition,
    float shadowDensity)
{
    float visibility = EfClothSampleZmdShadow(
        screenPosition,
        shadowDensity);
    float shadowCenter = EF_CLOTH_SHADOW_CENTER;
    float shadowSoftness = EF_CLOTH_SHADOW_SMOOTHNESS;
    float shadowControl = 1.0;
#if EF_CLOTH_CONTROLLER_ENABLED
    shadowCenter = EfClothControllerShadowCenter(shadowCenter);
    shadowSoftness = EfClothControllerShadowSoftness(shadowSoftness);
    shadowControl = EfClothControllerShadowStrength(shadowControl);
#endif
    float shadowT = (visibility - shadowCenter)
        / max(shadowSoftness, 1e-6);
    float shadowScene = 1.0 / (1.0 + exp(-shadowT));
    float baseVisibility = saturate(
        (shadowScene + EF_CLOTH_SHADOW_OFFSET)
            * EF_CLOTH_SHADOW_STRENGTH);
    return 1.0 - saturate(
        (1.0 - baseVisibility) * shadowControl);
}
#endif

float4 EfClothPS(
    EfClothVaryings input,
    float facing : VFACE,
    uniform bool useTexture) : COLOR0
{
    float3 color = saturate(EfClothMaterialDiffuse.rgb);
    if (useTexture) {
        color = tex2D(EfClothMainSampler, input.uv).rgb;
    }

    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float normalLengthSq = dot(input.normalWS, input.normalWS);
    float3 geometryNormalWS = normalLengthSq > 1e-8
        ? input.normalWS * rsqrt(normalLengthSq) * faceSign
        : float3(0.0, 1.0, 0.0);
    float3 tangentWS;
    float3 bitangentWS;
    bool tangentBasisValid;
    float3 specularNormalWS;
    float rainCoverage;
    float rainDropCoverage;
    float persistentWetCoverage;
    float3 normalWS = EfClothApplyNormalMap(
        input.positionWS,
        geometryNormalWS,
        input.uv,
        tangentWS,
        bitangentWS,
        tangentBasisValid,
        specularNormalWS,
        rainCoverage,
        rainDropCoverage,
        persistentWetCoverage);
#if EF_CLOTH_RAIN_ENABLED && EF_CLOTH_RAIN_CHANNEL_DEBUG > 0
    float4 rainChannelProbe = EfClothSampleRainVerticalProjection(
        input.positionWS,
        geometryNormalWS,
        max(EF_CLOTH_RAIN_UV_SCALE, 1e-4),
        0.0,
        0.0);
    float rainChannelValue = 0.0;
#if EF_CLOTH_RAIN_CHANNEL_DEBUG == 1
    rainChannelValue = rainChannelProbe.r;
#elif EF_CLOTH_RAIN_CHANNEL_DEBUG == 2
    rainChannelValue = rainChannelProbe.g;
#elif EF_CLOTH_RAIN_CHANNEL_DEBUG == 3
    rainChannelValue = rainChannelProbe.b;
#elif EF_CLOTH_RAIN_CHANNEL_DEBUG == 4
    rainChannelValue = rainChannelProbe.a;
#elif EF_CLOTH_RAIN_CHANNEL_DEBUG == 5
    float dropTiling = EfGlobalRainDropTiling(
        EF_CLOTH_RAIN_DROP_TILING);
    float2 dropUv = input.uv * dropTiling;
    float4 rainDropSample = tex2D(
        EfClothRainDropSampler,
        dropUv);
    float authoredTiming = tex2D(
        EfClothRainDropPhaseSampler,
        dropUv).r;
    float signedDropMask = rainDropSample.a * 2.0 - 1.0;
    float positiveDrop = saturate(signedDropMask);
    float negativeDrop = saturate(-signedDropMask);
    float dropEnvelope = EfClothRainDropEnvelopes(authoredTiming).x;
    float upwardMask = saturate(
        geometryNormalWS.y + EF_CLOTH_RAIN_DROP_NORMAL_OFFSET);
    upwardMask = saturate(
        (upwardMask - 0.5)
        * max(EF_CLOTH_RAIN_DROP_EDGE_SMOOTHNESS, 0.0)
        + 0.5);
    upwardMask = lerp(
        upwardMask,
        1.0,
        saturate(EF_CLOTH_RAIN_DROP_OMNI_COVERAGE));
    rainChannelValue = saturate(
        (positiveDrop + negativeDrop)
        * dropEnvelope
        * max(EF_CLOTH_RAIN_DROP_INTENSITY, 0.0)
        * upwardMask);
#endif
    return float4(rainChannelValue.xxx, 1.0);
#endif
    float3 lightWS = EfMmdSurfaceToLightWS(
        EfClothMmdLightDirection,
        normalWS);
    float lightCurve = EF_CLOTH_LIGHT_CURVE;
    float rdColorStrength = EF_CLOTH_RD_COLOR_STRENGTH;
    float lutStrength = EF_CLOTH_LUT_STRENGTH;
    float darkStrength = EF_CLOTH_DARK_STRENGTH;
    float lightStrength = EF_CLOTH_LIGHT_STRENGTH;
    float aoDarkStrength = EF_CLOTH_AO_DARK_STRENGTH;
    float aoLightStrength = EF_CLOTH_AO_LIGHT_STRENGTH;
    float metallicStrength = EF_CLOTH_METALLIC_STRENGTH;
    float roughnessStrength = EF_CLOTH_ROUGHNESS_STRENGTH;
    float reflectivityStrength = EF_CLOTH_REFLECTIVITY_STRENGTH;
#if EF_CLOTH_CONTROLLER_ENABLED
    lightCurve = EfClothControllerRampCurve(lightCurve);
    rdColorStrength = EfClothControllerRdColor(rdColorStrength);
    lutStrength = EfClothControllerLut(lutStrength);
    darkStrength = EfClothControllerDark(darkStrength);
    lightStrength = EfClothControllerLight(lightStrength);
    aoDarkStrength = EfClothControllerAoDark(aoDarkStrength);
    aoLightStrength = EfClothControllerAoLight(aoLightStrength);
    metallicStrength = EfClothControllerMetallic(metallicStrength);
    roughnessStrength = EfClothControllerRoughness(roughnessStrength);
    reflectivityStrength = EfClothControllerReflectivity(
        reflectivityStrength);
#endif
    float halfLambert = saturate(dot(normalWS, lightWS) * 0.5 + 0.5);
    halfLambert = pow(
        halfLambert,
        max(lightCurve, 1e-4));
    float4 rd = tex2D(EfClothRdSampler, float2(halfLambert, 0.5));
    float3 rdTintSrgb = lerp(
        float3(1.0, 1.0, 1.0),
        saturate(rd.rgb),
        saturate(rdColorStrength));
    float diffuseWeight = saturate(rd.a);
    // Endfield property map contract: R metallic, G reflectivity,
    // B ambient occlusion, A smoothness.
    float4 property = saturate(
        tex2D(EfClothPropertySampler, input.uv));
    float metallic = saturate(
        property.r * max(metallicStrength, 0.0));
    float reflectivity = saturate(
        property.g * max(reflectivityStrength, 0.0));
    float propertyAo = property.b;
    float roughness = saturate(
        (1.0 - property.a) * max(roughnessStrength, 0.0));
    roughness = max(roughness, 0.04);
    float rainAbsorption = EfClothRainAbsorption(
        property.a,
        metallic);
    float rainBeadRetention = 1.0 - rainAbsorption;
    float rainMaterialResponseStrength = saturate(
        EF_CLOTH_RAIN_MATERIAL_RESPONSE_STRENGTH);
    float absorbedWetResponse = lerp(
        1.0,
        rainAbsorption,
        rainMaterialResponseStrength);
    float surfaceWaterResponse = lerp(
        1.0,
        rainBeadRetention,
        rainMaterialResponseStrength);
    specularNormalWS = normalize(lerp(
        normalWS,
        specularNormalWS,
        surfaceWaterResponse));
    rainCoverage *= surfaceWaterResponse;
    rainDropCoverage *= surfaceWaterResponse;
    // Animated normals disappear with their envelope, while the material keeps
    // a softer persistent wet trace. Already-smooth materials are never made
    // rougher by the wet target value.
    float wetMask = saturate(
        persistentWetCoverage * absorbedWetResponse);
    float surfaceWaterMask = saturate(
        persistentWetCoverage * surfaceWaterResponse);
    float wetTargetRoughness = max(
        EF_CLOTH_WET_TARGET_ROUGHNESS,
        0.04);
    roughness = lerp(
        roughness,
        min(roughness, wetTargetRoughness),
        wetMask);
#if EF_CLOTH_RAIN_ENABLED
    float3 dryColorLinear = EfClothSrgbToLinear(color);
    float wetColorLuminance = dot(
        dryColorLinear,
        float3(0.2126, 0.7152, 0.0722));
    float3 saturatedWetColor = lerp(
        wetColorLuminance.xxx,
        dryColorLinear,
        1.0 + max(EF_CLOTH_RAIN_SATURATION_BOOST, 0.0));
    saturatedWetColor *= 1.0 - saturate(
        EF_CLOTH_RAIN_ALBEDO_DARKEN);
    float3 wetColorLinear = lerp(
        dryColorLinear,
        max(saturatedWetColor, 0.0),
        wetMask);
    color = saturate(EfClothLinearToSrgb(wetColorLinear));
#endif
    float dielectricMask = saturate(1.0 - metallic);
    float roughDielectricMask = smoothstep(
        EF_CLOTH_LAYER_ROUGH_START,
        max(EF_CLOTH_LAYER_ROUGH_END,
            EF_CLOTH_LAYER_ROUGH_START + 1e-4),
        roughness) * dielectricMask;
    float smoothDielectricMask = smoothstep(
        EF_CLOTH_LAYER_SMOOTH_START,
        max(EF_CLOTH_LAYER_SMOOTH_END,
            EF_CLOTH_LAYER_SMOOTH_START + 1e-4),
        property.a) * dielectricMask;
    float microNormalDetail = saturate(
        (1.0 - saturate(dot(normalWS, geometryNormalWS)))
        * max(EF_CLOTH_LAYER_NORMAL_DETAIL_SCALE, 0.0));
#if EF_CLOTH_MATERIAL_CLASS_DEBUG
    float materialMetalMask = metallic;
    float materialDielectricMask = saturate(1.0 - materialMetalMask);
    float materialSmoothMask = smoothstep(
        EF_CLOTH_MATERIAL_CLASS_SMOOTH_START,
        max(EF_CLOTH_MATERIAL_CLASS_SMOOTH_END,
            EF_CLOTH_MATERIAL_CLASS_SMOOTH_START + 1e-4),
        property.a) * materialDielectricMask;
    float materialFabricMask = (1.0 - materialSmoothMask)
        * materialDielectricMask;
    return float4(
        saturate(materialMetalMask),
        saturate(materialSmoothMask),
        saturate(materialFabricMask),
        1.0);
#endif
#if EF_CLOTH_AO_DEBUG
    // Unmistakable probe: blue/cyan = open, yellow/red = occluded.
    float occlusionDebug = saturate((1.0 - propertyAo) * 4.0);
    float3 aoDebugColor = lerp(
        float3(0.0, 0.35, 1.0),
        float3(1.0, 0.05, 0.0),
        occlusionDebug);
    aoDebugColor.g += 0.65 * (1.0 - abs(occlusionDebug * 2.0 - 1.0));
    return float4(saturate(aoDebugColor), 1.0);
#endif
    // Dark AO selects more of the RD/LUT shadow branch. Light AO separately
    // controls residual attenuation on the lit branch for the future runtime
    // controller; its baked default is zero to preserve the accepted result.
    float darkAo = lerp(
        1.0,
        propertyAo,
        saturate(aoDarkStrength));
    float diffuseWeightWithAo = min(diffuseWeight, darkAo);
    float lightAo = lerp(
        1.0,
        propertyAo,
        saturate(aoLightStrength));
    float sceneShadowVisibility = 1.0;
#if EF_CLOTH_ZMD_SHADOW_ENABLED
    sceneShadowVisibility = EfClothComputeZmdShadowEffect(
        input.screenPosition,
        input.shadowDensity);
    diffuseWeightWithAo = min(
        diffuseWeightWithAo,
        sceneShadowVisibility);
#if EF_CLOTH_SHADOW_DEBUG
    return float4(sceneShadowVisibility.xxx, 1.0);
#endif
#endif
    float branchLightAo = lerp(
        1.0,
        lightAo,
        diffuseWeightWithAo);
    float3 lutDarkSrgb = lerp(
        color,
        EfClothSampleLut(color),
        saturate(lutStrength));
    float3 diffuseAlbedoSrgb = lerp(
        lutDarkSrgb,
        color,
        diffuseWeightWithAo);
    float lightValue = lerp(
        max(darkStrength, 0.0),
        max(lightStrength, 0.0),
        diffuseWeightWithAo);
    float3 litColor = EfClothSrgbToLinear(diffuseAlbedoSrgb)
        * EfClothSrgbToLinear(rdTintSrgb)
        * lightValue
        * branchLightAo
        * (1.0 - metallic);

    float3 viewVectorWS = EfClothCameraPosition - input.positionWS;
    float viewLengthSq = dot(viewVectorWS, viewVectorWS);
    float3 viewDirWS = viewLengthSq > 1e-8
        ? viewVectorWS * rsqrt(viewLengthSq)
        : normalWS;
    float noV = saturate(dot(normalWS, viewDirWS));
    float specularNoV = saturate(dot(specularNormalWS, viewDirWS));
    float3 physicalHalfDirWS = EfClothPhysicalHalfDirection(
        viewDirWS,
        lightWS);
    float3 halfDirWS = EfClothStylizedHalfDirection(
        viewDirWS,
        lightWS);
    // Gate stylized highlight energy with the geometric light side. Normal-map
    // detail may shape the lobe, but it must not turn a geometric back face
    // into a fully lit highlight.
    float noL = saturate(dot(geometryNormalWS, lightWS));
    float noH = saturate(dot(specularNormalWS, halfDirWS));
    float3 albedoLinear = EfClothSrgbToLinear(color);
    float dielectricF0 = max(EF_CLOTH_DIELECTRIC_F0, 0.0)
        * reflectivity;
    float3 f0 = dielectricF0.xxx
        + metallic * (albedoLinear - dielectricF0.xxx);
    f0 = EfClothRefineSpecular(
        saturate(f0),
        metallic,
        roughness,
        noH);
    float fgdStrength = 1.0;
#if EF_CLOTH_FGD_LUT_ENABLED && EF_CLOTH_CONTROLLER_ENABLED
    fgdStrength = EfClothControllerFgdStrength();
#endif
#if EF_CLOTH_FGD_LUT_ENABLED
    float4 preIntegratedFgd = EfClothSamplePreIntegratedFgd(
        roughness,
        noV,
        f0);
    float fgdBlend = saturate(fgdStrength * EF_CLOTH_FGD_STRENGTH);
    litColor *= lerp(1.0, preIntegratedFgd.a, fgdBlend);
#endif
    // Endfield's stylized silver parts keep the authored metal response but
    // drive the highlight core toward neutral white. Using the fully colored
    // metallic F0 here made gray hardware inherit beige/brown albedo and RS
    // hues even with a monochrome environment map.
    // Use the strongest authored channel when neutralizing metal. Luminance
    // produced a clean hue but also discarded too much of the highlight.
    float neutralMetalF0Value = max(f0.r, max(f0.g, f0.b));
    float3 neutralMetalF0 = neutralMetalF0Value.xxx;
    float3 directMetalF0 = lerp(
        neutralMetalF0,
        f0,
        saturate(EF_CLOTH_DIRECT_METAL_TINT_STRENGTH));
    float3 directF0 = lerp(f0, directMetalF0, metallic);
    float3 directSpecular = EfClothPrimaryDirectGgx(
        specularNormalWS,
        physicalHalfDirWS,
        viewDirWS,
        lightWS,
        roughness,
        directF0);
    // The reference keeps a broad specular response even before the surface
    // fully faces the light. Raw NoL made MMD highlights vanish too abruptly.
    float specularLightWeight = lerp(
        saturate(EF_CLOTH_SPECULAR_LIGHT_FLOOR),
        1.0,
        noL);
    float specularAo = propertyAo * 0.5 + 0.5;
    float3 specularLightColor = max(EfClothMmdLightColor, 0.0)
        * specularLightWeight
        * specularAo;
    float directShadowFloor = EF_CLOTH_DIRECT_SHADOW_FLOOR;
    float directSpecularStrength = EF_CLOTH_SPECULAR_STRENGTH;
    float broadSpecularStrength = EF_CLOTH_BROAD_SPECULAR_STRENGTH;
    float anisotropicSpecularStrength = EF_CLOTH_ANISO_SPECULAR_STRENGTH;
#if EF_CLOTH_CONTROLLER_ENABLED
    directShadowFloor = EfClothControllerDirectShadowFloor(
        directShadowFloor);
    directSpecularStrength = EfClothControllerSpecular(
        directSpecularStrength);
    broadSpecularStrength = EfClothControllerBroadSpecular(
        broadSpecularStrength);
    anisotropicSpecularStrength = EfClothControllerAnisoSpecular(
        anisotropicSpecularStrength);
#endif
    float directShadowWeight = lerp(
        saturate(directShadowFloor),
        1.0,
        sceneShadowVisibility);
    specularLightColor *= directShadowWeight;
    directSpecular *= specularLightColor
        * max(directSpecularStrength, 0.0);
#if EF_CLOTH_PRIMARY_SPECULAR_THRESHOLD_DEBUG
    float directSpecularDebugValue = max(
        directSpecular.r,
        max(directSpecular.g, directSpecular.b));
    float directSpecularDebugMask = step(
        max(EF_CLOTH_PRIMARY_SPECULAR_DEBUG_THRESHOLD, 0.0),
        directSpecularDebugValue);
    return float4(directSpecularDebugMask.xxx, 1.0);
#endif

    // The reference separates the sharp GGX core from a wider reflection
    // band. Use a mostly geometric normal for this second lobe so normal-map
    // detail does not break the band into small highlights. Reject metallic
    // pixels aggressively so the accepted white metal core stays unchanged.
    float3 broadNormalWS = normalize(lerp(
        normalWS,
        geometryNormalWS,
        saturate(EF_CLOTH_BROAD_SPECULAR_NORMAL_SMOOTHING)));
    float broadRoughness = max(
        roughness,
        saturate(EF_CLOTH_BROAD_SPECULAR_ROUGHNESS));
    float broadDielectricF0 = max(EF_CLOTH_DIELECTRIC_F0, 0.0)
        * lerp(0.55, 1.0, reflectivity);
    float3 broadF0 = lerp(
        broadDielectricF0.xxx,
        albedoLinear,
        saturate(EF_CLOTH_BROAD_SPECULAR_TINT_STRENGTH));
    float3 broadSpecular = EfClothDirectGgx(
        broadNormalWS,
        halfDirWS,
        viewDirWS,
        broadRoughness,
        broadF0);
    float broadNonMetalMask = pow(
        saturate(1.0 - metallic),
        max(EF_CLOTH_BROAD_SPECULAR_METALLIC_REJECTION, 1e-4));
    float broadSmoothnessWeight = lerp(0.50, 1.0, property.a);
#if EF_CLOTH_LAYERED_DIELECTRIC_ENABLED
    // Very rough cloth still reflects a visible amount of light; roughness
    // should widen its lobe, not also remove half of its energy a second time.
    broadSmoothnessWeight = lerp(
        saturate(EF_CLOTH_LAYER_BROAD_ROUGH_ENERGY_FLOOR),
        1.0,
        property.a);
#endif
    float broadMaterialMask = broadNonMetalMask
        * lerp(0.35, 1.0, reflectivity)
        * broadSmoothnessWeight;
#if EF_CLOTH_LAYERED_DIELECTRIC_ENABLED
    // A rough dielectric is not "no specular": cloth and rough leather keep a
    // wide lobe whose intensity follows both authored roughness and micro-normal
    // structure. This is continuous, so no semantic material ID is required.
    float roughSurfaceResponse = roughDielectricMask
        * lerp(0.45, 1.0, microNormalDetail);
    broadMaterialMask *= lerp(0.80, 1.45, roughSurfaceResponse);
#endif
    broadSpecular *= specularLightColor
        * broadMaterialMask
        * max(broadSpecularStrength, 0.0);
#if EF_CLOTH_BROAD_SPECULAR_GRAYSCALE_DEBUG
    float broadSpecularGray = dot(
        broadSpecular,
        float3(0.2126, 0.7152, 0.0722));
    broadSpecularGray = 1.0 - exp2(
        -max(broadSpecularGray, 0.0)
        * max(EF_CLOTH_BROAD_SPECULAR_DEBUG_EXPOSURE, 0.0));
    return float4(saturate(broadSpecularGray).xxx, 1.0);
#endif
#if EF_CLOTH_BROAD_SPECULAR_THRESHOLD_DEBUG
    float broadSpecularDebugValue = dot(
        broadSpecular,
        float3(0.2126, 0.7152, 0.0722));
    float broadSpecularDebugMask = step(
        max(EF_CLOTH_BROAD_SPECULAR_DEBUG_THRESHOLD, 0.0),
        broadSpecularDebugValue);
    return float4(broadSpecularDebugMask.xxx, 1.0);
#endif

    // An elongated GGX lobe adds the directional streak visible on selected
    // cloth in the reference. The UV-derived bitangent is the default long
    // axis; EF_CLOTH_ANISO_AXIS can swap it without changing the mesh.
    float3 anisotropicNormalWS = normalize(lerp(
        normalWS,
        geometryNormalWS,
        saturate(EF_CLOTH_ANISO_NORMAL_SMOOTHING)));
    float3 anisotropicTangentWS = tangentWS
        - anisotropicNormalWS * dot(anisotropicNormalWS, tangentWS);
    float anisotropicTangentLengthSq = dot(
        anisotropicTangentWS,
        anisotropicTangentWS);
    float tangentValidity = tangentBasisValid
        && anisotropicTangentLengthSq > 1e-8 ? 1.0 : 0.0;
    anisotropicTangentWS = tangentValidity > 0.5
        ? anisotropicTangentWS * rsqrt(anisotropicTangentLengthSq)
        : float3(1.0, 0.0, 0.0);
    float tangentHandedness = dot(
        cross(geometryNormalWS, tangentWS),
        bitangentWS) < 0.0 ? -1.0 : 1.0;
    float3 anisotropicBitangentWS = normalize(
        cross(anisotropicNormalWS, anisotropicTangentWS))
        * tangentHandedness;
    float anisotropicDielectricF0 = max(EF_CLOTH_DIELECTRIC_F0, 0.0)
        * lerp(0.55, 1.0, reflectivity);
    float3 anisotropicF0 = lerp(
        anisotropicDielectricF0.xxx,
        albedoLinear,
        saturate(EF_CLOTH_ANISO_TINT_STRENGTH));
    float3 anisotropicSpecular = EfClothAnisotropicGgx(
        anisotropicNormalWS,
        anisotropicTangentWS,
        anisotropicBitangentWS,
        halfDirWS,
        viewDirWS,
        lightWS,
        roughness,
        anisotropicF0);
    float anisotropicNonMetalMask = pow(
        saturate(1.0 - metallic),
        max(EF_CLOTH_ANISO_METALLIC_REJECTION, 1e-4));
    float anisotropicNoV = saturate(dot(
        anisotropicNormalWS,
        viewDirWS));
    float anisotropicFacingMask = smoothstep(
        EF_CLOTH_ANISO_FACING_START,
        max(EF_CLOTH_ANISO_FACING_END,
            EF_CLOTH_ANISO_FACING_START + 1e-4),
        anisotropicNoV);
    float anisotropicMaterialMask = tangentValidity
        * anisotropicNonMetalMask
        * anisotropicFacingMask
        * lerp(0.25, 1.0, reflectivity);
#if EF_CLOTH_LAYERED_DIELECTRIC_ENABLED
    float fiberResponse = roughDielectricMask
        * lerp(0.40, 1.0, microNormalDetail);
    anisotropicMaterialMask *= lerp(0.45, 1.20, fiberResponse);
#else
    anisotropicMaterialMask *= lerp(0.35, 1.0, property.a);
#endif
    anisotropicSpecular *= specularLightColor
        * anisotropicMaterialMask
        * max(anisotropicSpecularStrength, 0.0);
#if EF_CLOTH_ANISO_THRESHOLD_DEBUG
    float anisotropicDebugValue = max(
        anisotropicSpecular.r,
        max(anisotropicSpecular.g, anisotropicSpecular.b));
    float anisotropicDebugMask = step(
        max(EF_CLOTH_ANISO_DEBUG_THRESHOLD, 0.0),
        anisotropicDebugValue);
    return float4(anisotropicDebugMask.xxx, 1.0);
#endif
    float3 dielectricCoatSpecular = float3(0.0, 0.0, 0.0);
#if EF_CLOTH_LAYERED_DIELECTRIC_ENABLED
    // The authored map does not consistently label every leather item as high
    // smoothness. Keep a weak coat floor on rough dielectrics, then strengthen
    // and tighten it continuously as P.a rises. This preserves boot highlights
    // without turning coarse fabric into a binary "leather" class.
    float coatPresence = dielectricMask
        * lerp(
            saturate(EF_CLOTH_LAYER_COAT_FLOOR),
            1.0,
            smoothDielectricMask);
    float coatRoughness = lerp(
        EF_CLOTH_LAYER_COAT_ROUGHNESS_ROUGH,
        EF_CLOTH_LAYER_COAT_ROUGHNESS_SMOOTH,
        smoothDielectricMask);
    float coatF0 = max(EF_CLOTH_DIELECTRIC_F0, 0.0)
        * lerp(0.65, 1.0, reflectivity);
    dielectricCoatSpecular = EfClothPrimaryDirectGgx(
        normalWS,
        physicalHalfDirWS,
        viewDirWS,
        lightWS,
        coatRoughness,
        coatF0.xxx);
    dielectricCoatSpecular *= specularLightColor
        * coatPresence
        * max(EF_CLOTH_LAYER_COAT_STRENGTH, 0.0);
#endif
    float3 rainCoatSpecular = float3(0.0, 0.0, 0.0);
#if EF_CLOTH_RAIN_ENABLED && EF_CLOTH_RAIN_COAT_ENABLED
    float rainCoatRoughness = saturate(EF_CLOTH_RAIN_COAT_ROUGHNESS);
    float rainCoatF0 = max(EF_CLOTH_RAIN_COAT_F0, 0.0);
    rainCoatSpecular = EfClothPrimaryDirectGgx(
        specularNormalWS,
        physicalHalfDirWS,
        viewDirWS,
        lightWS,
        rainCoatRoughness,
        rainCoatF0.xxx);
    float rainCoatNoL = saturate(dot(specularNormalWS, lightWS));
    float3 rainCoatLightColor = max(EfClothMmdLightColor, 0.0)
        * rainCoatNoL
        * specularAo
        * directShadowWeight;
    float rainCoatMetalWeight = lerp(1.0, 0.25, metallic);
    rainCoatSpecular *= rainCoatLightColor
        * surfaceWaterMask
        * rainCoatMetalWeight
        * max(EF_CLOTH_RAIN_COAT_STRENGTH, 0.0);
#endif
    float3 combinedDirectSpecular = directSpecular
        + broadSpecular
        + anisotropicSpecular
        + dielectricCoatSpecular
        + rainCoatSpecular;
#if EF_CLOTH_RAIN_ENABLED && EF_CLOTH_RAIN_DROP_ENABLED
    float neutralDirectSpecular = dot(
        combinedDirectSpecular,
        float3(0.2126, 0.7152, 0.0722));
    combinedDirectSpecular = lerp(
        combinedDirectSpecular,
        neutralDirectSpecular.xxx,
        saturate(rainDropCoverage));
#endif
    litColor += combinedDirectSpecular;

    float3 reflectionDirWS = reflect(-viewDirWS, specularNormalWS);
    float3 hdrEnvironmentLd = EfClothSampleEnvironment(
        reflectionDirWS,
        roughness) * max(EF_CLOTH_HDR_RELATIVE_STRENGTH, 0.0);
#if EF_CLOTH_MATCAP_ENABLED
    // EnvMode 0 preserves the accepted Goo MatCap appearance; 1 selects HDR.
    // Intermediate MMD morph values blend continuously between both sources.
    float environmentMode = 0.0;
#if EF_CLOTH_CONTROLLER_ENABLED
    environmentMode = EfClothControllerEnvMode();
#endif
    float3 matcapEnvironmentLd = EfClothSampleMatcap(
        specularNormalWS,
        roughness);
    float3 environmentLd = lerp(
        matcapEnvironmentLd,
        hdrEnvironmentLd,
        environmentMode);
#else
    float3 environmentLd = hdrEnvironmentLd;
#endif
    // Keep the environment lobe mostly neutral. Direct GGX retains the full
    // authored metal F0, while broad IBL only inherits a controlled fraction
    // so brown base color does not turn the whole material yellow/brassy.
    float environmentF0Luminance = dot(
        f0,
        float3(0.2126, 0.7152, 0.0722));
    float3 environmentF0 = lerp(
        environmentF0Luminance.xxx,
        f0,
        saturate(EF_CLOTH_ENV_METAL_TINT_STRENGTH));
    float3 environmentDfg = EfClothEnvironmentBrdf(
        roughness,
        specularNoV,
        environmentF0);
#if EF_CLOTH_FGD_LUT_ENABLED
    float4 environmentFgd = EfClothSamplePreIntegratedFgd(
        roughness,
        specularNoV,
        environmentF0);
    environmentDfg = lerp(
        environmentDfg,
        environmentFgd.rgb,
        saturate(fgdStrength * EF_CLOTH_FGD_STRENGTH));
#endif
    float environmentAoStrength = EF_CLOTH_ENV_AO_STRENGTH;
    float environmentStrength = EF_CLOTH_ENV_STRENGTH;
    float environmentShadowStrength = EF_CLOTH_ENV_SHADOW_STRENGTH;
    float3 environmentColor = EF_CLOTH_ENV_COLOR;
#if EF_CLOTH_CONTROLLER_ENABLED
    environmentAoStrength = EfClothControllerEnvAo(
        environmentAoStrength);
    environmentStrength = EfClothControllerEnvSpecular(
        environmentStrength);
    environmentShadowStrength = EfClothControllerEnvShadow(
        environmentShadowStrength);
    environmentColor = EfClothControllerEnvColor(environmentColor);
#endif
    float specularOcclusion = lerp(
        1.0,
        propertyAo,
        saturate(environmentAoStrength));
    // Use the same geometric light-side gate as direct GGX. This prevents the
    // environment lobe from reading as a second key light on the back side.
    float indirectLightWeight = saturate(specularLightWeight);
    float3 indirectSpecular = environmentLd
        * environmentDfg
        * max(environmentColor, 0.0)
        * specularOcclusion
        * indirectLightWeight
        * lerp(
            1.0,
            sceneShadowVisibility,
            saturate(environmentShadowStrength))
        * max(environmentStrength, 0.0);
    float3 rainCoatIndirectSpecular = float3(0.0, 0.0, 0.0);
#if EF_CLOTH_RAIN_ENABLED && EF_CLOTH_RAIN_COAT_ENABLED
    float3 rainCoatHdrLd = EfClothSampleEnvironment(
        reflectionDirWS,
        rainCoatRoughness) * max(EF_CLOTH_HDR_RELATIVE_STRENGTH, 0.0);
#if EF_CLOTH_MATCAP_ENABLED
    float3 rainCoatMatcapLd = EfClothSampleMatcap(
        specularNormalWS,
        rainCoatRoughness);
    float3 rainCoatEnvironmentLd = lerp(
        rainCoatMatcapLd,
        rainCoatHdrLd,
        environmentMode);
#else
    float3 rainCoatEnvironmentLd = rainCoatHdrLd;
#endif
    float3 rainCoatEnvironmentDfg = EfClothEnvironmentBrdf(
        rainCoatRoughness,
        specularNoV,
        rainCoatF0.xxx);
#if EF_CLOTH_FGD_LUT_ENABLED
    float4 rainCoatEnvironmentFgd = EfClothSamplePreIntegratedFgd(
        rainCoatRoughness,
        specularNoV,
        rainCoatF0.xxx);
    rainCoatEnvironmentDfg = lerp(
        rainCoatEnvironmentDfg,
        rainCoatEnvironmentFgd.rgb,
        saturate(fgdStrength * EF_CLOTH_FGD_STRENGTH));
#endif
    rainCoatIndirectSpecular = rainCoatEnvironmentLd
        * rainCoatEnvironmentDfg
        * max(environmentColor, 0.0)
        * specularOcclusion
        * indirectLightWeight
        * lerp(
            1.0,
            sceneShadowVisibility,
            saturate(environmentShadowStrength))
        * max(environmentStrength, 0.0)
        * surfaceWaterMask
        * rainCoatMetalWeight
        * max(EF_CLOTH_RAIN_COAT_ENV_STRENGTH, 0.0);
#endif
    float3 combinedIndirectSpecular = indirectSpecular
        + rainCoatIndirectSpecular;
#if EF_CLOTH_RAIN_ENABLED && EF_CLOTH_RAIN_DROP_ENABLED
    float neutralIndirectSpecular = dot(
        combinedIndirectSpecular,
        float3(0.2126, 0.7152, 0.0722));
    combinedIndirectSpecular = lerp(
        combinedIndirectSpecular,
        neutralIndirectSpecular.xxx,
        saturate(rainDropCoverage));
#endif
    litColor += combinedIndirectSpecular;

    // Clothing and skin in the reference use a view-angle rim in addition to
    // their direct specular. Keep it on the lit side so the opposite silhouette
    // does not glow, and smooth the normal so fabric detail cannot serrate it.
    float3 rimNormalWS = normalize(lerp(
        normalWS,
        geometryNormalWS,
        saturate(EF_CLOTH_RIM_NORMAL_SMOOTHING)));
    float rimNoV = saturate(dot(rimNormalWS, viewDirWS));
    float rimNoL = saturate(dot(rimNormalWS, lightWS));
    float rimEdge = 1.0 - rimNoV;
    float rimWidth = EF_CLOTH_RIM_WIDTH;
    float rimStrength = EF_CLOTH_RIM_STRENGTH;
    float rimContrast = 1.0;
    float3 edgeRimColor = EfClothSrgbToLinear(
        saturate(EfClothMaterialEdgeColor.rgb));
    float3 rimColor = edgeRimColor;
#if EF_CLOTH_CONTROLLER_ENABLED
    rimWidth = EfClothControllerRimWidth(rimWidth);
    rimStrength = EfClothControllerRimStrength(rimStrength);
    rimContrast = EfClothControllerRimContrast();
    rimColor = EfClothControllerRimColor(
        edgeRimColor, EF_CLOTH_RIM_COLOR);
#endif
    float rimCenter = 1.0 - saturate(rimWidth);
    float rimSoftness = max(EF_CLOTH_RIM_SOFTNESS, 1e-4);
    float rimRange = smoothstep(
        rimCenter - rimSoftness,
        rimCenter + rimSoftness,
        rimEdge);
    rimRange = EfRimApplyContrast(rimRange, rimContrast);
    float rimLightMask = smoothstep(
        EF_CLOTH_RIM_LIGHT_START,
        max(EF_CLOTH_RIM_LIGHT_END,
            EF_CLOTH_RIM_LIGHT_START + 1e-4),
        rimNoL);
    float rimMetalMask = lerp(
        1.0,
        saturate(EF_CLOTH_RIM_METAL_RETENTION),
        metallic);
    float3 rimBaseColor = rimColor * lerp(
        float3(1.0, 1.0, 1.0),
        albedoLinear,
        saturate(EF_CLOTH_RIM_ALBEDO_BLEND));
    float3 rimLighting = rimBaseColor
        * max(EfClothMmdLightColor, 0.0)
        * rimRange
        * rimLightMask
        * (propertyAo * 0.5 + 0.5)
        * lerp(
            1.0,
            sceneShadowVisibility,
            saturate(EF_CLOTH_RIM_SHADOW_STRENGTH))
        * rimMetalMask
        * max(rimStrength, 0.0);
    litColor += rimLighting;
    litColor = EfApplyGlobalMaterialGrade(
        litColor,
        diffuseWeightWithAo);
    return float4(max(EfClothLinearToSrgb(litColor), 0.0), 1.0);
}

#if EF_CLOTH_OUTLINE_ENABLED
struct EfClothOutlineVaryings {
    float4 positionCS : POSITION;
    float3 normalWS : TEXCOORD0;
};

EfClothOutlineVaryings EfClothOutlineVS(EfClothAttributes input)
{
    EfClothOutlineVaryings output = (EfClothOutlineVaryings)0;
    float4 positionCS = mul(input.positionOS, EfClothWorldViewProjection);
    float3 normalWS = normalize(
        mul(input.normalOS, (float3x3)EfClothWorld));
    output.positionCS = positionCS;
    output.normalWS = normalWS;
    return output;
}

float4 EfClothOutlinePS(EfClothOutlineVaryings input) : COLOR0
{
    float4 edgeColor = saturate(EfClothMaterialEdgeColor);
    clip(edgeColor.a - 1e-4);
    return edgeColor;
}

#define EF_CLOTH_OUTLINE_OBJECT_PASS
#endif
#ifndef EF_CLOTH_OUTLINE_OBJECT_PASS
#define EF_CLOTH_OUTLINE_OBJECT_PASS
#endif
#define EF_CLOTH_OUTLINE_EDGE_TECHNIQUE

#if EF_CLOTH_SCREEN_RIM_ENABLED
struct EfClothScreenRimVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float4 screenPosition : TEXCOORD3;
    float shadowDensity : TEXCOORD4;
};

EfClothScreenRimVaryings EfClothScreenRimVS(EfClothAttributes input)
{
    EfClothScreenRimVaryings output = (EfClothScreenRimVaryings)0;
    output.positionCS = mul(input.positionOS, EfClothWorldViewProjection);
    output.uv = input.texcoord0;
    output.positionWS = mul(input.positionOS, EfClothWorld).xyz;
    output.normalWS = normalize(
        mul(input.normalOS, (float3x3)EfClothWorld));
    output.screenPosition = output.positionCS;
    output.shadowDensity = max(
        (degrees(EfClothZmdShadowRotation)
            + 5.0 * EfClothShadowDensityUp + 1.0)
            * (1.0 - EfClothShadowDensityDown),
        0.0);
    return output;
}

float2 EfClothViewportUvFromClip(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / clipPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    return uv + 0.5 / max(EfClothViewportSize, 1.0);
}

float EfClothScreenDepthRim(
    float3 positionWS,
    float3 geometryNormalWS,
    float4 screenPosition)
{
    if (!EfClothZmdShadowValid || abs(screenPosition.w) < 1e-6) {
        return 0.0;
    }

    float3 positionVS = mul(float4(positionWS, 1.0), EfClothView).xyz;
    float3 normalVS = normalize(
        mul(geometryNormalWS, (float3x3)EfClothView) + 1e-6);
    float screenRimWidth = 1.0;
#if EF_CLOTH_CONTROLLER_ENABLED
    screenRimWidth = EfClothControllerScreenRimWidth(screenRimWidth);
#endif
    float3 rimOffsetVS = float3(
        normalVS.x * EF_CLOTH_SCREEN_RIM_WIDTH_X
            * EF_CLOTH_SCREEN_RIM_VIEW_SCALE
            * EF_CLOTH_SCREEN_RIM_MODEL_SCALE
            * screenRimWidth,
        normalVS.y * EF_CLOTH_SCREEN_RIM_WIDTH_Y
            * EF_CLOTH_SCREEN_RIM_VIEW_SCALE
            * EF_CLOTH_SCREEN_RIM_MODEL_SCALE
            * screenRimWidth,
        0.0);
    float4 offsetClip = mul(
        float4(positionVS + rimOffsetVS, 1.0),
        EfClothProjection);
    if (abs(offsetClip.w) < 1e-6) {
        return 0.0;
    }

    float centerDepth = tex2D(
        EfClothZmdShadowSampler,
        EfClothViewportUvFromClip(screenPosition)).g;
    float offsetDepth = tex2D(
        EfClothZmdShadowSampler,
        EfClothViewportUvFromClip(offsetClip)).g;
    return clamp(
        (offsetDepth - centerDepth) * EF_CLOTH_SCREEN_RIM_DEPTH_SCALE,
        0.0,
        EF_CLOTH_SCREEN_RIM_DEPTH_MAX);
}

float4 EfClothScreenRimPS(
    EfClothScreenRimVaryings input,
    float facing : VFACE) : COLOR0
{
#if EF_CLOTH_ANISO_THRESHOLD_DEBUG
    return float4(0.0, 0.0, 0.0, 0.0);
#else
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometryNormalWS = normalize(input.normalWS);
    float3 normalWS = geometryNormalWS * faceSign;
    float depthRim = EfClothScreenDepthRim(
        input.positionWS,
        geometryNormalWS,
        input.screenPosition);

    float3 viewVectorWS = EfClothCameraPosition - input.positionWS;
    float viewLengthSq = dot(viewVectorWS, viewVectorWS);
    float3 viewDirWS = viewLengthSq > 1e-8
        ? viewVectorWS * rsqrt(viewLengthSq)
        : normalWS;
    float noV = saturate(dot(normalWS, viewDirWS));
    float fresnel = pow(
        saturate(1.0 - noV),
        max(EF_CLOTH_SCREEN_RIM_FRESNEL_POWER, 1e-4));

    float3 lightWS = EfMmdSurfaceToLightWS(
        EfClothMmdLightDirection,
        normalWS);
    float noL = dot(normalWS, lightWS);
    float lightMask = smoothstep(
        EF_CLOTH_SCREEN_RIM_LIGHT_START,
        max(EF_CLOTH_SCREEN_RIM_LIGHT_END,
            EF_CLOTH_SCREEN_RIM_LIGHT_START + 1e-4),
        noL);

    float4 property = saturate(
        tex2D(EfClothPropertySampler, input.uv));
    float metallic = saturate(
        property.r * max(EF_CLOTH_METALLIC_STRENGTH, 0.0));
    float metalMask = lerp(
        1.0,
        saturate(EF_CLOTH_SCREEN_RIM_METAL_RETENTION),
        metallic);
    float aoMask = property.b * 0.5 + 0.5;
    float sceneShadowVisibility = 1.0;
#if EF_CLOTH_ZMD_SHADOW_ENABLED
    sceneShadowVisibility = EfClothComputeZmdShadowEffect(
        input.screenPosition,
        input.shadowDensity);
#endif
    float shadowMask = lerp(
        1.0,
        sceneShadowVisibility,
        saturate(EF_CLOTH_RIM_SHADOW_STRENGTH));
    float rimContrast = 1.0;
    float3 edgeRimColor = EfClothSrgbToLinear(
        saturate(EfClothMaterialEdgeColor.rgb));
    float3 rimColor = edgeRimColor;
#if EF_CLOTH_CONTROLLER_ENABLED
    rimContrast = EfClothControllerRimContrast();
    rimColor = EfClothControllerRimColor(
        edgeRimColor, EF_CLOTH_SCREEN_RIM_COLOR);
#endif
    float rimMask = EfRimApplyContrast(
        saturate(depthRim * fresnel * lightMask),
        rimContrast) * metalMask * aoMask * shadowMask;
    float screenRimStrength = EF_CLOTH_SCREEN_RIM_STRENGTH;
#if EF_CLOTH_CONTROLLER_ENABLED
    screenRimStrength = EfClothControllerScreenRimStrength(
        screenRimStrength);
#endif
    return float4(
        max(rimColor, 0.0)
            * max(screenRimStrength, 0.0)
            * rimMask
            * EfGlobalBrightnessMul(),
        0.0);
#endif
}

#define EF_CLOTH_SCREEN_RIM_PASS \
    pass DrawClothScreenRim { \
        ZEnable = true; \
        ZWriteEnable = false; \
        ZFunc = LESSEQUAL; \
        CullMode = EF_CLOTH_CULL_MODE; \
        AlphaTestEnable = false; \
        AlphaBlendEnable = true; \
        SrcBlend = ONE; \
        DestBlend = ONE; \
        BlendOp = ADD; \
        VertexShader = compile vs_3_0 EfClothScreenRimVS(); \
        PixelShader = compile ps_3_0 EfClothScreenRimPS(); \
    }
#define EF_CLOTH_OBJECT_SCRIPT \
    "RenderColorTarget0=;Pass=DrawObject;Pass=DrawClothScreenRim;"
#else
#define EF_CLOTH_SCREEN_RIM_PASS
#define EF_CLOTH_OBJECT_SCRIPT "RenderColorTarget0=;Pass=DrawObject;"
#endif

#define EF_CLOTH_TECHNIQUE(name, passName, useTextureValue) \
    technique name < \
        string MMDPass = passName; \
        string Script = EF_CLOTH_OBJECT_SCRIPT; \
        bool UseTexture = useTextureValue; \
        bool UseSphereMap = false; \
        bool UseSelfShadow = EF_CLOTH_USE_SELF_SHADOW; \
    > { \
        pass DrawObject { \
            ZEnable = true; \
            ZWriteEnable = true; \
            ZFunc = LESSEQUAL; \
            CullMode = EF_CLOTH_CULL_MODE; \
            AlphaTestEnable = false; \
            AlphaBlendEnable = false; \
            VertexShader = compile vs_3_0 EfClothVS(); \
            PixelShader = compile ps_3_0 EfClothPS(useTextureValue); \
        } \
        EF_CLOTH_OUTLINE_OBJECT_PASS \
        EF_CLOTH_SCREEN_RIM_PASS \
    }

EF_CLOTH_TECHNIQUE(EfClothObjectNoTexture, "object", false)
EF_CLOTH_TECHNIQUE(EfClothObjectTexture, "object", true)
EF_CLOTH_TECHNIQUE(EfClothObjectShadowNoTexture, "object_ss", false)
EF_CLOTH_TECHNIQUE(EfClothObjectShadowTexture, "object_ss", true)
EF_CLOTH_OUTLINE_EDGE_TECHNIQUE

#endif
