using System.Text;
using EndfieldMaterialStudio.Core;

Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

var repositoryRoot = FindRepositoryRoot();
var runtime = Environment.GetEnvironmentVariable("ENDFIELD_MME_RUNTIME") ?? Path.Combine(repositoryRoot, "EndfieldMME");

foreach (var message in RuntimeContract.Validate(runtime)) Console.WriteLine(message);
Assert(RuntimeContract.Validate(runtime).All(message => !message.IsError), "EndfieldMME 运行时不完整");
RunTemplateSmokeTests();
RunClothUvAddressingTests();
RunRuntimeCopySmokeTest();
RunPmxBaseTextureModeTests();
Console.WriteLine("PORTABLE_TESTS_PASSED");

var pmx = Environment.GetEnvironmentVariable("ENDFIELD_TEST_PMX");
if (string.IsNullOrWhiteSpace(pmx))
{
    Console.WriteLine("INTEGRATION_TEST_SKIPPED: set ENDFIELD_TEST_PMX to a locally licensed PMX for the optional package test.");
    return;
}

pmx = Path.GetFullPath(pmx);
var output = args.Length > 0
    ? Path.GetFullPath(args[0])
    : Path.Combine(Path.GetTempPath(), "EndfieldMaterialStudio_GenericPackageTest");
var project = ProjectFactory.Create(pmx, runtime, output);
project.ProjectName = args.Length > 1 ? ProjectFactory.SanitizeProjectName(args[1]) : "Generic_Endfield_Test";
project.EnableEyeThrough = false;
project.GenerateDerivedPmx = false;
foreach (var material in project.Materials) material.Role = MaterialRole.None;

var validation = ProjectValidator.Validate(project);
foreach (var message in validation) Console.WriteLine(message);
Assert(validation.All(message => !message.IsError), "通用 PMX 工程预检查失败");

var result = new PackageBuilder().Build(project);
Assert(File.Exists(result.ModelPath), "通用角色包缺少 PMX");
Assert(File.Exists(result.EmmPath), "通用角色包缺少 EMM");
Assert(File.Exists(Path.Combine(result.OutputDirectory, "internal", "endfield_shader.hlsl")),
    "通用角色包缺少 Shader 运行时");
Assert(File.Exists(Path.Combine(result.OutputDirectory, "EndfieldHairVisibility_Capture.fxsub")),
    "通用角色包缺少头发可见性 Capture");
Assert(File.ReadAllBytes(Path.Combine(result.OutputDirectory, "ZMDshadow.fx"))
    .SequenceEqual(File.ReadAllBytes(Path.Combine(runtime, "ZMDshadow.fx"))),
    "输出包改写了权威 ZMDshadow.fx");
Console.WriteLine("GENERIC_PACKAGE_TEST_PASSED");

void RunTemplateSmokeTests()
{
    var slots = new TextureSlots
    {
        Base = "textures/character/base.png",
        Normal = "textures/character/normal.png",
        Property = "textures/character/property.png",
        Rd = "textures/common/rd.png",
        Rs = "textures/common/rs.png",
        Lut = "textures/common/lut.png",
        Sdf = "textures/character/sdf.png",
        St = "textures/common/st.png",
        ColorMask = "textures/character/color_mask.png",
        LipSpecular = "textures/character/lip_specular.png",
        HairLine = "textures/common/hair_line.png"
    };
    var roles = new[]
    {
        MaterialRole.Face,
        MaterialRole.Iris,
        MaterialRole.EyeHighlight,
        MaterialRole.EyeWhite,
        MaterialRole.BrowLash,
        MaterialRole.Mouth,
        MaterialRole.Hair,
        MaterialRole.Skin,
        MaterialRole.Cloth,
        MaterialRole.EyeOverlay,
        MaterialRole.BrowOverlay,
        MaterialRole.Hidden
    };

    foreach (var role in roles)
    {
        var bytes = FxTemplateEngine.BuildMaterialFx(
            runtime,
            new MaterialAssignment { MaterialIndex = (int)role, MaterialName = role.ToString(), Role = role },
            slots,
            "頭",
            "endfield_generated_face_binding.cp932");
        AssertGeneratedText(Decode(bytes), $"{role} FX");
    }

    var captureProject = new StudioProject
    {
        HeadBone = "頭",
        Materials = new List<MaterialAssignment>
        {
            Material(0, MaterialRole.Face),
            Material(1, MaterialRole.Iris),
            Material(2, MaterialRole.EyeHighlight),
            Material(3, MaterialRole.EyeWhite),
            Material(4, MaterialRole.BrowLash),
            Material(5, MaterialRole.Hair),
            Material(6, MaterialRole.FaceProxy),
            Material(7, MaterialRole.EyeOverlay),
            Material(8, MaterialRole.BrowOverlay)
        }
    };
    AssertGeneratedText(FxTemplateEngine.BuildEyeCapture(runtime, captureProject, slots, "endfield_generated_face_binding.cp932"), "EyeThrough Capture");

    var explicitProject = new StudioProject
    {
        HeadBone = "頭",
        Materials = new List<MaterialAssignment>
        {
            new() { MaterialIndex = 10, MaterialName = "ExplicitIris", Role = MaterialRole.Iris, EyeThrough = EyeThroughParticipation.Iris },
            new() { MaterialIndex = 11, MaterialName = "IgnoredIris", Role = MaterialRole.Iris, EyeThrough = EyeThroughParticipation.Ignore },
            new() { MaterialIndex = 12, MaterialName = "ExplicitHair", Role = MaterialRole.None, EyeThrough = EyeThroughParticipation.HairDepth }
        }
    };
    var explicitCapture = FxTemplateEngine.BuildEyeCapture(runtime, explicitProject, slots, "endfield_generated_face_binding.cp932");
    Assert(explicitCapture.Contains("#define EF_EYE_CAPTURE_EYE_SUBSETS \"10\"", StringComparison.Ordinal),
        "显式眼透参与方式没有覆盖材质类型自动分类");
    Assert(explicitCapture.Contains("#define EF_EYE_CAPTURE_IGNORED_SUBSETS \"11\"", StringComparison.Ordinal),
        "显式排除材质没有写入 Ignore 集合");
    Assert(explicitCapture.Contains("#define EF_EYE_CAPTURE_HAIR_DEPTH_SUBSETS \"12\"", StringComparison.Ordinal),
        "显式头发深度材质没有写入 HairDepth 集合");
}

void RunPmxBaseTextureModeTests()
{
    var root = Path.Combine(Path.GetTempPath(), "EndfieldPmxBaseMode_" + Guid.NewGuid().ToString("N"));
    Directory.CreateDirectory(root);
    try
    {
        Directory.CreateDirectory(Path.Combine(root, "textures"));
        var source = Path.Combine(root, "source.pmx");
        WriteMinimalPmx(source, "textures", "textures");
        var originalBytes = File.ReadAllBytes(source);
        var replacement = Path.Combine(root, "replacement.png");
        File.WriteAllBytes(replacement, new byte[] { 0x89, 0x50, 0x4e, 0x47 });

        var project = new StudioProject
        {
            PmxPath = source,
            Materials = new List<MaterialAssignment>
            {
                new()
                {
                    MaterialIndex = 0,
                    MaterialName = "Override",
                    Role = MaterialRole.None,
                    BaseTextureMode = PmxBaseTextureMode.Override,
                    UsePmxBaseTexture = false,
                    Textures = new TextureSlots { Base = replacement }
                },
                new()
                {
                    MaterialIndex = 1,
                    MaterialName = "None",
                    Role = MaterialRole.None,
                    BaseTextureMode = PmxBaseTextureMode.None,
                    UsePmxBaseTexture = false
                }
            }
        };

        Assert(ProjectValidator.ValidatePmxDependencies(project).All(message => !message.IsError),
            "Override/None 不应被无效的原始 PMX 基础贴图阻塞");

        project.Materials[0].BaseTextureMode = PmxBaseTextureMode.Inherit;
        Assert(ProjectValidator.ValidatePmxDependencies(project).Any(message => message.IsError),
            "Inherit 应报告指向文件夹的 PMX 基础贴图");
        project.Materials[0].BaseTextureMode = PmxBaseTextureMode.Override;

        var rewritten = Path.Combine(root, "rewritten.pmx");
        PmxTextureRewriter.Rewrite(rewritten == source ? throw new InvalidOperationException() : source, rewritten,
            new Dictionary<int, string?>
            {
                [0] = "textures/endfield_m000_base.png",
                [1] = null
            });
        var rewrittenModel = PmxReader.Read(rewritten);
        Assert(rewrittenModel.Materials[0].TexturePath == "textures/endfield_m000_base.png",
            "Override 没有写入输出 PMX 的贴图索引");
        Assert(rewrittenModel.Materials[1].TexturePath is null,
            "None 没有把输出 PMX 的基础贴图索引设为 -1");
        Assert(File.ReadAllBytes(source).SequenceEqual(originalBytes), "PMX 重写修改了源模型");

        var oldProjectPath = Path.Combine(root, "legacy.json");
        File.WriteAllText(oldProjectPath,
            "{\"PmxPath\":\"\",\"Materials\":[{\"MaterialIndex\":0,\"UsePmxBaseTexture\":false,\"Textures\":{}}]}");
        var migrated = ProjectFactory.Load(oldProjectPath);
        Assert(migrated.Materials[0].EffectiveBaseTextureMode == PmxBaseTextureMode.Override,
            "旧工程 UsePmxBaseTexture=false 没有迁移为 Override");

        project.RuntimeRoot = runtime;
        project.OutputDirectory = Path.Combine(root, "output");
        project.ProjectName = "BaseModePortable";
        project.EnableEyeThrough = false;
        project.GenerateDerivedPmx = false;
        var package = new PackageBuilder().Build(project);
        var packaged = PmxReader.Read(package.ModelPath);
        Assert(packaged.Materials[0].TexturePath == "textures/endfield_m000_base.png",
            "角色包 PMX 没有保留 Override 路径");
        Assert(packaged.Materials[1].TexturePath is null, "角色包 PMX 没有保留 None 模式");
        Assert(File.Exists(Path.Combine(Path.GetDirectoryName(package.ModelPath)!, "textures", "endfield_m000_base.png")),
            "角色包没有复制手动基础贴图");
    }
    finally
    {
        if (Directory.Exists(root)) Directory.Delete(root, true);
    }
}

static void WriteMinimalPmx(string path, params string[] baseTextures)
{
    using var stream = File.Create(path);
    using var writer = new BinaryWriter(stream, new UTF8Encoding(false), leaveOpen: true);
    writer.Write(Encoding.ASCII.GetBytes("PMX "));
    writer.Write(2.0f);
    writer.Write((byte)8);
    writer.Write(new byte[] { 1, 0, 1, 1, 1, 1, 1, 1 });
    for (var i = 0; i < 4; i++) WriteText(writer, string.Empty);
    writer.Write(0); // vertices
    writer.Write(0); // surface indices
    writer.Write(baseTextures.Length);
    foreach (var texture in baseTextures) WriteText(writer, texture);
    writer.Write(baseTextures.Length);
    for (var index = 0; index < baseTextures.Length; index++)
    {
        WriteText(writer, $"material_{index}");
        WriteText(writer, string.Empty);
        writer.Write(new byte[16 + 12 + 4 + 12 + 1 + 16 + 4]);
        writer.Write(unchecked((sbyte)index));
        writer.Write(unchecked((sbyte)-1));
        writer.Write((byte)0);
        writer.Write((byte)1);
        writer.Write((byte)0);
        WriteText(writer, string.Empty);
        writer.Write(0);
    }
    writer.Write(0); // bones

    static void WriteText(BinaryWriter writer, string value)
    {
        var bytes = Encoding.UTF8.GetBytes(value);
        writer.Write(bytes.Length);
        writer.Write(bytes);
    }
}

void RunClothUvAddressingTests()
{
    AssertClothUvAddressing(runtime);
    Console.WriteLine("CLOTH_UV_ADDRESSING_TESTS_PASSED");
}

static void AssertClothUvAddressing(string runtimePath)
{
    var shader = File.ReadAllText(Path.Combine(runtimePath, "internal", "endfield_cloth.hlsl"));
    Assert(System.Text.RegularExpressions.Regex.IsMatch(shader,
        @"#ifndef\s+EF_CLOTH_UV_ADDRESS_MODE\s+#define\s+EF_CLOTH_UV_ADDRESS_MODE\s+WRAP\s+#endif"),
        "Cloth UV addressing must default to WRAP and allow a per-material override");
    // Model UV maps repeat outside 0-1; lookup tables must retain edge clamping.
    foreach (var (sampler, address) in new[]
    {
        ("EfClothMainSampler", "EF_CLOTH_UV_ADDRESS_MODE"),
        ("EfClothNormalSampler", "EF_CLOTH_UV_ADDRESS_MODE"),
        ("EfClothPropertySampler", "EF_CLOTH_UV_ADDRESS_MODE"),
        ("EfClothRdSampler", "CLAMP"),
        ("EfClothLutSampler", "CLAMP"),
        ("EfClothRsSampler", "CLAMP")
    })
    {
        var match = System.Text.RegularExpressions.Regex.Match(shader,
            $@"\bsampler2D\s+{sampler}\s*=\s*sampler_state\s*\{{(?<body>[^}}]*)\}}");
        Assert(match.Success, $"Missing cloth sampler: {sampler}");
        foreach (var axis in new[] { "U", "V" })
            Assert(System.Text.RegularExpressions.Regex.IsMatch(match.Groups["body"].Value,
                $@"\bAddress{axis}\s*=\s*{address}\s*;"),
                $"{sampler}.Address{axis} must be {address}");
    }
}

void RunRuntimeCopySmokeTest()
{
    var output = Path.Combine(Path.GetTempPath(), "EndfieldRuntimeContract_" + Guid.NewGuid().ToString("N"));
    try
    {
        var copied = RuntimeContract.CopyRuntime(runtime, output);
        AssertClothUvAddressing(output);
        Assert(copied.Count > 0, "运行时复制没有产生文件");
        Assert(File.Exists(Path.Combine(output, "EndfieldEyeThrough.fx")), "运行时复制缺少眼透入口");
        Assert(File.Exists(Path.Combine(output, "EndfieldHairVisibility_Capture.fxsub")),
            "运行时复制缺少头发可见性 Capture");
        Assert(File.Exists(Path.Combine(output, "ZMDshadow.fx")), "运行时复制缺少阴影入口");
        Assert(File.Exists(Path.Combine(output, "EndfieldPost.fx")), "运行时复制缺少后处理入口");
        Assert(File.ReadAllBytes(Path.Combine(output, "ZMDshadow.fx"))
            .SequenceEqual(File.ReadAllBytes(Path.Combine(runtime, "ZMDshadow.fx"))), "运行时复制阶段不应改写 ZMDshadow.fx");
        var shaderCore = File.ReadAllText(Path.Combine(output, "internal", "endfield_shader.hlsl"));
        Assert(shaderCore.Contains("EF_HAIR_FACE_SHADOW_SINGLE_BLEND_MASK", StringComparison.Ordinal),
            "运行时 Shader 缺少发影单次混合锁");
        Assert(shaderCore.Contains("StencilPass = INVERT", StringComparison.Ordinal),
            "运行时 Shader 没有阻止重叠发片重复叠色");
        Assert(!Directory.Exists(Path.Combine(output, "tools")), "运行时复制不应包含开发工具");
    }
    finally
    {
        if (Directory.Exists(output)) Directory.Delete(output, true);
    }
}

static MaterialAssignment Material(int index, MaterialRole role) => new()
{
    MaterialIndex = index,
    MaterialName = role.ToString(),
    Role = role
};

static void AssertGeneratedText(string text, string label)
{
    Assert(!text.Contains("__EF_", StringComparison.Ordinal), $"{label} 仍有未替换占位符");
    foreach (var banned in new[] { "Chen" + "Qianyu", "chen_" + "qianyu", "textures/" + "chen/" })
        Assert(!text.Contains(banned, StringComparison.OrdinalIgnoreCase), $"{label} 仍有角色专用内容");
}

static string Decode(byte[] bytes)
{
    try { return new UTF8Encoding(false, true).GetString(bytes); }
    catch (DecoderFallbackException) { return Encoding.GetEncoding(932).GetString(bytes); }
}

static string FindRepositoryRoot()
{
    var current = new DirectoryInfo(AppContext.BaseDirectory);
    while (current is not null)
    {
        if (File.Exists(Path.Combine(current.FullName, "EndfieldMME", "internal", "endfield_shader.hlsl")))
            return current.FullName;
        current = current.Parent;
    }
    throw new DirectoryNotFoundException("找不到包含 EndfieldMME 的仓库根目录。");
}

static void Assert(bool condition, string message)
{
    if (!condition) throw new InvalidOperationException(message);
}
