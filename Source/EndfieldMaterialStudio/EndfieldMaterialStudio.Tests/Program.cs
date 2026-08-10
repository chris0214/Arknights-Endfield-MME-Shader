using System.Text;
using System.Text.Json;
using EndfieldMaterialStudio.Core;

Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

var root = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
var runtime = Environment.GetEnvironmentVariable("ENDFIELD_MME_RUNTIME") ?? Path.Combine(root, "EndfieldMME");
var pmx = Environment.GetEnvironmentVariable("ENDFIELD_TEST_PMX");
if (string.IsNullOrWhiteSpace(pmx))
{
    Console.WriteLine("INTEGRATION_TEST_SKIPPED: set ENDFIELD_TEST_PMX to a locally licensed Chen Qianyu regression PMX.");
    return;
}
pmx = Path.GetFullPath(pmx);
var modelDirectory = Path.GetDirectoryName(pmx)!;
var output = args.Length > 0 ? Path.GetFullPath(args[0]) : Path.Combine(root, "_new_gui_verify");
var projectName = args.Length > 1 ? ProjectFactory.SanitizeProjectName(args[1]) : "ChenQianyu_NewStudio";

Assert(RuntimeContract.Validate(runtime).All(message => !message.IsError), "权威运行时不完整");
var project = ProjectFactory.Create(pmx, runtime, output);
project.ProjectName = projectName;
project.EnableEyeThrough = true;
project.GenerateDerivedPmx = true;

var expectedAutoRoles = new Dictionary<int, MaterialRole>
{
    [0] = MaterialRole.Face,
    [1] = MaterialRole.Iris,
    [2] = MaterialRole.EyeHighlight,
    [3] = MaterialRole.EyeWhite,
    [4] = MaterialRole.None,
    [5] = MaterialRole.BrowLash,
    [6] = MaterialRole.Mouth,
    [7] = MaterialRole.Hair,
    [8] = MaterialRole.None,
    [9] = MaterialRole.Skin,
    [10] = MaterialRole.Cloth,
    [11] = MaterialRole.FaceProxy
};
foreach (var pair in expectedAutoRoles)
    Assert(project.Materials.Single(material => material.MaterialIndex == pair.Key).Role == pair.Value, $"自动分类错误：#{pair.Key}");

var chenOtherTex = Directory.GetDirectories(modelDirectory, "*", SearchOption.TopDirectoryOnly)
    .Single(path => new string(Path.GetFileName(path).Where(char.IsLetterOrDigit).ToArray())
        .Equals("othertex", StringComparison.OrdinalIgnoreCase));
TextureAutoMatcher.Assign(project, overwriteExisting: true, modelDirectory, chenOtherTex);
foreach (var index in new[] { 1, 2 })
{
    var irisMaterial = project.Materials.Single(material => material.MaterialIndex == index);
    Assert(!irisMaterial.UsePmxBaseTexture, $"自动匹配没有关闭 PMX 基础色：#{index}");
    Assert(irisMaterial.Textures.Base is not null &&
           irisMaterial.Textures.Base.Contains("other tex", StringComparison.OrdinalIgnoreCase),
        $"自动匹配没有优先选择 other tex 虹膜贴图：#{index}");
    Assert(Sha256(irisMaterial.Textures.Base!) ==
           Sha256(Path.Combine(chenOtherTex, "T_actor_chen_iris_01_D.png")),
        $"自动匹配选择了错误的虹膜贴图：#{index}");
}

var roleMap = new Dictionary<int, MaterialRole>
{
    [0] = MaterialRole.Face,
    [1] = MaterialRole.Iris,
    [2] = MaterialRole.EyeHighlight,
    [3] = MaterialRole.EyeWhite,
    [4] = MaterialRole.None,
    [5] = MaterialRole.BrowLash,
    [6] = MaterialRole.Mouth,
    [7] = MaterialRole.Hair,
    [8] = MaterialRole.None,
    [9] = MaterialRole.Skin,
    [10] = MaterialRole.Cloth,
    [11] = MaterialRole.FaceProxy
};
foreach (var material in project.Materials)
    material.Role = roleMap.GetValueOrDefault(material.MaterialIndex, MaterialRole.None);

var chen = Path.Combine(runtime, "textures", "chen");
Set(0, baseName: "T_actor_chen_face_01_D.png", sdf: "T_actor_common_female_face_01_SDF.png", rd: "T_actor_common_face_01_RD.png", lut: "T_actor_common_femaleskincolor02_lut_D.png", st: "T_actor_common_female_face_01_ST.png", colorMask: "T_actor_common_female_face_01_cm_M.png");
Set(1, baseName: "T_actor_chen_iris_01_D.png");
Set(2, baseName: "T_actor_chen_iris_01_D.png");
Set(3, baseName: "T_actor_chen_face_01_D.png");
Set(5, baseName: "T_actor_chen_face_01_D.png");
Set(6, baseName: "T_actor_chen_face_01_D.png");
Set(7, baseName: "T_actor_chen_hair_01_D.png", normal: "T_actor_chen_hair_01_HN.png", property: "T_actor_chen_hair_01_P.png", rd: "T_actor_common_hair_01_RD.png", rs: "T_actor_common_hair_08_RS.png", st: "T_actor_common_hairst_01_ST.png", hairLine: "T_actor_common_hairline_03_M.png");
Set(9, baseName: "T_actor_chen_body_01_D.png", rd: "T_actor_common_body_01_RD.png", lut: "T_actor_common_femaleskincolor02_lut_D.png");
Set(10, baseName: "T_actor_chen_cloth_01_D.png", normal: "T_actor_chen_cloth_01_N.png", property: "T_actor_chen_cloth_01_P.png", rd: "T_actor_common_cloth_04_RD.png", rs: "T_actor_common_cloth_04_RS.png", lut: "T_actor_common_cloth_lut_01_D.png");

var examples = Path.Combine(root, "EndfieldMaterialStudio", "examples");
Directory.CreateDirectory(examples);
ProjectFactory.Save(project, Path.Combine(examples, "陈千语_从普通PMX开始.endfieldstudio.json"));

var validation = ProjectValidator.Validate(project);
foreach (var message in validation) Console.WriteLine(message);
Assert(validation.All(message => !message.IsError), "陈千语工程预检查失败");

var result = new PackageBuilder().Build(project);
Console.WriteLine($"PACKAGE={result.OutputDirectory}");
Console.WriteLine($"EMM={result.EmmPath}");
Console.WriteLine($"MATERIAL_MAP={result.MaterialMapPath}");
var completedProject = ProjectFactory.Load(Path.Combine(result.OutputDirectory, projectName + ".endfieldstudio.json"));
Assert(completedProject.PmxPath == result.ModelPath, "生成后的工程没有指向角色包内 PMX");
Assert(completedProject.RuntimeRoot == result.OutputDirectory, "生成后的工程没有使用角色包内运行时");
foreach (var material in completedProject.Materials.Where(material => material.Enabled))
{
    AssertProjectTexture(material.Textures.Base, $"#{material.MaterialIndex} Base");
    AssertProjectTexture(material.Textures.Normal, $"#{material.MaterialIndex} Normal");
    AssertProjectTexture(material.Textures.Property, $"#{material.MaterialIndex} Property");
    AssertProjectTexture(material.Textures.Rd, $"#{material.MaterialIndex} RD");
    AssertProjectTexture(material.Textures.Rs, $"#{material.MaterialIndex} RS");
    AssertProjectTexture(material.Textures.Lut, $"#{material.MaterialIndex} LUT");
    AssertProjectTexture(material.Textures.Sdf, $"#{material.MaterialIndex} SDF");
    AssertProjectTexture(material.Textures.St, $"#{material.MaterialIndex} ST");
    AssertProjectTexture(material.Textures.ColorMask, $"#{material.MaterialIndex} Color Mask");
    AssertProjectTexture(material.Textures.LipSpecular, $"#{material.MaterialIndex} Lip Specular");
    AssertProjectTexture(material.Textures.HairLine, $"#{material.MaterialIndex} Hair Line");
}
ProjectFactory.Save(completedProject, Path.Combine(examples, "陈千语_眼透完成示例.endfieldstudio.json"));

var emm = Encoding.GetEncoding(936).GetString(File.ReadAllBytes(result.EmmPath));
var packagedModelRoot = Path.Combine(result.OutputDirectory, "Model");
Assert(File.Exists(result.ModelPath), "角色包内缺少 PMX 模型");
Assert(File.Exists(result.MaterialMapPath), "角色包内缺少 material-map.json");
Assert(result.GeneratedFiles.Contains(result.MaterialMapPath, StringComparer.OrdinalIgnoreCase), "生成文件列表缺少 material-map.json");
Assert(Path.GetFullPath(result.ModelPath).StartsWith(Path.GetFullPath(packagedModelRoot) + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase), "PMX 模型没有放在角色包 Model 文件夹");
Assert(emm.Contains($"Pmd2 = {result.ModelPath}", StringComparison.Ordinal), "EMM 没有指向角色包内 PMX");
var packagedModel = PmxReader.Read(result.ModelPath);
foreach (var material in packagedModel.Materials)
{
    AssertPackagedDependency(material.TexturePath, $"#{material.Index} 基础贴图");
    if (material.SphereMode != 0) AssertPackagedDependency(material.SphereTexturePath, $"#{material.Index} 球面贴图");
    AssertPackagedDependency(material.ToonTexturePath, $"#{material.Index} Toon 贴图");
}
Assert(!emm.Contains("Pmd8", StringComparison.Ordinal), "EMM 不应包含 Pmd8");
foreach (var controller in new[] { "Pmd3", "Pmd4", "Pmd5", "Pmd6", "Pmd7" })
    Assert(emm.Contains($"{controller} = ", StringComparison.Ordinal), $"EMM 缺少控制器 {controller}");
Assert(emm.IndexOf("[Effect@EndfieldEyeThrough_RT]", StringComparison.Ordinal) < emm.IndexOf("[Effect@ZMDshadow_SMap]", StringComparison.Ordinal), "眼透 RT 必须先于阴影 RT");
Assert(emm.Contains("Pmd2[12]", StringComparison.Ordinal) && emm.Contains("Pmd2[13]", StringComparison.Ordinal), "眼透覆盖材质未写入 EMM");

var materialMapText = File.ReadAllText(result.MaterialMapPath, new UTF8Encoding(false));
using var materialMap = JsonDocument.Parse(materialMapText);
var mapRoot = materialMap.RootElement;
Assert(mapRoot.GetProperty("Workflow").GetString() == "independent-material-fx", "材质清单工作流标记错误");
Assert(!mapRoot.GetProperty("MaterialEmmRequired").GetBoolean(), "独立材质 FX 不应依赖 EMM");
Assert(mapRoot.GetProperty("ShadowRouting").GetString() == "zmd-default-effect", "阴影自路由标记错误");
Assert(!mapRoot.GetProperty("ShadowEmmRequired").GetBoolean(), "ZMD 阴影不应依赖 EMM");
Assert(!mapRoot.GetProperty("EyeThroughEmmRequired").GetBoolean(), "眼透自路由后不应依赖 EMM");
Assert(mapRoot.GetProperty("EmmOptional").GetBoolean(), "材质、阴影和眼透自路由完成后 EMM 应为可选");
var mapModelPath = mapRoot.GetProperty("ModelPath").GetString();
Assert(!string.IsNullOrWhiteSpace(mapModelPath), "材质清单缺少模型路径");
Assert(File.Exists(Path.Combine(result.OutputDirectory, mapModelPath!.Replace('/', Path.DirectorySeparatorChar))), "材质清单模型路径不存在");
Assert(!materialMapText.Contains(Path.GetFullPath(root), StringComparison.OrdinalIgnoreCase), "材质清单泄漏了工程绝对路径");

var mapMaterials = mapRoot.GetProperty("Materials").EnumerateArray().ToDictionary(
    entry => entry.GetProperty("MaterialIndex").GetInt32());
Assert(mapMaterials.Count == completedProject.Materials.Count, "材质清单没有覆盖全部打包 PMX 材质");
foreach (var material in completedProject.Materials)
{
    Assert(mapMaterials.TryGetValue(material.MaterialIndex, out var entry), $"材质清单缺少 #{material.MaterialIndex}");
    Assert(entry.GetProperty("Enabled").GetBoolean() == material.Enabled, $"材质清单启用状态错误：#{material.MaterialIndex}");
    var fxPath = entry.GetProperty("FxPath").GetString();
    if (material.Enabled)
    {
        Assert(!string.IsNullOrWhiteSpace(fxPath), $"启用材质没有 FX 路径：#{material.MaterialIndex}");
        Assert(File.Exists(Path.Combine(result.OutputDirectory, fxPath!.Replace('/', Path.DirectorySeparatorChar))), $"材质清单 FX 不存在：#{material.MaterialIndex}");
    }
    else
        Assert(string.IsNullOrWhiteSpace(fxPath), $"停用材质不应生成 FX：#{material.MaterialIndex}");
}

var packagedZmdPath = Path.Combine(result.OutputDirectory, "ZMDshadow.fx");
var packagedZmdText = ReadText(packagedZmdPath);
Assert(CountOccurrences(packagedZmdText, "\"*.pmx = ZMDshadow_ShadowMap.fxsub;\"") == 1, "ZMD ShadowMap PMX 自路由数量错误");
Assert(CountOccurrences(packagedZmdText, "\"*.pmx = ZMDshadow_ViewportMap.fxsub;\"") == 2, "ZMD ViewportMap PMX 自路由数量错误");
Assert(CountOccurrences(packagedZmdText, "\"*controller*.pmx = hide;\"") == 3, "ZMD 自路由没有在全部 RT 排除控制器");
Assert(CountOccurrences(packagedZmdText, "\"*.x = hide;\"") == 3, "ZMD 自路由没有在全部 RT 排除附件");
Assert(!packagedZmdText.Contains("\"* = ZMDshadow_ShadowMap.fxsub;\"", StringComparison.Ordinal), "ZMD ShadowMap 仍在使用全吞式通配规则");
Assert(!packagedZmdText.Contains("\"* = ZMDshadow_ViewportMap.fxsub;\"", StringComparison.Ordinal), "ZMD ViewportMap 仍在使用全吞式通配规则");

var packagedEyeHostPath = Path.Combine(result.OutputDirectory, "EndfieldEyeThrough.fx");
var packagedEyeHostText = ReadText(packagedEyeHostPath);
const string eyeControllerRule = "\"*controller*.pmx = hide;\"";
const string eyeTargetRule = "\"*Endfield*.pmx = EndfieldEyeThrough_Capture.fxsub;\"";
const string eyeGenericPmxRule = "\"*.pmx = EndfieldEyeThrough_Mask.fxsub;\"";
Assert(CountOccurrences(packagedEyeHostText, eyeTargetRule) == 1, "眼透派生 PMX Capture 自路由数量错误");
Assert(CountOccurrences(packagedEyeHostText, eyeControllerRule) == 1, "眼透自路由没有排除控制器");
Assert(CountOccurrences(packagedEyeHostText, eyeGenericPmxRule) == 1, "眼透普通 PMX Mask 自路由数量错误");
Assert(packagedEyeHostText.IndexOf(eyeControllerRule, StringComparison.Ordinal) < packagedEyeHostText.IndexOf(eyeTargetRule, StringComparison.Ordinal), "眼透控制器排除必须先于派生 PMX Capture");
Assert(packagedEyeHostText.IndexOf(eyeTargetRule, StringComparison.Ordinal) < packagedEyeHostText.IndexOf(eyeGenericPmxRule, StringComparison.Ordinal), "眼透派生 PMX Capture 必须先于普通 PMX Mask");
Assert(packagedEyeHostText.Contains("\"*.pmd = EndfieldEyeThrough_Mask.fxsub;\"", StringComparison.Ordinal), "眼透普通 PMD 没有写入遮挡深度");
Assert(packagedEyeHostText.Contains("\"*.x = EndfieldEyeThrough_Mask.fxsub;\"", StringComparison.Ordinal), "眼透场景附件没有写入遮挡深度");
Assert(packagedEyeHostText.Contains("\"* = EndfieldEyeThrough_Mask.fxsub;\"", StringComparison.Ordinal), "眼透缺少 Mask 回退规则");
Assert(File.Exists(Path.Combine(result.OutputDirectory, "EndfieldEyeThrough_Capture.fxsub")), "眼透角色包缺少模型专属 Capture");

AssertContains("Material_000_Face.fx", "#define EF_FACE_MAIN_TEXTURE_RESOURCE \"textures/character/m000_base.png\"");
var packagedLipSpecular = completedProject.Materials
    .Single(material => material.MaterialIndex == 0)
    .Textures.LipSpecular;
Assert(packagedLipSpecular is not null && File.Exists(packagedLipSpecular), "角色包缺少唇部高光贴图");
Assert(Sha256(packagedLipSpecular!) == Sha256(Path.Combine(runtime, "textures", "chen", "T_actor_common_face_01_hl_M.png")),
    "角色包唇部高光贴图内容错误");
AssertContains("Material_007_Hair.fx", "#define EF_HAIR_FACE_SHADOW_PASS 1");
AssertContains("Material_007_Hair.fx", "#define EF_HAIR_SPEC_OFF 1");
AssertContains("Material_010_Cloth.fx", "#define EF_CLOTH_ZMD_SHADOW_ENABLED 1");
AssertContains("Material_010_Cloth.fx", "#define EF_CLOTH_SHADOW_VIEWPORT_MAP ZMDshadow_ViewportMap2");
AssertContains("Material_001_Iris.fx", "#define EF_FACIAL_BASE_STENCIL_REF 1");
AssertContains("Material_001_Iris.fx", "\"textures/character/m001_base.png\"");
AssertContains("Material_001_Iris.fx", "#define EF_EYE_IRIS_MATCAP05_TEXTURE \"textures/common/T_actor_common_matcap_05_D.png\"");
AssertContains("Material_001_Iris.fx", "#define EF_EYE_IRIS_MATCAP07_TEXTURE \"textures/common/T_actor_common_matcap_07_D.png\"");
AssertContains("Material_012_EyeOverlay.fx", "#define EF_FACIAL_OVERLAY_STENCIL_REF 2");
AssertContains("Material_012_EyeOverlay.fx", "#define EF_FACIAL_OVERLAY_STENCIL_MASK 2");
AssertContains("Material_012_EyeOverlay.fx", "\"textures/character/m001_base.png\"");
AssertContains("EndfieldEyeThrough_Capture.fxsub", "#define EF_EYE_CAPTURE_HAIR_DEPTH_SUBSETS \"7,8\"");
AssertContains("EndfieldEyeThrough_Capture.fxsub", "#define EF_EYE_CAPTURE_SHIFTED_SUBSETS \"11,12,13\"");
AssertContains("EndfieldEyeThrough_Capture.fxsub", "#define EF_EYE_IRIS_MATCAP05_TEXTURE \"textures/common/T_actor_common_matcap_05_D.png\"");
AssertContains("EndfieldEyeThrough_Capture.fxsub", "#define EF_EYE_IRIS_MATCAP07_TEXTURE \"textures/common/T_actor_common_matcap_07_D.png\"");
AssertContains("EndfieldEyeThrough_Capture.fxsub", "#define EF_EYE_HL_TEXTURE_RESOURCE \"textures/character/m001_base.png\"");
var eyeCaptureText = ReadText(Path.Combine(result.OutputDirectory, "EndfieldEyeThrough_Capture.fxsub"));
Assert(!eyeCaptureText.Contains("textures/chen/", StringComparison.Ordinal), "生成的 Eye Capture 仍引用角色专用 Chen 纹理目录");

foreach (var name in new[] { "T_actor_common_face_01_hl_M.png", "T_actor_common_matcap_05_D.png", "T_actor_common_matcap_07_D.png" })
    Assert(File.Exists(Path.Combine(result.OutputDirectory, "textures", "common", name)), $"角色包缺少通用固定贴图：{name}");
foreach (var materialFx in Directory.GetFiles(result.OutputDirectory, "Material_*.fx", SearchOption.TopDirectoryOnly))
{
    var materialText = ReadText(materialFx);
    Assert(!materialText.Contains("textures/chen/", StringComparison.Ordinal), $"生成材质仍引用角色专用路径：{Path.GetFileName(materialFx)}");
}

var runtimeInternal = Directory.GetFiles(Path.Combine(runtime, "internal"), "*", SearchOption.AllDirectories);
foreach (var source in runtimeInternal)
{
    var target = Path.Combine(result.OutputDirectory, "internal", Path.GetRelativePath(Path.Combine(runtime, "internal"), source));
    if (Path.GetFileName(target).Equals("endfield_generated_face_binding.cp932", StringComparison.OrdinalIgnoreCase)) continue;
    Assert(File.Exists(target), $"输出缺少 internal 文件：{target}");
    Assert(Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(source))) ==
           Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(target))),
        $"运行时文件被修改：{Path.GetFileName(source)}");
}

var goldenRoot = Path.Combine(root, "EndfieldMME_Golden_20260809");
if (Directory.Exists(goldenRoot))
{
    foreach (var outputFile in Directory.GetFiles(result.OutputDirectory, "*", SearchOption.AllDirectories))
    {
        var relative = Path.GetRelativePath(result.OutputDirectory, outputFile);
        var isRuntimeAsset = relative.StartsWith("internal" + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase) ||
                             relative.StartsWith("controller" + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase) ||
                             relative.StartsWith(Path.Combine("textures", "common") + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase) ||
                             relative.StartsWith(Path.Combine("textures", "environment_presets") + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase) ||
                             !relative.Contains(Path.DirectorySeparatorChar);
        if (!isRuntimeAsset) continue;
        var goldenFile = Path.Combine(goldenRoot, relative);
        var sourceFile = Path.Combine(runtime, relative);
        if (!File.Exists(goldenFile) || !File.Exists(sourceFile)) continue;
        var outputHash = Sha256(outputFile);
        if (relative.Equals("ZMDshadow.fx", StringComparison.OrdinalIgnoreCase))
        {
            Assert(Sha256(sourceFile) == Sha256(goldenFile), "权威 ZMDshadow.fx 被修改");
            var expected = ZmdAutoRoutePatcher.Build(File.ReadAllBytes(sourceFile));
            Assert(File.ReadAllBytes(outputFile).SequenceEqual(expected), "打包 ZMDshadow.fx 包含自动路由以外的改动");
            continue;
        }
        if (relative.Equals("EndfieldEyeThrough.fx", StringComparison.OrdinalIgnoreCase))
        {
            Assert(Sha256(sourceFile) == Sha256(goldenFile), "权威 EndfieldEyeThrough.fx 被修改");
            var expected = EyeThroughAutoRoutePatcher.Build(File.ReadAllBytes(sourceFile));
            Assert(File.ReadAllBytes(outputFile).SequenceEqual(expected), "打包 EndfieldEyeThrough.fx 包含自动路由以外的改动");
            continue;
        }
        Assert(outputHash == Sha256(sourceFile), $"打包运行时与当前权威运行时不一致：{relative}");
        Assert(outputHash == Sha256(goldenFile), $"打包运行时与 Golden Runtime 不一致：{relative}");
    }
}

RunPmxTextureFallbackRegression();

Console.WriteLine("ALL_TESTS_PASSED");
return;

void RunPmxTextureFallbackRegression()
{
    var fixtureRoot = Path.Combine(output, "_pmx_texture_fallback_fixture");
    var fixtureOutput = Path.Combine(output, "_pmx_texture_fallback_output");
    if (Directory.Exists(fixtureRoot)) Directory.Delete(fixtureRoot, true);
    Directory.CreateDirectory(fixtureRoot);

    var fixturePmx = Path.Combine(fixtureRoot, Path.GetFileName(pmx));
    File.Copy(pmx, fixturePmx, true);
    var sourceModel = PmxReader.Read(pmx);
    var dependencies = PmxReader.ResolveTextureDependencies(sourceModel)
        .Where(dependency => dependency.Resolution.Exists &&
                             !Path.IsPathRooted(dependency.Resolution.DeclaredPath))
        .GroupBy(dependency => dependency.Resolution.DeclaredPath, StringComparer.OrdinalIgnoreCase)
        .Select(group => group.First())
        .ToArray();
    var fallbackDependencies = dependencies
        .Where(dependency => dependency.Kind == PmxTextureKind.Base)
        .GroupBy(dependency => Path.GetFileName(dependency.Resolution.DeclaredPath), StringComparer.OrdinalIgnoreCase)
        .Select(group => group.First())
        .Take(2)
        .ToArray();
    Assert(fallbackDependencies.Length == 2, "PMX 回退测试需要两个不同文件名的基础贴图依赖");

    foreach (var dependency in dependencies)
    {
        var declaredPath = NormalizeFixturePath(dependency.Resolution.DeclaredPath);
        string destination;
        if (dependency.Resolution.DeclaredPath.Equals(fallbackDependencies[0].Resolution.DeclaredPath, StringComparison.OrdinalIgnoreCase))
            destination = Path.Combine(fixtureRoot, "other tex", Path.GetFileName(declaredPath));
        else if (dependency.Resolution.DeclaredPath.Equals(fallbackDependencies[1].Resolution.DeclaredPath, StringComparison.OrdinalIgnoreCase))
            destination = Path.Combine(fixtureRoot, "other_tex", Path.GetFileName(declaredPath));
        else
            destination = Path.Combine(fixtureRoot, declaredPath);
        Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
        File.Copy(dependency.Resolution.ResolvedPath, destination, true);
    }

    var fixtureModel = PmxReader.Read(fixturePmx);
    var fixtureDependencies = PmxReader.ResolveTextureDependencies(fixtureModel);
    foreach (var expected in fallbackDependencies)
    {
        var actual = fixtureDependencies.Single(dependency =>
            dependency.MaterialIndex == expected.MaterialIndex &&
            dependency.Kind == expected.Kind &&
            dependency.Resolution.DeclaredPath.Equals(expected.Resolution.DeclaredPath, StringComparison.OrdinalIgnoreCase));
        Assert(actual.Resolution.Exists, $"PMX 回退未找到：{actual.Resolution.DeclaredPath}");
        Assert(actual.Resolution.UsedFallback, $"PMX 依赖没有标记为回退：{actual.Resolution.DeclaredPath}");
        Assert(Path.GetFileName(actual.Resolution.ResolvedPath).Equals(
            Path.GetFileName(actual.Resolution.DeclaredPath), StringComparison.OrdinalIgnoreCase),
            "PMX 回退没有使用完全相同的文件名");
    }

    var firstFallbackName = Path.GetFileNameWithoutExtension(fallbackDependencies[0].Resolution.DeclaredPath);
    var firstFallbackExtension = Path.GetExtension(fallbackDependencies[0].Resolution.DeclaredPath);
    var fuzzyResolution = PmxReader.ResolveTexture(
        fixturePmx,
        Path.Combine("textures", firstFallbackName + "_not_exact" + firstFallbackExtension));
    Assert(fuzzyResolution is { Exists: false, UsedFallback: false }, "PMX 回退错误接受了近似文件名");

    var fixtureProject = ProjectFactory.Create(fixturePmx, runtime, fixtureOutput);
    foreach (var expected in fallbackDependencies)
    {
        var material = fixtureProject.Materials.Single(item => item.MaterialIndex == expected.MaterialIndex);
        Assert(material.PmxBaseTexture is not null &&
               Path.GetFileName(material.PmxBaseTexture).Equals(Path.GetFileName(expected.Resolution.DeclaredPath), StringComparison.OrdinalIgnoreCase) &&
               (material.PmxBaseTexture.Contains("other tex", StringComparison.OrdinalIgnoreCase) ||
                material.PmxBaseTexture.Contains("other_tex", StringComparison.OrdinalIgnoreCase)),
            $"ProjectFactory 没有保存 PMX 基础贴图回退：#{material.MaterialIndex}");
    }

    var fixtureProjectPath = Path.Combine(fixtureRoot, "fallback.endfieldstudio.json");
    ProjectFactory.Save(fixtureProject, fixtureProjectPath);
    var loadedFixtureProject = ProjectFactory.Load(fixtureProjectPath);
    foreach (var expected in fallbackDependencies)
    {
        var material = loadedFixtureProject.Materials.Single(item => item.MaterialIndex == expected.MaterialIndex);
        Assert(material.PmxBaseTexture is not null && File.Exists(material.PmxBaseTexture),
            $"重开工程后 PMX 基础贴图回退失效：#{material.MaterialIndex}");
    }

    foreach (var material in loadedFixtureProject.Materials)
    {
        var source = project.Materials.Single(item => item.MaterialIndex == material.MaterialIndex);
        material.Role = source.Role;
        material.UsePmxBaseTexture = source.UsePmxBaseTexture;
        material.Textures = CloneSlots(source.Textures);
    }
    loadedFixtureProject.ProjectName = "PmxTextureFallbackRegression";
    loadedFixtureProject.OutputDirectory = fixtureOutput;
    loadedFixtureProject.EnableEyeThrough = false;
    loadedFixtureProject.GenerateDerivedPmx = false;

    var fallbackValidation = ProjectValidator.Validate(loadedFixtureProject);
    foreach (var message in fallbackValidation) Console.WriteLine(message);
    var expectedFallbackWarnings = fixtureDependencies.Count(dependency => dependency.Resolution.UsedFallback);
    Assert(fallbackValidation.Count(message => message.Code == "PMX_TEXTURE_FALLBACK") == expectedFallbackWarnings,
        "PMX 回退警告数量错误");
    Assert(fallbackValidation.All(message => !message.IsError), "PMX 回退不应阻止角色包生成");

    var fallbackResult = new PackageBuilder().Build(loadedFixtureProject);
    foreach (var expected in fallbackDependencies)
    {
        var packagedResolution = PmxReader.ResolveTexture(fallbackResult.ModelPath, expected.Resolution.DeclaredPath);
        Assert(packagedResolution is { Exists: true, UsedFallback: false },
            $"角色包没有按 PMX 原声明路径恢复贴图：{expected.Resolution.DeclaredPath}");
        var packagedPath = packagedResolution!.ResolvedPath;
        Assert(File.ReadAllBytes(packagedPath)
                .SequenceEqual(File.ReadAllBytes(fixtureDependencies.Single(dependency =>
                    dependency.MaterialIndex == expected.MaterialIndex &&
                    dependency.Kind == expected.Kind &&
                    dependency.Resolution.DeclaredPath.Equals(expected.Resolution.DeclaredPath, StringComparison.OrdinalIgnoreCase))
                    .Resolution.ResolvedPath)),
            $"角色包回退贴图内容不一致：{expected.Resolution.DeclaredPath}");
    }
    Console.WriteLine("PMX_TEXTURE_FALLBACK_TEST_PASSED");
}

string NormalizeFixturePath(string path)
{
    var normalized = path.Trim().Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
    var parts = normalized.Split(Path.DirectorySeparatorChar, StringSplitOptions.RemoveEmptyEntries);
    Assert(parts.Length > 0 && parts.All(part => part is not "." and not ".." && !part.Contains(':')),
        $"PMX 回退测试遇到不安全路径：{path}");
    return Path.Combine(parts);
}

TextureSlots CloneSlots(TextureSlots source) => new()
{
    Base = source.Base,
    Normal = source.Normal,
    Property = source.Property,
    Rd = source.Rd,
    Rs = source.Rs,
    Lut = source.Lut,
    Sdf = source.Sdf,
    St = source.St,
    ColorMask = source.ColorMask,
    LipSpecular = source.LipSpecular,
    HairLine = source.HairLine
};

void Set(
    int index,
    string? baseName = null,
    string? normal = null,
    string? property = null,
    string? rd = null,
    string? rs = null,
    string? lut = null,
    string? sdf = null,
    string? st = null,
    string? colorMask = null,
    string? hairLine = null)
{
    var material = project.Materials.Single(item => item.MaterialIndex == index);
    material.UsePmxBaseTexture = false;
    material.Textures.Base = Full(baseName);
    material.Textures.Normal = Full(normal);
    material.Textures.Property = Full(property);
    material.Textures.Rd = Full(rd);
    material.Textures.Rs = Full(rs);
    material.Textures.Lut = Full(lut);
    material.Textures.Sdf = Full(sdf);
    material.Textures.St = Full(st);
    material.Textures.ColorMask = Full(colorMask);
    material.Textures.HairLine = Full(hairLine);
}

string? Full(string? name) => name is null ? null : Path.Combine(chen, name);

void AssertContains(string relative, string value)
{
    var path = Path.Combine(result.OutputDirectory, relative);
    var text = ReadText(path);
    Assert(text.Contains(value, StringComparison.Ordinal), $"{relative} 缺少：{value}");
}

string ReadText(string path)
{
    var bytes = File.ReadAllBytes(path);
    try { return new UTF8Encoding(false, true).GetString(bytes); }
    catch (DecoderFallbackException) { return Encoding.GetEncoding(932).GetString(bytes); }
}

void AssertPackagedDependency(string? relativePath, string label)
{
    if (string.IsNullOrWhiteSpace(relativePath)) return;
    var path = PmxReader.ResolveTextureFilePath(result.ModelPath, relativePath)!;
    Assert(Path.GetFullPath(path).StartsWith(Path.GetFullPath(packagedModelRoot) + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase), $"{label}越出了 Model 文件夹");
    Assert(File.Exists(path), $"角色包缺少{label}：{path}");
}

void AssertProjectTexture(string? path, string label)
{
    if (string.IsNullOrWhiteSpace(path)) return;
    Assert(Path.GetFullPath(path).StartsWith(Path.GetFullPath(result.OutputDirectory) + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase), $"生成后的工程仍引用外部{label}贴图");
    Assert(File.Exists(path), $"生成后的工程缺少{label}贴图：{path}");
}

static void Assert(bool condition, string message)
{
    if (!condition) throw new InvalidOperationException(message);
}

static string Sha256(string path) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(path)));

static int CountOccurrences(string text, string value)
{
    var count = 0;
    var offset = 0;
    while ((offset = text.IndexOf(value, offset, StringComparison.Ordinal)) >= 0)
    {
        count++;
        offset += value.Length;
    }
    return count;
}
