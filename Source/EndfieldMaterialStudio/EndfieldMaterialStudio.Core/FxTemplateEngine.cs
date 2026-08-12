using System.Text;
using System.Text.RegularExpressions;

namespace EndfieldMaterialStudio.Core;

public static class FxTemplateEngine
{
    private const string FaceLipSpecularDefault = "textures/common/T_actor_common_face_01_hl_M.png";
    private const string IrisMatcap05 = "textures/common/T_actor_common_matcap_05_D.png";
    private const string IrisMatcap07 = "textures/common/T_actor_common_matcap_07_D.png";

    static FxTemplateEngine() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    public static byte[] BuildMaterialFx(
        MaterialAssignment material,
        TextureSlots packaged,
        string headBone,
        string bindingFileName)
    {
        var text = material.Role switch
        {
            MaterialRole.Face => BuildFace(packaged, bindingFileName),
            MaterialRole.Hair => BuildHair(packaged),
            MaterialRole.Cloth => BuildCloth(packaged),
            MaterialRole.Skin => BuildSkin(packaged),
            MaterialRole.Iris => BuildIris(packaged, headBone),
            MaterialRole.EyeHighlight => BuildEyeHighlight(packaged, bindingFileName),
            MaterialRole.EyeWhite => BuildSimpleBase("EndfieldEyeWhite_Template.fx", "__EF_FACIAL_BASE_TEXTURE__", packaged),
            MaterialRole.BrowLash => BuildFacial("EndfieldBrowLash_Template.fx", packaged, headBone),
            MaterialRole.Mouth => BuildFacial("EndfieldMouth_Template.fx", packaged, headBone),
            MaterialRole.EyeOverlay => BuildFacial("EndfieldEyeOverlay_Template.fx", packaged, headBone),
            MaterialRole.BrowOverlay => BuildFacial("EndfieldBrowOverlay_Template.fx", packaged, headBone),
            MaterialRole.Hidden => "#include \"internal/endfield_hidden.hlsl\"\r\n",
            _ => throw new InvalidOperationException($"材质角色 {material.Role} 不生成 FX。")
        };
        return RequiresCp932(material.Role)
            ? Encoding.GetEncoding(932).GetBytes(text)
            : new UTF8Encoding(false).GetBytes(text);
    }

    public static byte[] BuildFaceBinding(string headBone)
    {
        var text = $"float4x4 EfFaceHeadBone : CONTROLOBJECT < string name = \"(self)\"; string item = \"{EscapeQuoted(headBone)}\"; >;\r\n" +
                   "float3 EfFaceMmdLightDirection : DIRECTION < string Object = \"Light\"; >;\r\n";
        return Encoding.GetEncoding(932).GetBytes(text);
    }

    public static string BuildEyeCapture(
        StudioProject project,
        TextureSlots irisPackaged,
        string headBone)
    {
        var text = ReadTemplate("EndfieldEyeThrough_Capture_Template.fxsub");
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_HEAD_BONE", EscapeQuoted(headBone));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_EYE_SUBSETS", Subsets(project, MaterialRole.Iris));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_HIGHLIGHT_SUBSETS", Subsets(project, MaterialRole.EyeHighlight));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_SCLERA_SUBSETS", Subsets(project, MaterialRole.EyeWhite));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_BROW_SUBSETS", Subsets(project, MaterialRole.BrowLash));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_IGNORED_SUBSETS", IgnoredSubsets(project));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_HAIR_DEPTH_SUBSETS", HairDepthSubsets(project));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_SHIFTED_SUBSETS", Subsets(project, MaterialRole.FaceProxy, MaterialRole.EyeOverlay, MaterialRole.BrowOverlay));
        text = InsertBeforeInclude(text, "internal/endfield_eye_through_capture_core.fxsub",
            $"#define EF_EYE_CAPTURE_IRIS_TEXTURE_RESOURCE \"{Required(irisPackaged.Base, "Iris Base")}\"\r\n" +
            $"#define EF_EYE_IRIS_MATCAP05_TEXTURE \"{IrisMatcap05}\"\r\n" +
            $"#define EF_EYE_IRIS_MATCAP07_TEXTURE \"{IrisMatcap07}\"\r\n" +
            $"#define EF_EYE_HL_TEXTURE_RESOURCE \"{Required(irisPackaged.Base, "Iris Base")}\"\r\n");
        return text;
    }

    public static string BuildHairVisibilityCapture(StudioProject project)
    {
        var text = ReadTemplate("EndfieldHairVisibility_Capture_Template.fxsub");
        text = ReplaceDefineString(text, "EF_HAIR_VISIBILITY_SUBSETS",
            Subsets(project, MaterialRole.Hair));
        text = ReplaceDefineString(text, "EF_HAIR_VISIBILITY_FACE_OCCLUDER_SUBSETS",
            Subsets(project, MaterialRole.Face, MaterialRole.Iris, MaterialRole.EyeWhite));
        return text;
    }

    private static string BuildFace(TextureSlots textures, string bindingFileName)
    {
        var entry = ReadTemplate("EndfieldFace_Template.fx");
        entry = entry.Replace("__EF_FACE_BINDING__", bindingFileName, StringComparison.Ordinal);
        entry = ReplaceResources(entry, new Dictionary<string, string>
        {
            ["__EF_FACE_SDF_TEXTURE__"] = Required(textures.Sdf, "Face SDF"),
            ["__EF_FACE_COLOR_MASK_TEXTURE__"] = Required(textures.ColorMask, "Face ColorMask"),
            ["__EF_FACE_RD_TEXTURE__"] = Required(textures.Rd, "Face RD"),
            ["__EF_FACE_LUT_TEXTURE__"] = Required(textures.Lut, "Face LUT"),
            ["__EF_FACE_ST_TEXTURE__"] = Required(textures.St, "Face ST")
        });

        const string include = "#include \"EndfieldFace_Final.fx\"";
        var includeIndex = entry.IndexOf(include, StringComparison.Ordinal);
        if (includeIndex < 0) throw new InvalidDataException("Face 模板缺少 EndfieldFace_Final.fx 入口。");

        var final = ReadTemplate("EndfieldFace_Final.fx");
        final = final.Replace(
            "__EF_FACE_BASE_TEXTURE__",
            Required(textures.Base, "Face Base"),
            StringComparison.Ordinal);
        var lipSpecular = string.IsNullOrWhiteSpace(textures.LipSpecular)
            ? FaceLipSpecularDefault
            : Required(textures.LipSpecular, "Face Lip Specular");
        return entry[..includeIndex] +
               $"#define EF_FACE_LIP_SPECULAR_TEXTURE_RESOURCE \"{lipSpecular}\"\r\n" +
               final;
    }

    private static string BuildIris(TextureSlots textures, string headBone)
    {
        var text = BuildFacial("EndfieldEye_Template.fx", textures, headBone);
        return $"#define EF_EYE_IRIS_MATCAP05_TEXTURE \"{IrisMatcap05}\"\r\n" +
               $"#define EF_EYE_IRIS_MATCAP07_TEXTURE \"{IrisMatcap07}\"\r\n" +
               text;
    }

    private static string BuildHair(TextureSlots textures)
    {
        var entry = ReadTemplate("EndfieldHair_Template.fx");
        var include = "#include \"EndfieldHair_Final.fx\"";
        var prefix = entry[..entry.IndexOf(include, StringComparison.Ordinal)];
        var final = ReadTemplate("EndfieldHair_Final.fx");
        final = ReplaceResources(final, new Dictionary<string, string>
        {
            ["__EF_HAIR_BASE_TEXTURE__"] = Required(textures.Base, "Hair Base"),
            ["__EF_HAIR_NORMAL_TEXTURE__"] = Required(textures.Normal, "Hair Normal"),
            ["__EF_HAIR_PROPERTY_TEXTURE__"] = Required(textures.Property, "Hair Property"),
            ["__EF_HAIR_RD_TEXTURE__"] = Required(textures.Rd, "Hair RD"),
            ["__EF_HAIR_ST_TEXTURE__"] = Required(textures.St, "Hair ST"),
            ["__EF_HAIR_LINE_TEXTURE__"] = Required(textures.HairLine, "HairLine"),
            ["__EF_HAIR_RS_TEXTURE__"] = Required(textures.Rs, "Hair RS")
        });
        return prefix + final;
    }

    private static string BuildCloth(TextureSlots textures) => ReplaceResources(
        ReadTemplate("EndfieldCloth_Template.fx"),
        new Dictionary<string, string>
        {
            ["__EF_CLOTH_BASE_TEXTURE__"] = Required(textures.Base, "Cloth Base"),
            ["__EF_CLOTH_NORMAL_TEXTURE__"] = Required(textures.Normal, "Cloth Normal"),
            ["__EF_CLOTH_PROPERTY_TEXTURE__"] = Required(textures.Property, "Cloth Property"),
            ["__EF_CLOTH_RD_TEXTURE__"] = Required(textures.Rd, "Cloth RD"),
            ["__EF_CLOTH_LUT_TEXTURE__"] = Required(textures.Lut, "Cloth LUT"),
            ["__EF_CLOTH_RS_TEXTURE__"] = Required(textures.Rs, "Cloth RS")
        });

    private static string BuildSkin(TextureSlots textures) => ReplaceResources(
        ReadTemplate("EndfieldSkin_Template.fx"),
        new Dictionary<string, string>
        {
            ["__EF_SKIN_BASE_TEXTURE__"] = Required(textures.Base, "Skin Base"),
            ["__EF_SKIN_RD_TEXTURE__"] = Required(textures.Rd, "Skin RD"),
            ["__EF_SKIN_LUT_TEXTURE__"] = Required(textures.Lut, "Skin LUT")
        });

    private static string BuildEyeHighlight(TextureSlots textures, string bindingFileName)
    {
        var text = BuildSimpleBase("EndfieldEyeHighlight_Template.fx", "__EF_EYE_HIGHLIGHT_TEXTURE__", textures);
        return text.Replace("__EF_FACE_BINDING__", bindingFileName, StringComparison.Ordinal);
    }

    private static string BuildSimpleBase(string templateName, string textureToken, TextureSlots textures)
    {
        var text = ReadTemplate(templateName);
        return text.Replace(textureToken, Required(textures.Base, $"{templateName} Base"), StringComparison.Ordinal);
    }

    private static string BuildFacial(string templateName, TextureSlots textures, string headBone)
    {
        var text = BuildSimpleBase(templateName, "__EF_FACIAL_BASE_TEXTURE__", textures);
        return Regex.Replace(text, "string\\s+item\\s*=\\s*\"[^\"]*\"\\s*;", $"string item = \"{EscapeQuoted(headBone)}\";", RegexOptions.CultureInvariant);
    }

    private static string Subsets(StudioProject project, params MaterialRole[] roles)
    {
        var values = project.Materials.Where(material => roles.Contains(material.Role))
            .Select(material => material.MaterialIndex)
            .Distinct()
            .OrderBy(index => index)
            .ToArray();
        return values.Length == 0 ? "2147483647" : string.Join(",", values);
    }

    private static string IgnoredSubsets(StudioProject project)
    {
        var values = project.Materials.Where(material => material.Role == MaterialRole.None)
            .Where(material => ContainsAny(material, "目影", "眼影", "eyeshadow"))
            .Select(material => material.MaterialIndex)
            .OrderBy(index => index)
            .ToArray();
        return values.Length == 0 ? "2147483647" : string.Join(",", values);
    }

    private static string HairDepthSubsets(StudioProject project)
    {
        var values = project.Materials
            .Where(material => material.Role == MaterialRole.Hair ||
                               (material.Role == MaterialRole.None && ContainsAny(material, "发影", "髪影", "hairshadow")))
            .Select(material => material.MaterialIndex)
            .Distinct()
            .OrderBy(index => index)
            .ToArray();
        return values.Length == 0 ? "2147483647" : string.Join(",", values);
    }

    private static bool ContainsAny(MaterialAssignment material, params string[] values)
    {
        var text = $"{material.MaterialName} {material.EnglishName}";
        return values.Any(value => text.Contains(value, StringComparison.OrdinalIgnoreCase));
    }

    private static string ReplaceDefineString(string text, string name, string value) =>
        Regex.Replace(text, $"#define\\s+{Regex.Escape(name)}\\s+\"[^\"]*\"", $"#define {name} \"{value}\"", RegexOptions.CultureInvariant);

    private static string InsertBeforeInclude(string text, string includePath, string definitions)
    {
        var include = $"#include \"{includePath}\"";
        var index = text.IndexOf(include, StringComparison.Ordinal);
        if (index < 0) throw new InvalidDataException($"Eye Capture 模板缺少 {includePath} 入口。");
        return text.Insert(index, definitions);
    }

    private static string ReplaceResources(string text, IReadOnlyDictionary<string, string> replacements)
    {
        foreach (var pair in replacements) text = text.Replace(pair.Key, pair.Value.Replace('\\', '/'), StringComparison.Ordinal);
        return text;
    }

    private static string ReadTemplate(string name)
    {
        var resourceName = $"EndfieldMaterialStudio.Core.Templates.{name}";
        using var stream = typeof(FxTemplateEngine).Assembly.GetManifestResourceStream(resourceName)
            ?? throw new FileNotFoundException($"找不到内嵌材质模板：{name}", resourceName);
        using var memory = new MemoryStream();
        stream.CopyTo(memory);
        var bytes = memory.ToArray();
        try
        {
            return new UTF8Encoding(false, true).GetString(bytes);
        }
        catch (DecoderFallbackException)
        {
            return Encoding.GetEncoding(932).GetString(bytes);
        }
    }

    private static string Required(string? value, string label) =>
        string.IsNullOrWhiteSpace(value) ? throw new InvalidDataException($"缺少 {label} 贴图。") : value.Replace('\\', '/');

    private static bool RequiresCp932(MaterialRole role) => role is MaterialRole.Iris or MaterialRole.BrowLash or MaterialRole.Mouth or MaterialRole.EyeOverlay or MaterialRole.BrowOverlay;
    private static string EscapeQuoted(string value) => value.Replace("\\", "\\\\").Replace("\"", "\\\"");
}
