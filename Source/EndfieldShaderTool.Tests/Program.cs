using EndfieldShaderTool.Core;
using System.ComponentModel;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;

static void Require(bool condition, string message)
{
    if (!condition) throw new InvalidOperationException(message);
}

static string ReadShader(string path) => File.ReadAllText(path, FileEncoding.ForShader(path));

static bool IsStrictUtf8(string path)
{
    try
    {
        _ = new UTF8Encoding(false, true).GetString(File.ReadAllBytes(path));
        return true;
    }
    catch (DecoderFallbackException)
    {
        return false;
    }
}

static string ExpectedRuntime(ShaderDomain domain) => domain switch
{
    ShaderDomain.Face => "endfield_face.hlsl",
    ShaderDomain.Skin => "endfield_skin.hlsl",
    ShaderDomain.Cloth => "endfield_cloth.hlsl",
    ShaderDomain.Iris or ShaderDomain.EyeWhite => "endfield_facial.hlsl",
    ShaderDomain.EyeHighlight => "endfield_eye_highlight.hlsl",
    ShaderDomain.BrowLash or ShaderDomain.Mouth or ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay => "endfield_facial.hlsl",
    _ => "endfield_shader.hlsl"
};

static bool UsesCp932Wrapper(ShaderDomain domain)
    => domain is ShaderDomain.Face or ShaderDomain.Iris or ShaderDomain.EyeHighlight
        or ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay;

static bool HasFullOptionalAssets(string templateRoot)
{
    var required = new[]
    {
        "textures/common/Eff_MatCap_019.png",
        "textures/common/Eff_MatCap_019_manual_lod.png",
        "textures/common/PreIntegratedFGD_GGXDisneyDiffuse.png",
        "textures/common/rain/T_actor_common_rain_02_M.png",
        "textures/common/rain/rain_drops.png",
        "textures/common/rain/rain_drops_phase.png"
    };
    return required.All(relative => File.Exists(Path.Combine(
        templateRoot,
        relative.Replace('/', Path.DirectorySeparatorChar))));
}

static TextureReference TemplateTexture(string templateRoot, string relative)
    => new()
    {
        SourcePath = Path.Combine(templateRoot, relative.Replace('/', Path.DirectorySeparatorChar)),
        PackagePath = relative
    };

static EndfieldProject CreateDomainMatrixProject(string templateRoot, string roleSlug, bool featureRich)
{
    var domains = Enum.GetValues<ShaderDomain>()
        .Where(domain => domain != ShaderDomain.Unassigned)
        .ToArray();
    var model = new PmxModelInfo
    {
        FilePath = Path.Combine(Path.GetTempPath(), roleSlug + ".pmx"),
        BoneNames = new List<string> { "頭" }
    };
    var project = new EndfieldProject
    {
        RoleName = roleSlug,
        RoleSlug = roleSlug,
        TemplateRoot = templateRoot,
        PmxPath = model.FilePath,
        Model = model,
        HeadBone = "頭",
        GenerateEmm = true,
        IncludePostProcessing = true,
        IncludeEyeThrough = featureRich
    };

    for (var index = 0; index < domains.Length; index++)
    {
        var domain = domains[index];
        var material = new PmxMaterialInfo
        {
            Index = index,
            Name = $"material_{index:00}_{domain}",
            AdditionalUvCount = domain == ShaderDomain.Hair ? 1 : 0,
            HasUsableUv1 = domain == ShaderDomain.Hair
        };
        model.Materials.Add(material);
        var profile = MaterialDefaults.Create(material, domain, templateRoot);
        profile.ProfileName = $"{index:00}_{domain.ToString().ToLowerInvariant()}";
        profile.MaterialName = material.Name;
        if (featureRich) ConfigureFeatureRichProfile(profile, templateRoot);
        project.Profiles.Add(profile);
    }
    return project;
}

static void ConfigureFeatureRichProfile(MaterialProfile profile, string templateRoot)
{
    var matcap = "textures/common/Eff_MatCap_019.png";
    var atlas = "textures/common/Eff_MatCap_019_manual_lod.png";
    var fgd = "textures/common/PreIntegratedFGD_GGXDisneyDiffuse.png";
    var rainMask = "textures/common/rain/T_actor_common_rain_02_M.png";
    var rainDrops = "textures/common/rain/rain_drops.png";
    var rainPhase = "textures/common/rain/rain_drops_phase.png";

    switch (profile.Domain)
    {
        case ShaderDomain.Face:
            profile.Textures.Sdf = TemplateTexture(templateRoot, rainPhase);
            profile.Textures.Rd = TemplateTexture(templateRoot, rainDrops);
            profile.Textures.Lut = TemplateTexture(templateRoot, fgd);
            profile.Textures.St = TemplateTexture(templateRoot, atlas);
            profile.Textures.ColorMask = TemplateTexture(templateRoot, matcap);
            break;
        case ShaderDomain.Hair:
            profile.Textures.Normal = TemplateTexture(templateRoot, rainPhase);
            profile.Textures.Property = TemplateTexture(templateRoot, fgd);
            profile.Textures.Rd = TemplateTexture(templateRoot, rainMask);
            profile.Textures.Rs = TemplateTexture(templateRoot, rainDrops);
            profile.Textures.St = TemplateTexture(templateRoot, atlas);
            profile.Textures.HairLine = TemplateTexture(templateRoot, matcap);
            break;
        case ShaderDomain.Skin:
            profile.Textures.Normal = TemplateTexture(templateRoot, rainPhase);
            profile.Textures.Rd = TemplateTexture(templateRoot, rainDrops);
            profile.Textures.Rs = TemplateTexture(templateRoot, matcap);
            profile.Textures.Lut = TemplateTexture(templateRoot, fgd);
            break;
        case ShaderDomain.Cloth:
            profile.Textures.Normal = TemplateTexture(templateRoot, rainPhase);
            profile.Textures.Property = TemplateTexture(templateRoot, fgd);
            profile.Textures.Rd = TemplateTexture(templateRoot, rainDrops);
            profile.Textures.Rs = TemplateTexture(templateRoot, matcap);
            profile.Textures.Lut = TemplateTexture(templateRoot, rainMask);
            profile.Textures.St = TemplateTexture(templateRoot, atlas);
            profile.Textures.Matcap05 = TemplateTexture(templateRoot, matcap);
            profile.Textures.Matcap07 = TemplateTexture(templateRoot, atlas);
            break;
        case ShaderDomain.Iris:
            profile.Textures.Base = TemplateTexture(templateRoot, rainMask);
            profile.UsePmxBaseTexture = false;
            profile.Parameters.UseExternalBase = true;
            profile.Textures.Matcap05 = TemplateTexture(templateRoot, matcap);
            profile.Textures.Matcap07 = TemplateTexture(templateRoot, atlas);
            break;
        case ShaderDomain.EyeHighlight:
            profile.Textures.Base = TemplateTexture(templateRoot, matcap);
            profile.UsePmxBaseTexture = false;
            profile.Parameters.UseExternalBase = true;
            break;
    }

    MaterialDefaults.ConfigureFeatureFlags(profile);
    if (profile.Domain == ShaderDomain.Cloth)
    {
        profile.Parameters.UseFgdLut = true;
        profile.Parameters.EnableRain = true;
        profile.Parameters.UseMatcap = true;
        profile.Parameters.UseManualMatcapLod = true;
    }
    if (profile.Domain is ShaderDomain.Iris or ShaderDomain.EyeWhite
        or ShaderDomain.EyeHighlight or ShaderDomain.BrowLash)
    {
        profile.Parameters.EnableEyeThrough = true;
    }
    if (profile.Domain == ShaderDomain.Iris)
        profile.Parameters.GenerateEyeThroughDerivedModel = true;
}

static void VerifyGeneratedDomainMatrix(EndfieldProject project, string packageRoot, bool featureRich)
{
    var roleDirectory = Path.Combine(packageRoot, "presets", project.RoleSlug);
    var localInternal = Path.Combine(roleDirectory, "internal");
    foreach (var required in ShadowBackendSupport.CommonTemplateFiles
                 .Where(path => path.StartsWith("internal/", StringComparison.Ordinal)))
    {
        var fileName = Path.GetFileName(required);
        Require(File.Exists(Path.Combine(localInternal, fileName)),
            $"Generated preset runtime is missing {fileName}.");
    }

    Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
    var cp932 = Encoding.GetEncoding(932, EncoderFallback.ExceptionFallback, DecoderFallback.ExceptionFallback);
    foreach (var profile in project.Profiles)
    {
        var slug = ProjectService.Slugify(profile.ProfileName);
        var fx = Path.Combine(roleDirectory, $"{project.RoleSlug}_{slug}.fx");
        Require(File.Exists(fx), $"Missing generated FX for {profile.Domain}.");
        var wrapper = ReadShader(fx);
        var includeLine = wrapper.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries)
            .Single(line => line.StartsWith("#include \"includes/", StringComparison.Ordinal));
        var includeRelative = includeLine[(includeLine.IndexOf('"') + 1)..includeLine.LastIndexOf('"')];
        var include = Path.Combine(roleDirectory, includeRelative.Replace('/', Path.DirectorySeparatorChar));
        Require(File.Exists(include), $"Missing generated include for {profile.Domain}: {includeRelative}.");
        Require(wrapper.Contains($"#include \"internal/{ExpectedRuntime(profile.Domain)}\"", StringComparison.Ordinal),
            $"{profile.Domain} selected the wrong runtime wrapper.");
        Require(!wrapper.Contains("../internal/", StringComparison.Ordinal),
            $"{profile.Domain} escaped the preset-local internal runtime.");
        if (profile.Domain == ShaderDomain.EyeWhite)
            Require(wrapper.Contains("#include \"internal/endfield_eye_white.hlsl\"", StringComparison.Ordinal),
                "EyeWhite wrapper is missing its dedicated prelude.");

        if (UsesCp932Wrapper(profile.Domain))
        {
            Require(!IsStrictUtf8(fx), $"{profile.Domain} wrapper must be CP932 for MME bone lookup.");
            Require(cp932.GetString(File.ReadAllBytes(fx)).Contains("頭", StringComparison.Ordinal),
                $"{profile.Domain} CP932 wrapper lost the head-bone name.");
        }
        else
        {
            Require(IsStrictUtf8(fx), $"{profile.Domain} wrapper must remain UTF-8.");
        }
    }

    var packageValidation = ProjectValidator.ValidateGeneratedPackage(packageRoot);
    Require(packageValidation.IsValid,
        "Generated domain matrix failed static validation: "
        + string.Join("; ", packageValidation.Messages.Select(message => $"{message.Code}: {message.Message}")));

    var emmPath = Path.Combine(packageRoot, $"{project.RoleSlug}_自动映射.emm");
    Require(File.Exists(emmPath), "Generated domain matrix is missing its EMM file.");
    var emm = Encoding.GetEncoding(936).GetString(File.ReadAllBytes(emmPath));
    Require(!emm.Contains(".endfieldstage_", StringComparison.OrdinalIgnoreCase),
        "EMM retained a staging-directory path.");
    foreach (var profile in project.Profiles)
    {
        var binding = ProjectService.GetBindings(profile).Single();
        var slug = ProjectService.Slugify(profile.ProfileName);
        var expectedFx = Path.Combine(packageRoot, "presets", project.RoleSlug, $"{project.RoleSlug}_{slug}.fx");
        Require(emm.Contains($"Pmd2[{binding.MaterialIndex}] = {expectedFx}", StringComparison.OrdinalIgnoreCase),
            $"EMM is missing the {profile.Domain} material target.");
    }

    if (!featureRich) return;
    string IncludeFor(ShaderDomain domain)
    {
        var profile = project.Profiles.Single(item => item.Domain == domain);
        var slug = ProjectService.Slugify(profile.ProfileName);
        var fx = Path.Combine(roleDirectory, $"{project.RoleSlug}_{slug}.fx");
        var wrapper = ReadShader(fx);
        var includeLine = wrapper.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries)
            .Single(line => line.StartsWith("#include \"includes/", StringComparison.Ordinal));
        var includeRelative = includeLine[(includeLine.IndexOf('"') + 1)..includeLine.LastIndexOf('"')];
        return ReadShader(Path.Combine(roleDirectory, includeRelative.Replace('/', Path.DirectorySeparatorChar)));
    }

    var hair = IncludeFor(ShaderDomain.Hair);
    Require(hair.Contains("#define EF_HAIR_FINAL_RIM_PASS 1", StringComparison.Ordinal)
            && hair.Contains("#define EF_HAIR_RD_KK_RS_COMPOSITE_DEBUG 1", StringComparison.Ordinal)
            && hair.Contains("#define EF_HAIR_CONTROLLER_RANGE5_ENABLED 1", StringComparison.Ordinal)
            && hair.Contains("#define EF_HAIR_SPEC_OFF 0", StringComparison.Ordinal),
        "Hair production rim/highlight/controller macros were not generated.");
    var skin = IncludeFor(ShaderDomain.Skin);
    Require(skin.Contains("#define EF_SKIN_SCREEN_RIM_ENABLED 1", StringComparison.Ordinal)
            && skin.Contains("#define EF_SKIN_CONTROLLER_ENABLED 1", StringComparison.Ordinal)
            && skin.Contains("#define EF_SKIN_SPECULAR_ENABLED 1", StringComparison.Ordinal),
        "Skin production rim/specular/controller macros were not generated.");
    var cloth = IncludeFor(ShaderDomain.Cloth);
    Require(cloth.Contains("#define EF_CLOTH_PROPERTY_TEXTURE_RESOURCE \"../../textures/common/PreIntegratedFGD_GGXDisneyDiffuse.png\"", StringComparison.Ordinal)
            && cloth.Contains("#define EF_CLOTH_RAIN_DROP_ENABLED 1", StringComparison.Ordinal)
            && cloth.Contains("#define EF_CLOTH_RAIN_DROP_PHASE_TEXTURE_RESOURCE", StringComparison.Ordinal)
            && cloth.Contains("#define EF_CLOTH_FGD_LUT_ENABLED 1", StringComparison.Ordinal)
            && cloth.Contains("#define EF_CLOTH_MATCAP_ENABLED 1", StringComparison.Ordinal)
            && cloth.Contains("#define EF_CLOTH_CONTROLLER_ENABLED 1", StringComparison.Ordinal),
        "Cloth property/rain/FGD/MATCAP/controller macros were not generated.");
    var face = IncludeFor(ShaderDomain.Face);
    Require(face.Contains("#define EF_FACE_CMM_TEXTURE_RESOURCE \"../../textures/common/Eff_MatCap_019.png\"", StringComparison.Ordinal)
            && face.Contains("#define EF_FACE_SHADOW_RECEIVER_ST_TEXTURE_RESOURCE \"../../textures/common/Eff_MatCap_019_manual_lod.png\"", StringComparison.Ordinal)
            && face.Contains("#define EF_FACE_SSS_ENABLED 1", StringComparison.Ordinal)
            && face.Contains("#define EF_FACE_STENCIL_WRITE_ENABLED 1", StringComparison.Ordinal),
        "Face CMM/ST/SSS resource mapping was not generated correctly.");
    var capture = ReadShader(Path.Combine(packageRoot, "EndfieldEyeThrough_Capture.fxsub"));
    Require(capture.Contains("#define EF_EYE_CAPTURE_IRIS_TEXTURE_RESOURCE \"textures/common/rain/T_actor_common_rain_02_M.png\"", StringComparison.Ordinal),
        "EyeThrough capture did not retain the packaged external iris resource.");
}

static void VerifyFxcPackage(string packageRoot)
{
    if (Environment.GetEnvironmentVariable("ENDFIELD_SKIP_FXC") == "1") return;
    var fxc = FxcCompiler.Find()
        ?? throw new FileNotFoundException("Release verification requires fxc.exe.");
    var effects = Directory.GetFiles(packageRoot, "*.fx", SearchOption.AllDirectories);
    var results = FxcCompiler.CompileFiles(effects, fxc);
    Require(results.Count == effects.Length, "FXC did not return one result per generated effect.");
    Require(results.All(result => result.Succeeded),
        "Generated package failed FXC: "
        + string.Join("; ", results.Where(result => !result.Succeeded)
            .Select(result => $"{Path.GetRelativePath(packageRoot, result.FilePath)}: {result.Output}")));
}

Require(ProjectService.Slugify("  Chen 千语  ") == "chen", "Role slugification changed unexpectedly.");
Require(MaterialClassifier.Suggest(new PmxMaterialInfo { Name = "眼白" }) == ShaderDomain.EyeWhite,
    "Eye-white material classification failed.");
Require(MaterialClassifier.Suggest(new PmxMaterialInfo { Name = "hair_main" }) == ShaderDomain.Hair,
    "Hair material classification failed.");
Require(ProjectService.ShouldPromptForPmxSelection("missing.pmx", null),
    "Missing PMX paths must request a browse selection.");

static string FindTemplate()
{
    var current = new DirectoryInfo(AppContext.BaseDirectory);
    while (current is not null)
    {
        foreach (var candidate in new[]
        {
            Path.Combine(current.FullName, "ShaderTemplate")
        })
        {
            if (File.Exists(Path.Combine(candidate, "internal", "endfield_face.hlsl")))
                return candidate;
        }
        try
        {
            foreach (var candidate in Directory.EnumerateDirectories(current.FullName))
            {
                if (File.Exists(Path.Combine(candidate, "internal", "endfield_face.hlsl")))
                    return candidate;
            }
        }
        catch (IOException) { }
        catch (UnauthorizedAccessException) { }
        current = current.Parent;
    }
    throw new DirectoryNotFoundException("ShaderTemplate was not found from the test output directory.");
}

var template = Environment.GetEnvironmentVariable("ENDFIELD_TEMPLATE_ROOT") is { Length: > 0 } overrideRoot
    ? Path.GetFullPath(overrideRoot)
    : FindTemplate();
Require(File.Exists(Path.Combine(template, "internal", "endfield_shader.hlsl")),
    "Selected ShaderTemplate is missing the Endfield shader core.");

var includeClosureRoot = Path.Combine(Path.GetTempPath(), "EndfieldIncludeClosure_" + Guid.NewGuid().ToString("N"));
try
{
    var presetDirectory = Path.Combine(includeClosureRoot, "presets", "role");
    var presetInternal = Path.Combine(presetDirectory, "internal");
    Directory.CreateDirectory(presetInternal);
    File.WriteAllText(Path.Combine(presetDirectory, "role_material.fx"), "#include \"internal/main.hlsl\"\n");
    File.WriteAllText(Path.Combine(presetInternal, "main.hlsl"), "#include \"internal/dependency.inc\"\n");
    var dependency = Path.Combine(presetInternal, "dependency.inc");
    File.WriteAllText(dependency, "// dependency\n");
    Require(ProjectValidator.ValidateGeneratedPackage(includeClosureRoot).IsValid,
        "MME-style preset include closure rejected a complete package.");
    File.Delete(dependency);
    Require(ProjectValidator.ValidateGeneratedPackage(includeClosureRoot).Messages
            .Any(message => message.Code == "MISSING_PRESET_INCLUDE"),
        "Preset validation did not catch a nested include missing from the top-level FX directory.");
}
finally
{
    if (Directory.Exists(includeClosureRoot)) Directory.Delete(includeClosureRoot, recursive: true);
}

var project = new EndfieldProject
{
    RoleName = "Smoke",
    RoleSlug = "smoke",
    TemplateRoot = template,
    PmxPath = string.Empty,
    Model = null
};
project.Profiles.Add(new MaterialProfile
{
    ProfileName = "cloth",
    Domain = ShaderDomain.Cloth,
    MaterialIndex = -1,
    Parameters = MaterialDefaults.CreateParameters(ShaderDomain.Cloth)
});
var validation = ProjectValidator.Validate(project);
Require(validation.Messages.Any(x => x.Code == "MODEL"), "Validator did not report a missing PMX model.");
Require(ShadowBackendSupport.ControlFile(ShadowBackend.Zmd) == "ZMDshadow.x",
    "Endfield shadow backend mapping is incorrect.");
Require(ShadowBackendSupport.CommonTemplateFiles.Contains(
        "internal/endfield_cloth_controls.inc",
        StringComparer.OrdinalIgnoreCase),
    "Cloth controller include must be part of template preflight validation.");
var faceShader = File.ReadAllText(Path.Combine(template, "internal", "endfield_face.hlsl"));
Require(faceShader.Contains("EF_FACE_LIP_SPECULAR_TEXTURE_RESOURCE", StringComparison.Ordinal),
    "Face shader is missing the optional lip-specular resource hook.");
Require(!faceShader.Contains("neutral_mask.png", StringComparison.OrdinalIgnoreCase),
    "Face shader must not reference a missing neutral lip mask.");

var cloth = MaterialDefaults.Create(new PmxMaterialInfo { Index = 0, Name = "cloth" }, ShaderDomain.Cloth, template);
var hasCommonMatcap = File.Exists(Path.Combine(template, "textures", "common", "Eff_MatCap_019.png"))
    && File.Exists(Path.Combine(template, "textures", "common", "Eff_MatCap_019_manual_lod.png"));
Require(cloth.Textures.Matcap05.IsSelected == hasCommonMatcap
    && cloth.Textures.Matcap07.IsSelected == hasCommonMatcap,
    "Cloth MATCAP defaults must follow the assets present in the selected template.");
Require(cloth.Textures.Rd.SourcePath is null && cloth.Textures.Lut.SourcePath is null,
    "Character-specific RD/LUT assets must not be silently assigned.");
cloth.Textures.Matcap05.SourcePath = null;
cloth.Textures.Matcap07.SourcePath = "manual-lod.png";
MaterialDefaults.ConfigureFeatureFlags(cloth);
Require(cloth.Parameters.UseMatcap, "Either cloth MATCAP slot should enable the MATCAP feature.");
MaterialDefaults.ConfigureTextureSelection(cloth, "property", true);
Require(cloth.Parameters.UseMatcap, "Selecting the MRO/property slot must not disable MATCAP.");
cloth.Parameters.EnableRain = true;
MaterialDefaults.ConfigureTextureSelection(cloth, "rd", true);
Require(cloth.Parameters.EnableRain, "Texture selection must not reset the user rain toggle.");

var matrixOutput = Path.Combine(Path.GetTempPath(), "EndfieldDomainMatrix_" + Guid.NewGuid().ToString("N"));
try
{
    var matrixProject = CreateDomainMatrixProject(template, "domain_matrix", featureRich: false);
    var matrixGenerated = new PackageGenerator().Generate(matrixProject, matrixOutput, overwrite: true);
    Require(matrixGenerated.Validation.IsValid,
        "All-domain package generation failed: "
        + string.Join("; ", matrixGenerated.Validation.Messages.Select(message => $"{message.Code}: {message.Message}")));
    VerifyGeneratedDomainMatrix(matrixProject, matrixGenerated.OutputDirectory, featureRich: false);
    VerifyFxcPackage(matrixGenerated.OutputDirectory);

    if (HasFullOptionalAssets(template))
    {
        var richProject = CreateDomainMatrixProject(template, "domain_matrix_full", featureRich: true);
        var richGenerated = new PackageGenerator().Generate(richProject, matrixOutput, overwrite: true);
        Require(richGenerated.Validation.IsValid,
            "Full-feature package generation failed: "
            + string.Join("; ", richGenerated.Validation.Messages.Select(message => $"{message.Code}: {message.Message}")));
        VerifyGeneratedDomainMatrix(richProject, richGenerated.OutputDirectory, featureRich: true);
        VerifyFxcPackage(richGenerated.OutputDirectory);
    }
    else
    {
        var optionalProject = CreateDomainMatrixProject(template, "optional_assets_missing", featureRich: false);
        var optionalCloth = optionalProject.Profiles.Single(profile => profile.Domain == ShaderDomain.Cloth);
        optionalCloth.Parameters.EnableRain = true;
        optionalCloth.Parameters.UseFgdLut = true;
        var missingOptional = ProjectValidator.Validate(optionalProject);
        Require(missingOptional.Messages.Any(message => message.Code == "CLOTH_RAIN_RESOURCE"),
            "Rain enabled without optional assets did not produce a clear validation error.");
        Require(missingOptional.Messages.Any(message => message.Code == "CLOTH_FGD_RESOURCE"),
            "FGD enabled without its optional LUT did not produce a clear validation error.");
    }

    foreach (var unsafePath in new[] { "../escape.png", @"C:\escape.png", @"\\server\share\escape.png", "\0escape.png" })
    {
        var unsafeProject = CreateDomainMatrixProject(template, "unsafe_package_path", featureRich: false);
        var unsafeProfile = unsafeProject.Profiles.Single(profile => profile.Domain == ShaderDomain.Body);
        unsafeProfile.Textures.Base.PackagePath = unsafePath;
        unsafeProfile.UsePmxBaseTexture = false;
        unsafeProfile.Parameters.UseExternalBase = true;
        var unsafeValidation = ProjectValidator.Validate(unsafeProject);
        Require(unsafeValidation.Messages.Any(message => message.Code == "TEXTURE_PACKAGE_PATH"),
            $"Unsafe package texture path was accepted: {unsafePath}");
    }
}
finally
{
    if (Directory.Exists(matrixOutput)) Directory.Delete(matrixOutput, recursive: true);
}

var perlicaPath = Path.GetFullPath(Path.Combine(template, "..", "Arknights-Endfield-Inspired-Perlica-Character-Shader", "Assets", "佩丽卡.pmx"));
if (File.Exists(perlicaPath))
{
    var perlicaProject = ProjectService.CreateFromModel(template, perlicaPath, "perlica_smoke");
    Require(perlicaProject.Profiles.All(profile =>
        !string.Join(" ", profile.Textures.Base.SourcePath, profile.Textures.Normal.SourcePath,
            profile.Textures.Property.SourcePath, profile.Textures.Rd.SourcePath,
            profile.Textures.Lut.SourcePath).Contains("textures/chen", StringComparison.OrdinalIgnoreCase)),
        "A non-Chen model must not inherit Chen Qianyu texture paths.");
    // Keep the rim regression independent of a particular model's material
    // naming by turning one already-bound profile into a minimal Hair profile.
    // Reusing its PMX binding keeps package validation meaningful.
    var hairProfile = perlicaProject.Profiles.First();
    hairProfile.ProfileName = "hair_rim_smoke";
    hairProfile.MaterialName = "hair_rim_smoke";
    hairProfile.Domain = ShaderDomain.Hair;
    hairProfile.Parameters = MaterialDefaults.CreateParameters(ShaderDomain.Hair);
    hairProfile.Parameters.UseNormal = false;
    var smokeOutput = Path.Combine(Path.GetTempPath(), "EndfieldShaderToolSmoke_" + Guid.NewGuid().ToString("N"));
    var generator = new PackageGenerator();
    var generated = generator.Generate(perlicaProject, smokeOutput, overwrite: true);
    Require(generated.Validation.IsValid, "Non-Chen package generation failed: " + string.Join("; ", generated.Validation.Messages.Select(x => x.Message)));
    Require(File.Exists(Path.Combine(generated.OutputDirectory, "FXC_UNVERIFIED.txt")), "Generated package was not committed.");
    var presetInternal = Path.Combine(generated.OutputDirectory, "presets", perlicaProject.RoleSlug, "internal");
    Require(File.Exists(Path.Combine(presetInternal, "endfield_shader.hlsl")),
        "Generated presets must contain a local internal runtime for MME nested include resolution.");
    var hairInclude = Path.Combine(generated.OutputDirectory, "presets", perlicaProject.RoleSlug, "includes",
        $"{perlicaProject.RoleSlug}_{ProjectService.Slugify(hairProfile!.ProfileName)}.inc");
    Require(File.Exists(hairInclude), "Generated package did not contain the expected hair include.");
    Require(File.ReadAllText(hairInclude).Contains("#define EF_HAIR_FINAL_RIM_PASS 1", StringComparison.Ordinal),
        "Generated hair effects must compile the screen-space DrawHairRim pass.");
    var hairFx = Path.Combine(generated.OutputDirectory, "presets", perlicaProject.RoleSlug,
        $"{perlicaProject.RoleSlug}_{ProjectService.Slugify(hairProfile.ProfileName)}.fx");
    Require(File.ReadAllText(hairFx).Contains("#include \"internal/endfield_shader.hlsl\"", StringComparison.Ordinal),
        "Generated material wrappers must enter the preset-local internal runtime.");
    var regenerated = generator.Generate(perlicaProject, smokeOutput, overwrite: true);
    Require(regenerated.Validation.IsValid && File.Exists(Path.Combine(regenerated.OutputDirectory, "FXC_UNVERIFIED.txt")),
        "Overwriting an existing generated package failed.");
    Require(!Directory.GetDirectories(smokeOutput, "*.endfieldstage_*", SearchOption.TopDirectoryOnly).Any()
        && !Directory.GetDirectories(smokeOutput, "*.endfieldbackup_*", SearchOption.TopDirectoryOnly).Any(),
        "Successful package overwrite left staging or backup directories behind.");
    var fxc = Environment.GetEnvironmentVariable("ENDFIELD_SKIP_FXC") == "1"
        ? null
        : FxcCompiler.Find();
    if (fxc is not null)
    {
        var generatedFx = Directory.GetFiles(Path.Combine(generated.OutputDirectory, "presets"), "*.fx", SearchOption.AllDirectories);
        var compileResults = FxcCompiler.CompileFiles(generatedFx, fxc);
        Require(compileResults.All(x => x.Succeeded),
            "Generated non-Chen FX failed FXC: " + string.Join("; ", compileResults.Where(x => !x.Succeeded).Select(x => $"{Path.GetFileName(x.FilePath)}: {x.Output}")));
    }
    Directory.Delete(smokeOutput, recursive: true);
}

var realPmxPath = Environment.GetEnvironmentVariable("ENDFIELD_REAL_PMX");
if (!string.IsNullOrWhiteSpace(realPmxPath) && File.Exists(realPmxPath))
{
    var realProject = ProjectService.CreateFromModel(template, realPmxPath, "real_model_smoke");
    realProject.IncludeEyeThrough = false;
    realProject.IncludePostProcessing = true;
    var realModel = realProject.Model ?? throw new InvalidOperationException("Real PMX import returned no model.");
    Require(realProject.Profiles.Count == realModel.Materials.Count,
        "Real PMX import did not create one initial profile per material.");
    Require(realProject.Profiles.SelectMany(ProjectService.GetBindings)
            .Select(binding => binding.MaterialIndex).Distinct().Count() == realModel.Materials.Count,
        "Real PMX import lost or duplicated material bindings.");
    var realOutput = Path.Combine(Path.GetTempPath(), "EndfieldRealModel_" + Guid.NewGuid().ToString("N"));
    try
    {
        var realGenerated = new PackageGenerator().Generate(realProject, realOutput, overwrite: true);
        Require(realGenerated.Validation.IsValid,
            "Real PMX package generation failed: "
            + string.Join("; ", realGenerated.Validation.Messages.Select(message => $"{message.Code}: {message.Message}")));
        var realStaticValidation = ProjectValidator.ValidateGeneratedPackage(realGenerated.OutputDirectory);
        Require(realStaticValidation.IsValid,
            "Real PMX package failed static validation: "
            + string.Join("; ", realStaticValidation.Messages.Select(message => $"{message.Code}: {message.Message}")));
        VerifyFxcPackage(realGenerated.OutputDirectory);
    }
    finally
    {
        if (Directory.Exists(realOutput)) Directory.Delete(realOutput, recursive: true);
    }
}

if (OperatingSystem.IsWindows())
{
    var fallbackRoot = Path.Combine(Path.GetTempPath(), "EndfieldCommitFallback_" + Guid.NewGuid().ToString("N"));
    var staging = Path.Combine(fallbackRoot, "role.endfieldstage_test");
    var output = Path.Combine(fallbackRoot, "role");
    Directory.CreateDirectory(staging);
    File.WriteAllText(Path.Combine(staging, "fallback.txt"), "copy fallback");
    try
    {
        using (DirectoryLock.Open(staging))
        {
            var commit = typeof(PackageGenerator).GetMethod("CommitStaging", BindingFlags.NonPublic | BindingFlags.Static)
                ?? throw new MissingMethodException(nameof(PackageGenerator), "CommitStaging");
            try
            {
                commit.Invoke(null, new object[] { staging, output });
            }
            catch (TargetInvocationException ex)
            {
                throw ex.InnerException ?? ex;
            }
        }
        Require(File.ReadAllText(Path.Combine(output, "fallback.txt")) == "copy fallback",
            "A locked staging directory did not use the recursive-copy commit fallback.");
    }
    finally
    {
        if (Directory.Exists(fallbackRoot)) Directory.Delete(fallbackRoot, recursive: true);
    }
}

Console.WriteLine("EndfieldShaderTool smoke tests passed.");

internal static class DirectoryLock
{
    private const uint FileFlagBackupSemantics = 0x02000000;

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern SafeFileHandle CreateFile(
        string fileName,
        uint desiredAccess,
        FileShare shareMode,
        IntPtr securityAttributes,
        FileMode creationDisposition,
        uint flagsAndAttributes,
        IntPtr templateFile);

    public static SafeFileHandle Open(string path)
    {
        var handle = CreateFile(
            path,
            0,
            FileShare.Read | FileShare.Write,
            IntPtr.Zero,
            FileMode.Open,
            FileFlagBackupSemantics,
            IntPtr.Zero);
        if (handle.IsInvalid) throw new Win32Exception(Marshal.GetLastWin32Error());
        return handle;
    }
}
