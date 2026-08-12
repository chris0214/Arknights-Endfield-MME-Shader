using System.Text;
using EndfieldMaterialStudio.Core;

Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

var repositoryRoot = FindRepositoryRoot();
var runtime = Environment.GetEnvironmentVariable("ENDFIELD_MME_RUNTIME") ?? Path.Combine(repositoryRoot, "EndfieldMME");

foreach (var message in RuntimeContract.Validate(runtime)) Console.WriteLine(message);
Assert(RuntimeContract.Validate(runtime).All(message => !message.IsError), "EndfieldMME 运行时不完整");
RunTemplateSmokeTests();
RunRuntimeCopySmokeTest();
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
    AssertGeneratedText(FxTemplateEngine.BuildEyeCapture(captureProject, slots, captureProject.HeadBone), "EyeThrough Capture");
    var hairVisibility = FxTemplateEngine.BuildHairVisibilityCapture(captureProject);
    AssertGeneratedText(hairVisibility, "Hair Visibility Capture");
    Assert(hairVisibility.Contains("#define EF_HAIR_VISIBILITY_SUBSETS \"5\"", StringComparison.Ordinal),
        "Hair Visibility Capture 没有使用 Hair 材质索引");
    Assert(hairVisibility.Contains(
            "#define EF_HAIR_VISIBILITY_FACE_OCCLUDER_SUBSETS \"0,1,3\"",
            StringComparison.Ordinal),
        "Hair Visibility Capture 没有使用 Face/Iris/EyeWhite 遮挡索引");
}

void RunRuntimeCopySmokeTest()
{
    var output = Path.Combine(Path.GetTempPath(), "EndfieldRuntimeContract_" + Guid.NewGuid().ToString("N"));
    try
    {
        var copied = RuntimeContract.CopyRuntime(runtime, output);
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
