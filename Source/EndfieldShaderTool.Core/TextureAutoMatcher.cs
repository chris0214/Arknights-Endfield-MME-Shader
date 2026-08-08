namespace EndfieldShaderTool.Core;

public sealed record TextureMatch(string SlotKey, string SourcePath, int Score);

public sealed class TextureMatchResult
{
    public IReadOnlyDictionary<string, TextureMatch> Matches { get; init; }
        = new Dictionary<string, TextureMatch>(StringComparer.OrdinalIgnoreCase);

    public IReadOnlyList<string> AmbiguousSlots { get; init; } = Array.Empty<string>();
}

public static class TextureAutoMatcher
{
    // Endfield files with the same public name can still be different texture
    // variants. This matcher ranks only the assets the user selected for the
    // current role; it never promotes a global filename into a face default.
    private static readonly HashSet<string> ImageExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".png", ".dds", ".tga", ".bmp", ".jpg", ".jpeg"
    };

    public static bool IsSupportedTextureFile(string path)
        => ImageExtensions.Contains(Path.GetExtension(path));

    public static TextureMatchResult Suggest(ShaderDomain domain, IEnumerable<string> files)
    {
        var candidates = new Dictionary<string, List<TextureMatch>>(StringComparer.OrdinalIgnoreCase);
        foreach (var sourcePath in files.Where(IsSupportedTextureFile).Distinct(StringComparer.OrdinalIgnoreCase))
        {
            var slot = Classify(Path.GetFileNameWithoutExtension(sourcePath));
            if (slot is null || !IsAllowed(domain, slot)) continue;

            var score = Score(domain, slot, Path.GetFileNameWithoutExtension(sourcePath));
            if (score <= 0) continue;
            if (!candidates.TryGetValue(slot, out var list)) candidates[slot] = list = new();
            list.Add(new TextureMatch(slot, sourcePath, score));
        }

        var matches = new Dictionary<string, TextureMatch>(StringComparer.OrdinalIgnoreCase);
        var ambiguous = new List<string>();
        foreach (var (slot, list) in candidates)
        {
            var highest = list.Max(item => item.Score);
            var winners = list.Where(item => item.Score == highest)
                .OrderBy(item => item.SourcePath, StringComparer.OrdinalIgnoreCase)
                .ToArray();
            if (winners.Length != 1)
            {
                ambiguous.Add(slot);
                continue;
            }
            matches[slot] = winners[0];
        }

        return new TextureMatchResult { Matches = matches, AmbiguousSlots = ambiguous };
    }

    private static string? Classify(string fileName)
    {
        var name = fileName.ToLowerInvariant();
        if ((name.Contains("face", StringComparison.Ordinal) && name.Contains("_hl", StringComparison.Ordinal))
            || name.Contains("lip", StringComparison.Ordinal)) return "LipSpecular";
        if (name.Contains("hairline", StringComparison.Ordinal) || name.Contains("hair_line", StringComparison.Ordinal)) return "HairLine";
        if (name.Contains("matcap", StringComparison.Ordinal) && (name.Contains("07", StringComparison.Ordinal) || name.Contains("manual", StringComparison.Ordinal))) return "Matcap07";
        if (name.Contains("matcap", StringComparison.Ordinal) && name.Contains("05", StringComparison.Ordinal)) return "Matcap05";
        if (name.Contains("matcap", StringComparison.Ordinal) || name.StartsWith("mc", StringComparison.Ordinal)) return "Matcap05";
        if (name.Contains("sdf", StringComparison.Ordinal)) return "SDF";
        if (name.Contains("colormask", StringComparison.Ordinal) || name.Contains("color_mask", StringComparison.Ordinal)
            || name.Contains("_cm_", StringComparison.Ordinal) || name.EndsWith("_cm", StringComparison.Ordinal)) return "ColorMask";
        if (name.EndsWith("_st", StringComparison.Ordinal) || name.Contains("_st_", StringComparison.Ordinal)
            || name.Contains("st_texture", StringComparison.Ordinal) || name.Contains("_skinmask", StringComparison.Ordinal)) return "ST";
        if (name.EndsWith("_rd", StringComparison.Ordinal) || name.Contains("_rd_", StringComparison.Ordinal)
            || name.Contains("diffuse_rd", StringComparison.Ordinal)) return "RD";
        if (name.EndsWith("_rs", StringComparison.Ordinal) || name.Contains("_rs_", StringComparison.Ordinal)
            || name.Contains("specular", StringComparison.Ordinal)) return "RS";
        if (name.Contains("lut", StringComparison.Ordinal) || name.Contains("preintegrated", StringComparison.Ordinal)
            || name.Contains("fgd", StringComparison.Ordinal)) return "LUT";
        if (name.Contains("property", StringComparison.Ordinal) || name.Contains("mro", StringComparison.Ordinal)
            || name.Contains("orm", StringComparison.Ordinal) || name.EndsWith("_p", StringComparison.Ordinal)) return "Property";
        if (name.EndsWith("_n", StringComparison.Ordinal) || name.EndsWith("_hn", StringComparison.Ordinal)
            || name.Contains("normal", StringComparison.Ordinal)) return "Normal";
        if (name.EndsWith("_d", StringComparison.Ordinal) || name.Contains("diffuse", StringComparison.Ordinal)
            || name.Contains("albedo", StringComparison.Ordinal) || name.Contains("basecolor", StringComparison.Ordinal)) return "Base";
        return null;
    }

    private static bool IsAllowed(ShaderDomain domain, string slot)
    {
        return domain switch
        {
            ShaderDomain.Face => slot is "Base" or "RD" or "LUT" or "SDF" or "ColorMask" or "ST" or "LipSpecular",
            ShaderDomain.Hair => slot is "Base" or "Normal" or "Property" or "RD" or "RS" or "ST" or "HairLine",
            ShaderDomain.Skin => slot is "Base" or "Normal" or "RD" or "LUT",
            ShaderDomain.Cloth => slot is "Base" or "Normal" or "Property" or "RD" or "RS" or "LUT" or "Matcap05" or "Matcap07",
            ShaderDomain.Iris => slot is "Base" or "Matcap05" or "Matcap07",
            ShaderDomain.EyeWhite or ShaderDomain.EyeHighlight or ShaderDomain.BrowLash or ShaderDomain.Mouth
                or ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay => slot == "Base",
            ShaderDomain.Hidden => false,
            _ => slot is "Base" or "Normal" or "Property" or "RD" or "RS" or "LUT" or "Matcap05" or "Matcap07"
        };
    }

    private static int Score(ShaderDomain domain, string slot, string fileName)
    {
        var name = fileName.ToLowerInvariant();
        var score = 100;
        var hasFace = name.Contains("face", StringComparison.Ordinal);
        var hasSkin = name.Contains("skin", StringComparison.Ordinal) || name.Contains("body", StringComparison.Ordinal);
        var hasHair = name.Contains("hair", StringComparison.Ordinal);
        var hasCloth = name.Contains("cloth", StringComparison.Ordinal);
        var hasEye = name.Contains("eye", StringComparison.Ordinal) || name.Contains("iris", StringComparison.Ordinal);

        if (slot == "LipSpecular") return hasFace ? 400 : 0;
        if (slot == "ColorMask" || slot == "SDF" || slot == "ST")
            return domain == ShaderDomain.Face && hasFace ? 400 : 0;

        score += domain switch
        {
            ShaderDomain.Face => hasFace ? 220 : hasSkin && slot == "LUT" ? 180 : -300,
            ShaderDomain.Hair => hasHair ? 220 : -300,
            ShaderDomain.Skin => hasSkin ? 220 : hasFace || hasHair || hasCloth ? -300 : 0,
            ShaderDomain.Cloth => hasCloth ? 220 : hasFace || hasHair || hasSkin ? -300 : 0,
            ShaderDomain.Iris => hasEye ? 220 : -300,
            ShaderDomain.EyeWhite or ShaderDomain.BrowLash or ShaderDomain.Mouth or ShaderDomain.BrowOverlay
                => hasFace ? 220 : -300,
            ShaderDomain.EyeHighlight or ShaderDomain.EyeOverlay => hasEye ? 220 : -300,
            ShaderDomain.Body => hasSkin ? 220 : hasFace || hasHair || hasCloth ? -300 : 0,
            _ => 0
        };

        if (slot == "LUT" && domain == ShaderDomain.Face && name.Contains("skincolor", StringComparison.Ordinal)) score += 120;
        if (slot is "Matcap05" or "Matcap07") score += 80;
        return score;
    }
}
