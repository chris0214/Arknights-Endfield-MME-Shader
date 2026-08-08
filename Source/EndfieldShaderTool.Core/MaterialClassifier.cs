namespace EndfieldShaderTool.Core;

public static class MaterialClassifier
{
    public static ShaderDomain Suggest(PmxMaterialInfo material)
    {
        var name = $"{material.Name} {material.EnglishName}".ToLowerInvariant();
        var primary = material.Name.Trim().ToLowerInvariant();

        // Common PMX exports use terse CJK material labels instead of English
        // words. These are category markers, not character-specific names.
        if (primary is "目hl" or "目_hl" or "目高光" or "眼hl" or "眼高光") return ShaderDomain.EyeHighlight;
        if (primary is "目白" or "眼白") return ShaderDomain.EyeWhite;
        if (primary is "目" or "眼" or "瞳") return ShaderDomain.Iris;
        if (primary is "睫眉" or "眉睫" or "眉毛" or "睫毛") return ShaderDomain.BrowLash;
        if (primary is "目影" or "眼影" or "表情" or "顔影" or "面影") return ShaderDomain.FaceParts;
        if (primary is "面" or "顔" or "脸") return ShaderDomain.Face;
        if (primary is "肌" or "皮" or "皮肤") return ShaderDomain.Skin;
        if (primary is "发影" or "髪影" or "頭髪影" or "hairshadow") return ShaderDomain.HairShadow;
        if (primary is "发" or "髪" or "髮" or "頭髪") return ShaderDomain.Hair;

        if (Contains(name, "eyeoverlay", "eye overlay", "眼透眼", "眼睛透")) return ShaderDomain.EyeOverlay;
        if (Contains(name, "browoverlay", "brow overlay", "眉透", "睫毛透")) return ShaderDomain.BrowOverlay;
        if (Contains(name, "eye hl", "eyehighlight", "eye highlight", "眼高光", "目光", "目hl", "眼hl")) return ShaderDomain.EyeHighlight;
        if (Contains(name, "eye white", "eyewhite", "sclera", "眼白")) return ShaderDomain.EyeWhite;
        if (Contains(name, "iris", "pupil", "瞳", "虹膜", "眼球", "眼睛", "目")) return ShaderDomain.Iris;
        if (Contains(name, "eyelash", "brow", "眉", "睫毛", "まゆ")) return ShaderDomain.BrowLash;
        if (Contains(name, "hairshadow", "hair shadow", "发影", "髪影")) return ShaderDomain.HairShadow;
        if (Contains(name, "face parts", "facepart", "表情", "眼影", "目影", "顔影")) return ShaderDomain.FaceParts;
        if (Contains(name, "mouth", "tongue", "teeth", "tooth", "口", "嘴", "舌", "牙")) return ShaderDomain.Mouth;
        if (Contains(name, "face", "脸", "面部", "顔")) return ShaderDomain.Face;
        if (Contains(name, "skin", "body skin", "肌", "皮肤", "身体")) return ShaderDomain.Skin;
        if (Contains(name, "hair", "头发", "髮", "发丝")) return ShaderDomain.Hair;
        if (Contains(name, "cloth", "costume", "dress", "coat", "服", "衣", "裙", "鞋", "靴")) return ShaderDomain.Cloth;
        return ShaderDomain.Cloth;
    }

    private static bool Contains(string value, params string[] terms) => terms.Any(value.Contains);
}
