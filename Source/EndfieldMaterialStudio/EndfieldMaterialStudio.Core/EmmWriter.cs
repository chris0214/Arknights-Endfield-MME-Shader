using System.Text;

namespace EndfieldMaterialStudio.Core;

public static class EmmWriter
{
    static EmmWriter() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    public static byte[] Build(
        StudioProject project,
        string packageRoot,
        string runtimeLookupRoot,
        string modelPath,
        IReadOnlyDictionary<int, string> materialFxPaths,
        string? eyeCapturePath)
    {
        var zmd = Path.Combine(packageRoot, "ZMDshadow.x");
        var eyeThrough = Path.Combine(packageRoot, "EndfieldEyeThrough.x");
        var controllers = ControllerPaths(packageRoot, runtimeLookupRoot);
        var lines = new List<string>
        {
            "[Info]",
            "Version = 3",
            string.Empty,
            "[Object]",
            $"Acs1 = {zmd}"
        };
        if (project.EnableEyeThrough) lines.Add($"Acs2 = {eyeThrough}");
        lines.Add($"Pmd2 = {modelPath}");
        foreach (var pair in controllers) lines.Add($"{pair.Key} = {pair.Value}");

        lines.Add(string.Empty);
        lines.Add("[Effect]");
        lines.Add("Default = none");
        lines.Add("Pmd2 = none");
        foreach (var pair in materialFxPaths.OrderBy(pair => pair.Key))
            lines.Add($"Pmd2[{pair.Key}] = {pair.Value}");
        foreach (var key in controllers.Keys) lines.Add($"{key} = none");

        if (project.EnableEyeThrough && !string.IsNullOrWhiteSpace(eyeCapturePath))
        {
            lines.Add(string.Empty);
            lines.Add("[Effect@EndfieldEyeThrough_RT]");
            lines.Add("Owner = Acs2");
            lines.Add("Acs1.show = false");
            lines.Add("Acs2.show = false");
            lines.Add($"Pmd2 = {eyeCapturePath}");
            foreach (var key in controllers.Keys) lines.Add($"{key}.show = false");
        }

        AddShadowSection(lines, "SMap", project.EnableEyeThrough, controllers.Keys, packageRoot, "ZMDshadow_ShadowMap.fxsub");
        AddShadowSection(lines, "VMap", project.EnableEyeThrough, controllers.Keys, packageRoot, "ZMDshadow_ViewportMap.fxsub");
        return Encoding.GetEncoding(936).GetBytes(string.Join("\r\n", lines) + "\r\n");
    }

    private static void AddShadowSection(
        ICollection<string> lines,
        string suffix,
        bool includeEyeThrough,
        IEnumerable<string> controllerKeys,
        string packageRoot,
        string effectFile)
    {
        lines.Add(string.Empty);
        lines.Add($"[Effect@ZMDshadow_{suffix}]");
        lines.Add("Owner = Acs1");
        lines.Add("Acs1.show = false");
        if (includeEyeThrough) lines.Add("Acs2.show = false");
        lines.Add($"Pmd2 = {Path.Combine(packageRoot, effectFile)}");
        foreach (var key in controllerKeys) lines.Add($"{key}.show = false");
    }

    private static IReadOnlyDictionary<string, string> ControllerPaths(string packageRoot, string runtimeLookupRoot)
    {
        var definitions = new[]
        {
            ("Pmd3", "EndfieldHair_controller_Range5.pmx"),
            ("Pmd4", "EndfieldFace_controller.pmx"),
            ("Pmd5", "EndfieldSkin_controller.pmx"),
            ("Pmd6", "EndfieldCloth_controller.pmx"),
            ("Pmd7", "Endfield_controller.pmx")
        };
        return definitions.Where(item => File.Exists(Path.Combine(runtimeLookupRoot, "controller", item.Item2)))
            .ToDictionary(item => item.Item1, item => Path.Combine(packageRoot, "controller", item.Item2), StringComparer.Ordinal);
    }
}
