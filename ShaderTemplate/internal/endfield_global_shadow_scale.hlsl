// Endfield MME - release-wide shadow branch baseline.
#ifndef ENDFIELD_GLOBAL_SHADOW_SCALE_INCLUDED
#define ENDFIELD_GLOBAL_SHADOW_SCALE_INCLUDED

#ifndef EF_GLOBAL_SHADOW_BRIGHTNESS
#define EF_GLOBAL_SHADOW_BRIGHTNESS 0.4
#endif

float EfDarkBranchMul()
{
    return max(EF_GLOBAL_SHADOW_BRIGHTNESS, 0.0) * EfDarkMul();
}

float3 EfApplyGlobalMaterialGradeScaled(float3 color, float lightWeight)
{
    float branchBrightness = lerp(
        EfDarkBranchMul(),
        EfBrightMul(),
        saturate(lightWeight));
    return EfApplyGlobalColorGrade(max(color, 0.0) * branchBrightness);
}

#endif
