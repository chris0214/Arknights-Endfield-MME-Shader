using System.Text;

namespace EndfieldShaderTool.Core;

public static class EmmGenerator
{
    public static string Build(EndfieldProject project, string outputDirectory)
    {
        ProjectService.NormalizeMaterialBindings(project);
        var output = Path.GetFullPath(outputDirectory);
        var modelPath = Path.GetFullPath(project.PmxPath);
        var shadowX = Path.Combine(output, ShadowBackendSupport.ControlFile(ShadowBackend.Zmd));
        var controller = Path.Combine(output, "controller", "Endfield_controller.pmx");

        var lines = new List<string>
        {
            "[Info]",
            "Version = 3",
            string.Empty,
            "[Object]",
            $"Acs1 = {shadowX}",
            "Acs1.show = false",
            $"Pmd2 = {modelPath}",
            $"Pmd3 = {Path.Combine(output, "controller", "EndfieldHair_controller_Range5.pmx")}",
            $"Pmd4 = {Path.Combine(output, "controller", "EndfieldFace_controller.pmx")}",
            $"Pmd5 = {Path.Combine(output, "controller", "EndfieldSkin_controller.pmx")}",
            $"Pmd6 = {Path.Combine(output, "controller", "EndfieldCloth_controller.pmx")}",
            $"Pmd7 = {controller}",
            $"Pmd8 = {Path.Combine(output, "controller", "EndfieldPost_controller.pmx")}",
            string.Empty,
            "[Effect]",
            "Default = none",
            "Pmd2 = none"
        };

        if (project.IncludeEyeThrough)
        {
            lines.Insert(7, $"Acs2 = {Path.Combine(output, "EndfieldEyeThrough.x")}");
            lines.Insert(8, "Acs2.show = false");
        }

        foreach (var mapping in MaterialMappings(project, output))
            lines.Add($"Pmd2[{mapping.Binding.MaterialIndex}] = {mapping.FxPath}");
        lines.Add("Pmd3 = none");

        AddShadowSection(lines, project, output, "ZMDShadowMap", "ZMDshadow_ShadowMap.fxsub",
            static profile => profile.CastExcellentShadow);
        AddShadowSection(lines, project, output, "ZMDViewportMap", "ZMDshadow_ViewportMap.fxsub",
            static profile => profile.CastExcellentShadow);

        if (project.IncludeEyeThrough)
        {
            lines.Add(string.Empty);
            lines.Add("[Effect@EndfieldEyeThrough_RT]");
            lines.Add("Owner = Acs2");
            lines.Add("Acs1.show = false");
            lines.Add("Acs2.show = false");
            lines.Add($"Pmd2 = {Path.Combine(output, "EndfieldEyeThrough_Capture.fxsub")}");
            for (var index = 3; index <= 7; index++) lines.Add($"Pmd{index}.show = false");
        }
        return string.Join("\r\n", lines) + "\r\n";
    }

    public static byte[] Encode(string text)
    {
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        return Encoding.GetEncoding(936, EncoderFallback.ExceptionFallback, DecoderFallback.ExceptionFallback).GetBytes(text);
    }

    private static void AddShadowSection(
        ICollection<string> lines,
        EndfieldProject project,
        string output,
        string section,
        string effectFile,
        Func<MaterialProfile, bool> includeProfile)
    {
        lines.Add(string.Empty);
        lines.Add($"[Effect@{section}]");
        lines.Add("Owner = Acs1");
        lines.Add("Acs1.show = false");
        lines.Add("Pmd2 = none");
        var effectPath = Path.Combine(output, effectFile);
        foreach (var profile in project.Profiles.Where(includeProfile))
        {
            foreach (var binding in ProjectService.GetBindings(profile).OrderBy(x => x.MaterialIndex))
                lines.Add($"Pmd2[{binding.MaterialIndex}] = {effectPath}");
        }
        lines.Add("Pmd3 = none");
        lines.Add("Pmd3.show = false");
    }

    private static IEnumerable<(MaterialBinding Binding, string FxPath)> MaterialMappings(EndfieldProject project, string output)
    {
        foreach (var profile in project.Profiles)
        {
            var profileSlug = ProjectService.Slugify(profile.ProfileName);
            var fxPath = Path.Combine(output, "presets", project.RoleSlug, $"{project.RoleSlug}_{profileSlug}.fx");
            foreach (var binding in ProjectService.GetBindings(profile).OrderBy(x => x.MaterialIndex))
                yield return (binding, fxPath);
        }
    }
}


