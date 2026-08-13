using System.Text.Json;

namespace EndfieldMaterialStudio.Core;

public static class ProjectFactory
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true
    };

    public static StudioProject Create(string pmxPath, string runtimeRoot, string outputDirectory)
    {
        var model = PmxReader.Read(pmxPath);
        var project = new StudioProject
        {
            ProjectName = SanitizeProjectName(Path.GetFileNameWithoutExtension(pmxPath)),
            PmxPath = Path.GetFullPath(pmxPath),
            RuntimeRoot = Path.GetFullPath(runtimeRoot),
            OutputDirectory = Path.GetFullPath(outputDirectory),
            HeadBone = FindHeadBone(model)
        };

        foreach (var material in model.Materials)
        {
            var pmxBaseTexture = PmxReader.ResolveTexture(model.FilePath, material.TexturePath)?.ResolvedPath;
            project.Materials.Add(new MaterialAssignment
            {
                MaterialIndex = material.Index,
                MaterialName = material.Name,
                EnglishName = material.EnglishName,
                Role = MaterialClassifier.Suggest(material),
                BaseTextureMode = PmxBaseTextureMode.Inherit,
                PmxBaseTexture = pmxBaseTexture,
                Textures = new TextureSlots
                {
                    Base = pmxBaseTexture
                }
            });
        }

        return project;
    }

    public static void Save(StudioProject project, string path)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
        File.WriteAllText(path, JsonSerializer.Serialize(project, JsonOptions));
    }

    public static StudioProject Load(string path)
    {
        var project = JsonSerializer.Deserialize<StudioProject>(File.ReadAllText(path), JsonOptions)
            ?? throw new InvalidDataException("工程 JSON 无法解析。");
        Normalize(project);
        return project;
    }

    public static void Normalize(StudioProject project)
    {
        project.Materials ??= new List<MaterialAssignment>();
        foreach (var material in project.Materials)
        {
            material.Textures ??= new TextureSlots();
            material.BaseTextureMode ??= material.UsePmxBaseTexture
                ? PmxBaseTextureMode.Inherit
                : PmxBaseTextureMode.Override;
            material.UsePmxBaseTexture = material.BaseTextureMode == PmxBaseTextureMode.Inherit;
        }
        RefreshPmxBaseTextures(project);
    }

    public static void RefreshPmxBaseTextures(StudioProject project)
    {
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath)) return;

        var model = PmxReader.Read(project.PmxPath);
        var pmxMaterials = model.Materials.ToDictionary(material => material.Index);
        foreach (var material in project.Materials)
        {
            if (!pmxMaterials.TryGetValue(material.MaterialIndex, out var pmxMaterial)) continue;
            var resolved = PmxReader.ResolveTexture(model.FilePath, pmxMaterial.TexturePath)?.ResolvedPath;
            material.PmxBaseTexture = resolved;
            if (material.EffectiveBaseTextureMode == PmxBaseTextureMode.Inherit)
                material.Textures.Base = resolved;
        }
    }

    private static string FindHeadBone(PmxModelInfo model)
    {
        foreach (var name in new[] { "頭", "头", "Head", "head" })
        {
            var found = model.BoneNames.FirstOrDefault(candidate => candidate.Equals(name, StringComparison.OrdinalIgnoreCase));
            if (!string.IsNullOrWhiteSpace(found)) return found;
        }
        return model.BoneNames.FirstOrDefault(candidate => candidate.Contains("頭") || candidate.Contains("头") || candidate.Contains("Head", StringComparison.OrdinalIgnoreCase)) ?? "頭";
    }

    public static string SanitizeProjectName(string name)
    {
        var invalid = Path.GetInvalidFileNameChars().ToHashSet();
        var value = new string(name.Select(character => invalid.Contains(character) ? '_' : character).ToArray()).Trim();
        return string.IsNullOrWhiteSpace(value) ? "EndfieldCharacter" : value;
    }
}
