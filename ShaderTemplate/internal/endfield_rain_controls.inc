// Endfield MME - packed character-wide rain controls.
// The production copy is encoded as CP932 for MME.
#ifndef ENDFIELD_RAIN_CONTROLS_INCLUDED
#define ENDFIELD_RAIN_CONTROLS_INCLUDED

#ifndef EF_GLOBAL_CONTROLLER_NAME
#define EF_GLOBAL_CONTROLLER_NAME "Endfield_controller.pmx"
#endif

float3 EfRainPacked0 : CONTROLOBJECT <
    string name = EF_GLOBAL_CONTROLLER_NAME;
    string item = "‘S‚Ä‚Ìe";
>;

float EfRainControlSigned(float packedValue)
{
    return clamp(packedValue, -1.0, 1.0);
}

float EfGlobalRainAmount(float maximumAmount)
{
    return max(maximumAmount, 0.0) * saturate(EfRainPacked0.x);
}

float EfGlobalRainDropTiling(float bakedTiling)
{
    float control = EfRainControlSigned(EfRainPacked0.y);
    float multiplier = 1.0
        - 0.67 * max(control, 0.0)
        + 1.5 * max(-control, 0.0);
    return max(bakedTiling, 1e-4) * max(multiplier, 0.20);
}

float EfGlobalRainDropLifetime(float bakedLifetime)
{
    float control = EfRainControlSigned(EfRainPacked0.z);
    float multiplier = 1.0
        - 0.9 * max(control, 0.0)
        + 3.0 * max(-control, 0.0);
    return clamp(bakedLifetime * multiplier, 0.05, 2.6);
}

#endif
