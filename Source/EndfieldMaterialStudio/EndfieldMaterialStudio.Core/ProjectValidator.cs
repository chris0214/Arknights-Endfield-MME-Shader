namespace EndfieldMaterialStudio.Core;

public static class ProjectValidator
{
    public static IReadOnlyList<ValidationMessage> Validate(StudioProject project)
    {
        var messages = new List<ValidationMessage>();
        messages.AddRange(RuntimeContract.Validate(project.RuntimeRoot));
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath))
            messages.Add(Error("PMX", "PMX 文件不存在。"));
        else
            messages.AddRange(ValidatePmxDependencies(project));
        if (string.IsNullOrWhiteSpace(project.OutputDirectory))
            messages.Add(Error("OUTPUT", "没有选择输出目录。"));

        var duplicateIndices = project.Materials.GroupBy(material => material.MaterialIndex)
            .Where(group => group.Count() > 1)
            .Select(group => group.Key)
            .ToArray();
        foreach (var index in duplicateIndices)
            messages.Add(Error("DUPLICATE_BINDING", $"PMX 材质 #{index} 被重复绑定。"));

        if (project.EnableEyeThrough)
        {
            if (!project.Materials.Any(material => material.Role == MaterialRole.Iris))
                messages.Add(Error("EYE_IRIS", "眼透至少需要一个 Iris/眼睛材质。"));
            if (!project.Materials.Any(material => material.Role == MaterialRole.BrowLash))
                messages.Add(Error("EYE_BROW", "眼透至少需要一个 BrowLash/眉毛睫毛材质。"));
        }

        foreach (var material in project.Materials)
        {
            ValidateBaseTextureChoice(material, messages);
            if (material.Enabled) ValidateMaterial(material, messages);
        }
        return messages;
    }

    public static IReadOnlyList<ValidationMessage> ValidatePmxDependencies(StudioProject project)
    {
        var messages = new List<ValidationMessage>();
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath)) return messages;

        PmxModelInfo model;
        try
        {
            model = PmxReader.Read(project.PmxPath);
        }
        catch (Exception exception) when (exception is IOException or PmxFormatException or UnauthorizedAccessException)
        {
            messages.Add(Error("PMX_READ", $"PMX 无法读取：{exception.Message}"));
            return messages;
        }

        var assignments = project.Materials
            .GroupBy(material => material.MaterialIndex)
            .ToDictionary(group => group.Key, group => group.First());
        foreach (var dependency in PmxReader.ResolveTextureDependencies(model))
        {
            if (dependency.Kind == PmxTextureKind.Base &&
                assignments.TryGetValue(dependency.MaterialIndex, out var assignment) &&
                assignment.EffectiveBaseTextureMode != PmxBaseTextureMode.Inherit)
            {
                continue;
            }

            var resolution = dependency.Resolution;
            var kind = TextureKindName(dependency.Kind);
            if (resolution.UsedFallback)
            {
                messages.Add(Warning(
                    "PMX_TEXTURE_FALLBACK",
                    $"PMX 材质 #{dependency.MaterialIndex} {dependency.MaterialName} 的{kind}按声明路径不存在；已从 {resolution.FallbackDirectory} 精确找到同名文件：{resolution.DeclaredPath} -> {resolution.ResolvedPath}"));
            }
            else if (!resolution.Exists)
            {
                var detail = Directory.Exists(resolution.DirectPath)
                    ? $"声明路径指向文件夹而不是贴图文件：{resolution.DeclaredPath}"
                    : $"不存在：{resolution.DeclaredPath}";
                messages.Add(Error(
                    "PMX_TEXTURE_MISSING",
                    $"PMX 材质 #{dependency.MaterialIndex} {dependency.MaterialName} 的{kind}{detail}。可将基础贴图模式改为“手动替换”或“无基础贴图”。"));
            }
        }
        return messages;
    }

    private static void ValidateMaterial(MaterialAssignment material, ICollection<ValidationMessage> messages)
    {
        foreach (var (slot, path) in RequiredTextures(material))
        {
            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
                messages.Add(Error("TEXTURE", $"材质 #{material.MaterialIndex} {material.MaterialName}（{material.Role}）缺少 {slot} 贴图。"));
        }
    }

    private static void ValidateBaseTextureChoice(MaterialAssignment material, ICollection<ValidationMessage> messages)
    {
        if (material.EffectiveBaseTextureMode == PmxBaseTextureMode.Override &&
            (string.IsNullOrWhiteSpace(material.Textures.Base) || !File.Exists(material.Textures.Base)))
        {
            messages.Add(Error("BASE_OVERRIDE", $"材质 #{material.MaterialIndex} {material.MaterialName} 选择了手动替换，但替换贴图不存在。"));
        }
        if (material.EffectiveBaseTextureMode == PmxBaseTextureMode.None &&
            MaterialRequiresBase(material.Role))
        {
            messages.Add(Error("BASE_REQUIRED", $"材质 #{material.MaterialIndex} {material.MaterialName}（{material.Role}）需要基础贴图，不能选择“无基础贴图”。"));
        }
    }

    public static IEnumerable<(string Slot, string? Path)> RequiredTextures(MaterialAssignment material)
    {
        var textures = material.Textures;
        var basePath = material.EffectiveBaseTextureMode switch
        {
            PmxBaseTextureMode.Inherit => material.PmxBaseTexture,
            PmxBaseTextureMode.Override => textures.Base,
            _ => null
        };
        switch (material.Role)
        {
            case MaterialRole.Face:
                yield return ("Base", basePath);
                yield return ("SDF", textures.Sdf);
                yield return ("ColorMask", textures.ColorMask);
                yield return ("RD", textures.Rd);
                yield return ("LUT", textures.Lut);
                yield return ("ST", textures.St);
                break;
            case MaterialRole.Hair:
                yield return ("Base", basePath);
                yield return ("Normal/HN", textures.Normal);
                yield return ("Property/P", textures.Property);
                yield return ("RD", textures.Rd);
                yield return ("RS", textures.Rs);
                yield return ("ST", textures.St);
                yield return ("HairLine", textures.HairLine);
                break;
            case MaterialRole.Cloth:
                yield return ("Base", basePath);
                yield return ("Normal", textures.Normal);
                yield return ("Property/P", textures.Property);
                yield return ("RD", textures.Rd);
                yield return ("RS", textures.Rs);
                yield return ("LUT", textures.Lut);
                break;
            case MaterialRole.Skin:
                yield return ("Base", basePath);
                yield return ("RD", textures.Rd);
                yield return ("LUT", textures.Lut);
                break;
            case MaterialRole.Iris:
            case MaterialRole.EyeHighlight:
            case MaterialRole.EyeWhite:
            case MaterialRole.BrowLash:
            case MaterialRole.Mouth:
            case MaterialRole.EyeOverlay:
            case MaterialRole.BrowOverlay:
                yield return ("Base", basePath);
                break;
        }
    }

    private static bool MaterialRequiresBase(MaterialRole role) => role is
        MaterialRole.Face or MaterialRole.Hair or MaterialRole.Cloth or MaterialRole.Skin or
        MaterialRole.Iris or MaterialRole.EyeHighlight or MaterialRole.EyeWhite or
        MaterialRole.BrowLash or MaterialRole.Mouth or MaterialRole.EyeOverlay or MaterialRole.BrowOverlay;

    private static ValidationMessage Error(string code, string message) => new() { IsError = true, Code = code, Message = message };
    private static ValidationMessage Warning(string code, string message) => new() { IsError = false, Code = code, Message = message };

    private static string TextureKindName(PmxTextureKind kind) => kind switch
    {
        PmxTextureKind.Base => "基础贴图",
        PmxTextureKind.Sphere => "球面贴图",
        PmxTextureKind.Toon => "Toon 贴图",
        _ => "贴图"
    };
}
