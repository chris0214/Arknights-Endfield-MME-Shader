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
        string runtimeRoot,
        MaterialAssignment material,
        TextureSlots packaged,
        string headBone,
        string bindingFileName)
    {
        var text = material.Role switch
        {
            MaterialRole.Face => BuildFace(runtimeRoot, packaged, bindingFileName),
            MaterialRole.Hair => BuildHair(runtimeRoot, packaged),
            MaterialRole.Cloth => BuildCloth(runtimeRoot, packaged),
            MaterialRole.Skin => BuildSkin(runtimeRoot, packaged),
            MaterialRole.Iris => BuildIris(runtimeRoot, packaged, headBone),
            MaterialRole.EyeHighlight => BuildEyeHighlight(runtimeRoot, packaged, bindingFileName),
            MaterialRole.EyeWhite => BuildSimpleBase(runtimeRoot, "EndfieldEyeWhite_ChenQianyu.fx", packaged),
            MaterialRole.BrowLash => BuildFacial(runtimeRoot, "EndfieldFacial_ChenQianyu.fx", packaged, headBone),
            MaterialRole.Mouth => BuildFacial(runtimeRoot, "EndfieldMouth_ChenQianyu.fx", packaged, headBone),
            MaterialRole.EyeOverlay => BuildFacial(runtimeRoot, "EndfieldEyeOverlay_ChenQianyu.fx", packaged, headBone),
            MaterialRole.BrowOverlay => BuildFacial(runtimeRoot, "EndfieldBrowOverlay_ChenQianyu.fx", packaged, headBone),
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
        string runtimeRoot,
        StudioProject project,
        TextureSlots irisPackaged,
        string bindingFileName)
    {
        var text = ReadTemplate(Path.Combine(runtimeRoot, "EndfieldEyeThrough_Capture_ChenQianyu.fxsub"));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_EYE_SUBSETS", Subsets(project, MaterialRole.Iris));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_HIGHLIGHT_SUBSETS", Subsets(project, MaterialRole.EyeHighlight));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_SCLERA_SUBSETS", Subsets(project, MaterialRole.EyeWhite));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_BROW_SUBSETS", Subsets(project, MaterialRole.BrowLash));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_IGNORED_SUBSETS", IgnoredSubsets(project));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_HAIR_DEPTH_SUBSETS", HairDepthSubsets(project));
        text = ReplaceDefineString(text, "EF_EYE_CAPTURE_SHIFTED_SUBSETS", Subsets(project, MaterialRole.FaceProxy, MaterialRole.EyeOverlay, MaterialRole.BrowOverlay));
        text = InsertBeforeInclude(text, "internal/endfield_eye.hlsl",
            $"#define EF_EYE_IRIS_MATCAP05_TEXTURE \"{IrisMatcap05}\"\r\n" +
            $"#define EF_EYE_IRIS_MATCAP07_TEXTURE \"{IrisMatcap07}\"\r\n");
        text = InsertBeforeInclude(text, "internal/endfield_eye_highlight.hlsl",
            $"#define EF_EYE_HL_TEXTURE_RESOURCE \"{Required(irisPackaged.Base, "Iris Base")}\"\r\n");
        text = text.Replace("internal/chen_qianyu_face_binding.cp932", $"internal/{bindingFileName}", StringComparison.Ordinal);
        text = text.Replace("textures/chen/T_actor_chen_iris_01_D.png", Required(irisPackaged.Base, "Iris Base"), StringComparison.Ordinal);
        return text;
    }

    private static string BuildFace(string runtimeRoot, TextureSlots textures, string bindingFileName)
    {
        var entry = ReadTemplate(Path.Combine(runtimeRoot, "EndfieldFace_ChenQianyu.fx"));
        entry = entry.Replace("internal/chen_qianyu_face_binding.cp932", $"internal/{bindingFileName}", StringComparison.Ordinal);
        entry = ReplaceResources(entry, new Dictionary<string, string>
        {
            ["textures/chen/T_actor_common_female_face_01_SDF.png"] = Required(textures.Sdf, "Face SDF"),
            ["textures/chen/T_actor_common_female_face_01_cm_M.png"] = Required(textures.ColorMask, "Face ColorMask"),
            ["textures/chen/T_actor_common_face_01_RD.png"] = Required(textures.Rd, "Face RD"),
            ["textures/chen/T_actor_common_femaleskincolor02_lut_D.png"] = Required(textures.Lut, "Face LUT"),
            ["textures/chen/T_actor_common_female_face_01_ST.png"] = Required(textures.St, "Face ST")
        });

        const string include = "#include \"EndfieldFace_Final.fx\"";
        var includeIndex = entry.IndexOf(include, StringComparison.Ordinal);
        if (includeIndex < 0) throw new InvalidDataException("Face 模板缺少 EndfieldFace_Final.fx 入口。");

        var final = ReadTemplate(Path.Combine(runtimeRoot, "EndfieldFace_Final.fx"));
        final = final.Replace(
            "textures/chen/T_actor_chen_face_01_D.png",
            Required(textures.Base, "Face Base"),
            StringComparison.Ordinal);
        var lipSpecular = string.IsNullOrWhiteSpace(textures.LipSpecular)
            ? FaceLipSpecularDefault
            : Required(textures.LipSpecular, "Face Lip Specular");
        return entry[..includeIndex] +
               $"#define EF_FACE_LIP_SPECULAR_TEXTURE_RESOURCE \"{lipSpecular}\"\r\n" +
               final;
    }

    private static string BuildIris(string runtimeRoot, TextureSlots textures, string headBone)
    {
        var text = BuildFacial(runtimeRoot, "EndfieldEyeBase_ChenQianyu.fx", textures, headBone);
        return $"#define EF_EYE_IRIS_MATCAP05_TEXTURE \"{IrisMatcap05}\"\r\n" +
               $"#define EF_EYE_IRIS_MATCAP07_TEXTURE \"{IrisMatcap07}\"\r\n" +
               text;
    }

    private static string BuildHair(string runtimeRoot, TextureSlots textures)
    {
        var entry = ReadTemplate(Path.Combine(runtimeRoot, "EndfieldHair_ChenQianyu.fx"));
        var include = "#include \"EndfieldHair_Final.fx\"";
        var prefix = entry[..entry.IndexOf(include, StringComparison.Ordinal)];
        var final = ReadTemplate(Path.Combine(runtimeRoot, "EndfieldHair_Final.fx"));
        final = ReplaceResources(final, new Dictionary<string, string>
        {
            ["textures/chen/T_actor_chen_hair_01_D.png"] = Required(textures.Base, "Hair Base"),
            ["textures/chen/T_actor_chen_hair_01_HN.png"] = Required(textures.Normal, "Hair Normal"),
            ["textures/chen/T_actor_chen_hair_01_P.png"] = Required(textures.Property, "Hair Property"),
            ["textures/chen/T_actor_common_hair_01_RD.png"] = Required(textures.Rd, "Hair RD"),
            ["textures/chen/T_actor_common_hairst_01_ST.png"] = Required(textures.St, "Hair ST"),
            ["textures/chen/T_actor_common_hairline_03_M.png"] = Required(textures.HairLine, "HairLine"),
            ["textures/chen/T_actor_common_hair_08_RS.png"] = Required(textures.Rs, "Hair RS")
        });
        return prefix + final;
    }

    private static string BuildCloth(string runtimeRoot, TextureSlots textures) => ReplaceResources(
        ReadTemplate(Path.Combine(runtimeRoot, "EndfieldCloth_ChenQianyu.fx")),
        new Dictionary<string, string>
        {
            ["textures/chen/T_actor_chen_cloth_01_D.png"] = Required(textures.Base, "Cloth Base"),
            ["textures/chen/T_actor_chen_cloth_01_N.png"] = Required(textures.Normal, "Cloth Normal"),
            ["textures/chen/T_actor_chen_cloth_01_P.png"] = Required(textures.Property, "Cloth Property"),
            ["textures/chen/T_actor_common_cloth_04_RD.png"] = Required(textures.Rd, "Cloth RD"),
            ["textures/chen/T_actor_common_cloth_lut_01_D.png"] = Required(textures.Lut, "Cloth LUT"),
            ["textures/chen/T_actor_common_cloth_04_RS.png"] = Required(textures.Rs, "Cloth RS")
        });

    private static string BuildSkin(string runtimeRoot, TextureSlots textures) => ReplaceResources(
        ReadTemplate(Path.Combine(runtimeRoot, "EndfieldSkin_ChenQianyu.fx")),
        new Dictionary<string, string>
        {
            ["textures/chen/T_actor_chen_body_01_D.png"] = Required(textures.Base, "Skin Base"),
            ["textures/chen/T_actor_common_body_01_RD.png"] = Required(textures.Rd, "Skin RD"),
            ["textures/chen/T_actor_common_femaleskincolor02_lut_D.png"] = Required(textures.Lut, "Skin LUT")
        });

    private static string BuildEyeHighlight(string runtimeRoot, TextureSlots textures, string bindingFileName)
    {
        var text = BuildSimpleBase(runtimeRoot, "EndfieldEyeHighlight_ChenQianyu.fx", textures);
        return text.Replace("internal/chen_qianyu_face_binding.cp932", $"internal/{bindingFileName}", StringComparison.Ordinal);
    }

    private static string BuildSimpleBase(string runtimeRoot, string templateName, TextureSlots textures)
    {
        var text = ReadTemplate(Path.Combine(runtimeRoot, templateName));
        var oldPath = templateName switch
        {
            "EndfieldEyeBase_ChenQianyu.fx" or
            "EndfieldEyeHighlight_ChenQianyu.fx" or
            "EndfieldEyeOverlay_ChenQianyu.fx" => "textures/chen/T_actor_chen_iris_01_D.png",
            _ => "textures/chen/T_actor_chen_face_01_D.png"
        };
        return text.Replace(oldPath, Required(textures.Base, $"{templateName} Base"), StringComparison.Ordinal);
    }

    private static string BuildFacial(string runtimeRoot, string templateName, TextureSlots textures, string headBone)
    {
        var text = BuildSimpleBase(runtimeRoot, templateName, textures);
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

    private static string ReadTemplate(string path)
    {
        var bytes = File.ReadAllBytes(path);
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
