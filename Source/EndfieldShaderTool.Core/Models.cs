using System.Text.Json.Serialization;

namespace EndfieldShaderTool.Core;

public enum ShaderDomain
{
    Face,
    Hair,
    Skin,
    Cloth,
    Body,
    Prop,
    Transparent,
    Iris,
    EyeWhite,
    EyeHighlight,
    BrowLash,
    FaceParts,
    Mouth,
    EyeOverlay,
    BrowOverlay,
    HairShadow,
    Overlay,
    Emissive,
    Eye,
    Unassigned
}

public enum EnvironmentMode
{
    Matcap = 0,
    Hdr = 1
}

public enum BlendMode { Opaque, AlphaZWrite, Overlay }
public enum CullMode { None, Ccw, Cw }
public enum HairSpecularStyle { Smooth, ToonJagged, KajiyaKay }
public enum MatcapLayerMode { Both, ROnly, BOnly }

public sealed class ColorValue
{
    public float R { get; set; }
    public float G { get; set; }
    public float B { get; set; }
    public float A { get; set; } = 1f;

    public ColorValue() { }
    public ColorValue(float r, float g, float b, float a = 1f)
    {
        R = r; G = g; B = b; A = a;
    }
}

public sealed class TextureReference
{
    public string? SourcePath { get; set; }
    public string? PackagePath { get; set; }

    [JsonIgnore]
    public bool IsSelected => !string.IsNullOrWhiteSpace(SourcePath) || !string.IsNullOrWhiteSpace(PackagePath);
}

public sealed class TextureSlots
{
    public TextureReference Base { get; set; } = new();
    public TextureReference Normal { get; set; } = new();
    public TextureReference Property { get; set; } = new();
    public TextureReference Rd { get; set; } = new();
    public TextureReference Rs { get; set; } = new();
    public TextureReference Lut { get; set; } = new();
    public TextureReference Sdf { get; set; } = new();
    public TextureReference St { get; set; } = new();
    public TextureReference ColorMask { get; set; } = new();
    public TextureReference HairLine { get; set; } = new();
    public TextureReference Matcap05 { get; set; } = new();
    public TextureReference Matcap07 { get; set; } = new();

    // Legacy editor aliases. They map to Endfield's neutral slots so older
    // SnowBreak-shaped controls can still load while the Endfield UI is being
    // migrated.
    [JsonIgnore] public TextureReference Material { get => Property; set => Property = value; }
    [JsonIgnore] public TextureReference Id { get => ColorMask; set => ColorMask = value; }
    [JsonIgnore] public TextureReference Ramp { get => Lut; set => Lut = value; }
    [JsonIgnore] public TextureReference Matcap { get => Matcap05; set => Matcap05 = value; }
    [JsonIgnore] public TextureReference ManualMatcap { get => Matcap07; set => Matcap07 = value; }
    [JsonIgnore] public TextureReference Highlight { get => St; set => St = value; }
    [JsonIgnore] public TextureReference LightCurve { get => Lut; set => Lut = value; }
}

public sealed class ShaderParameters
{
    // Compatibility fields keep the SnowBreak-style editor schema stable while
    // the Endfield generator consumes the domain-specific values below.
    public BlendMode BlendMode { get; set; } = BlendMode.Opaque;
    public CullMode CullMode { get; set; } = CullMode.None;
    public bool UseExternalBase { get; set; }
    public bool UsePmxSphere { get; set; }
    public bool UseNormal { get; set; } = true;
    public bool UseRamp { get; set; }
    public bool UseMaterial { get; set; }
    public bool UseId { get; set; }
    public bool UseMatcap { get; set; }
    public bool UseManualMatcapLod { get; set; }
    public bool UseEmission { get; set; }
    public bool UseLightCurve { get; set; }
    public bool UseAlphaClip { get; set; }
    public float AlphaCutoff { get; set; } = 0.5f;
    public float NormalStrengthLegacy { get; set; } = 1f;
    public float NormalYSignLegacy { get; set; } = 1f;
    public float RampRow { get; set; } = 1f;
    public float RampRows { get; set; } = 1f;
    public float RampScale { get; set; } = 1f;
    public float RampBlendStrength { get; set; } = 1f;
    public bool RampToonify { get; set; }
    public float ToonThreshold { get; set; } = 0.5f;
    public float ToonSoftness { get; set; } = 0.03f;
    public float RampShadowScale { get; set; } = 1f;
    public float RampLightScale { get; set; } = 1f;
    public float MaterialRBase { get; set; }
    public float MatcapStrength { get; set; } = 1f;
    public float MatcapRScale { get; set; } = 1f;
    public float MatcapBScale { get; set; } = 1f;
    public float MatcapLodScale { get; set; } = 1f;
    public float EmissionStrength { get; set; } = 1f;
    public float AmbientStrength { get; set; } = 1f;
    public float SpecularStrength { get; set; } = 1f;
    public float SpecularPower { get; set; } = 32f;
    public float SpecularBroadStrength { get; set; } = 1f;
    public float SpecularBaseTint { get; set; }
    public float SpecularShadowMin { get; set; }
    public bool UseProceduralSpecular { get; set; }
    public bool UseMmdLightColor { get; set; } = true;
    public float HighlightStrength { get; set; } = 1f;
    public float HighlightVdotPower { get; set; } = 5f;
    public float HighlightVdotScale { get; set; } = 1f;
    public float HighlightDiffuseScale { get; set; } = 1f;
    public float HighlightShadowScale { get; set; } = 1f;
    public float RimStrength { get; set; } = 0.5f;
    public float RimPower { get; set; } = 2f;
    public float FaceSdfScale { get; set; } = 1f;
    public float FaceDiffuseStrength { get; set; } = 1f;
    public float BodyDiffuseStrength { get; set; } = 1f;
    public float SelfShadowStrength { get; set; } = 1f;
    public float PmxSphereAddStrength { get; set; } = 1f;
    public float PmxSphereMultiplyStrength { get; set; } = 1f;
    public bool UseSdf { get; set; }
    public ColorValue AmbientColor { get; set; } = new(0.42f, 0.46f, 0.55f);
    public ColorValue EmissionColor { get; set; } = new(1f, 1f, 1f);
    public ColorValue SpecularColor { get; set; } = new(1f, 1f, 1f);
    public ColorValue HighlightColor { get; set; } = new(1f, 1f, 1f);
    public ColorValue RimColor { get; set; } = new(1f, 1f, 1f);
    public HairSpecularStyle HairSpecularStyle { get; set; } = HairSpecularStyle.Smooth;
    public int HairUvSet { get; set; }
    public bool UseHighlight { get; set; }
    public int HairKkStrandUvAxis { get; set; } = 1;
    public float HairKkPower { get; set; } = 8f;
    public float HairKkThreshold { get; set; } = 0.18f;
    public float HairKkSoftness { get; set; } = 0.08f;
    public float HairKkTangentShift { get; set; } = 0.08f;
    public float HairKkBaseLobe { get; set; } = 0.15f;
    public float HairKkMinLight { get; set; } = 0.25f;
    public float HairToonSpecularTeeth { get; set; } = 7f;
    public float HairToonSpecularAmplitude { get; set; } = 0.1f;
    public float HairToonSpecularWidth { get; set; } = 0.075f;
    public float HairToonSpecularCutoff { get; set; } = 0.42f;
    public float HairToonSpecularSoftness { get; set; } = 0.012f;
    public MatcapLayerMode MatcapLayerMode { get; set; } = MatcapLayerMode.Both;
    public float NormalStrength { get; set; } = 1f;
    public float NormalYSign { get; set; } = 1f;
    public bool UseSkinBrdfControl { get; set; }
    public bool UseSkinLighting { get; set; }
    public float MatcapExpR { get; set; } = 1f;
    public float MatcapExpB { get; set; } = 1f;
    public float MatcapDiffuseScale { get; set; } = 1f;
    public float MaterialLodScale { get; set; } = 1f;
    public float MatcapLodOverride { get; set; } = -1f;
    public bool MatcapLodRound { get; set; }
    public float MatcapLodBias { get; set; }
    public float MatcapShadowScale { get; set; } = 1f;
    public float EmissionExp { get; set; } = 1f;
    public float FaceGeometricNormalWeight { get; set; } = 1f;
    public ColorValue OverlayColor { get; set; } = new(1f, 1f, 1f, 1f);
    public bool UseMatcap05 { get; set; }
    public bool UseMatcap07 { get; set; }
    public EnvironmentMode EnvironmentMode { get; set; } = EnvironmentMode.Matcap;
    public bool UseFgdLut { get; set; }
    public bool EnableRain { get; set; }
    public float RainMaximum { get; set; } = 1.5f;
    // EyeThrough depends on model-specific material ordering and, for many
    // models, a derived PMX. Keep it opt-in for the generic template.
    public bool EnableEyeThrough { get; set; }
    public bool GenerateEyeThroughDerivedModel { get; set; }
    public bool CastCharacterShadow { get; set; } = true;
}

public sealed class PmxMaterialInfo
{
    public int Index { get; set; }
    public string Name { get; set; } = string.Empty;
    public string EnglishName { get; set; } = string.Empty;
    public string? TexturePath { get; set; }
    public string? SphereTexturePath { get; set; }
    public int SphereMode { get; set; }
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

public sealed class MaterialBinding
{
    public int MaterialIndex { get; set; }
    public string MaterialName { get; set; } = string.Empty;
    public string? PmxTexturePath { get; set; }
    public string? PmxSphereTexturePath { get; set; }
    public int AdditionalUvCount { get; set; }
    public bool HasUsableUv1 { get; set; }
}

public sealed class MaterialProfile
{
    public int MaterialIndex { get; set; }
    public string MaterialName { get; set; } = string.Empty;
    public string? PmxTexturePath { get; set; }
    public string? PmxSphereTexturePath { get; set; }
    public int AdditionalUvCount { get; set; }
    public bool HasUsableUv1 { get; set; }
    public string ProfileName { get; set; } = string.Empty;
    public ShaderDomain Domain { get; set; } = ShaderDomain.Unassigned;
    public bool UsePmxBaseTexture { get; set; } = true;
    public bool UsePmxSphereMap { get; set; }
    public bool CastExcellentShadow { get; set; } = true;
    public TextureSlots Textures { get; set; } = new();
    public ShaderParameters Parameters { get; set; } = new();
    public List<MaterialBinding> MaterialBindings { get; set; } = new();

    [JsonIgnore]
    public int BindingCount => MaterialBindings.Count > 0 ? MaterialBindings.Count : MaterialIndex >= 0 ? 1 : 0;

    [JsonIgnore]
    public string MaterialIndexDisplay => MaterialBindings.Count > 0
        ? string.Join(", ", MaterialBindings.OrderBy(x => x.MaterialIndex).Select(x => x.MaterialIndex))
        : MaterialIndex >= 0 ? MaterialIndex.ToString() : "未绑定";

    [JsonIgnore]
    public string MaterialNameDisplay => MaterialBindings.Count switch
    {
        0 => string.IsNullOrWhiteSpace(MaterialName) ? "未绑定" : MaterialName,
        1 => MaterialBindings[0].MaterialName,
        _ => $"{MaterialBindings[0].MaterialName} 等 {MaterialBindings.Count} 项"
    };

    [JsonIgnore]
    public string PmxTextureDisplay => PmxTexturePath ?? "(无)";
}

public sealed class EndfieldProject
{
    public int SchemaVersion { get; set; } = 1;
    public string RoleName { get; set; } = "NewRole";
    public string RoleSlug { get; set; } = "new_role";
    public string TemplateRoot { get; set; } = string.Empty;
    public string PmxPath { get; set; } = string.Empty;
    public string HeadBone { get; set; } = "頭";
    public bool GenerateEmm { get; set; } = true;
    public bool IncludePostProcessing { get; set; } = true;
    // A generic PMX cannot provide a safe eye-through capture contract by
    // default. The GUI still exposes the option for a model-specific setup.
    public bool IncludeEyeThrough { get; set; }
    public string? EnvironmentPresetPath { get; set; }
    public PmxModelInfo? Model { get; set; }
    public List<MaterialProfile> Profiles { get; set; } = new();
}

public sealed record ValidationMessage(string Code, string Message, bool IsError);

public sealed class ValidationResult
{
    public List<ValidationMessage> Messages { get; } = new();
    public bool IsValid => Messages.All(x => !x.IsError);

    public void Error(string code, string message) => Messages.Add(new(code, message, true));
    public void Warning(string code, string message) => Messages.Add(new(code, message, false));
}

public sealed class GenerationResult
{
    public string OutputDirectory { get; init; } = string.Empty;
    public List<string> GeneratedFiles { get; } = new();
    public ValidationResult Validation { get; init; } = new();
}
