using System.Text;
using System.Text.Json;

namespace EndfieldMaterialStudio.Core;

/// <summary>
/// Writes the model-to-FX contract used by the independent-material workflow.
/// The manifest is deliberately separate from EMM so manual MME assignment remains possible.
/// </summary>
public static class MaterialMapWriter
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true
    };

    public static byte[] Build(
        StudioProject project,
        string packageRoot,
        string packagedModelPath,
        string packagedModelReadPath,
        IReadOnlyDictionary<int, string> materialFxPaths,
        IReadOnlyDictionary<int, TextureSlots> packagedTextures,
        string? emmPath,
        string? eyeCapturePath)
    {
        var packagedModel = PmxReader.Read(packagedModelReadPath);
        var missingFx = project.Materials
            .Where(material => material.Enabled && !materialFxPaths.ContainsKey(material.MaterialIndex))
            .Select(material => $"#{material.MaterialIndex} {material.MaterialName}")
            .ToArray();
        if (missingFx.Length > 0)
            throw new InvalidDataException($"启用材质没有生成独立 FX：{string.Join("、", missingFx)}");

        var pmxBaseTextures = packagedModel.Materials.ToDictionary(
            material => material.Index,
            material => PmxReader.ResolveTextureFilePath(packagedModelPath, material.TexturePath));

        var document = new MaterialMapDocument
        {
            ProjectName = project.ProjectName,
            ModelPath = RelativeFile(packageRoot, packagedModelPath)
                ?? throw new InvalidDataException("打包清单缺少角色 PMX 路径。"),
            EyeThroughEnabled = project.EnableEyeThrough,
            EyeCaptureFxSub = RelativeFile(packageRoot, eyeCapturePath),
            MaterialEmmRequired = false,
            ShadowRouting = "zmd-default-effect",
            ShadowEmmRequired = false,
            EyeThroughEmmRequired = false,
            EmmOptional = true,
            EmmPath = RelativeFile(packageRoot, emmPath),
            Materials = project.Materials
                .OrderBy(material => material.MaterialIndex)
                .Select(material => new MaterialMapEntry
                {
                    MaterialIndex = material.MaterialIndex,
                    MaterialName = material.MaterialName,
                    EnglishName = material.EnglishName,
                    Role = material.Role,
                    Enabled = material.Enabled,
                    FxPath = materialFxPaths.TryGetValue(material.MaterialIndex, out var fx)
                        ? RelativeFile(packageRoot, fx)
                        : null,
                    UsePmxBaseTexture = material.UsePmxBaseTexture,
                    PmxBaseTexture = pmxBaseTextures.TryGetValue(material.MaterialIndex, out var pmxBase)
                        ? RelativeFile(packageRoot, pmxBase)
                        : null,
                    Textures = packagedTextures.TryGetValue(material.MaterialIndex, out var textures)
                        ? RelativeSlots(textures)
                        : new TextureSlots()
                })
                .ToList()
        };

        var json = JsonSerializer.Serialize(document, JsonOptions) + Environment.NewLine;
        return new UTF8Encoding(false).GetBytes(json);
    }

    private static TextureSlots RelativeSlots(TextureSlots source) => new()
    {
        Base = RelativePath(source.Base),
        Normal = RelativePath(source.Normal),
        Property = RelativePath(source.Property),
        Rd = RelativePath(source.Rd),
        Rs = RelativePath(source.Rs),
        Lut = RelativePath(source.Lut),
        Sdf = RelativePath(source.Sdf),
        St = RelativePath(source.St),
        ColorMask = RelativePath(source.ColorMask),
        LipSpecular = RelativePath(source.LipSpecular),
        HairLine = RelativePath(source.HairLine)
    };

    private static string? RelativeFile(string packageRoot, string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return null;
        var root = Path.GetFullPath(packageRoot);
        var full = Path.GetFullPath(path);
        var prefix = root.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!full.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException($"打包清单路径越出了角色包：{path}");
        return Path.GetRelativePath(root, full).Replace('\\', '/');
    }

    private static string? RelativePath(string? path) =>
        string.IsNullOrWhiteSpace(path) ? null : path.Replace('\\', '/');
}

public sealed class MaterialMapDocument
{
    public int SchemaVersion { get; init; } = 1;
    public string Format { get; init; } = "EndfieldMaterialStudio.MaterialMap";
    public string Workflow { get; init; } = "independent-material-fx";
    public string ProjectName { get; init; } = string.Empty;
    public string ModelPath { get; init; } = string.Empty;
    public bool EyeThroughEnabled { get; init; }
    public string? EyeCaptureFxSub { get; init; }
    public bool MaterialEmmRequired { get; init; }
    public string ShadowRouting { get; init; } = string.Empty;
    public bool ShadowEmmRequired { get; init; }
    public bool EyeThroughEmmRequired { get; init; }
    public bool EmmOptional { get; init; }
    public string? EmmPath { get; init; }
    public List<MaterialMapEntry> Materials { get; init; } = new();
}

public sealed class MaterialMapEntry
{
    public int MaterialIndex { get; init; }
    public string MaterialName { get; init; } = string.Empty;
    public string EnglishName { get; init; } = string.Empty;
    public MaterialRole Role { get; init; }
    public bool Enabled { get; init; }
    public string? FxPath { get; init; }
    public bool UsePmxBaseTexture { get; init; }
    public string? PmxBaseTexture { get; init; }
    public TextureSlots Textures { get; init; } = new();
}
