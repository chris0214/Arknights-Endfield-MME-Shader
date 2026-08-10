// Endfield MME - HgShadow camera-light shim.
//
// HgShadow_CFSUSM.fxh / HgShadow_CLSPSM.fxh (as shipped inside HS_Snow) include
// "internal/snow_camera_light.hlsl" and use three symbols: SnowCameraLight,
// SnowGetCameraRelativeLightRayWS(), SnowCameraLightNormalizeOr(). This file
// provides exactly those, self-contained, but points the controller at
// Endfield_controller.pmx so the projected shadow follows the SAME controller
// (and the same yaw/pitch/azimuth basis) as the Endfield material lighting.
//
// The morph item names and the -35 azimuth / 20 elevation defaults match
// endfield_camera_light.hlsl, so HgShadow's camera-light mode stays in lockstep
// with EfGetLightDirectionWS(). When no controller is loaded, SnowCameraLight
// reads 0 and both fall back to the raw MMD world light.
#ifndef SNOW_CAMERA_LIGHT_INCLUDED
#define SNOW_CAMERA_LIGHT_INCLUDED

#ifndef SNOW_CAMERA_LIGHT_AZIMUTH_DEGREES
#define SNOW_CAMERA_LIGHT_AZIMUTH_DEGREES -35.0
#endif
#ifndef SNOW_CAMERA_LIGHT_ELEVATION_DEGREES
#define SNOW_CAMERA_LIGHT_ELEVATION_DEGREES 20.0
#endif

#define SNOW_CAMERA_LIGHT_PI 3.14159265358979323846
#define SNOW_CAMERA_LIGHT_DEG_TO_RAD (SNOW_CAMERA_LIGHT_PI / 180.0)

float SnowCameraLight : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "CameraLight"; >;
float SnowLightYawP   : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw+"; >;
float SnowLightYawM   : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw-"; >;
float SnowLightYawPP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw++"; >;
float SnowLightYawMM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw--"; >;
float SnowLightPitchP : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightPitch+"; >;
float SnowLightPitchM : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightPitch-"; >;

float3 SnowCameraLightNormalizeOr(float3 value, float3 fallbackValue)
{
    float lengthSquared = dot(value, value);
    return lengthSquared < 1e-8 ? fallbackValue : value * rsqrt(lengthSquared);
}

void SnowBuildCameraBasis(float3 cameraDirectionWS, out float3 screenRightWS,
    out float3 screenUpWS, out float3 towardCameraWS)
{
    float3 worldUpWS = float3(0.0, 1.0, 0.0);
    float3 cameraForwardWS = SnowCameraLightNormalizeOr(
        float3(cameraDirectionWS.x, 0.0, cameraDirectionWS.z),
        float3(0.0, 0.0, 1.0));
    screenRightWS = SnowCameraLightNormalizeOr(cross(worldUpWS, cameraForwardWS), float3(1.0, 0.0, 0.0));
    screenUpWS = worldUpWS;
    towardCameraWS = -cameraForwardWS;
}

float3 SnowGetCameraRelativeSurfaceToLightWS(float3 cameraDirectionWS)
{
    float3 screenRightWS, screenUpWS, towardCameraWS;
    SnowBuildCameraBasis(cameraDirectionWS, screenRightWS, screenUpWS, towardCameraWS);

    float yawOffset =
        saturate(SnowLightYawP) - saturate(SnowLightYawM)
        + saturate(SnowLightYawPP) - saturate(SnowLightYawMM);
    float pitchOffset = saturate(SnowLightPitchP) - saturate(SnowLightPitchM);

    float azimuth = SNOW_CAMERA_LIGHT_AZIMUTH_DEGREES * SNOW_CAMERA_LIGHT_DEG_TO_RAD;
    azimuth += yawOffset * SNOW_CAMERA_LIGHT_PI * 0.5;

    float elevation = SNOW_CAMERA_LIGHT_ELEVATION_DEGREES * SNOW_CAMERA_LIGHT_DEG_TO_RAD;
    elevation += pitchOffset * SNOW_CAMERA_LIGHT_PI * 0.5;
    elevation = clamp(elevation, -80.0 * SNOW_CAMERA_LIGHT_DEG_TO_RAD, 80.0 * SNOW_CAMERA_LIGHT_DEG_TO_RAD);

    float3 horizontalDirection = towardCameraWS * cos(azimuth) + screenRightWS * sin(azimuth);
    float3 surfaceToLightWS = horizontalDirection * cos(elevation) + screenUpWS * sin(elevation);
    return SnowCameraLightNormalizeOr(surfaceToLightWS, float3(-0.46984631, 0.57357644, -0.67101007));
}

float3 SnowGetCameraRelativeLightRayWS(float3 cameraDirectionWS)
{
    return -SnowGetCameraRelativeSurfaceToLightWS(cameraDirectionWS);
}

#endif
