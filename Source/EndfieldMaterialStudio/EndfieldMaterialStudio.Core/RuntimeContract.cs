namespace EndfieldMaterialStudio.Core;

public static class RuntimeContract
{
    private static readonly string[] FixedTextureNames =
    {
        "T_actor_common_face_01_hl_M.png",
        "T_actor_common_matcap_05_D.png",
        "T_actor_common_matcap_07_D.png",
        "T_actor_common_cloth_lut_01_D.png"
    };

    private static readonly string[] RequiredTopLevelFiles =
    {
        "EndfieldHair_Final.fx",
        "EndfieldFace_Final.fx",
        "EndfieldFace_ChenQianyu.fx",
        "EndfieldHair_ChenQianyu.fx",
        "EndfieldCloth_ChenQianyu.fx",
        "EndfieldSkin_ChenQianyu.fx",
        "EndfieldEyeBase_ChenQianyu.fx",
        "EndfieldEyeHighlight_ChenQianyu.fx",
        "EndfieldEyeWhite_ChenQianyu.fx",
        "EndfieldFacial_ChenQianyu.fx",
        "EndfieldMouth_ChenQianyu.fx",
        "EndfieldEyeOverlay_ChenQianyu.fx",
        "EndfieldBrowOverlay_ChenQianyu.fx",
        "EndfieldEyeThrough_Capture_ChenQianyu.fxsub",
        "EndfieldHairVisibility_Capture.fxsub",
        "EndfieldEyeThrough_Mask.fxsub",
        "EndfieldEyeThrough.fx",
        "EndfieldEyeThrough.x",
        "ZMDshadow.x",
        "ZMDshadow.fx",
        "ZMDshadow_ShadowMap.fxsub",
        "ZMDshadow_ViewportMap.fxsub",
        "HgShadow_CFSUSM.fxh",
        "HgShadow_CLSPSM.fxh",
        "HgShadow_Header.fxh"
    };

    private static readonly string[] CopiedTopLevelFiles =
    {
        "EndfieldHair_Final.fx",
        "EndfieldFace_Final.fx",
        "EndfieldEyeThrough_Mask.fxsub",
        "EndfieldHairVisibility_Capture.fxsub",
        "EndfieldEyeThrough.fx",
        "EndfieldEyeThrough.x",
        "ZMDshadow.x",
        "ZMDshadow.fx",
        "ZMDshadow_ShadowMap.fxsub",
        "ZMDshadow_ViewportMap.fxsub",
        "HgShadow_CFSUSM.fxh",
        "HgShadow_CLSPSM.fxh",
        "HgShadow_Header.fxh",
        "EndfieldPost.fx",
        "EndfieldPost.x",
        "JitteredSamp.png"
    };

    public static IReadOnlyList<ValidationMessage> Validate(string runtimeRoot)
    {
        var messages = new List<ValidationMessage>();
        if (string.IsNullOrWhiteSpace(runtimeRoot) || !Directory.Exists(runtimeRoot))
        {
            messages.Add(Error("RUNTIME_ROOT", "没有找到 EndfieldMME 运行时目录。"));
            return messages;
        }

        foreach (var directory in new[] { "internal", "controller", Path.Combine("textures", "common") })
        {
            if (!Directory.Exists(Path.Combine(runtimeRoot, directory)))
                messages.Add(Error("RUNTIME_DIRECTORY", $"运行时缺少目录：{directory}"));
        }

        foreach (var name in RequiredTopLevelFiles)
        {
            if (!File.Exists(Path.Combine(runtimeRoot, name)))
                messages.Add(Error("RUNTIME_FILE", $"运行时缺少权威文件：{name}"));
        }
        foreach (var name in FixedTextureNames)
        {
            if (FindFixedTexture(runtimeRoot, name) is null)
                messages.Add(Error("RUNTIME_TEXTURE", $"运行时缺少通用固定贴图：{name}"));
        }
        return messages;
    }

    public static IReadOnlyList<string> CopyRuntime(string runtimeRoot, string outputRoot)
    {
        var validation = Validate(runtimeRoot);
        var errors = validation.Where(message => message.IsError).ToArray();
        if (errors.Length > 0) throw new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.Message)));

        var files = new List<string>();
        CopyDirectory(Path.Combine(runtimeRoot, "internal"), Path.Combine(outputRoot, "internal"), files);
        CopyDirectory(Path.Combine(runtimeRoot, "controller"), Path.Combine(outputRoot, "controller"), files);
        CopyDirectory(Path.Combine(runtimeRoot, "textures", "common"), Path.Combine(outputRoot, "textures", "common"), files);
        CopyDirectory(Path.Combine(runtimeRoot, "textures", "environment_presets"), Path.Combine(outputRoot, "textures", "environment_presets"), files);
        foreach (var name in FixedTextureNames)
        {
            var source = FindFixedTexture(runtimeRoot, name)!;
            var destination = Path.Combine(outputRoot, "textures", "common", name);
            Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
            File.Copy(source, destination, true);
            if (!files.Contains(destination, StringComparer.OrdinalIgnoreCase)) files.Add(destination);
        }
        foreach (var name in CopiedTopLevelFiles)
        {
            var source = Path.Combine(runtimeRoot, name);
            if (!File.Exists(source)) continue;
            var destination = Path.Combine(outputRoot, name);
            File.Copy(source, destination, true);
            files.Add(destination);
        }
        return files;
    }

    private static void CopyDirectory(string source, string destination, ICollection<string> files)
    {
        if (!Directory.Exists(source)) return;
        foreach (var file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            var target = Path.Combine(destination, Path.GetRelativePath(source, file));
            Directory.CreateDirectory(Path.GetDirectoryName(target)!);
            File.Copy(file, target, true);
            files.Add(target);
        }
    }

    private static string? FindFixedTexture(string runtimeRoot, string name)
    {
        foreach (var directory in new[] { "common", "chen" })
        {
            var candidate = Path.Combine(runtimeRoot, "textures", directory, name);
            if (File.Exists(candidate)) return candidate;
        }
        return null;
    }

    private static ValidationMessage Error(string code, string message) => new() { IsError = true, Code = code, Message = message };
}
