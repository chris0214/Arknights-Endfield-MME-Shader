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
        "ZMDshadow.x",
        "ZMDshadow.fx",
        "ZMDshadow_ShadowMap.fxsub",
        "ZMDshadow_ViewportMap.fxsub",
        "HgShadow_Header.fxh",
        "HgShadow_CFSUSM.fxh",
        "HgShadow_CLSPSM.fxh",
        "controller/Endfield_controller.pmx",
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


