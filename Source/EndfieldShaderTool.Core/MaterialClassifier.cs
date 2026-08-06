namespace EndfieldShaderTool.Core;

public static class MaterialClassifier
{
    public static ShaderDomain Suggest(PmxMaterialInfo material)
    {
        var name = $"{material.Name} {material.EnglishName}".ToLowerInvariant();
        if (Contains(name, "eyeoverlay", "eye overlay", "眼透眼", "眼睛透")) return ShaderDomain.EyeOverlay;
        if (Contains(name, "browoverlay", "brow overlay", "眉透", "睫毛透")) return ShaderDomain.BrowOverlay;
        if (Contains(name, "eye hl", "eyehighlight", "eye highlight", "眼高光", "目光")) return ShaderDomain.EyeHighlight;
        if (Contains(name, "eye white", "eyewhite", "sclera", "眼白")) return ShaderDomain.EyeWhite;
        if (Contains(name, "iris", "pupil", "瞳", "虹膜", "眼球", "眼睛")) return ShaderDomain.Iris;
        if (Contains(name, "eyelash", "brow", "眉", "睫毛", "まゆ")) return ShaderDomain.BrowLash;
        if (Contains(name, "mouth", "tongue", "teeth", "tooth", "口", "嘴", "舌", "牙")) return ShaderDomain.Mouth;
        if (Contains(name, "face", "脸", "面部", "顔")) return ShaderDomain.Face;
        if (Contains(name, "skin", "body skin", "肌", "皮肤", "身体")) return ShaderDomain.Skin;
        if (Contains(name, "hair", "头发", "髮", "发丝")) return ShaderDomain.Hair;
        if (Contains(name, "cloth", "costume", "dress", "coat", "服", "衣", "裙", "鞋", "靴")) return ShaderDomain.Cloth;
        return ShaderDomain.Cloth;
    }

    private static bool Contains(string value, params string[] terms) => terms.Any(value.Contains);
}
