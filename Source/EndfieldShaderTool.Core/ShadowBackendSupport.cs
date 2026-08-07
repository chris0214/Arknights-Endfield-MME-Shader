namespace EndfieldShaderTool.Core;

public enum ShadowBackend
{
    Zmd
}

public static class ShadowBackendSupport
{
    public static readonly string[] CommonTemplateFiles =
    {
        "internal/endfield_shader.hlsl",
        "internal/endfield_face.hlsl",
        "internal/endfield_skin.hlsl",
        "internal/endfield_cloth.hlsl",
        "internal/endfield_cloth_controls.inc",
        "internal/endfield_facial.hlsl",
        "internal/endfield_eye_highlight.hlsl",
        "internal/endfield_eye_white.hlsl",
        "internal/endfield_eye.hlsl",
        "internal/endfield_eye_through_capture_core.fxsub",
        "internal/endfield_camera_light.hlsl",
        "internal/endfield_controls.inc",
        "internal/endfield_eye_controls.inc",
        "internal/endfield_face_controls.inc",
        "internal/endfield_global_controls.inc",
        "internal/endfield_global_shadow_scale.hlsl",
        "internal/endfield_hair_controls.inc",
        "internal/endfield_hair_controls_c5.inc",
        "internal/endfield_hair_ggx.hlsl",
        "internal/endfield_hair_goo_position.hlsl",
        "internal/endfield_hair_specular.hlsl",
        "internal/endfield_lighting.hlsl",
        "internal/endfield_outline.hlsl",
        "internal/endfield_outline_controls.cp932",
        "internal/endfield_rain_controls.inc",
        "internal/endfield_skin_controls.inc",
        "internal/endfield_specular.hlsl",
        "internal/snow_camera_light.hlsl",
        "ZMDshadow.x",
        "ZMDshadow.fx",
        "ZMDshadow_ShadowMap.fxsub",
        "ZMDshadow_ViewportMap.fxsub",
        "HgShadow_Header.fxh",
        "HgShadow_CFSUSM.fxh",
        "HgShadow_CLSPSM.fxh",
        "controller/Endfield_controller.pmx",
        "controller/EndfieldHair_controller_Range5.pmx",
        "controller/EndfieldFace_controller.pmx",
        "controller/EndfieldSkin_controller.pmx",
        "controller/EndfieldCloth_controller.pmx",
        "controller/EndfieldPost_controller.pmx",
        "textures/common"
    };

    public static readonly string[] EndfieldFiles =
    {
        "ZMDshadow.x",
        "ZMDshadow.fx",
        "ZMDshadow_ShadowMap.fxsub",
        "ZMDshadow_ViewportMap.fxsub",
        "HgShadow_Header.fxh",
        "HgShadow_CFSUSM.fxh",
        "HgShadow_CLSPSM.fxh"
    };

    public static ShadowBackend? TryDetect(string templateRoot)
    {
        if (string.IsNullOrWhiteSpace(templateRoot) || !Directory.Exists(templateRoot)) return null;
        return File.Exists(Path.Combine(templateRoot, "ZMDshadow.x")) ? ShadowBackend.Zmd : null;
    }

    public static ShadowBackend DetectRequired(string templateRoot)
        => TryDetect(templateRoot) ?? throw new InvalidOperationException("模板缺少 ZMDshadow.x 阴影后端。");

    public static IReadOnlyList<string> RequiredFiles(ShadowBackend backend)
        => EndfieldFiles;

    public static string DisplayName(ShadowBackend backend)
        => "ZMDshadow";

    public static string ControlFile(ShadowBackend backend)
        => "ZMDshadow.x";

}


