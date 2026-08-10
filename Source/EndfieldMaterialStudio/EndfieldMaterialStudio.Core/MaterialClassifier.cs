namespace EndfieldMaterialStudio.Core;

public static class MaterialClassifier
{
    public static MaterialRole Suggest(PmxMaterialInfo material)
    {
        var value = Normalize($"{material.Name} {material.EnglishName}");

        if (Contains(value, "目透发", "eyeoverlay")) return MaterialRole.EyeOverlay;
        if (Contains(value, "睫眉透发", "browoverlay")) return MaterialRole.BrowOverlay;
        if (Contains(value, "表情", "emotion", "faceproxy", "faceparts", "面部代理")) return MaterialRole.FaceProxy;
        if (Contains(value, "目影", "眼影", "eyeshadow", "发影", "髪影", "hairshadow")) return MaterialRole.None;
        if (Contains(value, "眼白", "目白", "sclera", "eyewhite")) return MaterialRole.EyeWhite;
        if (Contains(value, "目hl", "眼hl", "高光", "highlight", "catchlight", "eyehighlight", "eyehl")) return MaterialRole.EyeHighlight;
        if (Contains(value, "睫毛", "眉毛", "睫眉", "eyelash", "eyebrow", "browlash")) return MaterialRole.BrowLash;
        if (Contains(value, "虹膜", "瞳", "眼睛", "目", "iris", "eyebase") && !Contains(value, "面", "face")) return MaterialRole.Iris;
        if (Contains(value, "口内", "口腔", "嘴", "mouth", "teeth", "tongue")) return MaterialRole.Mouth;
        if (value is "发" or "髪" || Contains(value, "头发", "頭髪", "髪", "hair")) return MaterialRole.Hair;
        if (Contains(value, "皮肤", "皮膚", "肌", "skin", "body") && !Contains(value, "cloth", "衣")) return MaterialRole.Skin;
        if (value is "面" or "脸" or "顔" || Contains(value, "脸", "面部", "顔", "face")) return MaterialRole.Face;
        if (Contains(value, "衣", "布", "服", "裙", "鞋", "靴", "金属", "metal", "cloth", "coat", "dress", "skirt", "shoe", "boot")) return MaterialRole.Cloth;
        return MaterialRole.None;
    }

    private static string Normalize(string value) => value.Replace(" ", string.Empty).Replace("_", string.Empty).ToLowerInvariant();

    private static bool Contains(string value, params string[] tokens) => tokens.Any(value.Contains);
}
