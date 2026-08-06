using EndfieldShaderTool.Core;

static void Require(bool condition, string message)
{
    if (!condition) throw new InvalidOperationException(message);
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
    var generated = new PackageGenerator().Generate(perlicaProject, smokeOutput, overwrite: true);
    Require(generated.Validation.IsValid, "Non-Chen package generation failed: " + string.Join("; ", generated.Validation.Messages.Select(x => x.Message)));
    Require(File.Exists(Path.Combine(generated.OutputDirectory, "FXC_UNVERIFIED.txt")), "Generated package was not committed.");
    var hairInclude = Path.Combine(generated.OutputDirectory, "presets", perlicaProject.RoleSlug, "includes",
        $"{perlicaProject.RoleSlug}_{ProjectService.Slugify(hairProfile!.ProfileName)}.inc");
    Require(File.Exists(hairInclude), "Generated package did not contain the expected hair include.");
    Require(File.ReadAllText(hairInclude).Contains("#define EF_HAIR_FINAL_RIM_PASS 1", StringComparison.Ordinal),
        "Generated hair effects must compile the screen-space DrawHairRim pass.");
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

Console.WriteLine("EndfieldShaderTool smoke tests passed.");
