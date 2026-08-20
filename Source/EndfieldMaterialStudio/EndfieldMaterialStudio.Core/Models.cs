using System.Text.Json.Serialization;

namespace EndfieldMaterialStudio.Core;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum MaterialRole
{
    None,
    Face,
    Iris,
    EyeHighlight,
    EyeWhite,
    BrowLash,
    Mouth,
    Hair,
    Skin,
    Cloth,
    EyeOverlay,
    BrowOverlay,
    FaceProxy,
    Hidden
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum EyeThroughParticipation
{
    Auto,
    Ignore,
    Iris,
    Highlight,
    Sclera,
    BrowLash,
    HairDepth,
    ShiftedDepth
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum PmxBaseTextureMode
{
    Inherit,
    Override,
    None
}

public sealed class TextureSlots
{
    public string? Base { get; set; }
    public string? Normal { get; set; }
    public string? Property { get; set; }
    public string? Rd { get; set; }
    public string? Rs { get; set; }
    public string? Lut { get; set; }
    public string? Sdf { get; set; }
    public string? St { get; set; }
    public string? ColorMask { get; set; }
    public string? LipSpecular { get; set; }
    public string? HairLine { get; set; }
}

public sealed class MaterialAssignment
{
    public int MaterialIndex { get; set; }
    public string MaterialName { get; set; } = string.Empty;
    public string EnglishName { get; set; } = string.Empty;
    public MaterialRole Role { get; set; }
    // Auto preserves the legacy role/name classification. Other values are
    // explicit per-material routing for the generated EyeThrough capture.
    public EyeThroughParticipation EyeThrough { get; set; } = EyeThroughParticipation.Auto;
    public TextureSlots Textures { get; set; } = new();
    public PmxBaseTextureMode? BaseTextureMode { get; set; }
    // Kept for loading projects made by versions before the three-state mode.
    public bool UsePmxBaseTexture { get; set; } = true;
    public string? PmxBaseTexture { get; set; }
    public bool Enabled => Role is not MaterialRole.None and not MaterialRole.FaceProxy;

    [JsonIgnore]
    public PmxBaseTextureMode EffectiveBaseTextureMode
        => BaseTextureMode ?? (UsePmxBaseTexture ? PmxBaseTextureMode.Inherit : PmxBaseTextureMode.Override);
}

public sealed class StudioProject
{
    public int SchemaVersion { get; set; } = 2;
    public string ProjectName { get; set; } = "EndfieldCharacter";
    public string PmxPath { get; set; } = string.Empty;
    public string RuntimeRoot { get; set; } = string.Empty;
    public string OutputDirectory { get; set; } = string.Empty;
    public string HeadBone { get; set; } = "頭";
    public bool EnableEyeThrough { get; set; } = true;
    public bool GenerateDerivedPmx { get; set; } = true;
    public List<MaterialAssignment> Materials { get; set; } = new();
}

public sealed class PmxMaterialInfo
{
    public int Index { get; set; }
    public string Name { get; set; } = string.Empty;
    public string EnglishName { get; set; } = string.Empty;
    public string? TexturePath { get; set; }
    public string? SphereTexturePath { get; set; }
    public byte SphereMode { get; set; }
    public string? ToonTexturePath { get; set; }
    public int AdditionalUvCount { get; set; }
    public bool HasUsableUv1 { get; set; }
}

public sealed class PmxModelInfo
{
    public string FilePath { get; set; } = string.Empty;
    public float Version { get; set; }
    public string Encoding { get; set; } = string.Empty;
    public int AdditionalUvCount { get; set; }
    public List<string> BoneNames { get; set; } = new();
    public List<PmxMaterialInfo> Materials { get; set; } = new();
}

public enum PmxTextureKind
{
    Base,
    Sphere,
    Toon
}

public sealed class PmxTextureResolution
{
    public string DeclaredPath { get; init; } = string.Empty;
    public string DirectPath { get; init; } = string.Empty;
    public string ResolvedPath { get; init; } = string.Empty;
    public bool Exists { get; init; }
    public bool UsedFallback { get; init; }
    public string? FallbackDirectory { get; init; }
}

public sealed class PmxTextureDependency
{
    public int MaterialIndex { get; init; }
    public string MaterialName { get; init; } = string.Empty;
    public PmxTextureKind Kind { get; init; }
    public PmxTextureResolution Resolution { get; init; } = new();
}

public sealed class ValidationMessage
{
    public bool IsError { get; init; }
    public string Code { get; init; } = string.Empty;
    public string Message { get; init; } = string.Empty;

    public override string ToString() => $"{(IsError ? "ERROR" : "WARN")} [{Code}] {Message}";
}

public sealed class PackageResult
{
    public string OutputDirectory { get; init; } = string.Empty;
    public string EmmPath { get; init; } = string.Empty;
    public string MaterialMapPath { get; init; } = string.Empty;
    public string ModelPath { get; init; } = string.Empty;
    public IReadOnlyList<string> GeneratedFiles { get; init; } = Array.Empty<string>();
}

public sealed class EyeThroughOverlayBinding
{
    public int SourceMaterialIndex { get; init; }
    public int OverlayMaterialIndex { get; init; }
    public MaterialRole SourceRole { get; init; }
    public MaterialRole OverlayRole { get; init; }
    public string SourceMaterialName { get; init; } = string.Empty;
    public string OverlayMaterialName { get; init; } = string.Empty;
}

public sealed class EyeThroughBuildResult
{
    public string SourcePmxPath { get; init; } = string.Empty;
    public string DerivedPmxPath { get; init; } = string.Empty;
    public bool Created { get; init; }
    public IReadOnlyList<EyeThroughOverlayBinding> Overlays { get; init; } = Array.Empty<EyeThroughOverlayBinding>();
}
