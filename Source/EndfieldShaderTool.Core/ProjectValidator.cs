using System.Text.RegularExpressions;

namespace EndfieldShaderTool.Core;

public static class ProjectValidator
{
    public static ValidationResult Validate(EndfieldProject project)
    {
        ProjectService.NormalizeMaterialBindings(project);
        var result = new ValidationResult();
        if (project.SchemaVersion is < 1 or > 2) result.Error("SCHEMA_VERSION", $"不支持工程格式版本 {project.SchemaVersion}。");
        if (string.IsNullOrWhiteSpace(project.RoleName)) result.Error("ROLE_NAME", "角色名称不能为空。");
        if (string.IsNullOrWhiteSpace(project.RoleSlug) || project.RoleSlug != ProjectService.Slugify(project.RoleSlug))
            result.Error("ROLE_SLUG", "角色 slug 必须只包含 ASCII 小写字母、数字和下划线。");
        if (!Directory.Exists(project.TemplateRoot)) result.Error("TEMPLATE_ROOT", "Endfield 模板目录不存在。");
        foreach (var required in ShadowBackendSupport.CommonTemplateFiles)
        {
            var path = Path.Combine(project.TemplateRoot, required.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(path) && !Directory.Exists(path)) result.Error("TEMPLATE_RESOURCE", $"模板缺少必要资源：{required}");
        }
        var backend = ShadowBackendSupport.TryDetect(project.TemplateRoot);
        if (backend is null)
        {
            result.Error("SHADOW_BACKEND", "模板缺少 Endfield 的 ZMDshadow.x 阴影后端。");
        }
        else
        {
            foreach (var required in ShadowBackendSupport.RequiredFiles(backend.Value))
            {
                var path = Path.Combine(project.TemplateRoot, required.Replace('/', Path.DirectorySeparatorChar));
                if (!File.Exists(path)) result.Error("TEMPLATE_RESOURCE", $"{ShadowBackendSupport.DisplayName(backend.Value)} 模板缺少必要资源：{required}");
            }
        }
        if (project.Model is null) result.Error("MODEL", "尚未导入 PMX 模型。");
        if (project.Profiles.Count == 0) result.Error("PROFILES", "没有可生成的材质预设。");
        if (project.IncludeEyeThrough)
        {
            if (!project.Profiles.Any(profile => profile.Domain == ShaderDomain.Iris && profile.Parameters.EnableEyeThrough))
                result.Error("EYE_THROUGH_IRIS", "工程开启了眼透，但没有已确认并启用的 Iris（眼睛）材质。");
            if (!project.Profiles.Any(profile => profile.Domain == ShaderDomain.BrowLash && profile.Parameters.EnableEyeThrough))
                result.Error("EYE_THROUGH_BROW", "工程开启了眼透，但没有已确认并启用的 BrowLash（眉毛/睫毛）材质。");
            if (!project.Profiles.Any(profile => profile.Domain == ShaderDomain.EyeOverlay))
                result.Error("EYE_THROUGH_EYE_OVERLAY", "工程开启了眼透，但派生 PMX 缺少 EyeOverlay 覆盖材质。请使用 GUI 重新生成眼透派生 PMX。");
            if (!project.Profiles.Any(profile => profile.Domain == ShaderDomain.BrowOverlay))
                result.Error("EYE_THROUGH_BROW_OVERLAY", "工程开启了眼透，但派生 PMX 缺少 BrowOverlay 覆盖材质。请使用 GUI 重新生成眼透派生 PMX。");
            var eyeThroughFiles = new[]
            {
                "EndfieldEyeThrough.x",
                "EndfieldEyeThrough.fx",
                "EndfieldEyeThrough_Mask.fxsub",
                "EndfieldEyeThrough_Capture.fxsub"
            };
            foreach (var required in eyeThroughFiles)
            {
                if (!File.Exists(Path.Combine(project.TemplateRoot, required)))
                    result.Error("EYE_THROUGH_RESOURCE", $"工程开启 EyeThrough，但模板缺少通用捕获资源：{required}。请先为当前模型生成/配置它。");
            }
        }
        if (project.IncludePostProcessing)
        {
            foreach (var required in new[]
                     {
                         "EndfieldPost.x",
                         "EndfieldPost.fx",
                         "internal/endfield_post.fxsub",
                         "internal/endfield_post_controls.inc"
                     })
            {
                if (!File.Exists(Path.Combine(project.TemplateRoot, required.Replace('/', Path.DirectorySeparatorChar))))
                    result.Error("POST_RESOURCE", $"工程开启了后处理，但模板缺少 {required}。");
            }
        }
        if (project.Model is not null && !string.IsNullOrWhiteSpace(project.HeadBone) && !project.Model.BoneNames.Contains(project.HeadBone))
            result.Warning("HEAD_BONE", $"找不到头骨 {project.HeadBone}，Face FX 仍会写入该名称，请确认模型骨骼名称。");

        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var boundMaterials = new Dictionary<int, string>();
        foreach (var profile in project.Profiles)
        {
            ValidateProfile(project, profile, result);
            if (!names.Add(ProjectService.Slugify(profile.ProfileName))) result.Error("DUPLICATE_PROFILE", $"重复的预设名称：{profile.ProfileName}");
            foreach (var binding in ProjectService.GetBindings(profile))
            {
                if (boundMaterials.TryGetValue(binding.MaterialIndex, out var owner))
                    result.Error("DUPLICATE_BINDING", $"PMX 材质 #{binding.MaterialIndex} 同时绑定到 {owner} 和 {profile.ProfileName}。");
                else boundMaterials[binding.MaterialIndex] = profile.ProfileName;
            }
        }
        if (project.Model is not null)
        {
            foreach (var material in project.Model.Materials.Where(x => !boundMaterials.ContainsKey(x.Index)))
                result.Warning("UNBOUND_MATERIAL", $"PMX 材质 #{material.Index} {material.Name} 没有绑定材质球，EMM 不会为它指定 FX。");
        }
        return result;
    }

    private static void ValidateProfile(EndfieldProject project, MaterialProfile profile, ValidationResult result)
    {
        var bindings = ProjectService.GetBindings(profile);
        if (bindings.Count == 0) result.Error("MATERIAL_BINDING", $"材质球 {profile.ProfileName} 尚未绑定任何 PMX 材质。");
        foreach (var binding in bindings)
        {
            if (binding.MaterialIndex < 0) result.Error("MATERIAL_INDEX", "材质序号不能为负数。");
            if (project.Model is not null && project.Model.Materials.All(x => x.Index != binding.MaterialIndex))
                result.Error("MATERIAL_INDEX", $"材质球 {profile.ProfileName} 绑定了不存在的 PMX 材质 #{binding.MaterialIndex}。");
        }
        if (string.IsNullOrWhiteSpace(profile.ProfileName)) result.Error("PROFILE_NAME", $"材质 {profile.MaterialIndex} 缺少预设名称。");
        if (profile.Domain == ShaderDomain.Face && string.IsNullOrWhiteSpace(project.HeadBone)) result.Error("FACE_BONE", "Face 预设必须指定头骨名称。");

        var p = profile.Parameters;
        var t = profile.Textures;
        foreach (var (label, texture) in NamedTextureReferences(t))
        {
            if (!string.IsNullOrWhiteSpace(texture.PackagePath) && !IsSafePackageRelativePath(texture.PackagePath))
            {
                result.Error("TEXTURE_PACKAGE_PATH", $"{profile.ProfileName} 的 {label} 包内路径不安全：{texture.PackagePath}");
                continue;
            }
            if (!texture.IsSelected || TextureAvailable(project, texture)) continue;
            var path = texture.SourcePath ?? texture.PackagePath ?? "(empty)";
            result.Error("TEXTURE_SOURCE_MISSING", $"{profile.ProfileName} 的 {label} 已选择，但找不到贴图文件：{path}");
        }
        if (p.UseExternalBase && !profile.UsePmxBaseTexture && !TextureAvailable(project, t.Base))
            result.Error("BASE_TEXTURE", $"{profile.ProfileName} 启用了外部基础色，但没有选择 Base 贴图。");
        if (p.UseNormal && !TextureAvailable(project, t.Normal)) result.Error("NORMAL_TEXTURE", $"{profile.ProfileName} 启用了法线，但没有 Normal 贴图。");
        if (p.UseSdf && !TextureAvailable(project, t.Sdf)) result.Error("SDF_TEXTURE", $"{profile.ProfileName} 启用了 SDF，但没有 SDF 贴图。");
        if (profile.Domain == ShaderDomain.Iris && p.UseMatcap05 && !TextureAvailable(project, t.Matcap05))
            result.Error("MATCAP05_TEXTURE", $"{profile.ProfileName} 启用了 MATCAP05，但没有贴图。");
        if (profile.Domain == ShaderDomain.Iris && p.UseMatcap07 && !TextureAvailable(project, t.Matcap07))
            result.Error("MATCAP07_TEXTURE", $"{profile.ProfileName} 启用了 MATCAP07，但没有贴图。");
        if (profile.Domain == ShaderDomain.Cloth)
        {
            ValidateTemplateFeatureResource(
                project,
                profile,
                "Cloth environment",
                "textures/common/cloth_environment_current.dds",
                "CLOTH_ENV_RESOURCE",
                result);
            if (p.UseMatcap && !TextureAvailable(project, t.Matcap05))
                result.Error("CLOTH_MATCAP_TEXTURE", $"{profile.ProfileName} 启用了 MATCAP，但没有 MATCAP 05 贴图。");
            if (p.UseManualMatcapLod && !TextureAvailable(project, t.Matcap07))
                result.Error("CLOTH_MATCAP_LOD_TEXTURE", $"{profile.ProfileName} 启用了手动 MATCAP LOD，但没有 MATCAP 07 Atlas。");
            if (p.UseFgdLut)
                ValidateTemplateFeatureResource(
                    project,
                    profile,
                    "FGD LUT",
                    "textures/common/PreIntegratedFGD_GGXDisneyDiffuse.png",
                    "CLOTH_FGD_RESOURCE",
                    result);
            if (p.EnableRain)
            {
                foreach (var relative in new[]
                         {
                             "textures/common/rain/T_actor_common_rain_02_M.png",
                             "textures/common/rain/rain_drops.png",
                             "textures/common/rain/rain_drops_phase.png"
                         })
                    ValidateTemplateFeatureResource(project, profile, "Rain", relative, "CLOTH_RAIN_RESOURCE", result);
            }
        }
        if (profile.Domain == ShaderDomain.Hair && p.HairUvSet == 1 && profile.AdditionalUvCount < 1)
            result.Error("UV1", $"{profile.ProfileName} 选择了 UV1，但 PMX 没有声明追加 UV1 通道。");
        if (profile.Domain == ShaderDomain.Hair && p.UseHighlight && p.HairUvSet != 1)
            result.Error("HAIR_HIGHLIGHT_UV", $"{profile.ProfileName} 的 Unity Highlight 必须使用追加 UV1。");
        if (profile.Domain == ShaderDomain.Hair && p.UseAlphaClip)
            result.Warning(
                "HAIR_ALPHA_SEMANTIC",
                $"{profile.ProfileName} 开启了透明裁切。终末地 Hair D.A 通常是材质/光照数据；仅在当前 Base Alpha 确实是发片覆盖遮罩时开启。");
        if (p.AlphaCutoff is < 0 or > 1) result.Error("ALPHA_CUTOFF", $"{profile.ProfileName} 的 Alpha Cutoff 必须在 0..1。");
        if (EstimateSamplers(p) > 16) result.Error("SAMPLER_LIMIT", $"{profile.ProfileName} 预计使用 {EstimateSamplers(p)} 个采样器，超过 D3D9 的 16 个上限。");
        ValidateEndfieldSlots(profile, result);
        if (profile.Domain == ShaderDomain.Hair && profile.AdditionalUvCount < 1 && t.St.IsSelected)
            result.Warning("HAIR_HIGHLIGHT_NO_UV1", $"{profile.ProfileName} 选择了 Hair ST，但 PMX 没有追加 UV1；生成时会回退到 UV0。");
        if (profile.Domain == ShaderDomain.Hair && profile.AdditionalUvCount >= 1 && !profile.HasUsableUv1 && t.St.IsSelected)
            result.Warning("HAIR_HIGHLIGHT_DEGENERATE_UV1", $"{profile.ProfileName} 的 UV1 坐标面积检查为零；请在 MMD 中确认追加 UV 转换结果。");
        foreach (var binding in bindings.Where(x => profile.UsePmxBaseTexture && string.IsNullOrWhiteSpace(x.PmxTexturePath)))
            result.Warning("PMX_BASE_MISSING", $"{profile.ProfileName} 选择了 PMX 基础色，但 PMX 材质 #{binding.MaterialIndex} {binding.MaterialName} 没有基础贴图。");
        if (p.NormalYSign is not (-1f or 1f))
            result.Warning("NORMAL_Y_SIGN", $"{profile.ProfileName} 的 Normal Y Sign 通常应为 +1 或 -1。");
        foreach (var texture in TextureReferences(t))
        {
            var path = !string.IsNullOrWhiteSpace(texture.SourcePath) ? texture.SourcePath : texture.PackagePath;
            if (path is not null && (path.EndsWith(".tga", StringComparison.OrdinalIgnoreCase) || path.EndsWith(".dds", StringComparison.OrdinalIgnoreCase)))
                result.Warning("TEXTURE_PREVIEW", $"{profile.ProfileName} 使用 {Path.GetExtension(path)} 贴图，可生成但 GUI 不提供缩略图。");
        }
    }

    private static void ValidateEndfieldSlots(MaterialProfile profile, ValidationResult result)
    {
        var t = profile.Textures;
        var p = profile.Parameters;
        if (profile.Domain == ShaderDomain.Face)
        {
            if (p.UseSdf && !TextureAvailableForValidation(t.Sdf)) result.Error("FACE_SDF_TEXTURE", $"{profile.ProfileName} 开启了 Face SDF，但没有选择模型自己的 SDF 贴图。");
            if (!t.Rd.IsSelected || !t.Lut.IsSelected) result.Warning("FACE_MODEL_MAPS", $"{profile.ProfileName} 未选择完整 Face RD/LUT；不会自动使用 Chen Qianyu 资源。");
        }
        if (profile.Domain == ShaderDomain.Skin && (!t.Rd.IsSelected || !t.Lut.IsSelected))
            result.Warning("SKIN_MODEL_MAPS", $"{profile.ProfileName} 未选择 Skin RD/LUT；请从当前模型 other tex 中匹配，避免颜色链缺图。");
        if (profile.Domain == ShaderDomain.Cloth)
        {
            foreach (var (label, reference) in new[] { ("Normal", t.Normal), ("Property/MRO", t.Property), ("RD", t.Rd), ("RS", t.Rs) })
                if (!reference.IsSelected) result.Warning("CLOTH_MODEL_MAP", $"{profile.ProfileName} 缺少 Cloth {label}，对应层会使用中性/关闭策略。");
        }
        if (profile.Domain == ShaderDomain.Iris)
        {
            if (p.UseMatcap05 && !t.Matcap05.IsSelected) result.Warning("MATCAP05_MISSING", $"{profile.ProfileName} 开启了 MATCAP05，但当前模型没有提供贴图。");
            if (p.UseMatcap07 && !t.Matcap07.IsSelected) result.Warning("MATCAP07_MISSING", $"{profile.ProfileName} 开启了 MATCAP07，但当前模型没有提供贴图。");
        }
        if (p.EnableRain && profile.Domain != ShaderDomain.Cloth)
            result.Warning("RAIN_DOMAIN", $"{profile.ProfileName} 不是 Cloth，Rain 参数不会产生衣物湿润效果。");
        if (p.UseFgdLut && profile.Domain != ShaderDomain.Cloth)
            result.Warning("FGD_DOMAIN", $"{profile.ProfileName} 不是 Cloth，FGD LUT 参数不会生效。");
        if (p.UseMatcap && profile.Domain != ShaderDomain.Cloth)
            result.Warning("MATCAP_DOMAIN", $"{profile.ProfileName} 不是 Cloth，当前 Endfield 材质入口不会启用衣服 MATCAP。");
    }

    private static void ValidateTemplateFeatureResource(
        EndfieldProject project,
        MaterialProfile profile,
        string feature,
        string relativePath,
        string code,
        ValidationResult result)
    {
        var path = Path.Combine(project.TemplateRoot, relativePath.Replace('/', Path.DirectorySeparatorChar));
        if (!File.Exists(path))
            result.Error(code, $"{profile.ProfileName} 启用了 {feature}，但模板缺少资源：{relativePath}");
    }

    private static bool TextureAvailableForValidation(TextureReference reference)
        => reference.IsSelected && (string.IsNullOrWhiteSpace(reference.SourcePath) || File.Exists(reference.SourcePath));

    public static int EstimateSamplers(ShaderParameters p)
    {
        var count = 2; // PMX diffuse and the selected shadow backend's processed map.
        if (p.UseExternalBase) count++;
        if (p.UseNormal) count++;
        if (p.UseRamp) count++;
        if (p.UseMaterial) count++;
        if (p.UseId) count++;
        if (p.UseMatcap) count++;
        if (p.UseMatcap && p.UseId && p.UseManualMatcapLod) count++;
        if (p.UseHighlight) count++;
        if (p.UseSdf) count++;
        if (p.UseLightCurve) count++;
        if (p.UsePmxSphere) count++;
        return count;
    }

    private static bool TextureAvailable(EndfieldProject project, TextureReference reference)
    {
        if (!string.IsNullOrWhiteSpace(reference.SourcePath) && File.Exists(reference.SourcePath)) return true;
        if (string.IsNullOrWhiteSpace(reference.PackagePath)) return false;
        var relative = reference.PackagePath.Replace('/', Path.DirectorySeparatorChar);
        return File.Exists(Path.Combine(project.TemplateRoot, relative));
    }

    private static IEnumerable<TextureReference> TextureReferences(TextureSlots slots)
        => NamedTextureReferences(slots).Select(item => item.Reference);

    private static IEnumerable<(string Label, TextureReference Reference)> NamedTextureReferences(TextureSlots slots)
    {
        yield return ("Base/Diffuse", slots.Base);
        yield return ("Normal", slots.Normal);
        yield return ("Property / MRO", slots.Property);
        yield return ("RD", slots.Rd);
        yield return ("RS", slots.Rs);
        yield return ("LUT", slots.Lut);
        yield return ("SDF", slots.Sdf);
        yield return ("ST / Highlight", slots.St);
        yield return ("Face ColorMask", slots.ColorMask);
        yield return ("Face Lip Specular", slots.LipSpecular);
        yield return ("HairLine", slots.HairLine);
        yield return ("MATCAP05", slots.Matcap05);
        yield return ("MATCAP07", slots.Matcap07);
    }

    public static ValidationResult ValidateGeneratedPackage(string outputDirectory)
    {
        var result = new ValidationResult();
        var files = Directory.Exists(outputDirectory)
            ? Directory.GetFiles(outputDirectory, "*", SearchOption.AllDirectories)
            : Array.Empty<string>();
        var shaderExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".fx", ".inc", ".fxh", ".fxsub", ".hlsl"
        };
        var effectDirectories = files
            .Where(x => x.EndsWith(".fx", StringComparison.OrdinalIgnoreCase))
            .Select(Path.GetDirectoryName)
            .Where(x => x is not null)
            .Cast<string>()
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
        foreach (var file in files.Where(x => shaderExtensions.Contains(Path.GetExtension(x))))
        {
            var content = File.ReadAllText(file, FileEncoding.ForShader(file));
            if (Regex.IsMatch(content, @"(?:[A-Za-z]:[\\/]|\\\\[^\\]+[\\/][^\\]+)", RegexOptions.IgnoreCase))
                result.Error("ABSOLUTE_PATH", $"Shader 包含绝对资源路径：{file}");
            foreach (Match match in Regex.Matches(content, @"#include\s+""([^""]+)"""))
            {
                var include = match.Groups[1].Value.Replace('/', Path.DirectorySeparatorChar);
                if (Path.IsPathFullyQualified(include) || Path.IsPathRooted(include))
                {
                    result.Error("ABSOLUTE_INCLUDE", $"Shader include 必须位于角色包内：{match.Groups[1].Value}");
                    continue;
                }
                var includeCandidates = effectDirectories
                    .Prepend(Path.GetDirectoryName(file)!)
                    .Select(directory => Path.GetFullPath(Path.Combine(directory, include)))
                    .Where(candidate => IsInside(outputDirectory, candidate))
                    .Append(Path.Combine(outputDirectory, Path.GetFileName(include)));
                if (!includeCandidates.Any(File.Exists))
                    result.Error("MISSING_INCLUDE", $"缺少 include：{match.Groups[1].Value}");
            }
            foreach (Match match in Regex.Matches(
                         content,
                         @"^\s*#define\s+EF_[A-Z0-9_]+(?:TEXTURE|TEXTURE_RESOURCE)\s+""([^""]+)""",
                         RegexOptions.Multiline))
            {
                var ownerDirectory = ShaderResourceBaseDirectory(outputDirectory, file);
                var reference = match.Groups[1].Value.Replace('/', Path.DirectorySeparatorChar);
                if (Path.IsPathFullyQualified(reference) || Path.IsPathRooted(reference))
                {
                    result.Error("ABSOLUTE_TEXTURE", $"贴图路径必须位于角色包内：{match.Groups[1].Value}");
                    continue;
                }
                var resourcePath = Path.GetFullPath(Path.Combine(ownerDirectory, reference));
                if (!IsInside(outputDirectory, resourcePath))
                {
                    result.Error("TEXTURE_PATH_ESCAPE", $"贴图路径超出角色包：{match.Groups[1].Value}");
                    continue;
                }
                if (!File.Exists(resourcePath)) result.Error("MISSING_TEXTURE", $"缺少贴图：{match.Groups[1].Value}");
            }
        }
        ValidatePresetIncludeClosures(outputDirectory, files, result);
        return result;
    }

    private static bool IsInside(string root, string candidate)
    {
        var fullRoot = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
            + Path.DirectorySeparatorChar;
        var fullCandidate = Path.GetFullPath(candidate);
        return fullCandidate.StartsWith(fullRoot, StringComparison.OrdinalIgnoreCase);
    }

    private static string ShaderResourceBaseDirectory(string outputDirectory, string shaderFile)
    {
        var packageRoot = Path.GetFullPath(outputDirectory);
        var fullFile = Path.GetFullPath(shaderFile);
        var presetsRoot = Path.Combine(packageRoot, "presets");
        if (IsInside(presetsRoot, fullFile))
        {
            var relative = Path.GetRelativePath(presetsRoot, fullFile);
            var roleDirectory = relative.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)[0];
            return Path.Combine(presetsRoot, roleDirectory);
        }
        if (IsInside(Path.Combine(packageRoot, "internal"), fullFile)) return packageRoot;
        return Path.GetDirectoryName(fullFile)!;
    }

    private static bool IsSafePackageRelativePath(string value)
    {
        try
        {
            var normalized = value.Replace('/', Path.DirectorySeparatorChar);
            if (Path.IsPathFullyQualified(normalized) || Path.IsPathRooted(normalized)) return false;
            var root = Path.GetFullPath(Path.Combine(Path.GetTempPath(), "endfield_package_path_root"));
            var candidate = Path.GetFullPath(Path.Combine(root, normalized));
            return IsInside(root, candidate);
        }
        catch (Exception exception) when (exception is ArgumentException or NotSupportedException or PathTooLongException)
        {
            return false;
        }
    }

    private static void ValidatePresetIncludeClosures(
        string outputDirectory,
        IReadOnlyCollection<string> files,
        ValidationResult result)
    {
        var packageRoot = Path.GetFullPath(outputDirectory);
        var presetsRoot = Path.GetFullPath(Path.Combine(packageRoot, "presets"));
        var presetsPrefix = presetsRoot.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
            + Path.DirectorySeparatorChar;
        var packagePrefix = packageRoot.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
            + Path.DirectorySeparatorChar;

        foreach (var entry in files.Where(file =>
                     file.EndsWith(".fx", StringComparison.OrdinalIgnoreCase)
                     && Path.GetFullPath(file).StartsWith(presetsPrefix, StringComparison.OrdinalIgnoreCase)))
        {
            var effectDirectory = Path.GetDirectoryName(entry)!;
            var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            Visit(entry);

            void Visit(string file)
            {
                var fullPath = Path.GetFullPath(file);
                if (!visited.Add(fullPath)) return;

                var content = File.ReadAllText(fullPath, FileEncoding.ForShader(fullPath));
                foreach (Match match in Regex.Matches(content, @"^\s*#include\s+""([^""]+)""", RegexOptions.Multiline))
                {
                    var include = match.Groups[1].Value.Replace('/', Path.DirectorySeparatorChar);
                    var target = Path.GetFullPath(Path.Combine(effectDirectory, include));
                    if (!target.StartsWith(packagePrefix, StringComparison.OrdinalIgnoreCase))
                    {
                        result.Error(
                            "PRESET_INCLUDE_ESCAPE",
                            $"生成材质的 include 超出角色包：{Path.GetRelativePath(packageRoot, entry)} -> {match.Groups[1].Value}");
                        continue;
                    }
                    if (!File.Exists(target))
                    {
                        result.Error(
                            "MISSING_PRESET_INCLUDE",
                            $"生成材质缺少 MME 可解析的 include：{Path.GetRelativePath(packageRoot, entry)} -> "
                            + $"{Path.GetRelativePath(packageRoot, fullPath)} -> {match.Groups[1].Value}");
                        continue;
                    }
                    Visit(target);
                }
            }
        }
    }
}

public static class FileEncoding
{
    public static System.Text.Encoding ForShader(string path)
    {
        var utf8 = new System.Text.UTF8Encoding(false, true);
        try
        {
            utf8.GetString(File.ReadAllBytes(path));
            return utf8;
        }
        catch (System.Text.DecoderFallbackException)
        {
            System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);
            return System.Text.Encoding.GetEncoding(932);
        }
    }
}


