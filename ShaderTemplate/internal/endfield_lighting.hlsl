// Endfield MME - toon lighting core. Ported from Perlica ZmdToonLighting.hlsl.
// Depends on globals declared in endfield_shader.hlsl (LightColor, matView, the
// Ef* controller helpers) and on endfield_camera_light.hlsl.
#ifndef ENDFIELD_LIGHTING_INCLUDED
#define ENDFIELD_LIGHTING_INCLUDED

float EfLuminance(float3 c) { return dot(c, float3(0.2126, 0.7152, 0.0722)); }

// ── Main light: strip intensity, keep hue ───────────────
// Unity's GetMainLight().color carries intensity; the toon path normalizes it
// so brightness is driven by the Ramp/controller, not the MMD light strength.
void EfGetMainLight(out float3 mainLightDir, out float3 mainLightDir_xz,
    out float3 mainLightColor, out float mainLightIntensity)
{
    mainLightDir = EfGetLightDirectionWS();
    mainLightDir_xz = normalize(float3(mainLightDir.x, 6.10351562e-05, mainLightDir.z));

    mainLightColor = max(LightColor, 0.0);
    mainLightIntensity = max(0.001, EfLuminance(mainLightColor));
    mainLightColor = mainLightColor / mainLightIntensity;
}

// ── Top fill light (constant direction) ─────────────────
float3 EfGetOtherLight(float3 normalWS, float3 otherLightDirRaw, float3 otherLightColor,
    float offset, float strength, float strengthOffset)
{
    float3 otherLightDir = normalize(otherLightDirRaw);
    float otherNoL = dot(otherLightDir, normalWS);
    otherNoL = saturate(otherNoL + offset);
    otherNoL = otherNoL * strength + strengthOffset;
    return otherLightColor * otherNoL;
}

// ── Composite main light color (day/cloudy blend) ───────
float3 EfGetMainLightColorFinal(float3 mainLightColor, float3 otherLightResult,
    float dayStrength, float otherDay1, float otherDay0)
{
    float3 other_day1 = otherLightResult * otherDay1;
    float3 other_day0 = otherLightResult * otherDay0;
    return lerp(other_day0, mainLightColor + other_day1, dayStrength);
}

// ── Back-light detection (camera facing away from light) ──
float EfGetBackLight(float3 cameraForward, float3 mainLightDir_xz)
{
    float2 cf_xz = normalize(cameraForward.xz);
    float backLight = saturate(-dot(cf_xz, mainLightDir_xz.xz));
    float backLightY = saturate(-abs(cameraForward.y) + 0.75);
    backLightY = backLightY * backLightY * (3.0 - 2.0 * backLightY); // smoothstep
    return backLight * backLightY;
}

// ── Ramp NoL (back-light lifts the dark side) ───────────
float EfGetRampNoL(float NoL, float backLight)
{
    float rampN = 0.5 - 0.5 * NoL * NoL;
    float finalN = clamp(rampN * backLight + NoL, -1.0, 1.0);
    return finalN * 0.5 + 0.5;
}

// ── 3-layer diffuse BRDF (dark -> dark_attn -> light) ───
float3 EfGetDiffuseBRDF(
    float3 baseColor, float3 baseColor_dark, float ao, float shadow,
    float4 rampColor, float rampNoF, float energyDist,
    out float3 diffLight, out float3 diffDark)
{
    float3 diffLightOut = baseColor      * energyDist;
    float3 diffDarkOut  = baseColor_dark * energyDist;
    float3 diffDarkAttn = diffDarkOut * 0.65;

    float aoShadow  = ao * shadow;
    float minShadow = min(min(ao, shadow), rampColor.w);
    float aoShaNoF  = aoShadow * rampNoF;

    float3 darkLerp = lerp(diffDarkAttn, diffDarkOut, saturate(aoShaNoF + rampColor.w));
    float3 diffuse  = lerp(darkLerp, diffLightOut, minShadow);

    diffLight = diffLightOut;
    diffDark  = diffDarkOut;
    return diffuse;
}

// ── Ramp color, saturation-adaptive blending ────────────
float3 EfApplyRampColor(float3 diffuse, float4 rampColor)
{
    float rampMax = max(max(rampColor.r, rampColor.g), rampColor.b);
    float rampMin = min(min(rampColor.r, rampColor.g), rampColor.b);
    float rampSat = rampMax - rampMin;
    float3 rampEff = rampColor.rgb * rampSat + 1.0 - rampSat;
    float3 diffRamp = diffuse * rampEff;

    float brdfStr  = EfLuminance(diffuse);
    float brdfRStr = EfLuminance(diffRamp);
    float rampCtrl = clamp(brdfStr / max(0.01, brdfRStr), 0.0, 1.5);
    return diffRamp * rampCtrl;
}

#endif
