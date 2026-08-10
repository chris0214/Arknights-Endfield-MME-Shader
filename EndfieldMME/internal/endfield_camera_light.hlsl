// Endfield MME - camera-relative fixed directional light (optional mode).
// Ported from HS_Snow/internal/snow_camera_light.hlsl. When the controller's
// CameraLight morph is >= 0.5 the main light follows the camera yaw only, so
// Toon boundaries stay put when the camera pitches. Otherwise the shader uses
// the raw MMD world light.
#ifndef ENDFIELD_CAMERA_LIGHT_INCLUDED
#define ENDFIELD_CAMERA_LIGHT_INCLUDED

#ifndef EF_CAMERA_LIGHT_AZIMUTH_DEGREES
#define EF_CAMERA_LIGHT_AZIMUTH_DEGREES -35.0
#endif
#ifndef EF_CAMERA_LIGHT_ELEVATION_DEGREES
#define EF_CAMERA_LIGHT_ELEVATION_DEGREES 20.0
#endif

#define EF_PI 3.14159265358979323846
#define EF_DEG_TO_RAD (EF_PI / 180.0)

float EfCameraLight  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "CameraLight"; >;
float EfLightYawP    : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw+"; >;
float EfLightYawM    : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw-"; >;
float EfLightYawPP   : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw++"; >;
float EfLightYawMM   : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightYaw--"; >;
float EfLightPitchP  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightPitch+"; >;
float EfLightPitchM  : CONTROLOBJECT < string name = "Endfield_controller.pmx"; string item = "LightPitch-"; >;

float3 EfNormalizeOr(float3 value, float3 fallbackValue)
{
    float lengthSquared = dot(value, value);
    return lengthSquared < 1e-8 ? fallbackValue : value * rsqrt(lengthSquared);
}

void EfBuildCameraBasis(float3 cameraDirectionWS, out float3 screenRightWS,
    out float3 screenUpWS, out float3 towardCameraWS)
{
    float3 worldUpWS = float3(0.0, 1.0, 0.0);
    float3 cameraForwardWS = EfNormalizeOr(
        float3(cameraDirectionWS.x, 0.0, cameraDirectionWS.z),
        float3(0.0, 0.0, 1.0));
    screenRightWS = EfNormalizeOr(cross(worldUpWS, cameraForwardWS), float3(1.0, 0.0, 0.0));
    screenUpWS = worldUpWS;
    towardCameraWS = -cameraForwardWS;
}

float3 EfGetCameraRelativeSurfaceToLightWS(float3 cameraDirectionWS)
{
    float3 screenRightWS, screenUpWS, towardCameraWS;
    EfBuildCameraBasis(cameraDirectionWS, screenRightWS, screenUpWS, towardCameraWS);

    float yawOffset =
        saturate(EfLightYawP) - saturate(EfLightYawM)
        + saturate(EfLightYawPP) - saturate(EfLightYawMM);
    float pitchOffset = saturate(EfLightPitchP) - saturate(EfLightPitchM);

    float azimuth = EF_CAMERA_LIGHT_AZIMUTH_DEGREES * EF_DEG_TO_RAD;
    azimuth += yawOffset * EF_PI * 0.5;

    float elevation = EF_CAMERA_LIGHT_ELEVATION_DEGREES * EF_DEG_TO_RAD;
    elevation += pitchOffset * EF_PI * 0.5;
    elevation = clamp(elevation, -80.0 * EF_DEG_TO_RAD, 80.0 * EF_DEG_TO_RAD);

    float3 horizontalDirection = towardCameraWS * cos(azimuth) + screenRightWS * sin(azimuth);
    float3 surfaceToLightWS = horizontalDirection * cos(elevation) + screenUpWS * sin(elevation);
    return EfNormalizeOr(surfaceToLightWS, float3(-0.46984631, 0.57357644, -0.67101007));
}

// MME supplies the direction the light travels. Shading needs the opposite,
// surface-to-light direction. When CameraLight is on, switch hard (blending
// opposing vectors can collapse toward zero and erase both Toon and shadow).
float3 EfGetLightDirectionWS()
{
    float3 fallback = float3(0.0, 0.70710678, -0.70710678);
    float3 lightDirectionWS = EfNormalizeOr(-LightDirection, fallback);
    if (EfCameraLight >= 0.5) {
        return EfGetCameraRelativeSurfaceToLightWS(CameraDirection);
    }
    return lightDirectionWS;
}

#endif
