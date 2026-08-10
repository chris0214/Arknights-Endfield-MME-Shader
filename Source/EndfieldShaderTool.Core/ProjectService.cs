using System.Text.Json;
using System.Text.Json.Serialization;

namespace EndfieldShaderTool.Core;

public static class ProjectService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true,
        Converters = { new JsonStringEnumConverter() }
    };

    public static void Save(EndfieldProject project, string path)
    {
        NormalizeMaterialBindings(project);
        project.SchemaVersion = 1;
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
        File.WriteAllText(path, JsonSerializer.Serialize(project, JsonOptions));
    }

    public static EndfieldProject Load(string path)
    {
        var project = JsonSerializer.Deserialize<EndfieldProject>(File.ReadAllText(path), JsonOptions)
                      ?? throw new InvalidDataException("Endfield 工程文件为空。");
        var projectDirectory = Path.GetDirectoryName(Path.GetFullPath(path))!;
        if (!Path.IsPathRooted(project.TemplateRoot))
            project.TemplateRoot = Path.GetFullPath(Path.Combine(projectDirectory, project.TemplateRoot));
        if (!Path.IsPathRooted(project.PmxPath))
            project.PmxPath = Path.GetFullPath(Path.Combine(projectDirectory, project.PmxPath));
        if (File.Exists(project.PmxPath)) project.Model = PmxReader.Read(project.PmxPath);
        NormalizeMaterialBindings(project);
        return project;
    }

    public static bool ShouldPromptForPmxSelection(string requestedPath, string? previousPath)
    {
        if (string.IsNullOrWhiteSpace(requestedPath) || !File.Exists(requestedPath)) return true;
        return !string.IsNullOrWhiteSpace(previousPath) &&
               string.Equals(Path.GetFullPath(requestedPath), Path.GetFullPath(previousPath), StringComparison.OrdinalIgnoreCase);
    }

    public static IReadOnlyList<MaterialProfile> SplitProfileBindings(EndfieldProject project, MaterialProfile merged)
    {
        var index = project.Profiles.IndexOf(merged);
        if (index < 0) return Array.Empty<MaterialProfile>();
        var bindings = GetBindings(merged).ToArray();
        if (bindings.Length <= 1) return new[] { merged };
        var results = new List<MaterialProfile>(bindings.Length);
        foreach (var binding in bindings)
        {
            var clone = CloneProfile(merged);
            clone.ProfileName = $"{merged.ProfileName}_{binding.MaterialIndex:00}";
            SetBindings(clone, new[] { binding });
            results.Add(clone);
        }
        project.Profiles.RemoveAt(index);
        project.Profiles.InsertRange(index, results);
        return results;
    }

    public static EndfieldProject Clone(EndfieldProject project)
        => JsonSerializer.Deserialize<EndfieldProject>(JsonSerializer.Serialize(project, JsonOptions), JsonOptions)
           ?? throw new InvalidDataException("无法复制 Endfield 工程。");

    public static MaterialProfile CloneProfile(MaterialProfile profile)
        => JsonSerializer.Deserialize<MaterialProfile>(JsonSerializer.Serialize(profile, JsonOptions), JsonOptions)
           ?? throw new InvalidDataException("无法复制材质预设。");

    public static EndfieldProject CreateFromModel(string templateRoot, string pmxPath, string roleName)
    {
        var model = PmxReader.Read(pmxPath);
        var project = new EndfieldProject
        {
            RoleName = roleName,
            RoleSlug = Slugify(roleName),
            TemplateRoot = Path.GetFullPath(templateRoot),
            PmxPath = Path.GetFullPath(pmxPath),
            Model = model,
            HeadBone = FindHeadBone(model.BoneNames)
        };
        foreach (var material in model.Materials)
        {
            var domain = MaterialClassifier.Suggest(material);
            var profile = MaterialDefaults.Create(material, domain, project.TemplateRoot);
            project.Profiles.Add(profile);
        }
        NormalizeMaterialBindings(project);
        return project;
    }

    public static MaterialBinding CreateBinding(PmxMaterialInfo material) => new()
    {
        MaterialIndex = material.Index,
        MaterialName = material.Name,
        PmxTexturePath = material.TexturePath,
        PmxSphereTexturePath = material.SphereTexturePath,
        AdditionalUvCount = material.AdditionalUvCount,
        HasUsableUv1 = material.HasUsableUv1
    };

    public static IReadOnlyList<MaterialBinding> GetBindings(MaterialProfile profile)
    {
        if (profile.MaterialBindings.Count > 0) return profile.MaterialBindings;
        if (profile.MaterialIndex < 0) return Array.Empty<MaterialBinding>();
        return new[] { new MaterialBinding
        {
            MaterialIndex = profile.MaterialIndex,
            MaterialName = profile.MaterialName,
            PmxTexturePath = profile.PmxTexturePath,
            PmxSphereTexturePath = profile.PmxSphereTexturePath,
            AdditionalUvCount = profile.AdditionalUvCount,
            HasUsableUv1 = profile.HasUsableUv1
        }};
    }

    public static void SetBindings(MaterialProfile profile, IEnumerable<MaterialBinding> bindings)
    {
        profile.MaterialBindings = bindings.GroupBy(x => x.MaterialIndex).Select(x => x.First())
            .OrderBy(x => x.MaterialIndex).ToList();
        if (profile.MaterialBindings.Count == 0)
        {
            profile.MaterialIndex = -1;
            profile.MaterialName = string.Empty;
            return;
        }
        var primary = profile.MaterialBindings[0];
        profile.MaterialIndex = primary.MaterialIndex;
        profile.MaterialName = primary.MaterialName;
        profile.PmxTexturePath = primary.PmxTexturePath;
        profile.PmxSphereTexturePath = primary.PmxSphereTexturePath;
        profile.AdditionalUvCount = profile.MaterialBindings.Min(x => x.AdditionalUvCount);
        profile.HasUsableUv1 = profile.MaterialBindings.All(x => x.HasUsableUv1);
    }

    public static void NormalizeMaterialBindings(EndfieldProject project)
    {
        foreach (var profile in project.Profiles)
        {
            var indices = profile.MaterialBindings.Count > 0
                ? profile.MaterialBindings.Select(x => x.MaterialIndex)
                : profile.MaterialIndex >= 0 ? new[] { profile.MaterialIndex } : Array.Empty<int>();
            var bindings = indices.Distinct().Select(index => project.Model?.Materials.FirstOrDefault(x => x.Index == index))
                .Where(x => x is not null).Select(x => CreateBinding(x!));
            SetBindings(profile, bindings);
        }
    }

    public static string Slugify(string value)
    {
        var chars = value.Trim().ToLowerInvariant().Select(ch =>
            (ch is >= 'a' and <= 'z') || (ch is >= '0' and <= '9') ? ch : '_').ToArray();
        var slug = new string(chars);
        while (slug.Contains("__", StringComparison.Ordinal)) slug = slug.Replace("__", "_");
        slug = slug.Trim('_');
        return string.IsNullOrWhiteSpace(slug) ? "endfield_role" : slug;
    }

    public static string FindHeadBone(IEnumerable<string> bones)
        => bones.FirstOrDefault(name => name.Contains("頭", StringComparison.Ordinal) ||
                                        name.Contains("头", StringComparison.Ordinal) ||
                                        name.Contains("head", StringComparison.OrdinalIgnoreCase)) ?? "頭";
}

public static class MaterialDefaults
{
    public static MaterialProfile Create(PmxMaterialInfo material, ShaderDomain domain)
        => Create(material, domain, string.Empty);

    public static void DisableSkinBrdf(EndfieldProject project)
    {
        // Endfield keeps the skin BRDF opt-in per profile. This compatibility
        // hook intentionally does not mutate user settings.
    }

    public static ShaderParameters CreateParameters(ShaderDomain domain)
    {
        var p = new ShaderParameters
        {
            UseNormal = domain is ShaderDomain.Hair or ShaderDomain.Skin or ShaderDomain.Cloth or ShaderDomain.Body or ShaderDomain.Prop,
            UseRamp = domain is ShaderDomain.Hair or ShaderDomain.Skin or ShaderDomain.Face or ShaderDomain.Cloth or ShaderDomain.Body or ShaderDomain.Prop,
            UseMatcap = domain is ShaderDomain.Iris or ShaderDomain.Cloth or ShaderDomain.Body or ShaderDomain.Prop,
            UseSdf = domain == ShaderDomain.Face,
            // Endfield hair D.A is authored material data (used by the
            // lighting/SSS chain), not a generic coverage mask. Treating it
            // as cutout alpha removes entire hair-card regions and resembles
            // incorrect back-face culling. Genuine cutout hair remains an
            // explicit per-profile option in the editor.
            UseAlphaClip = domain is ShaderDomain.BrowLash or ShaderDomain.FaceParts or ShaderDomain.EyeHighlight,
            UseSkinLighting = domain == ShaderDomain.Skin,
            UseHighlight = domain == ShaderDomain.Hair,
            UsePmxSphere = domain is ShaderDomain.Hair or ShaderDomain.Cloth or ShaderDomain.Body or ShaderDomain.Prop,
            BlendMode = domain is ShaderDomain.BrowLash or ShaderDomain.FaceParts ? BlendMode.AlphaZWrite : BlendMode.Opaque,
            // Eye-white meshes are frequently authored as thin, split shells
            // with inconsistent winding between exporters. Culling them can
            // erase the whole sclera while the separate iris still renders.
            // Keep the iris's established CCW default, but make EyeWhite
            // double-sided for a safe generic project default.
            CullMode = domain == ShaderDomain.Iris ? CullMode.Ccw : CullMode.None,
            RampRows = domain is ShaderDomain.Cloth or ShaderDomain.Body or ShaderDomain.Prop ? 8f : 1f
        };
        if (domain == ShaderDomain.Hair)
            p.HighlightStrength = 1.05f;
        if (domain == ShaderDomain.Skin)
        {
            p.SpecularStrength = 0.65f;
            p.RimStrength = 1.17f;
            p.RimColor = new ColorValue(1f, 0.82f, 0.78f);
        }
        if (domain == ShaderDomain.Cloth)
        {
            p.SpecularStrength = 2f;
            p.SpecularBroadStrength = 1.35f;
            p.RampBlendStrength = 0f;
            p.RampShadowScale = 0.56f;
            p.RampLightScale = 1.12f;
            p.RimStrength = 0.55f;
        }
        return p;
    }

    public static MaterialProfile Create(PmxMaterialInfo material, ShaderDomain domain, string templateRoot)
    {
        var profile = new MaterialProfile
        {
            MaterialIndex = material.Index,
            MaterialName = material.Name,
            PmxTexturePath = material.TexturePath,
            PmxSphereTexturePath = material.SphereTexturePath,
            AdditionalUvCount = material.AdditionalUvCount,
            HasUsableUv1 = material.HasUsableUv1,
            ProfileName = $"material_{material.Index:00}",
            Domain = domain,
            Parameters = CreateParameters(domain)
        };
        // Iris MatCap is an optional diagnostic/finish layer. Keep it off in
        // newly imported projects so the iris does not become over-bright;
        // users can still enable it explicitly in the material controller.
        profile.Parameters.UseMatcap05 = false;
        profile.Parameters.UseMatcap07 = false;
        // EyeThrough is model-specific (subset order, head bone, and often a
        // derived PMX). Do not silently enable it for every imported model.
        profile.Parameters.EnableEyeThrough = false;
        profile.Parameters.EnableRain = false;
        profile.Parameters.CastCharacterShadow = domain is not (ShaderDomain.Face or ShaderDomain.Iris or ShaderDomain.EyeWhite or ShaderDomain.EyeHighlight);
        profile.UsePmxSphereMap = profile.Parameters.UsePmxSphere;
        profile.CastExcellentShadow = profile.Parameters.CastCharacterShadow;
        profile.MaterialBindings.Add(ProjectService.CreateBinding(material));
        AssignTemplateTextures(profile, templateRoot);
        ConfigureFeatureFlags(profile);
        return profile;
    }

    public static void AssignTemplateTextures(MaterialProfile profile, string templateRoot)
    {
        var common = Path.Combine(templateRoot, "textures", "common");
        // Only assets that are genuinely model-independent are assigned here.
        // Character-specific RD/LUT/SDF/normal maps must be selected explicitly
        // (or matched from the imported model's own texture directory) so a
        // new PMX can never silently render with Chen Qianyu data.
        if (profile.Domain is ShaderDomain.Cloth)
        {
            profile.Textures.Matcap05.SourcePath = Existing(common, "Eff_MatCap_019.png");
            profile.Textures.Matcap07.SourcePath = Existing(common, "Eff_MatCap_019_manual_lod.png");
            profile.Parameters.UseManualMatcapLod = profile.Textures.Matcap07.IsSelected;
            profile.Parameters.UseFgdLut = File.Exists(Path.Combine(common, "PreIntegratedFGD_GGXDisneyDiffuse.png"));
        }
    }

    public static void ConfigureFeatureFlags(MaterialProfile profile)
    {
        var p = profile.Parameters;
        var t = profile.Textures;
        p.UseNormal = t.Normal.IsSelected;
        p.UseSdf = profile.Domain == ShaderDomain.Face && t.Sdf.IsSelected;
        p.UseMatcap = profile.Domain == ShaderDomain.Cloth &&
                      (t.Matcap05.IsSelected || t.Matcap07.IsSelected);
        p.UseMatcap05 = profile.Domain == ShaderDomain.Iris && t.Matcap05.IsSelected;
        p.UseMatcap07 = profile.Domain == ShaderDomain.Iris && t.Matcap07.IsSelected;
        p.UseHighlight = profile.Domain == ShaderDomain.Hair && t.St.IsSelected && profile.AdditionalUvCount > 0;
        if (profile.Domain != ShaderDomain.Cloth)
            p.EnableRain = false;
        if (profile.Domain is not (ShaderDomain.Iris or ShaderDomain.EyeWhite or ShaderDomain.EyeHighlight or ShaderDomain.BrowLash))
            p.EnableEyeThrough = false;
    }

    public static void ConfigureHairHighlights(EndfieldProject project)
    {
        foreach (var profile in project.Profiles) ConfigureHairHighlight(profile);
    }

    public static void ConfigureHairHighlight(MaterialProfile profile)
    {
        if (profile.Domain != ShaderDomain.Hair) return;
        profile.Parameters.HairUvSet = profile.AdditionalUvCount > 0 && profile.Textures.St.IsSelected ? 1 : 0;
        profile.Parameters.UseHighlight = profile.AdditionalUvCount > 0 && profile.Textures.St.IsSelected;
    }

    public static void ConfigureTextureSelection(MaterialProfile profile, string slotKey, bool selected)
    {
        switch (new string(slotKey.Where(char.IsLetterOrDigit).ToArray()).ToLowerInvariant())
        {
            case "base": profile.UsePmxBaseTexture = !selected; profile.Parameters.UseExternalBase = selected; break;
            case "normal": profile.Parameters.UseNormal = selected; break;
            case "property":
            case "material": profile.Parameters.UseMaterial = selected; break;
            case "matcap05": profile.Parameters.UseMatcap = selected || profile.Textures.Matcap07.IsSelected; break;
            case "matcap07": profile.Parameters.UseMatcap = selected || profile.Textures.Matcap05.IsSelected; break;
            case "matcap": profile.Parameters.UseMatcap = selected; break;
            case "sdf": profile.Parameters.UseSdf = selected; break;
            case "highlight": ConfigureHairHighlight(profile); break;
            case "st": ConfigureHairHighlight(profile); break;
            case "rd":
            case "lut":
            case "rs":
            case "colormask":
            case "lipspecular":
            case "hairline":
            case "ramp": break;
            case "lightcurve": profile.Parameters.UseLightCurve = selected; break;
        }
        ConfigureFeatureFlags(profile);
    }

    private static string? Existing(string directory, string name)
    {
        var path = Path.Combine(directory, name);
        return File.Exists(path) ? path : null;
    }
}
