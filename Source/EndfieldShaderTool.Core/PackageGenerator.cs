using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace EndfieldShaderTool.Core;

public sealed class PackageGenerator
{
    public GenerationResult GenerateSingleProfile(
        EndfieldProject project,
        MaterialProfile profile,
        string outputParent,
        bool overwrite = false)
    {
        ArgumentNullException.ThrowIfNull(project);
        ArgumentNullException.ThrowIfNull(profile);

        var selected = ProjectService.CloneProfile(profile);
        var roleSlug = ProjectService.Slugify($"{project.RoleSlug}_{selected.ProfileName}");
        var singleProject = ProjectService.Clone(project);
        singleProject.RoleName = $"{project.RoleName} - {selected.ProfileName}";
        singleProject.RoleSlug = roleSlug;
        singleProject.Profiles = new List<MaterialProfile> { selected };

        return Generate(singleProject, outputParent, overwrite);
    }

    public GenerationResult Generate(EndfieldProject project, string outputParent, bool overwrite = false)
    {
        ProjectService.NormalizeMaterialBindings(project);
        MaterialDefaults.DisableSkinBrdf(project);
        MaterialDefaults.ConfigureHairHighlights(project);
        var validation = ProjectValidator.Validate(project);
        if (!validation.IsValid) return new GenerationResult { Validation = validation };
        if (string.IsNullOrWhiteSpace(outputParent)) throw new ArgumentException("Output directory is required.", nameof(outputParent));

        var outputRoot = Path.GetFullPath(outputParent);
        var output = Path.Combine(outputRoot, project.RoleSlug);
        if (Directory.Exists(output) && !overwrite) throw new IOException($"Output directory already exists: {output}");
        var staging = output + ".endfieldstage_" + Guid.NewGuid().ToString("N");
        try
        {
            RunFileSystemWithRetry(
                () => Directory.CreateDirectory(outputRoot),
                $"无法创建角色包输出根目录：{outputRoot}");
            RunFileSystemWithRetry(
                () => Directory.CreateDirectory(staging),
                $"无法创建角色包临时目录：{staging}");
        }
        catch (Exception ex)
        {
            TryDeleteDirectory(staging);
            throw CreateCommitException(
                "无法创建角色包输出或临时目录。",
                staging,
                output,
                null,
                ex);
        }
        var generated = new GenerationResult { OutputDirectory = output, Validation = validation };
        try
        {
            var shadowBackend = ShadowBackendSupport.DetectRequired(project.TemplateRoot);
            CopyRuntime(project.TemplateRoot, staging, generated.GeneratedFiles);
            var controllerPath = Path.Combine(staging, "controller", "Endfield_controller.pmx");
            if (File.Exists(controllerPath))
            {
                PmxControllerMorphEditor.EnsureEndfieldMorphs(
                    controllerPath,
                    includeCameraLight: false
                );
            }
            var textureMap = BuildCommonTextureMap(staging);
            var sharedIncludes = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (var profile in project.Profiles)
            {
                var profileSlug = ProjectService.Slugify(profile.ProfileName);
                var includeDirectory = Path.Combine(staging, "presets", project.RoleSlug, "includes");
                Directory.CreateDirectory(includeDirectory);
                var packageTexturePaths = CopyProfileTextures(project, profile, staging, profileSlug, textureMap, generated.GeneratedFiles);
                var includeContent = BuildInclude(profile, packageTexturePaths);
                var includeHash = ComputeHash(Encoding.UTF8.GetBytes(includeContent));
                if (!sharedIncludes.TryGetValue(includeHash, out var includeName))
                {
                    includeName = $"{project.RoleSlug}_{profileSlug}.inc";
                    var includePath = Path.Combine(includeDirectory, includeName);
                    File.WriteAllText(includePath, includeContent, new UTF8Encoding(false));
                    generated.GeneratedFiles.Add(includePath);
                    sharedIncludes[includeHash] = includeName;
                }

                var fxDirectory = Path.Combine(staging, "presets", project.RoleSlug);
                var fxName = $"{project.RoleSlug}_{profileSlug}.fx";
                var fxPath = Path.Combine(fxDirectory, fxName);
                File.WriteAllBytes(fxPath, BuildWrapper(project, profile, includeName));
                generated.GeneratedFiles.Add(fxPath);
            }

            if (project.IncludeEyeThrough)
            {
                var capturePath = Path.Combine(staging, "EndfieldEyeThrough_Capture.fxsub");
                File.WriteAllText(capturePath, BuildEyeThroughCapture(project), new UTF8Encoding(false));
                generated.GeneratedFiles.Add(capturePath);
            }

            var projectPath = Path.Combine(staging, $"{project.RoleSlug}.endfieldproject.json");
            var exportedProject = ProjectService.Clone(project);
            // Resolve the package template relative to the project JSON so the
            // entire role directory can be moved without editing the file.
            exportedProject.TemplateRoot = ".";
            MakeTextureReferencesPortable(exportedProject);
            ProjectService.Save(exportedProject, projectPath);
            generated.GeneratedFiles.Add(projectPath);

            var readmePath = Path.Combine(staging, $"{project.RoleSlug}_材质分配说明.md");
            File.WriteAllText(readmePath, BuildReadme(project), new UTF8Encoding(false));
            generated.GeneratedFiles.Add(readmePath);

            if (project.GenerateEmm)
            {
                var emmPath = Path.Combine(staging, $"{project.RoleSlug}_自动映射.emm");
                File.WriteAllBytes(emmPath, EmmGenerator.Encode(EmmGenerator.Build(project, output)));
                generated.GeneratedFiles.Add(emmPath);
            }

            var unverifiedPath = Path.Combine(staging, "FXC_UNVERIFIED.txt");
            File.WriteAllText(unverifiedPath, "This package has passed static path validation but has not been validated by fxc.exe yet.\r\nRun Compile Check in Endfield Shader Tool before distribution.\r\n", new UTF8Encoding(false));
            generated.GeneratedFiles.Add(unverifiedPath);

            var packageValidation = ProjectValidator.ValidateGeneratedPackage(staging);
            foreach (var message in packageValidation.Messages) validation.Messages.Add(message);
            if (!packageValidation.IsValid) return generated;

            CommitStaging(staging, output);
            for (var index = 0; index < generated.GeneratedFiles.Count; index++)
                generated.GeneratedFiles[index] = Path.Combine(output, Path.GetRelativePath(staging, generated.GeneratedFiles[index]));
            return generated;
        }
        finally
        {
            TryDeleteDirectory(staging);
        }
    }

    private static void CopyRuntime(string templateRoot, string output, ICollection<string> generatedFiles)
    {
        var backend = ShadowBackendSupport.DetectRequired(templateRoot);
        CopyDirectory(Path.Combine(templateRoot, "internal"), Path.Combine(output, "internal"), generatedFiles);
        CopyDirectory(Path.Combine(templateRoot, "textures", "common"), Path.Combine(output, "textures", "common"), generatedFiles);
        var runtimeNames = new HashSet<string>(ShadowBackendSupport.RequiredFiles(backend), StringComparer.OrdinalIgnoreCase)
        {
            "ZMDshadow.x", "ZMDshadow.fx", "ZMDshadow_ShadowMap.fxsub", "ZMDshadow_ViewportMap.fxsub",
            "EndfieldPost.fx", "EndfieldPost.x", "EndfieldEyeThrough.fx", "EndfieldEyeThrough.x",
            "EndfieldEyeThrough_Mask.fxsub", "EndfieldEyeThrough_Capture.fxsub"
        };
        CopyDirectory(Path.Combine(templateRoot, "controller"), Path.Combine(output, "controller"), generatedFiles);
        CopyDirectory(Path.Combine(templateRoot, "textures", "environment_presets"), Path.Combine(output, "textures", "environment_presets"), generatedFiles);
        foreach (var name in runtimeNames)
        {
            var file = Path.Combine(templateRoot, name);
            if (!File.Exists(file)) continue;
            var dest = Path.Combine(output, name);
            File.Copy(file, dest, true);
            generatedFiles.Add(dest);
        }
    }

    private static void CopyDirectory(string source, string destination, ICollection<string> generatedFiles)
    {
        if (!Directory.Exists(source)) return;
        Directory.CreateDirectory(destination);
        foreach (var file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(source, file);
            var dest = Path.Combine(destination, relative);
            Directory.CreateDirectory(Path.GetDirectoryName(dest)!);
            File.Copy(file, dest, true);
            generatedFiles.Add(dest);
        }
    }

    private static Dictionary<string, string> BuildCommonTextureMap(string output)
    {
        var map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var common = Path.Combine(output, "textures", "common");
        if (!Directory.Exists(common)) return map;
        foreach (var file in Directory.GetFiles(common, "*", SearchOption.AllDirectories))
        {
            var relative = Path.GetRelativePath(output, file).Replace('\\', '/');
            map[ComputeHash(file)] = relative;
        }
        return map;
    }

    private static Dictionary<string, string> CopyProfileTextures(
        EndfieldProject project,
        MaterialProfile profile,
        string output,
        string profileSlug,
        IDictionary<string, string> textureMap,
        ICollection<string> generatedFiles)
    {
        var values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var slots = new Dictionary<string, TextureReference>(StringComparer.OrdinalIgnoreCase)
        {
            ["base"] = profile.Textures.Base,
            ["normal"] = profile.Textures.Normal,
            ["property"] = profile.Textures.Property,
            ["rd"] = profile.Textures.Rd,
            ["rs"] = profile.Textures.Rs,
            ["lut"] = profile.Textures.Lut,
            ["sdf"] = profile.Textures.Sdf,
            ["st"] = profile.Textures.St,
            ["color_mask"] = profile.Textures.ColorMask,
            ["matcap05"] = profile.Textures.Matcap05,
            ["matcap07"] = profile.Textures.Matcap07,
            ["hair_line"] = profile.Textures.HairLine
        };
        foreach (var pair in slots)
        {
            if (!pair.Value.IsSelected) continue;
            var source = ResolveTextureSource(project, pair.Value);
            if (string.IsNullOrWhiteSpace(source) || !File.Exists(source))
            {
                var selectedPath = pair.Value.SourcePath ?? pair.Value.PackagePath ?? "(empty)";
                throw new FileNotFoundException($"Selected {pair.Key} texture could not be resolved: {selectedPath}", selectedPath);
            }
            var hash = ComputeHash(source);
            if (!textureMap.TryGetValue(hash, out var packagePath))
            {
                var extension = Path.GetExtension(source).ToLowerInvariant();
                if (string.IsNullOrWhiteSpace(extension)) extension = ".png";
                var fileName = $"{profileSlug}_{pair.Key}{extension}";
                packagePath = Path.Combine("textures", project.RoleSlug, fileName).Replace('\\', '/');
                var destination = Path.Combine(output, packagePath.Replace('/', Path.DirectorySeparatorChar));
                Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
                File.Copy(source, destination, true);
                generatedFiles.Add(destination);
                textureMap[hash] = packagePath;
            }
            pair.Value.PackagePath = packagePath;
            values[pair.Key] = packagePath;
        }
        return values;
    }

    private static string BuildInclude(MaterialProfile profile, IReadOnlyDictionary<string, string> textures)
    {
        var p = profile.Parameters;
        var lines = new List<string>
        {
            "// Generated by Endfield Shader Tool.",
            $"#define EF_DOMAIN {DomainValue(profile.Domain)}",
            $"#define EF_CULL_MODE {CullValue(p.CullMode)}",
            $"#define EF_USE_NORMAL_MAP {Bool(p.UseNormal)}",
            $"#define EF_BUMP_SCALE {F(p.NormalStrength)}",
            $"#define EF_USE_ALPHA_CLIP {Bool(p.UseAlphaClip)}",
            $"#define EF_ALPHA_CUTOFF {F(p.AlphaCutoff)}",
            $"#define EF_USE_SPHERE_NORMAL {Bool(profile.UsePmxSphereMap)}",
            $"#define EF_RIM_STRENGTH {F(p.RimStrength)}",
            $"#define EF_RIM_COLOR {Color3(p.RimColor)}",
            $"#define EF_SPEC_POW_STRENGTH {F(p.SpecularPower)}",
            $"#define EF_SPEC_BACK_F0 {Color3(p.SpecularColor)}",
            $"#define EF_HAIR_HIGHLIGHT_INTENSITY {F(p.HighlightStrength)}",
            $"#define EF_HAIR_SPEC_OFF {Bool(profile.Domain != ShaderDomain.Hair || !p.UseHighlight)}",
            $"#define EF_FACE_SDF_ENABLED {Bool(p.UseSdf)}",
            $"#define EF_FACE_SHADOW_STRENGTH {F(p.SelfShadowStrength)}",
            $"#define EF_SKIN_SPECULAR_STRENGTH {F(p.SpecularStrength)}",
            $"#define EF_CLOTH_SPECULAR_STRENGTH {F(p.SpecularStrength)}",
            $"#define EF_CLOTH_BROAD_SPECULAR_STRENGTH {F(p.SpecularBroadStrength)}",
            $"#define EF_CLOTH_RAIN_ENABLED {Bool(p.EnableRain)}",
            $"#define EF_CLOTH_RAIN_AMOUNT {F(p.EnableRain ? p.RainMaximum : 0f)}",
            $"#define EF_EYE_IRIS_MATCAP05_ENABLED {Bool(p.UseMatcap05)}",
            $"#define EF_EYE_IRIS_MATCAP07_ENABLED {Bool(p.UseMatcap07)}"
        };
        AddEndfieldMacros(lines, profile, textures);
        return string.Join(Environment.NewLine, lines) + Environment.NewLine;
    }

    private static void AddEndfieldMacros(ICollection<string> lines, MaterialProfile profile, IReadOnlyDictionary<string, string> textures)
    {
        var p = profile.Parameters;
        var prefix = profile.Domain switch
        {
            ShaderDomain.Face => "FACE",
            ShaderDomain.Skin => "SKIN",
            ShaderDomain.Cloth => "CLOTH",
            ShaderDomain.Hair => "MAIN",
            ShaderDomain.Iris or ShaderDomain.EyeWhite or ShaderDomain.EyeHighlight or ShaderDomain.BrowLash or ShaderDomain.Mouth or ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay => "FACIAL",
            _ => "MAIN"
        };
        lines.Add($"#define EF_USE_ORM {Bool(textures.ContainsKey("property"))}");
        AddTexture(lines, $"EF_{prefix}_MAIN_TEXTURE_RESOURCE", textures, "base");
        AddTexture(lines, $"EF_{prefix}_NORMAL_TEXTURE_RESOURCE", textures, "normal");
        AddTexture(lines, "EF_MAIN_TEXTURE_RESOURCE", textures, "base");
        AddTexture(lines, "EF_NORMAL_TEXTURE", textures, "normal");
        AddTexture(lines, "EF_ORM_TEXTURE", textures, "property");
        AddTexture(lines, "EF_RAMP_TEXTURE", textures, "rd");
        AddTexture(lines, $"EF_{prefix}_RD_TEXTURE_RESOURCE", textures, "rd");
        AddTexture(lines, $"EF_{prefix}_RS_TEXTURE_RESOURCE", textures, "rs");
        AddTexture(lines, $"EF_{prefix}_LUT_TEXTURE_RESOURCE", textures, "lut");
        AddTexture(lines, $"EF_{prefix}_ST_TEXTURE_RESOURCE", textures, "st");
        if (profile.Domain == ShaderDomain.Face)
        {
            AddTexture(lines, "EF_FACE_SKIN_LUT_TEXTURE_RESOURCE", textures, "lut");
            AddTexture(lines, "EF_FACE_SDF_TEXTURE_RESOURCE", textures, "sdf");
        }
        if (profile.Domain == ShaderDomain.Hair)
        {
            AddTexture(lines, "EF_HAIR_SPEC_TEXTURE", textures, "rs");
            AddTexture(lines, "EF_HAIR_ANISO_NOISE_TEXTURE", textures, "st");
            AddTexture(lines, "EF_HAIR_LINE_TEXTURE", textures, "hair_line");
            // The accepted screen-space hair rim is a separate additive pass.
            // It must be enabled before endfield_shader.hlsl is included or the
            // DrawHairRim pass is omitted from the generated effect entirely.
            lines.Add("#define EF_HAIR_FINAL_RIM_PASS 1");
            lines.Add("#define EF_GOO_RIM_WIDTH_X 0.041847");
            lines.Add("#define EF_GOO_RIM_WIDTH_Y 0.019108");
            lines.Add("#define EF_GOO_DEPTH_RIM_VIEW_SCALE 0.1");
            lines.Add("#define EF_GOO_DEPTH_RIM_MODEL_SCALE 10.0");
            lines.Add("#define EF_GOO_DEPTH_RIM_DELTA_SCALE 0.8");
            lines.Add("#define EF_GOO_DEPTH_RIM_MAX 4.0");
            lines.Add("#define EF_GOO_RIM_FRESNEL_POWER 4.0");
            lines.Add("#define EF_GOO_RIM_DIRECTIONAL_ATTENUATION 0.961783409");
            lines.Add("#define EF_GOO_RIM_LIMITATION_STRENGTH 0.35");
            lines.Add("#define EF_GOO_RIM_COLOR float3(1.0, 1.0, 1.0)");
            lines.Add("#define EF_GOO_RIM_COLOR_STRENGTH 2.0");
            lines.Add($"#define EF_HAIR_HIGHLIGHT_INTENSITY {F(p.HighlightStrength)}");
            lines.Add($"#define EF_HAIR_SPEC_OFF {Bool(!p.UseHighlight)}");
        }
        if (profile.Domain == ShaderDomain.Cloth)
        {
            lines.Add($"#define EF_CLOTH_MATCAP_ENABLED {(p.UseMatcap05 || p.UseMatcap07 ? 1 : 0)}");
            lines.Add($"#define EF_CLOTH_MATCAP_MANUAL_LOD_ENABLED {(p.UseManualMatcapLod ? 1 : 0)}");
            lines.Add($"#define EF_CLOTH_FGD_LUT_ENABLED {(p.UseFgdLut ? 1 : 0)}");
            lines.Add($"#define EF_CLOTH_RAIN_ENABLED {(p.EnableRain ? 1 : 0)}");
            lines.Add($"#define EF_CLOTH_RAIN_AMOUNT {F(p.EnableRain ? p.RainMaximum : 0f)}");
            AddTexture(lines, "EF_CLOTH_MATCAP_TEXTURE_RESOURCE", textures, "matcap05");
            AddTexture(lines, "EF_CLOTH_MATCAP_MANUAL_TEXTURE_RESOURCE", textures, "matcap07");
        }
        if (profile.Domain == ShaderDomain.Iris)
        {
            lines.Add("#define EF_FACIAL_IRIS_ENABLED 1");
            lines.Add($"#define EF_EYE_IRIS_MATCAP05_ENABLED {(p.UseMatcap05 ? 1 : 0)}");
            lines.Add($"#define EF_EYE_IRIS_MATCAP07_ENABLED {(p.UseMatcap07 ? 1 : 0)}");
            AddTexture(lines, "EF_EYE_IRIS_MATCAP05_TEXTURE", textures, "matcap05");
            AddTexture(lines, "EF_EYE_IRIS_MATCAP07_TEXTURE", textures, "matcap07");
        }
        if (profile.Domain == ShaderDomain.EyeWhite)
            lines.Add("#define EF_FACIAL_EYE_WHITE_ENABLED 1");
        if (profile.Domain is ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay)
            lines.Add("#define EF_FACIAL_OVERLAY_ENABLED 1");
        if (profile.Domain == ShaderDomain.EyeHighlight)
            AddTexture(lines, "EF_EYE_HL_TEXTURE_RESOURCE", textures, "base");
        if (profile.Domain == ShaderDomain.Face)
        {
            lines.Add($"#define EF_FACE_SDF_ENABLED {(p.UseSdf ? 1 : 0)}");
            AddTexture(lines, "EF_FACE_SHADOW_RECEIVER_ST_TEXTURE_RESOURCE", textures, "color_mask");
        }
        if (profile.Domain == ShaderDomain.Skin)
        {
            lines.Add($"#define EF_SKIN_SPECULAR_ENABLED {(p.SpecularStrength > 0f ? 1 : 0)}");
            lines.Add($"#define EF_SKIN_SPECULAR_STRENGTH {F(p.SpecularStrength)}");
        }
    }

    private static byte[] BuildWrapper(EndfieldProject project, MaterialProfile profile, string includeName)
    {
        var lines = new List<string>();
        var usesFacialHeadBone = profile.Domain is ShaderDomain.Iris or ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay;
        var usesCp932 = profile.Domain == ShaderDomain.Face || usesFacialHeadBone || profile.Domain == ShaderDomain.EyeHighlight;
        if (profile.Domain == ShaderDomain.Face)
        {
            lines.Add("// Face wrapper is encoded as CP932 for MME bone name matching.");
            lines.Add($"float4x4 EfFaceHeadBone : CONTROLOBJECT < string name = \"(self)\"; string item = \"{project.HeadBone}\"; >;");
            lines.Add("float3 EfFaceMmdLightDirection : DIRECTION < string Object = \"Light\"; >;");
        }
        if (usesFacialHeadBone)
            lines.Add($"float4x4 EfFacialHeadBone : CONTROLOBJECT < string name = \"(self)\"; string item = \"{project.HeadBone}\"; >;");
        if (profile.Domain == ShaderDomain.EyeHighlight)
            lines.Add($"float4x4 EfEyeHlHeadBone : CONTROLOBJECT < string name = \"(self)\"; string item = \"{project.HeadBone}\"; >;");
        lines.Add(profile.Domain == ShaderDomain.Face
            ? "// Generated Endfield Face FX."
            : $"// Generated Endfield FX for {profile.MaterialName}");
        lines.Add($"#include \"includes/{includeName}\"");
        if (profile.Domain == ShaderDomain.EyeWhite)
            lines.Add("#include \"../../internal/endfield_eye_white.hlsl\"");
        var shaderInclude = profile.Domain switch
        {
            ShaderDomain.Face => "endfield_face.hlsl",
            ShaderDomain.Skin => "endfield_skin.hlsl",
            ShaderDomain.Cloth => "endfield_cloth.hlsl",
            ShaderDomain.Iris or ShaderDomain.EyeWhite => "endfield_facial.hlsl",
            ShaderDomain.EyeHighlight => "endfield_eye_highlight.hlsl",
            ShaderDomain.BrowLash or ShaderDomain.Mouth or ShaderDomain.EyeOverlay or ShaderDomain.BrowOverlay => "endfield_facial.hlsl",
            _ => "endfield_shader.hlsl"
        };
        lines.Add($"#include \"../../internal/{shaderInclude}\"");
        var text = string.Join(Environment.NewLine, lines) + Environment.NewLine;
        return usesCp932 ? EncodeMmdText(text) : new UTF8Encoding(false).GetBytes(text);
    }

    private static string BuildEyeThroughCapture(EndfieldProject project)
    {
        var byDomain = project.Profiles
            .SelectMany(profile => ProjectService.GetBindings(profile)
                .Select(binding => (profile.Domain, binding.MaterialIndex)))
            .GroupBy(x => x.Domain)
            .ToDictionary(x => x.Key, x => string.Join(",", x.Select(v => v.MaterialIndex).Distinct().OrderBy(v => v)));

        static string Subsets(IReadOnlyDictionary<ShaderDomain, string> map, params ShaderDomain[] domains)
        {
            var values = domains.Where(map.ContainsKey)
                .SelectMany(domain => map[domain].Split(',', StringSplitOptions.RemoveEmptyEntries));
            var result = string.Join(",", values.Distinct()
                .OrderBy(value => int.TryParse(value, out var index) ? index : int.MaxValue));
            return string.IsNullOrWhiteSpace(result) ? "2147483647" : result;
        }

        var lines = new List<string>
        {
            "// Generated generic Endfield EyeThrough capture.",
            "// Material subsets are derived from the current PMX/domain bindings.",
            $"#define EF_EYE_CAPTURE_HEAD_BONE {Quote(project.HeadBone)}",
            $"#define EF_EYE_CAPTURE_EYE_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.Iris))}",
            $"#define EF_EYE_CAPTURE_HIGHLIGHT_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.EyeHighlight))}",
            $"#define EF_EYE_CAPTURE_SCLERA_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.EyeWhite))}",
            $"#define EF_EYE_CAPTURE_BROW_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.BrowLash))}",
            $"#define EF_EYE_CAPTURE_IGNORED_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.FaceParts, ShaderDomain.Mouth))}",
            $"#define EF_EYE_CAPTURE_HAIR_DEPTH_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.Hair, ShaderDomain.HairShadow))}",
            $"#define EF_EYE_CAPTURE_SHIFTED_SUBSETS {Quote(Subsets(byDomain, ShaderDomain.EyeOverlay, ShaderDomain.BrowOverlay))}"
        };

        var iris = project.Profiles.FirstOrDefault(x => x.Domain == ShaderDomain.Iris);
        var irisResource = iris?.Textures.Base.PackagePath;
        if (!string.IsNullOrWhiteSpace(irisResource) && iris is not null && !iris.UsePmxBaseTexture)
            lines.Add($"#define EF_EYE_CAPTURE_IRIS_TEXTURE_RESOURCE {Quote(irisResource)}");

        lines.Add(string.Empty);
        lines.Add("#include \"internal/endfield_eye_through_capture_core.fxsub\"");
        return string.Join(Environment.NewLine, lines) + Environment.NewLine;
    }

    private static string Quote(string value)
        => $"\"{value.Replace("\\", "\\\\").Replace("\"", "\\\"")}\"";

    private static string BuildReadme(EndfieldProject project)
    {
        var backend = ShadowBackendSupport.DetectRequired(project.TemplateRoot);
        var backendName = ShadowBackendSupport.DisplayName(backend);
        var controlFile = ShadowBackendSupport.ControlFile(backend);
        var mappingPages = "两个 ZMDshadow 映射页";
        var sb = new StringBuilder();
        sb.AppendLine($"# {project.RoleName} Endfield MME");
        sb.AppendLine();
        sb.AppendLine($"由 Endfield Shader Tool 生成。请先加载同目录的 controller/Endfield_controller.pmx 和 {controlFile}，再在 MME Main 页分配下表 FX。");
        sb.AppendLine();
        sb.AppendLine($"| 材质序号 | 材质名称 | 类型 | FX | {backendName} |");
        sb.AppendLine("|---:|---|---|---|---|");
        foreach (var profile in project.Profiles)
        {
            var fx = $"presets/{project.RoleSlug}/{project.RoleSlug}_{ProjectService.Slugify(profile.ProfileName)}.fx";
            var shadow = profile.CastExcellentShadow ? "参与" : "排除";
            foreach (var binding in ProjectService.GetBindings(profile).OrderBy(x => x.MaterialIndex))
                sb.AppendLine($"| {binding.MaterialIndex} | {EscapeMarkdown(binding.MaterialName)} | {profile.Domain} | `{fx}` | {shadow} |");
        }
        sb.AppendLine();
        sb.AppendLine("## 贴图对应关系");
        foreach (var profile in project.Profiles)
        {
            sb.AppendLine();
            var bindings = ProjectService.GetBindings(profile).OrderBy(x => x.MaterialIndex).ToArray();
            var bindingText = string.Join("、", bindings.Select(x => $"#{x.MaterialIndex} {x.MaterialName}"));
            sb.AppendLine($"### 材质球 {profile.ProfileName}（{bindings.Length} 个 PMX 材质）");
            sb.AppendLine();
            sb.AppendLine($"- 绑定材质：{bindingText}");
            sb.AppendLine($"- PMX 基础贴图：{string.Join(" / ", bindings.Select(x => $"`{x.PmxTexturePath ?? "(无)"}`"))}；生成时基础色：{(profile.UsePmxBaseTexture ? "各材质自己的 MATERIALTEXTURE" : "共享 External Base")}");
            sb.AppendLine($"- PMX Sphere Map：{string.Join(" / ", bindings.Select(x => $"`{x.PmxSphereTexturePath ?? "(无)"}`"))}；Sphere 模式：{(profile.UsePmxSphereMap ? "启用" : "关闭")}");
            sb.AppendLine($"- Base / Normal / Material / ID：{TexturePath(profile.Textures.Base)} / {TexturePath(profile.Textures.Normal)} / {TexturePath(profile.Textures.Material)} / {TexturePath(profile.Textures.Id)}");
            sb.AppendLine($"- Ramp / Matcap / Manual Atlas：{TexturePath(profile.Textures.Ramp)} / {TexturePath(profile.Textures.Matcap)} / {TexturePath(profile.Textures.ManualMatcap)}");
            sb.AppendLine($"- Highlight / SDF / Light Curve：{TexturePath(profile.Textures.Highlight)} / {TexturePath(profile.Textures.Sdf)} / {TexturePath(profile.Textures.LightCurve)}");
            sb.AppendLine($"- Alpha Clip：{(profile.Parameters.UseAlphaClip ? $"启用，Cutoff={F(profile.Parameters.AlphaCutoff)}" : "关闭")}；Blend={profile.Parameters.BlendMode}；Cull={profile.Parameters.CullMode}");
            if (profile.Domain == ShaderDomain.Hair)
            {
                var highlightMode = profile.Parameters.UseHighlight
                    ? "Unity Highlight 已启用（UV1）"
                    : profile.AdditionalUvCount >= 1
                        ? "UV1 通道存在，但未选择 Highlight 贴图"
                        : "PMX 无 UV1 通道，Unity Highlight 已关闭并回退 UV0";
                var uvArea = profile.HasUsableUv1 ? "非退化" : "面积检查为零（仅提示）";
                sb.AppendLine($"- Hair UV：UV{profile.Parameters.HairUvSet}；PMX 追加 UV 数量：{profile.AdditionalUvCount}；UV1 XY：{uvArea}；{highlightMode}；高光风格：{profile.Parameters.HairSpecularStyle}");
            }
        }
        sb.AppendLine();
        sb.AppendLine("## 注意事项");
        sb.AppendLine();
        sb.AppendLine($"- 本包使用 {backendName} 作为自阴影后端，不要同时加载其他自阴影后端。");
        sb.AppendLine("- Face 默认不接收几何自阴影，只使用 SDF。");
        sb.AppendLine($"- HairShadow、眉毛、眼睛和口腔小部件通常应在{mappingPages}排除。");
        sb.AppendLine($"- `Bright/Dark` 调整合成后的二分与几何阴影颜色；`SelfShadow+/-` 单独调整 {backendName} 接收强度。");
        sb.AppendLine("- `Exposure+/-` 以 stops 调整全部 Endfield 材质曝光，不影响场景和后处理。");
        sb.AppendLine($"- `Highlight+/-` 独立控制 Hair Highlight；二分 Ramp、Face SDF 和 {backendName} 均使用 MMD 世界光方向。");
        sb.AppendLine("- `SkinNormal` 从 0 到 1 混合皮肤法线，默认 0（关闭）；`Normal+/-` 仍控制启用后的法线强度。");
        sb.AppendLine("- `RampShadow+/-` 与 `RampLight+/-` 只调整 Body/Prop 的暗部和亮部比例。");
        sb.AppendLine("- `MatcapAtlas+/-` 每 0.2 移动一个手动 Matcap Atlas LOD；`+` 更模糊，`-` 更锐利。");
        sb.AppendLine("- Face 固定为 SDF-only；`FaceShadow+/-` 只调整 SDF 阈值，不接收几何自阴影。");
        sb.AppendLine("- 所有 Shader 资源路径都是相对路径，可以整体移动本目录。");
        if (project.GenerateEmm)
            sb.AppendLine($"- `{project.RoleSlug}_自动映射.emm` 为方便直接加载而使用绝对路径；移动模型或角色包后请在 GUI 中重新生成 EMM。");
        return sb.ToString();
    }

    private static string TexturePath(TextureReference reference)
        => string.IsNullOrWhiteSpace(reference.PackagePath) ? "`(未使用)`" : $"`{reference.PackagePath}`";

    private static string EscapeMarkdown(string value) => value.Replace("|", "\\|");

    private static void AddTexture(ICollection<string> lines, string macro, IReadOnlyDictionary<string, string> textures, string key)
    {
        if (textures.TryGetValue(key, out var path)) lines.Add($"#define {macro} \"../../{path}\"");
    }

    private static string ComputeHash(string path)
    {
        using var sha = SHA256.Create();
        using var stream = File.OpenRead(path);
        return Convert.ToHexString(sha.ComputeHash(stream));
    }

    private static string ComputeHash(byte[] bytes) => Convert.ToHexString(SHA256.HashData(bytes));

    private static string? ResolveTextureSource(EndfieldProject project, TextureReference reference)
    {
        if (!string.IsNullOrWhiteSpace(reference.SourcePath) && File.Exists(reference.SourcePath))
            return reference.SourcePath;
        if (string.IsNullOrWhiteSpace(reference.PackagePath)) return null;
        var relative = reference.PackagePath.Replace('/', Path.DirectorySeparatorChar);
        var source = Path.GetFullPath(Path.Combine(project.TemplateRoot, relative));
        return File.Exists(source) ? source : null;
    }

    private static void MakeTextureReferencesPortable(EndfieldProject project)
    {
        foreach (var profile in project.Profiles)
        {
            foreach (var reference in GetTextureReferences(profile.Textures)) reference.SourcePath = null;
        }
    }

    private static IEnumerable<TextureReference> GetTextureReferences(TextureSlots slots)
    {
        yield return slots.Base;
        yield return slots.Normal;
        yield return slots.Property;
        yield return slots.Rd;
        yield return slots.Rs;
        yield return slots.Lut;
        yield return slots.Sdf;
        yield return slots.St;
        yield return slots.ColorMask;
        yield return slots.HairLine;
        yield return slots.Matcap05;
        yield return slots.Matcap07;
    }

    private static void CommitStaging(string staging, string output)
    {
        string? backup = null;
        if (Directory.Exists(output))
        {
            backup = output + ".endfieldbackup_" + Guid.NewGuid().ToString("N");
            if (!TryMoveDirectoryWithRetry(output, backup, out var backupError))
            {
                throw CreateCommitException(
                    "无法为已有角色包创建备份，因此没有覆盖原目录。",
                    staging,
                    output,
                    backup,
                    backupError);
            }
        }

        if (TryMoveDirectoryWithRetry(staging, output, out var moveError))
        {
            if (backup is not null) TryDeleteDirectoryWithRetry(backup);
            return;
        }

        try
        {
            // Sync clients and antivirus software can hold a directory handle that
            // blocks renaming while still allowing its files to be read. Copying is
            // slower, but gives users in those folders a reliable fallback.
            CopyDirectoryWithRetry(staging, output);
        }
        catch (Exception copyError)
        {
            var partialOutputRemoved = TryDeleteDirectoryWithRetry(output);
            var restored = backup is null;
            Exception? restoreError = null;
            if (backup is not null)
                restored = TryRestoreBackup(backup, output, out restoreError);

            var errors = new List<Exception>();
            if (moveError is not null) errors.Add(moveError);
            errors.Add(copyError);
            if (restoreError is not null) errors.Add(restoreError);
            var inner = errors.Count == 1 ? errors[0] : new AggregateException(errors);
            var recovery = backup is null
                ? "本次没有覆盖已有角色包。"
                : restored
                    ? "原有角色包已自动恢复。"
                    : $"原有角色包未能自动恢复，备份仍保留在：{backup}";
            if (!partialOutputRemoved && Directory.Exists(output))
                recovery += $" 部分输出可能仍保留在：{output}";

            throw CreateCommitException(
                $"目录重命名和逐文件复制都失败。{recovery}",
                staging,
                output,
                backup,
                inner);
        }

        if (backup is not null) TryDeleteDirectoryWithRetry(backup);
    }

    private static void TryDeleteDirectory(string path)
    {
        try { TryDeleteDirectoryWithRetry(path); } catch { }
    }

    private static bool TryDeleteDirectoryWithRetry(string path)
    {
        if (!Directory.Exists(path)) return true;
        for (var attempt = 0; attempt < 5; attempt++)
        {
            try
            {
                Directory.Delete(path, true);
                return true;
            }
            catch (Exception ex) when (IsRetryableFileSystemException(ex))
            {
                if (attempt < 4) Thread.Sleep(120 * (attempt + 1));
            }
        }
        return !Directory.Exists(path);
    }

    private static bool TryMoveDirectoryWithRetry(string source, string destination, out Exception? last)
    {
        last = null;
        for (var attempt = 0; attempt < 5; attempt++)
        {
            try
            {
                Directory.Move(source, destination);
                return true;
            }
            catch (Exception ex) when (IsRetryableFileSystemException(ex))
            {
                last = ex;
                if (attempt < 4) Thread.Sleep(150 * (attempt + 1));
            }
        }
        return false;
    }

    private static void CopyDirectoryWithRetry(string source, string destination)
    {
        if (!Directory.Exists(source))
            throw new DirectoryNotFoundException($"角色包临时目录不存在：{source}");
        if (Directory.Exists(destination))
            throw new IOException($"复制兜底的目标目录已存在：{destination}");

        RunFileSystemWithRetry(
            () => Directory.CreateDirectory(destination),
            $"无法创建输出目录：{destination}");
        var directories = RunFileSystemWithRetry(
            () => Directory.GetDirectories(source, "*", SearchOption.AllDirectories),
            $"无法读取角色包临时目录：{source}");
        foreach (var directory in directories)
        {
            var relative = Path.GetRelativePath(source, directory);
            var target = Path.Combine(destination, relative);
            RunFileSystemWithRetry(
                () => Directory.CreateDirectory(target),
                $"无法创建输出子目录：{target}");
        }

        var files = RunFileSystemWithRetry(
            () => Directory.GetFiles(source, "*", SearchOption.AllDirectories),
            $"无法枚举角色包临时文件：{source}");
        foreach (var file in files)
        {
            var relative = Path.GetRelativePath(source, file);
            var target = Path.Combine(destination, relative);
            RunFileSystemWithRetry(
                () => File.Copy(file, target, true),
                $"无法复制角色包文件：{file}\n目标：{target}");
        }
    }

    private static bool TryRestoreBackup(string backup, string output, out Exception? error)
    {
        error = null;
        if (!Directory.Exists(backup))
        {
            error = new DirectoryNotFoundException($"角色包备份目录不存在：{backup}");
            return false;
        }
        if (Directory.Exists(output) && !TryDeleteDirectoryWithRetry(output))
        {
            error = new IOException($"无法清理部分输出，不能安全恢复备份：{output}");
            return false;
        }
        if (TryMoveDirectoryWithRetry(backup, output, out var moveError)) return true;

        try
        {
            CopyDirectoryWithRetry(backup, output);
            TryDeleteDirectoryWithRetry(backup);
            return true;
        }
        catch (Exception copyError)
        {
            error = moveError is null
                ? copyError
                : new AggregateException(moveError, copyError);
            return false;
        }
    }

    private static T RunFileSystemWithRetry<T>(Func<T> operation, string failureMessage)
    {
        Exception? last = null;
        for (var attempt = 0; attempt < 5; attempt++)
        {
            try
            {
                return operation();
            }
            catch (Exception ex) when (IsRetryableFileSystemException(ex))
            {
                last = ex;
                if (attempt < 4) Thread.Sleep(120 * (attempt + 1));
            }
        }
        throw new IOException(failureMessage, last);
    }

    private static void RunFileSystemWithRetry(Action operation, string failureMessage)
    {
        RunFileSystemWithRetry(
            () =>
            {
                operation();
                return true;
            },
            failureMessage);
    }

    private static IOException CreateCommitException(
        string reason,
        string staging,
        string output,
        string? backup,
        Exception? inner)
    {
        var message = new StringBuilder()
            .AppendLine("角色包无法安全写入或提交到输出目录。")
            .AppendLine(reason)
            .AppendLine($"临时目录：{staging}")
            .AppendLine($"输出目录：{output}");
        if (!string.IsNullOrWhiteSpace(backup) && Directory.Exists(backup))
            message.AppendLine($"备份目录：{backup}");
        message.Append("请关闭正在读取该目录的 MMD、资源管理器预览、百度网盘/OneDrive 和杀毒软件，或改用本地普通目录后重试。");
        return new IOException(message.ToString(), inner);
    }

    private static bool IsRetryableFileSystemException(Exception ex) =>
        ex is IOException or UnauthorizedAccessException;

    private static string F(float value) => value.ToString("0.######", CultureInfo.InvariantCulture);
    private static string Bool(bool value) => value ? "1" : "0";
    private static int DomainValue(ShaderDomain domain) => domain switch
    {
        ShaderDomain.Hair => 1,
        ShaderDomain.Face => 2,
        ShaderDomain.Eye => 3,
        ShaderDomain.FaceParts or ShaderDomain.HairShadow or ShaderDomain.Overlay => 4,
        ShaderDomain.Emissive => 5,
        ShaderDomain.Transparent => 0,
        _ => 0
    };
    private static string CullValue(CullMode mode) => mode switch
    {
        CullMode.Ccw => "CCW",
        CullMode.Cw => "CW",
        _ => "NONE"
    };
    private static string Color3(ColorValue c) => $"float3({F(c.R)}, {F(c.G)}, {F(c.B)})";
    private static string Color4(ColorValue c) => $"float4({F(c.R)}, {F(c.G)}, {F(c.B)}, {F(c.A)})";
    private static byte[] EncodeCp932(string text)
    {
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        return Encoding.GetEncoding(932, EncoderFallback.ExceptionFallback, DecoderFallback.ExceptionFallback).GetBytes(text);
    }

    private static byte[] EncodeMmdText(string text)
    {
        try { return EncodeCp932(text); }
        catch (EncoderFallbackException) { return new UTF8Encoding(false).GetBytes(text); }
    }
}


