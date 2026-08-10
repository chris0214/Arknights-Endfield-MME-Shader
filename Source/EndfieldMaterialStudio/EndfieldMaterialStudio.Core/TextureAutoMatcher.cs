using System.Text.RegularExpressions;

namespace EndfieldMaterialStudio.Core;

/// <summary>
/// Assigns auxiliary Endfield textures from a model's own texture family.
/// The matcher deliberately leaves ambiguous candidates unset instead of
/// silently picking an unrelated common texture.
/// </summary>
public static class TextureAutoMatcher
{
    private static readonly string[] ImageExtensions = { ".png", ".jpg", ".jpeg", ".bmp", ".tga", ".dds" };

    // Endfield's common female LUTs are palette variants, not interchangeable
    // fallbacks. These are compatibility profiles inferred from the character
    // texture family; unknown families remain explicit/ambiguous for the user.
    private static readonly IReadOnlyDictionary<string, string> SkinLutProfiles =
        new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["jsspsi"] = "femaleskincolor03",
            ["liino"] = "femaleskincolor01",
            ["chen"] = "femaleskincolor02",
            ["lizhiyan"] = "femaleskincolor02"
        };

    /// <summary>
    /// Keeps the original source-compatible API. Existing non-empty slots are
    /// preserved, which is useful after a user has manually tuned a project.
    /// </summary>
    public static IReadOnlyList<ValidationMessage> Assign(StudioProject project, params string[] searchRoots)
        => Assign(project, overwriteExisting: false, searchRoots);

    /// <summary>
    /// Re-matches auxiliary slots. The GUI uses overwriteExisting=true so a
    /// previously generated project can be repaired by pressing Auto Match
    /// again; the explicit overload keeps manual editing opt-in elsewhere.
    /// </summary>
    public static IReadOnlyList<ValidationMessage> Assign(
        StudioProject project,
        bool overwriteExisting,
        params string[] searchRoots)
    {
        ArgumentNullException.ThrowIfNull(project);

        // Model-local textures take precedence, while the runtime texture
        // library supplies shared assets such as the cloth LUT used by Si.
        // Keeping this inside the matcher makes GUI and batch generation use
        // the same search contract.
        var roots = searchRoots
            .Concat(new[] { Path.Combine(project.RuntimeRoot ?? string.Empty, "textures") })
            .Where(root => !string.IsNullOrWhiteSpace(root) && Directory.Exists(root))
            .Select(Path.GetFullPath)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();

        var candidates = roots
            .SelectMany((root, index) => Directory.GetFiles(root, "*", SearchOption.AllDirectories)
                .Where(path => ImageExtensions.Contains(Path.GetExtension(path), StringComparer.OrdinalIgnoreCase))
                .Select(path => new Candidate(path, index)))
            .GroupBy(candidate => candidate.Path, StringComparer.OrdinalIgnoreCase)
            .Select(group => group.OrderBy(candidate => candidate.RootRank).First())
            .ToArray();

        var messages = new List<ValidationMessage>();
        var sharedSkinLut = SelectSkinLut(candidates, project, messages);

        foreach (var material in project.Materials.OrderBy(material => material.MaterialIndex))
        {
            // A number of game exports keep the authored source textures in a
            // sibling "other tex"/"other_tex" directory while the PMX points
            // at a flattened MMD copy.  The latter can lose channel semantics
            // (notably iris Alpha, which is an emission mask in the shader).
            // Prefer an exact-name authored copy, but preserve an explicit
            // manual base selection when the project already opted out of the
            // PMX base texture.
            var authoredBase = SelectOtherTexBase(candidates, material);
            if (authoredBase is not null &&
                (material.UsePmxBaseTexture ||
                 string.IsNullOrWhiteSpace(material.Textures.Base) ||
                 SamePath(material.Textures.Base, material.PmxBaseTexture)))
            {
                material.Textures.Base = authoredBase;
                material.UsePmxBaseTexture = false;
            }
            else
            {
                material.Textures.Base ??= material.PmxBaseTexture;
            }

            var allowed = AllowedSlots(material.Role);
            foreach (var slot in allowed)
            {
                if (!overwriteExisting && !string.IsNullOrWhiteSpace(Get(material.Textures, slot))) continue;

                var selected = SelectSlot(candidates, material, slot, sharedSkinLut, messages);
                if (selected is not null) Set(material.Textures, slot, selected);
                else if (overwriteExisting) Set(material.Textures, slot, null);
            }

            // Auxiliary slots from a previous broad matcher must not leak into
            // roles where the shader never consumes them.
            if (overwriteExisting)
            {
                foreach (var slot in AllAuxiliarySlots.Except(allowed)) Set(material.Textures, slot, null);
            }
        }

        return messages;
    }

    private static string? SelectOtherTexBase(
        IReadOnlyList<Candidate> candidates,
        MaterialAssignment material)
    {
        var fileName = Path.GetFileName(material.PmxBaseTexture);
        if (string.IsNullOrWhiteSpace(fileName)) return null;

        return candidates
            .Where(candidate =>
                string.Equals(Path.GetFileName(candidate.Path), fileName, StringComparison.OrdinalIgnoreCase) &&
                IsOtherTexPath(candidate.Path))
            .OrderBy(candidate => candidate.RootRank)
            .ThenBy(candidate => candidate.Path.Length)
            .ThenBy(candidate => candidate.Path, StringComparer.OrdinalIgnoreCase)
            .Select(candidate => candidate.Path)
            .FirstOrDefault();
    }

    private static bool IsOtherTexPath(string path) => path
        .Split(new[] { Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar }, StringSplitOptions.RemoveEmptyEntries)
        .Any(segment => NormalizeDirectoryName(segment) == "othertex");

    private static string NormalizeDirectoryName(string value) => new(value
        .Where(char.IsLetterOrDigit)
        .Select(char.ToLowerInvariant)
        .ToArray());

    private static bool SamePath(string? left, string? right)
    {
        if (string.IsNullOrWhiteSpace(left) || string.IsNullOrWhiteSpace(right)) return false;
        return string.Equals(Path.GetFullPath(left), Path.GetFullPath(right), StringComparison.OrdinalIgnoreCase);
    }

    private static readonly TextureSlot[] AllAuxiliarySlots =
    {
        TextureSlot.Normal, TextureSlot.Property, TextureSlot.Rd, TextureSlot.Rs,
        TextureSlot.Lut, TextureSlot.Sdf, TextureSlot.St, TextureSlot.ColorMask,
        TextureSlot.LipSpecular, TextureSlot.HairLine
    };

    private static IReadOnlyList<TextureSlot> AllowedSlots(MaterialRole role) => role switch
    {
        MaterialRole.Face => new[]
        {
            TextureSlot.Rd, TextureSlot.Lut, TextureSlot.Sdf, TextureSlot.St,
            TextureSlot.ColorMask, TextureSlot.LipSpecular
        },
        MaterialRole.Skin => new[] { TextureSlot.Rd, TextureSlot.Lut },
        MaterialRole.Hair => new[]
        {
            TextureSlot.Normal, TextureSlot.Property, TextureSlot.Rd, TextureSlot.Rs,
            TextureSlot.St, TextureSlot.HairLine
        },
        MaterialRole.Cloth => new[]
        {
            TextureSlot.Normal, TextureSlot.Property, TextureSlot.Rd,
            TextureSlot.Rs, TextureSlot.Lut
        },
        _ => Array.Empty<TextureSlot>()
    };

    private static string? SelectSkinLut(
        IReadOnlyList<Candidate> candidates,
        StudioProject project,
        ICollection<ValidationMessage> messages)
    {
        var lutCandidates = candidates
            .Where(candidate => IsSlotCandidate(candidate.Name, TextureSlot.Lut))
            .ToArray();
        if (lutCandidates.Length == 0) return null;

        var family = project.Materials
            .Where(material => material.Role is MaterialRole.Face or MaterialRole.Skin)
            .Select(material => ExtractFamily(material.PmxBaseTexture))
            .FirstOrDefault(value => !string.IsNullOrWhiteSpace(value));

        if (!string.IsNullOrWhiteSpace(family) && SkinLutProfiles.TryGetValue(family, out var profile))
        {
            var preferred = lutCandidates
                .Where(candidate => candidate.Name.Contains(profile, StringComparison.OrdinalIgnoreCase))
                .OrderBy(candidate => candidate.RootRank)
                .ToArray();
            if (preferred.Length > 0) return preferred[0].Path;
        }

        var unique = DistinctByFileName(lutCandidates);
        if (unique.Length == 1) return unique[0].Path;

        messages.Add(Warning(
            "TEXTURE_AMBIGUOUS_LUT",
            $"检测到多个皮肤 LUT（{string.Join("、", unique.Select(candidate => candidate.Name))}），未静默选择；请在面部/皮肤材质中手动指定。"));
        return null;
    }

    private static string? SelectSlot(
        IReadOnlyList<Candidate> candidates,
        MaterialAssignment material,
        TextureSlot slot,
        string? sharedSkinLut,
        ICollection<ValidationMessage> messages)
    {
        if (slot == TextureSlot.Lut)
        {
            if (material.Role is MaterialRole.Face or MaterialRole.Skin) return sharedSkinLut;

            var clothLuts = candidates
                .Where(candidate => IsSlotCandidate(candidate.Name, TextureSlot.Lut))
                .Where(candidate => candidate.Name.Contains("cloth", StringComparison.OrdinalIgnoreCase))
                .ToArray();
            var uniqueClothLuts = DistinctByFileName(clothLuts);
            if (uniqueClothLuts.Length == 1) return uniqueClothLuts[0].Path;
            if (uniqueClothLuts.Length > 1)
            {
                messages.Add(Warning(
                    "TEXTURE_AMBIGUOUS_CLOTH_LUT",
                    $"材质 #{material.MaterialIndex} {material.MaterialName} 检测到多个布料 LUT，未静默选择。"));
                return null;
            }

            // Do not silently reuse a face/skin LUT for cloth. The palettes
            // are not interchangeable; leave the slot unset so the user can
            // choose a model-specific cloth LUT when the runtime has none.
            return null;
        }

        var family = ExtractFamily(material.PmxBaseTexture);
        var baseStem = BaseStem(material.PmxBaseTexture);
        var variantHint = slot == TextureSlot.Rs || slot == TextureSlot.Rd
            ? ClothCommonVariant(material, slot)
            : null;

        var slotCandidates = candidates
            .Where(candidate => IsSlotCandidate(candidate.Name, slot))
            .ToArray();

        // Face ST is a semantic face mask. Character bundles often also ship
        // hair/cloth ST textures from the same family, whose family-name score
        // would otherwise beat the shared female-face ST asset.
        if (material.Role == MaterialRole.Face && slot == TextureSlot.St)
        {
            var faceSt = slotCandidates
                .Where(candidate => candidate.Name.Contains("face", StringComparison.OrdinalIgnoreCase))
                .ToArray();
            if (faceSt.Length > 0) slotCandidates = faceSt;
        }

        var ranked = slotCandidates
            .Select(candidate => new
            {
                Candidate = candidate,
                Score = Score(candidate, material, slot, family, baseStem, variantHint)
            })
            .Where(item => item.Score > 0)
            .OrderByDescending(item => item.Score)
            .ThenBy(item => item.Candidate.RootRank)
            .ThenBy(item => item.Candidate.Name, StringComparer.OrdinalIgnoreCase)
            .ToArray();

        if (ranked.Length == 0) return null;
        var bestScore = ranked[0].Score;
        var best = ranked.Where(item => item.Score == bestScore).Select(item => item.Candidate).ToArray();
        // Explicit search roots are ordered by caller priority (model-local
        // roots first, runtime library last). Prefer the earliest root when
        // candidates are otherwise tied; only report ambiguity among files
        // from that same priority tier.
        var preferredRoot = best.Min(candidate => candidate.RootRank);
        best = best.Where(candidate => candidate.RootRank == preferredRoot).ToArray();
        var uniqueBest = DistinctByFileName(best);
        if (uniqueBest.Length == 1) return uniqueBest[0].Path;

        messages.Add(Warning(
            "TEXTURE_AMBIGUOUS",
            $"材质 #{material.MaterialIndex} {material.MaterialName} 的 {slot} 有多个同等候选（{string.Join("、", uniqueBest.Select(candidate => candidate.Name))}），未静默选择。"));
        return null;
    }

    private static int Score(
        Candidate candidate,
        MaterialAssignment material,
        TextureSlot slot,
        string? family,
        string baseStem,
        string? variantHint)
    {
        var name = candidate.Name;
        var score = 20;

        if (!string.IsNullOrWhiteSpace(baseStem) && name.Contains(baseStem, StringComparison.OrdinalIgnoreCase)) score += 100;
        if (!string.IsNullOrWhiteSpace(family) && !family.Equals("common", StringComparison.OrdinalIgnoreCase) &&
            name.Contains($"_{family}_", StringComparison.OrdinalIgnoreCase)) score += 70;

        var semantic = material.Role switch
        {
            MaterialRole.Face => new[] { "face", "female_face" },
            MaterialRole.Skin => new[] { "body", "skin" },
            MaterialRole.Hair => new[] { "hair", "hairst", "hairline" },
            MaterialRole.Cloth => new[] { "cloth" },
            _ => Array.Empty<string>()
        };
        if (semantic.Any(token => name.Contains(token, StringComparison.OrdinalIgnoreCase))) score += 20;

        if (!string.IsNullOrWhiteSpace(variantHint) && name.Contains(variantHint, StringComparison.OrdinalIgnoreCase)) score += 55;
        if (slot == TextureSlot.LipSpecular && name.Contains("face_01_hl", StringComparison.OrdinalIgnoreCase)) score += 50;
        if (slot == TextureSlot.Rs && material.Role == MaterialRole.Hair && name.Contains("_hair_", StringComparison.OrdinalIgnoreCase)) score += 25;
        if (slot == TextureSlot.St && name.Contains("_st", StringComparison.OrdinalIgnoreCase)) score += 10;

        // A generic MRO is a last-resort property source; do not let it beat a
        // model-family P/Property texture.
        if (slot == TextureSlot.Property && name.Contains("mro", StringComparison.OrdinalIgnoreCase)) score -= 10;
        return score;
    }

    private static string? ClothCommonVariant(MaterialAssignment material, TextureSlot slot)
    {
        if (material.Role != MaterialRole.Cloth) return null;
        var stem = BaseStem(material.PmxBaseTexture);
        var match = Regex.Match(stem, @"_cloth_(\d+)(?:_|$)", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
        if (!match.Success) return null;

        var variant = match.Groups[1].Value switch
        {
            "01" => "cloth_04",
            "02" => "cloth_02",
            _ => $"cloth_{match.Groups[1].Value}"
        };
        return $"common_{variant}_{slot switch { TextureSlot.Rd => "rd", TextureSlot.Rs => "rs", _ => "" }}";
    }

    private static bool IsSlotCandidate(string name, TextureSlot slot)
    {
        var value = name.ToLowerInvariant();
        return slot switch
        {
            TextureSlot.Normal => value.EndsWith("_n", StringComparison.Ordinal) || value.EndsWith("_hn", StringComparison.Ordinal) || value.Contains("normal"),
            TextureSlot.Property => value.EndsWith("_p", StringComparison.Ordinal) || value.Contains("property") || value.Contains("orm") || value.Contains("mro"),
            TextureSlot.Rd => value.Contains("_rd", StringComparison.Ordinal),
            TextureSlot.Rs => value.Contains("_rs", StringComparison.Ordinal),
            TextureSlot.Lut => value.Contains("lut", StringComparison.Ordinal),
            TextureSlot.Sdf => value.Contains("sdf", StringComparison.Ordinal),
            TextureSlot.St => value.Contains("_st", StringComparison.Ordinal),
            TextureSlot.ColorMask => value.Contains("cm_m", StringComparison.Ordinal) || value.Contains("colormask", StringComparison.Ordinal) || value.Contains("color_mask", StringComparison.Ordinal),
            TextureSlot.LipSpecular => value.Contains("lip", StringComparison.Ordinal) || value.Contains("mouthspec", StringComparison.Ordinal) || value.Contains("face_01_hl", StringComparison.Ordinal),
            TextureSlot.HairLine => value.Contains("hairline", StringComparison.Ordinal),
            _ => false
        };
    }

    private static string BaseStem(string? path)
    {
        var name = Path.GetFileNameWithoutExtension(path ?? string.Empty).ToLowerInvariant();
        foreach (var suffix in new[] { "_diffuse", "_base", "_d", "_normal", "_hn", "_p", "_property", "_rd", "_rs", "_st" })
        {
            if (name.EndsWith(suffix, StringComparison.Ordinal)) return name[..^suffix.Length];
        }
        return name;
    }

    private static string? ExtractFamily(string? path)
    {
        var name = Path.GetFileNameWithoutExtension(path ?? string.Empty);
        var parts = name.Split('_', StringSplitOptions.RemoveEmptyEntries);
        return parts.Length >= 3 && parts[0].Equals("T", StringComparison.OrdinalIgnoreCase) &&
               parts[1].Equals("actor", StringComparison.OrdinalIgnoreCase)
            ? parts[2].ToLowerInvariant()
            : null;
    }

    private static Candidate[] DistinctByFileName(IEnumerable<Candidate> candidates) => candidates
        .GroupBy(candidate => candidate.Name, StringComparer.OrdinalIgnoreCase)
        .Select(group => group.OrderBy(candidate => candidate.RootRank).First())
        .ToArray();

    private static string? Get(TextureSlots textures, TextureSlot slot) => slot switch
    {
        TextureSlot.Normal => textures.Normal,
        TextureSlot.Property => textures.Property,
        TextureSlot.Rd => textures.Rd,
        TextureSlot.Rs => textures.Rs,
        TextureSlot.Lut => textures.Lut,
        TextureSlot.Sdf => textures.Sdf,
        TextureSlot.St => textures.St,
        TextureSlot.ColorMask => textures.ColorMask,
        TextureSlot.LipSpecular => textures.LipSpecular,
        TextureSlot.HairLine => textures.HairLine,
        _ => null
    };

    private static void Set(TextureSlots textures, TextureSlot slot, string? value)
    {
        switch (slot)
        {
            case TextureSlot.Normal: textures.Normal = value; break;
            case TextureSlot.Property: textures.Property = value; break;
            case TextureSlot.Rd: textures.Rd = value; break;
            case TextureSlot.Rs: textures.Rs = value; break;
            case TextureSlot.Lut: textures.Lut = value; break;
            case TextureSlot.Sdf: textures.Sdf = value; break;
            case TextureSlot.St: textures.St = value; break;
            case TextureSlot.ColorMask: textures.ColorMask = value; break;
            case TextureSlot.LipSpecular: textures.LipSpecular = value; break;
            case TextureSlot.HairLine: textures.HairLine = value; break;
        }
    }

    private static ValidationMessage Warning(string code, string message) => new()
    {
        IsError = false,
        Code = code,
        Message = message
    };

    private sealed class Candidate
    {
        public Candidate(string path, int rootRank)
        {
            Path = path;
            RootRank = rootRank;
            Name = System.IO.Path.GetFileNameWithoutExtension(path).ToLowerInvariant();
        }

        public string Path { get; }
        public string Name { get; }
        public int RootRank { get; }
    }

    private enum TextureSlot
    {
        Normal,
        Property,
        Rd,
        Rs,
        Lut,
        Sdf,
        St,
        ColorMask,
        LipSpecular,
        HairLine
    }
}
