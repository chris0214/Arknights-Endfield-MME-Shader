using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using Microsoft.Win32;
using WinForms = System.Windows.Forms;
using EndfieldShaderTool.Core;
using CoreValidationResult = EndfieldShaderTool.Core.ValidationResult;

namespace EndfieldShaderTool.App;

public partial class MainWindow : Window
{
    private sealed record BlendModeOption(BlendMode Value, string Label)
    {
        public override string ToString() => Label;
    }

    private sealed record DomainOption(ShaderDomain Value, string Label)
    {
        public override string ToString() => Label;
    }

    private static readonly BlendModeOption[] BlendModeOptions =
    {
        new(BlendMode.Opaque, "不透明 (Opaque)"),
        new(BlendMode.AlphaZWrite, "半透明 (Alpha Blend + ZWrite)"),
        new(BlendMode.Overlay, "叠加层 (Alpha Blend，无 ZWrite)")
    };

    private static readonly DomainOption[] DomainOptions =
    {
        new(ShaderDomain.Face, "Face（面部）"),
        new(ShaderDomain.Hair, "Hair（头发）"),
        new(ShaderDomain.HairShadow, "HairShadow（发影）"),
        new(ShaderDomain.Skin, "Skin（皮肤）"),
        new(ShaderDomain.Cloth, "Cloth（衣服）"),
        new(ShaderDomain.Body, "Body（身体）"),
        new(ShaderDomain.Prop, "Prop（道具）"),
        new(ShaderDomain.Transparent, "Transparent（透明材质）"),
        new(ShaderDomain.Iris, "Iris（虹膜/瞳孔）"),
        new(ShaderDomain.EyeWhite, "EyeWhite（眼白）"),
        new(ShaderDomain.EyeHighlight, "EyeHighlight（眼部高光）"),
        new(ShaderDomain.BrowLash, "BrowLash（眉毛/睫毛）"),
        new(ShaderDomain.FaceParts, "FaceParts（面部部件）"),
        new(ShaderDomain.Mouth, "Mouth（口腔）"),
        new(ShaderDomain.EyeOverlay, "EyeOverlay（眼透覆盖）"),
        new(ShaderDomain.BrowOverlay, "BrowOverlay（眉毛覆盖）"),
        new(ShaderDomain.Hidden, "Hidden（隐藏材质）"),
        new(ShaderDomain.Overlay, "Overlay（叠加材质）"),
        new(ShaderDomain.Eye, "Eye（眼部通用）"),
        new(ShaderDomain.Emissive, "Emissive（自发光）"),
        new(ShaderDomain.Unassigned, "Unassigned（未分配）")
    };

    private EndfieldProject? _project;
    private MaterialProfile? _profile;
    private string? _projectPath;
    private readonly List<Action> _editorReaders = new();
    private TextBox? _profileNameBox;
    private ComboBox? _domainBox;
    private CheckBox? _pmxBaseBox;
    private CheckBox? _castShadowBox;
    private ComboBox? _headBoneBox;
    private readonly List<CheckBox> _materialBindingBoxes = new();
    private string? _lastGeneratedDirectory;
    private readonly DispatcherTimer _materialSelectionTimer;
    private bool _isApplyingMaterialSelection;
    private static readonly Dictionary<string, BitmapImage> PreviewCache = new(StringComparer.OrdinalIgnoreCase);

    public MainWindow()
    {
        InitializeComponent();
        _materialSelectionTimer = new DispatcherTimer(DispatcherPriority.Background)
        {
            Interval = TimeSpan.FromMilliseconds(80)
        };
        _materialSelectionTimer.Tick += MaterialSelectionTimer_Tick;
        TemplateText.Text = FindTemplateRoot() ?? string.Empty;
        OutputText.Text = GetDefaultOutputDirectory();
        FxcText.Text = FxcCompiler.Find() ?? string.Empty;
        Log("Endfield Shader Tool 已启动。选择 ShaderTemplate 和 PMX 后点击“导入 PMX”。");
    }

    private void ChooseTemplate_Click(object sender, RoutedEventArgs e)
    {
        var path = PickFolder();
        if (path is not null) TemplateText.Text = path;
    }

    private void ChoosePmx_Click(object sender, RoutedEventArgs e)
    {
        var path = PickPmxFile(PmxText.Text);
        if (path is not null) PmxText.Text = path;
    }

    private void ChooseOutput_Click(object sender, RoutedEventArgs e)
    {
        var path = PickFolder();
        if (path is not null) OutputText.Text = path;
    }

    private void ChooseFxc_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog { Filter = "DirectX FX Compiler|fxc.exe|程序|*.exe" };
        if (dialog.ShowDialog() == true) FxcText.Text = dialog.FileName;
    }

    private void ImportPmx_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            var previousProject = _project;
            var pmxPath = PmxText.Text.Trim();
            if (ProjectService.ShouldPromptForPmxSelection(pmxPath, previousProject?.PmxPath))
            {
                var selectedPath = PickPmxFile(pmxPath);
                if (selectedPath is null) return;
                pmxPath = selectedPath;
                PmxText.Text = selectedPath;
            }
            if (!Directory.Exists(TemplateText.Text))
            {
                ChooseTemplate_Click(sender, e);
                if (!Directory.Exists(TemplateText.Text)) return;
            }
            var roleName = string.IsNullOrWhiteSpace(RoleText.Text)
                ? Path.GetFileNameWithoutExtension(pmxPath)
                : RoleText.Text.Trim();

            _profile = null;
            _editorReaders.Clear();
            _lastGeneratedDirectory = null;
            _project = ProjectService.CreateFromModel(TemplateText.Text, pmxPath, roleName);
            RoleText.Text = _project.RoleName;
            GenerateEmmCheck.IsChecked = _project.GenerateEmm;
            EyeThroughCheck.IsChecked = _project.IncludeEyeThrough;
            PostProcessingCheck.IsChecked = _project.IncludePostProcessing;
            _projectPath = null;
            RefreshMaterialGrid();
            Log($"已导入 {Path.GetFileName(pmxPath)}：{_project.Model?.Materials.Count ?? 0} 个材质，追加 UV：{_project.Model?.AdditionalUvCount ?? 0}。");
        }
        catch (Exception ex) { ShowError("导入 PMX 失败", ex); }
    }

    private static string? PickPmxFile(string? currentPath)
    {
        var dialog = new OpenFileDialog
        {
            Title = "选择要导入的 PMX 模型",
            Filter = "PMX 模型|*.pmx|所有文件|*.*",
            CheckFileExists = true,
            RestoreDirectory = true
        };
        if (!string.IsNullOrWhiteSpace(currentPath))
        {
            try
            {
                var fullPath = Path.GetFullPath(currentPath);
                var directory = Path.GetDirectoryName(fullPath);
                if (Directory.Exists(directory)) dialog.InitialDirectory = directory;
                dialog.FileName = Path.GetFileName(fullPath);
            }
            catch (Exception ex) when (ex is ArgumentException or NotSupportedException or PathTooLongException)
            {
                // Leave the dialog at its default location for malformed text input.
            }
        }
        return dialog.ShowDialog() == true ? dialog.FileName : null;
    }

    private void OpenProject_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog { Filter = "Endfield 工程|*.endfieldproject.json|JSON|*.json" };
        if (dialog.ShowDialog() != true) return;
        try
        {
            _project = ProjectService.Load(dialog.FileName);
            _projectPath = dialog.FileName;
            TemplateText.Text = _project.TemplateRoot;
            PmxText.Text = _project.PmxPath;
            RoleText.Text = _project.RoleName;
            GenerateEmmCheck.IsChecked = _project.GenerateEmm;
            EyeThroughCheck.IsChecked = _project.IncludeEyeThrough;
            PostProcessingCheck.IsChecked = _project.IncludePostProcessing;
            var projectDirectory = Path.GetDirectoryName(dialog.FileName)!;
            OutputText.Text = Path.GetFullPath(_project.TemplateRoot).Equals(Path.GetFullPath(projectDirectory), StringComparison.OrdinalIgnoreCase)
                ? Directory.GetParent(projectDirectory)?.FullName ?? projectDirectory
                : projectDirectory;
            RefreshMaterialGrid();
            Log($"已打开工程：{dialog.FileName}");
        }
        catch (Exception ex) { ShowError("打开工程失败", ex); }
    }

    private void SaveProject_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) return;
        try
        {
            CommitEditor();
            CommitProjectHeader();
            if (string.IsNullOrWhiteSpace(_projectPath))
            {
                var dialog = new SaveFileDialog { Filter = "Endfield 工程|*.endfieldproject.json", FileName = $"{_project.RoleSlug}.endfieldproject.json" };
                if (dialog.ShowDialog() != true) return;
                _projectPath = dialog.FileName;
            }
            ProjectService.Save(_project, _projectPath);
            Log($"工程已保存：{_projectPath}");
        }
        catch (Exception ex) { ShowError("保存工程失败", ex); }
    }

    private void AddPreset_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null)
        {
            Log("请先导入 PMX 或打开工程。");
            return;
        }

        CommitEditor();
        var material = new PmxMaterialInfo { Index = -1, Name = "Custom Material" };
        var profile = MaterialDefaults.Create(material, ShaderDomain.Cloth, _project.TemplateRoot);
        ProjectService.SetBindings(profile, Array.Empty<MaterialBinding>());
        MaterialDefaults.AssignTemplateTextures(profile, _project.TemplateRoot);
        profile.ProfileName = UniqueProfileName("custom_material");
        profile.MaterialName = material.Name;
        _project.Profiles.Add(profile);
        RefreshMaterialGrid();
        MaterialsGrid.SelectedItem = profile;
        Log($"已添加预设：{profile.ProfileName}。请在右侧选择 Shader 类型和贴图。");
    }

    private void CopyPreset_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null || _profile is null)
        {
            Log("请先选择要复制的材质预设。");
            return;
        }

        CommitEditor();
        var copy = ProjectService.CloneProfile(_profile);
        copy.ProfileName = UniqueProfileName(_profile.ProfileName + "_copy");
        ProjectService.SetBindings(copy, Array.Empty<MaterialBinding>());
        _project.Profiles.Add(copy);
        RefreshMaterialGrid();
        MaterialsGrid.SelectedItem = copy;
        Log($"已复制材质球：{copy.ProfileName}。参数和贴图已复制，请在右侧勾选它要绑定的 PMX 材质。");
    }

    private void MergePresets_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) return;
        var selected = MaterialsGrid.SelectedItems.Cast<MaterialProfile>()
            .OrderBy(x => _project.Profiles.IndexOf(x))
            .ToArray();
        if (selected.Length < 2)
        {
            Log("请在左侧按 Ctrl 或 Shift 多选至少两个材质球，再点击“合并所选”。");
            return;
        }

        CommitEditor();
        var target = selected[0];
        var differingStates = selected.Any(x => x.Domain != target.Domain ||
                                                 x.Parameters.BlendMode != target.Parameters.BlendMode ||
                                                 x.Parameters.CullMode != target.Parameters.CullMode ||
                                                 x.Parameters.UseAlphaClip != target.Parameters.UseAlphaClip);
        if (differingStates)
        {
            var answer = MessageBox.Show(
                $"所选材质球的 Shader 类型或透明/Cull 状态不同。\n合并后将保留“{target.ProfileName}”的全部参数和贴图，是否继续？",
                "合并材质球", MessageBoxButton.YesNo, MessageBoxImage.Warning);
            if (answer != MessageBoxResult.Yes) return;
        }

        var bindings = selected.SelectMany(ProjectService.GetBindings).ToArray();
        ProjectService.SetBindings(target, bindings);
        foreach (var profile in selected.Skip(1)) _project.Profiles.Remove(profile);
        _profile = null;
        RefreshMaterialGrid();
        MaterialsGrid.SelectedItem = target;
        Log($"已合并 {selected.Length} 个材质球：现在由 {target.ProfileName} 绑定 {target.BindingCount} 个 PMX 材质，只生成一份 FX。");
    }

    private void UnmergePreset_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null || _profile is null)
        {
            Log("请先选择一个已经合并的材质球。");
            return;
        }

        CommitEditor();
        var bindingCount = ProjectService.GetBindings(_profile).Count;
        if (bindingCount <= 1)
        {
            Log($"{_profile.ProfileName} 只绑定了一个 PMX 材质，不需要解除合并。");
            return;
        }

        var answer = MessageBox.Show(
            $"将“{_profile.ProfileName}”拆成 {bindingCount} 个独立材质球。\n每个材质球都会继承当前贴图和全部 Shader 参数，是否继续？",
            "解除合并", MessageBoxButton.YesNo, MessageBoxImage.Question);
        if (answer != MessageBoxResult.Yes) return;

        var originalName = _profile.ProfileName;
        var splitProfiles = ProjectService.SplitProfileBindings(_project, _profile);
        _profile = null;
        RefreshMaterialGrid();
        MaterialsGrid.SelectedItem = splitProfiles[0];
        Log($"已解除合并 {originalName}：生成 {splitProfiles.Count} 个独立材质球，现在可以分别调整贴图和参数。");
    }

    private void DeletePreset_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null || _profile is null)
        {
            Log("请先选择要删除的材质预设。");
            return;
        }
        if (_project.Profiles.Count == 1)
        {
            Log("至少保留一个材质预设。");
            return;
        }
        var answer = MessageBox.Show($"确定删除预设“{_profile.ProfileName}”吗？\n不会修改 PMX 或 ShaderTemplate 模板。", "删除预设", MessageBoxButton.YesNo, MessageBoxImage.Warning);
        if (answer != MessageBoxResult.Yes) return;

        CommitEditor();
        var removed = _profile;
        _project.Profiles.Remove(removed);
        _profile = null;
        RefreshMaterialGrid();
        Log($"已删除预设：{removed.ProfileName}。");
    }

    private string UniqueProfileName(string requested)
    {
        if (_project is null) return ProjectService.Slugify(requested);
        var baseName = ProjectService.Slugify(requested);
        var candidate = baseName;
        var suffix = 2;
        var used = _project.Profiles.Select(x => ProjectService.Slugify(x.ProfileName)).ToHashSet(StringComparer.OrdinalIgnoreCase);
        while (used.Contains(candidate)) candidate = $"{baseName}_{suffix++:00}";
        return candidate;
    }

    private void Generate_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) { Log("请先导入 PMX。"); return; }
        try
        {
            CommitEditor();
            CommitProjectHeader();
            EnsureEyeThroughDerivedModel();
            var generator = new PackageGenerator();
            var result = generator.Generate(_project, OutputText.Text, overwrite: true);
            LogValidation(result.Validation);
            if (result.Validation.IsValid)
            {
                _lastGeneratedDirectory = result.OutputDirectory;
                Log($"生成完成：{result.OutputDirectory}\n文件数：{result.GeneratedFiles.Count}");
                MessageBox.Show($"角色包生成完成。\n{result.OutputDirectory}", "Endfield Shader Tool", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
        catch (Exception ex) { ShowError("生成角色包失败", ex); }
    }

    private void EnsureEyeThroughDerivedModel()
    {
        if (_project is null || !_project.IncludeEyeThrough) return;

        var result = PmxEyeThroughDerivedModelBuilder.Ensure(_project);
        PmxEyeThroughDerivedModelBuilder.ApplyToProject(_project, result);
        PmxText.Text = _project.PmxPath;
        RefreshMaterialGrid();

        var status = result.Status switch
        {
            EyeThroughDerivedModelStatus.Created => "已生成",
            EyeThroughDerivedModelStatus.ReusedSibling => "已复用",
            _ => "已使用"
        };
        var overlayText = result.Overlays.Count == 0
            ? "当前 PMX 已具备覆盖材质"
            : string.Join("、", result.Overlays.Select(item =>
                $"#{item.OverlayMaterialIndex} {item.OverlayMaterialName} <- #{item.SourceMaterialIndex} {item.SourceMaterialName}"));
        Log($"眼透派生 PMX：{status} {Path.GetFileName(result.DerivedPmxPath)}。{overlayText}。原 PMX 未被修改。");
    }

    private void ExportProfile_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) { Log("请先导入 PMX。"); return; }
        if (_profile is null) { Log("请先在左侧选择要导出的材质预设。"); return; }
        try
        {
            CommitEditor();
            CommitProjectHeader();
            var profileName = _profile.ProfileName;
            var result = new PackageGenerator().GenerateSingleProfile(_project, _profile, OutputText.Text, overwrite: true);
            LogValidation(result.Validation);
            if (result.Validation.IsValid)
            {
                _lastGeneratedDirectory = result.OutputDirectory;
                Log($"单材质包导出完成：{result.OutputDirectory}\n预设：{profileName}\n文件数：{result.GeneratedFiles.Count}");
                MessageBox.Show($"当前材质预设已导出。\n{result.OutputDirectory}", "Endfield Shader Tool", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
        catch (Exception ex) { ShowError("导出当前材质失败", ex); }
    }

    private void Compile_Click(object sender, RoutedEventArgs e)
    {
        var directory = _lastGeneratedDirectory;
        if (string.IsNullOrWhiteSpace(directory) && _project is not null)
            directory = Path.Combine(OutputText.Text, _project.RoleSlug);
        if (string.IsNullOrWhiteSpace(directory) || !Directory.Exists(directory))
        {
            Log("还没有生成角色包。");
            return;
        }
        try
        {
            var staticValidation = ProjectValidator.ValidateGeneratedPackage(directory);
            LogValidation(staticValidation);
            if (!staticValidation.IsValid) { Log("静态验证失败，已停止 FXC 编译。"); return; }
            var fxc = File.Exists(FxcText.Text) ? FxcText.Text : FxcCompiler.Find();
            if (fxc is null) { Log("未找到 fxc.exe，已完成静态路径检查。"); return; }
            var packageSlug = Path.GetFileName(Path.TrimEndingDirectorySeparator(directory));
            var presetDirectory = Path.Combine(directory, "presets", packageSlug);
            var files = Directory.Exists(presetDirectory)
                ? Directory.GetFiles(presetDirectory, "*.fx", SearchOption.TopDirectoryOnly)
                : Directory.GetFiles(directory, "*.fx", SearchOption.AllDirectories);
            var results = FxcCompiler.CompileFiles(files, fxc);
            foreach (var result in results)
                Log($"{(result.Succeeded ? "PASS" : "FAIL")} {result.FilePath}\n{result.Output}");
            FxcCompiler.WritePackageValidationStatus(directory, results);
            Log(results.Count > 0 && results.All(x => x.Succeeded)
                ? "全部角色 FX 已通过 FXC 编译，FXC_UNVERIFIED 标记已移除。"
                : "存在 FXC 编译失败，角色包继续保留未验证标记。");
        }
        catch (Exception ex) { ShowError("编译检查失败", ex); }
    }

    private void OpenOutput_Click(object sender, RoutedEventArgs e)
    {
        var path = _lastGeneratedDirectory ?? OutputText.Text;
        if (!Directory.Exists(path)) return;
        Process.Start(new ProcessStartInfo("explorer.exe", $"\"{path}\"") { UseShellExecute = true });
    }

    private void ClearLog_Click(object sender, RoutedEventArgs e)
    {
        LogText.Clear();
        StatusText.Text = "就绪";
    }

    private void MaterialsGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_isApplyingMaterialSelection) return;
        _materialSelectionTimer.Stop();
        _materialSelectionTimer.Start();
    }

    private void MaterialSelectionTimer_Tick(object? sender, EventArgs e)
    {
        _materialSelectionTimer.Stop();
        if (_isApplyingMaterialSelection || _project is null) return;

        _isApplyingMaterialSelection = true;
        try
        {
            CommitEditor(refreshGrid: false);
            var selected = MaterialsGrid.SelectedItems.Cast<MaterialProfile>().ToArray();
            _profile = selected.Length == 1 ? selected[0] : null;
            SelectedMaterialText.Text = _profile is null
                ? selected.Length > 1 ? $"已选择 {selected.Length} 个材质球，点击“合并所选”" : "未选择材质球"
                : $"PMX #{_profile.MaterialIndexDisplay}  ·  {_profile.ProfileName}  ·  {DomainLabel(_profile.Domain)}";
            BuildEditor();
        }
        catch (Exception ex)
        {
            // Selection changes are user-driven and can happen while WPF is
            // recycling DataGrid rows. Keep a malformed preview/material from
            // terminating the whole editor process.
            Log($"切换材质球失败：{ex.Message}");
        }
        finally
        {
            _isApplyingMaterialSelection = false;
        }
    }

    private void Editor_Drop(object sender, DragEventArgs e)
    {
        if (_profile is null || !e.Data.GetDataPresent(DataFormats.FileDrop)) return;
        var files = ExpandDroppedFiles(e.Data);
        AutoAssignTextures(files);
        BuildEditor();
        Log($"已尝试自动匹配 {files.Length} 张贴图，请检查各贴图槽。");
        e.Handled = true;
    }

    private static string[] ExpandDroppedFiles(IDataObject data)
    {
        if (!data.GetDataPresent(DataFormats.FileDrop)) return Array.Empty<string>();
        var dropped = (string[])data.GetData(DataFormats.FileDrop)!;
        return dropped.SelectMany(path => File.Exists(path)
                ? new[] { path }
                : Directory.Exists(path) ? Directory.GetFiles(path, "*", SearchOption.AllDirectories) : Array.Empty<string>())
            .Where(File.Exists)
            .ToArray();
    }

    private void RefreshMaterialGrid()
    {
        MaterialsGrid.ItemsSource = null;
        MaterialsGrid.ItemsSource = _project?.Profiles;
        var profileCount = _project?.Profiles.Count ?? 0;
        var materialCount = _project?.Model?.Materials.Count ?? 0;
        MaterialCountText.Text = $"{profileCount} 球 / {materialCount} 材质";
        SelectedMaterialText.Text = "未选择材质球";
        if (_project?.Profiles.Count > 0) MaterialsGrid.SelectedIndex = 0;
    }

    private void BuildEditor()
    {
        _editorReaders.Clear();
        EditorPanel.Children.Clear();
        _headBoneBox = null;
        _materialBindingBoxes.Clear();
        if (_profile is null)
        {
            EditorPanel.Children.Add(new TextBlock { Text = MaterialsGrid.SelectedItems.Count > 1 ? "已多选材质球。点击上方“合并所选”，它们将共用一套贴图、参数和 FX。" : "请从左侧选择一个材质球。", Foreground = System.Windows.Media.Brushes.LightGray, Margin = new Thickness(4), TextWrapping = TextWrapping.Wrap });
            return;
        }

        _profileNameBox = new TextBox { Text = _profile.ProfileName, Margin = new Thickness(0, 0, 0, 8), Padding = new Thickness(5) };
        AddLabeledControl("FX 预设名", _profileNameBox);

        if (_project?.Model is not null)
        {
            var bindingExpander = new Expander
            {
                Header = $"绑定 PMX 材质（{_profile.BindingCount}）",
                IsExpanded = true,
                Foreground = System.Windows.Media.Brushes.White,
                Margin = new Thickness(0, 0, 0, 8)
            };
            var bindingPanel = new StackPanel();
            var bound = ProjectService.GetBindings(_profile).Select(x => x.MaterialIndex).ToHashSet();
            foreach (var material in _project.Model.Materials)
            {
                var check = new CheckBox
                {
                    Content = $"#{material.Index:00}  {material.Name}    {material.TexturePath ?? "(无基础贴图)"}",
                    IsChecked = bound.Contains(material.Index),
                    Tag = material,
                    Margin = new Thickness(2, 3, 2, 3),
                    ToolTip = $"Sphere: {material.SphereTexturePath ?? "(无)"}；追加 UV: {material.AdditionalUvCount}"
                };
                _materialBindingBoxes.Add(check);
                bindingPanel.Children.Add(check);
            }
            bindingExpander.Content = new ScrollViewer
            {
                Content = bindingPanel,
                MaxHeight = 210,
                VerticalScrollBarVisibility = ScrollBarVisibility.Auto,
                Padding = new Thickness(4)
            };
            EditorPanel.Children.Add(bindingExpander);
        }
        _domainBox = new ComboBox
        {
            ItemsSource = DomainOptions,
            SelectedItem = DomainOptions.First(option => option.Value == _profile.Domain),
            Margin = new Thickness(0, 0, 0, 8)
        };
        _domainBox.SelectionChanged += (_, _) =>
        {
            if (_domainBox.SelectedItem is not DomainOption option || option.Value == _profile.Domain) return;
            var domain = option.Value;
            CommitEditor();
            _profile.Domain = domain;
            _profile.Parameters = MaterialDefaults.CreateParameters(domain);
            _profile.CastExcellentShadow = domain is ShaderDomain.Skin or ShaderDomain.Hair or ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Transparent;
            _profile.UsePmxSphereMap = domain is ShaderDomain.Hair or ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Transparent
                && !string.IsNullOrWhiteSpace(_profile.PmxSphereTexturePath);
            _profile.Parameters.UsePmxSphere = _profile.UsePmxSphereMap;
            if (_project is not null) MaterialDefaults.AssignTemplateTextures(_profile, _project.TemplateRoot);
            MaterialDefaults.ConfigureFeatureFlags(_profile);
            BuildEditor();
        };
        AddLabeledControl("材质域", _domainBox);
        _pmxBaseBox = new CheckBox { Content = "使用 PMX MATERIALTEXTURE 作为基础色", IsChecked = _profile.UsePmxBaseTexture, Foreground = System.Windows.Media.Brushes.White, Margin = new Thickness(0, 0, 0, 4) };
        _castShadowBox = new CheckBox
        {
            Content = "参与 ZMD 几何阴影投影",
            IsChecked = _profile.CastExcellentShadow,
            IsEnabled = _profile.Domain != ShaderDomain.Emissive,
            ToolTip = _profile.Domain == ShaderDomain.Emissive ? "纯自发光材质默认不投射角色阴影。" : null,
            Foreground = System.Windows.Media.Brushes.White,
            Margin = new Thickness(0, 0, 0, 8)
        };
        EditorPanel.Children.Add(_pmxBaseBox);
        EditorPanel.Children.Add(_castShadowBox);

        if (_profile.Domain is ShaderDomain.Iris or ShaderDomain.EyeWhite or ShaderDomain.EyeHighlight or ShaderDomain.BrowLash)
            EditorPanel.Children.Add(new TextBlock { Text = "眼透由顶部“眼透”工程开关统一控制。", Foreground = System.Windows.Media.Brushes.LightSkyBlue, Margin = new Thickness(0, 0, 0, 8), TextWrapping = TextWrapping.Wrap });

        var sources = ProjectService.GetBindings(_profile);
        if (sources.Count > 0)
            EditorPanel.Children.Add(new TextBlock { Text = $"当前材质球绑定 {sources.Count} 个 PMX 材质：{string.Join("、", sources.Select(x => $"#{x.MaterialIndex} {x.MaterialName}"))}\nUV1 共同可用：{(_profile.AdditionalUvCount >= 1 ? "是" : "否")}；UV1 XY 均非退化：{(_profile.HasUsableUv1 ? "是" : "否/未检测")}", Foreground = System.Windows.Media.Brushes.LightGray, Margin = new Thickness(0, 0, 0, 8), TextWrapping = TextWrapping.Wrap });

        if (_profile.Domain == ShaderDomain.Face)
        {
            _headBoneBox = new ComboBox
            {
                IsEditable = true,
                ItemsSource = _project?.Model?.BoneNames,
                Text = _project?.HeadBone ?? "頭",
                Margin = new Thickness(0, 0, 0, 8)
            };
            AddLabeledControl("头骨名称", _headBoneBox);
        }

        var textureExpander = new Expander { Header = "Endfield 贴图槽（可拖入文件自动匹配）", IsExpanded = true, Foreground = System.Windows.Media.Brushes.White, Margin = new Thickness(0, 0, 0, 8) };
        var texturePanel = new StackPanel();
        textureExpander.Content = texturePanel;
        AddTextureSlot(texturePanel, "基础色 Base / Diffuse", _profile.Textures.Base, "base");
        switch (_profile.Domain)
        {
            case ShaderDomain.Face:
                AddTextureSlot(texturePanel, "面部 RD（漫反射/阴影）", _profile.Textures.Rd, "rd");
                AddTextureSlot(texturePanel, "面部 LUT", _profile.Textures.Lut, "lut");
                AddTextureSlot(texturePanel, "面部 SDF", _profile.Textures.Sdf, "sdf");
                AddTextureSlot(texturePanel, "面部 ColorMask / ST", _profile.Textures.ColorMask, "color_mask");
                AddTextureSlot(texturePanel, "面部 ST", _profile.Textures.St, "st");
                AddTextureSlot(texturePanel, "嘴唇高光 Lip Highlight（可选）", _profile.Textures.LipSpecular, "lip_specular");
                break;
            case ShaderDomain.Hair:
                AddTextureSlot(texturePanel, "法线 Normal / HN", _profile.Textures.Normal, "normal");
                AddTextureSlot(texturePanel, "属性 Property", _profile.Textures.Property, "property");
                AddTextureSlot(texturePanel, "RD（漫反射）", _profile.Textures.Rd, "rd");
                AddTextureSlot(texturePanel, "RS（高光/粗糙度）", _profile.Textures.Rs, "rs");
                AddTextureSlot(texturePanel, "ST（高光/遮罩）", _profile.Textures.St, "st");
                AddTextureSlot(texturePanel, "HairLine", _profile.Textures.HairLine, "hair_line");
                break;
            case ShaderDomain.Skin:
                AddTextureSlot(texturePanel, "法线 Normal", _profile.Textures.Normal, "normal");
                AddTextureSlot(texturePanel, "RD（皮肤漫反射）", _profile.Textures.Rd, "rd");
                AddTextureSlot(texturePanel, "LUT（皮肤阴影）", _profile.Textures.Lut, "lut");
                break;
            case ShaderDomain.Cloth:
                AddTextureSlot(texturePanel, "法线 Normal", _profile.Textures.Normal, "normal");
                AddTextureSlot(texturePanel, "属性 MRO / Property", _profile.Textures.Property, "property");
                AddTextureSlot(texturePanel, "RD（衣服漫反射）", _profile.Textures.Rd, "rd");
                AddTextureSlot(texturePanel, "RS（高光/粗糙度）", _profile.Textures.Rs, "rs");
                AddTextureSlot(texturePanel, "LUT（衣服色调，可选）", _profile.Textures.Lut, "lut");
                AddTextureSlot(texturePanel, "MATCAP 05", _profile.Textures.Matcap05, "matcap05");
                AddTextureSlot(texturePanel, "MATCAP 07 / 手动 LOD", _profile.Textures.Matcap07, "matcap07");
                break;
            case ShaderDomain.Iris:
                AddTextureSlot(texturePanel, "MATCAP 05（可选）", _profile.Textures.Matcap05, "matcap05");
                AddTextureSlot(texturePanel, "MATCAP 07（可选）", _profile.Textures.Matcap07, "matcap07");
                break;
            case ShaderDomain.Body:
            case ShaderDomain.Prop:
            case ShaderDomain.Transparent:
                AddTextureSlot(texturePanel, "法线 Normal", _profile.Textures.Normal, "normal");
                AddTextureSlot(texturePanel, "属性 MRO / Property", _profile.Textures.Property, "property");
                AddTextureSlot(texturePanel, "RD", _profile.Textures.Rd, "rd");
                AddTextureSlot(texturePanel, "RS", _profile.Textures.Rs, "rs");
                AddTextureSlot(texturePanel, "LUT", _profile.Textures.Lut, "lut");
                AddTextureSlot(texturePanel, "MATCAP 05", _profile.Textures.Matcap05, "matcap05");
                AddTextureSlot(texturePanel, "MATCAP 07", _profile.Textures.Matcap07, "matcap07");
                break;
        }
        var import = new Button { Content = "从文件夹自动匹配", Padding = new Thickness(8, 4, 8, 4), Margin = new Thickness(0, 4, 0, 0) };
        import.Click += (_, _) => ImportTextureFolder();
        texturePanel.Children.Add(import);
        EditorPanel.Children.Add(textureExpander);

        var basic = new Expander { Header = "Endfield 基础参数", IsExpanded = true, Foreground = System.Windows.Media.Brushes.White, Margin = new Thickness(0, 0, 0, 8) };
        var basicPanel = new StackPanel();
        basic.Content = basicPanel;
        var blendModeBox = AddBlendMode(basicPanel, _profile.Parameters.BlendMode);
        AddEnum(basicPanel, "Cull Mode", typeof(CullMode), value => _profile.Parameters.CullMode = (CullMode)value!, _profile.Parameters.CullMode);
        var alphaClipLabel = _profile.Domain == ShaderDomain.Hair
            ? "Alpha Clip（真实镂空发片）"
            : "Alpha Clip（镂空裁剪）";
        var alphaClipBox = AddBool(basicPanel, alphaClipLabel, nameof(ShaderParameters.UseAlphaClip), v => _profile.Parameters.UseAlphaClip = v, _profile.Parameters.UseAlphaClip);
        if (_profile.Domain == ShaderDomain.Hair)
            alphaClipBox.ToolTip = "终末地 Hair D.A 通常是材质/光照数据，不是透明度。仅当当前 Base Alpha 确实是覆盖遮罩时开启。";
        blendModeBox.SelectionChanged += (_, _) =>
        {
            if (blendModeBox.SelectedItem is BlendModeOption { Value: not BlendMode.Opaque })
                alphaClipBox.IsChecked = false;
        };
        AddFloat(basicPanel, "Alpha Cutoff", nameof(ShaderParameters.AlphaCutoff), v => _profile.Parameters.AlphaCutoff = v, _profile.Parameters.AlphaCutoff);
        if (_profile.Domain is ShaderDomain.Skin or ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Hair or ShaderDomain.Transparent)
        {
            AddBool(basicPanel, "使用法线 Normal", nameof(ShaderParameters.UseNormal), v => _profile.Parameters.UseNormal = v, _profile.Parameters.UseNormal);
            AddFloat(basicPanel, "法线强度", nameof(ShaderParameters.NormalStrength), v => _profile.Parameters.NormalStrength = v, _profile.Parameters.NormalStrength);
            AddFloat(basicPanel, "法线 Y 翻转（DX/GL）", nameof(ShaderParameters.NormalYSign), v => _profile.Parameters.NormalYSign = v, _profile.Parameters.NormalYSign);
            if (_profile.Domain == ShaderDomain.Skin)
            {
                basicPanel.Children.Add(new TextBlock
                {
                    Text = "Skin 法线默认关闭；在 MMD 控制器中用 SkinNormal 逐渐开启。",
                    Foreground = System.Windows.Media.Brushes.LightSkyBlue,
                    Margin = new Thickness(0, 2, 0, 6),
                    TextWrapping = TextWrapping.Wrap
                });
            }
        }
        if (_profile.Domain is ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Hair or ShaderDomain.Transparent or ShaderDomain.Body)
        {
            AddFloat(basicPanel, "Toon 阈值", nameof(ShaderParameters.ToonThreshold), v => _profile.Parameters.ToonThreshold = v, _profile.Parameters.ToonThreshold);
            AddFloat(basicPanel, "Toon 过渡柔和度", nameof(ShaderParameters.ToonSoftness), v => _profile.Parameters.ToonSoftness = v, _profile.Parameters.ToonSoftness);
            AddFloat(basicPanel, "暗部强度", nameof(ShaderParameters.RampShadowScale), v => _profile.Parameters.RampShadowScale = v, _profile.Parameters.RampShadowScale);
            AddFloat(basicPanel, "亮部强度", nameof(ShaderParameters.RampLightScale), v => _profile.Parameters.RampLightScale = v, _profile.Parameters.RampLightScale);
            AddColor(basicPanel, "Ambient Color", typeof(ShaderParameters).GetProperty(nameof(ShaderParameters.AmbientColor))!, _profile.Parameters);
            AddFloat(basicPanel, "环境光强度", nameof(ShaderParameters.AmbientStrength), v => _profile.Parameters.AmbientStrength = v, _profile.Parameters.AmbientStrength);
        }
        if (_profile.Domain is ShaderDomain.Skin or ShaderDomain.Face)
        {
            AddFloat(basicPanel, "Toon Threshold", nameof(ShaderParameters.ToonThreshold), v => _profile.Parameters.ToonThreshold = v, _profile.Parameters.ToonThreshold);
            AddFloat(basicPanel, "Toon Softness", nameof(ShaderParameters.ToonSoftness), v => _profile.Parameters.ToonSoftness = v, _profile.Parameters.ToonSoftness);
            AddColor(basicPanel, "环境光颜色", typeof(ShaderParameters).GetProperty(nameof(ShaderParameters.AmbientColor))!, _profile.Parameters);
            AddFloat(basicPanel, "环境光强度", nameof(ShaderParameters.AmbientStrength), v => _profile.Parameters.AmbientStrength = v, _profile.Parameters.AmbientStrength);
        }
        if (_profile.Domain is ShaderDomain.Cloth or ShaderDomain.Body or ShaderDomain.Prop or ShaderDomain.Transparent)
        {
            AddBool(basicPanel, "启用 MATCAP", nameof(ShaderParameters.UseMatcap), v => _profile.Parameters.UseMatcap = v, _profile.Parameters.UseMatcap);
            AddFloat(basicPanel, "MATCAP 强度", nameof(ShaderParameters.MatcapStrength), v => _profile.Parameters.MatcapStrength = v, _profile.Parameters.MatcapStrength);
            AddFloat(basicPanel, "MATCAP LOD 强度", nameof(ShaderParameters.MatcapLodScale), v => _profile.Parameters.MatcapLodScale = v, _profile.Parameters.MatcapLodScale);
            AddBool(basicPanel, "使用 FGD 微高光 LUT", nameof(ShaderParameters.UseFgdLut), v => _profile.Parameters.UseFgdLut = v, _profile.Parameters.UseFgdLut);
            AddBool(basicPanel, "启用雨水湿润效果", nameof(ShaderParameters.EnableRain), v => _profile.Parameters.EnableRain = v, _profile.Parameters.EnableRain);
            AddFloat(basicPanel, "最大雨量（默认 0）", nameof(ShaderParameters.RainMaximum), v => _profile.Parameters.RainMaximum = v, _profile.Parameters.RainMaximum);
            AddFloat(basicPanel, "高光强度", nameof(ShaderParameters.SpecularStrength), v => _profile.Parameters.SpecularStrength = v, _profile.Parameters.SpecularStrength);
            AddFloat(basicPanel, "宽高光强度", nameof(ShaderParameters.SpecularBroadStrength), v => _profile.Parameters.SpecularBroadStrength = v, _profile.Parameters.SpecularBroadStrength);
            AddBool(basicPanel, "启用自发光", nameof(ShaderParameters.UseEmission), v => _profile.Parameters.UseEmission = v, _profile.Parameters.UseEmission);
            AddColor(basicPanel, "自发光颜色", typeof(ShaderParameters).GetProperty(nameof(ShaderParameters.EmissionColor))!, _profile.Parameters);
            AddFloat(basicPanel, "自发光强度", nameof(ShaderParameters.EmissionStrength), v => _profile.Parameters.EmissionStrength = v, _profile.Parameters.EmissionStrength);
        }
        if (_profile.Domain == ShaderDomain.Iris)
        {
            AddBool(basicPanel, "MATCAP 05", nameof(ShaderParameters.UseMatcap05), v => _profile.Parameters.UseMatcap05 = v, _profile.Parameters.UseMatcap05);
            AddBool(basicPanel, "MATCAP 07", nameof(ShaderParameters.UseMatcap07), v => _profile.Parameters.UseMatcap07 = v, _profile.Parameters.UseMatcap07);
        }
        if (_profile.Domain == ShaderDomain.Emissive)
        {
            AddColor(basicPanel, "Emission Color", typeof(ShaderParameters).GetProperty(nameof(ShaderParameters.EmissionColor))!, _profile.Parameters);
            AddFloat(basicPanel, "Emission Strength", nameof(ShaderParameters.EmissionStrength), v => _profile.Parameters.EmissionStrength = v, _profile.Parameters.EmissionStrength);
            basicPanel.Children.Add(new TextBlock
            {
                Text = "不受灯光、Ramp、法线和阴影影响；在 MMD 中使用 EMS+ / EMS++ 提高亮度。",
                Foreground = System.Windows.Media.Brushes.LightSkyBlue,
                Margin = new Thickness(0, 2, 0, 6),
                TextWrapping = TextWrapping.Wrap
            });
        }
        if (_profile.Domain == ShaderDomain.Face)
        {
            AddBool(basicPanel, "Face SDF", nameof(ShaderParameters.UseSdf), v => _profile.Parameters.UseSdf = v, _profile.Parameters.UseSdf);
            AddFloat(basicPanel, "Face SDF Scale", nameof(ShaderParameters.FaceSdfScale), v => _profile.Parameters.FaceSdfScale = v, _profile.Parameters.FaceSdfScale);
            AddFloat(basicPanel, "Face Diffuse Strength", nameof(ShaderParameters.FaceDiffuseStrength), v => _profile.Parameters.FaceDiffuseStrength = v, _profile.Parameters.FaceDiffuseStrength);
        }
        if (_profile.Domain == ShaderDomain.Hair)
        {
            var hasUv1 = _profile.AdditionalUvCount >= 1;
            var hasHighlight = _profile.Textures.Highlight.IsSelected;
            var highlightStatus = hasUv1
                ? hasHighlight
                    ? _profile.HasUsableUv1
                        ? "Unity Highlight：已启用（追加 UV1）"
                        : "Unity Highlight：已启用（UV1 通道存在；坐标面积检查仅作提示）"
                    : "Unity Highlight：可用，选择 Highlight 贴图后自动启用"
                : "Unity Highlight：不可用（PMX 未声明追加 UV1，自动回退 UV0）";
            basicPanel.Children.Add(new TextBlock
            {
                Text = highlightStatus,
                Foreground = hasUv1 ? System.Windows.Media.Brushes.LightGreen : System.Windows.Media.Brushes.Gold,
                Margin = new Thickness(0, 2, 0, 6),
                TextWrapping = TextWrapping.Wrap
            });
            if (_profile.Parameters.UseHighlight)
            {
                AddFloat(basicPanel, "Unity Highlight Strength", nameof(ShaderParameters.HighlightStrength), v => _profile.Parameters.HighlightStrength = v, _profile.Parameters.HighlightStrength);
                AddColor(basicPanel, "Unity Highlight Color", typeof(ShaderParameters).GetProperty(nameof(ShaderParameters.HighlightColor))!, _profile.Parameters);
            }
            AddEnum(basicPanel, "Hair 高光风格", typeof(HairSpecularStyle), value => _profile.Parameters.HairSpecularStyle = (HairSpecularStyle)value!, _profile.Parameters.HairSpecularStyle);
            AddColor(basicPanel, "Rim Color", typeof(ShaderParameters).GetProperty(nameof(ShaderParameters.RimColor))!, _profile.Parameters);
            AddFloat(basicPanel, "Rim Strength", nameof(ShaderParameters.RimStrength), v => _profile.Parameters.RimStrength = v, _profile.Parameters.RimStrength);
            AddFloat(basicPanel, "Rim Power", nameof(ShaderParameters.RimPower), v => _profile.Parameters.RimPower = v, _profile.Parameters.RimPower);
        }
        if (_profile.Domain is not (ShaderDomain.Face or ShaderDomain.Emissive))
            AddFloat(basicPanel, "Self Shadow Strength", nameof(ShaderParameters.SelfShadowStrength), v => _profile.Parameters.SelfShadowStrength = v, _profile.Parameters.SelfShadowStrength);
        EditorPanel.Children.Add(basic);

        if (_profile.Domain != ShaderDomain.Emissive)
        {
            var advanced = new Expander { Header = "Endfield 高级参数（少用）", IsExpanded = false, Foreground = System.Windows.Media.Brushes.White };
            var advancedPanel = new StackPanel();
            advanced.Content = advancedPanel;
            BuildAdvancedControls(advancedPanel);
            EditorPanel.Children.Add(advanced);
        }
    }

    private void BuildAdvancedControls(Panel panel)
    {
        if (_profile is null) return;
        var p = _profile.Parameters;
        var basicProperties = BasicPropertyNames(_profile.Domain);
        foreach (var property in typeof(ShaderParameters).GetProperties(BindingFlags.Instance | BindingFlags.Public))
        {
            if (_profile.Domain is ShaderDomain.Skin or ShaderDomain.Face && property.Name is
                nameof(ShaderParameters.UseRamp) or nameof(ShaderParameters.RampRow) or
                nameof(ShaderParameters.RampRows) or nameof(ShaderParameters.RampBlendStrength) or
                nameof(ShaderParameters.UseSkinBrdfControl)) continue;
            if (property.Name is nameof(ShaderParameters.UsePmxSphere) or nameof(ShaderParameters.UseExternalBase)
                or nameof(ShaderParameters.HairUvSet) or nameof(ShaderParameters.UseHighlight)
                || basicProperties.Contains(property.Name)) continue;
            if (property.PropertyType == typeof(bool)) AddBool(panel, Friendly(property.Name), property.Name, value => property.SetValue(p, value), (bool)property.GetValue(p)!);
            else if (property.PropertyType == typeof(float)) AddFloat(panel, Friendly(property.Name), property.Name, value => property.SetValue(p, value), (float)property.GetValue(p)!);
            else if (property.PropertyType.IsEnum) AddEnum(panel, Friendly(property.Name), property.PropertyType, value => property.SetValue(p, value), property.GetValue(p)!);
            else if (property.PropertyType == typeof(ColorValue)) AddColor(panel, Friendly(property.Name), property, p);
        }
    }

    private static HashSet<string> BasicPropertyNames(ShaderDomain domain)
    {
        var names = new HashSet<string>(StringComparer.Ordinal)
        {
            nameof(ShaderParameters.BlendMode), nameof(ShaderParameters.CullMode),
            nameof(ShaderParameters.UseAlphaClip), nameof(ShaderParameters.AlphaCutoff),
            nameof(ShaderParameters.SelfShadowStrength)
        };
        if (domain is ShaderDomain.Skin or ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Hair or ShaderDomain.Transparent)
        {
            names.Add(nameof(ShaderParameters.UseNormal));
            names.Add(nameof(ShaderParameters.NormalStrength));
            names.Add(nameof(ShaderParameters.NormalYSign));
        }
        if (domain is ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Hair or ShaderDomain.Transparent)
        {
            names.UnionWith(new[]
            {
                nameof(ShaderParameters.UseRamp), nameof(ShaderParameters.RampRow), nameof(ShaderParameters.RampRows), nameof(ShaderParameters.RampScale),
                nameof(ShaderParameters.ToonThreshold), nameof(ShaderParameters.ToonSoftness),
                nameof(ShaderParameters.RampShadowScale), nameof(ShaderParameters.RampLightScale),
                nameof(ShaderParameters.RampBlendStrength), nameof(ShaderParameters.AmbientColor),
                nameof(ShaderParameters.AmbientStrength), nameof(ShaderParameters.UseMatcap),
                nameof(ShaderParameters.MatcapStrength), nameof(ShaderParameters.MatcapLodScale),
                nameof(ShaderParameters.UseFgdLut), nameof(ShaderParameters.EnableRain),
                nameof(ShaderParameters.RainMaximum), nameof(ShaderParameters.SpecularStrength),
                nameof(ShaderParameters.SpecularBroadStrength), nameof(ShaderParameters.UseEmission),
                nameof(ShaderParameters.EmissionColor), nameof(ShaderParameters.EmissionStrength)
            });
        }
        if (domain is ShaderDomain.Skin or ShaderDomain.Face)
            names.UnionWith(new[]
            {
                nameof(ShaderParameters.ToonThreshold), nameof(ShaderParameters.ToonSoftness),
                nameof(ShaderParameters.AmbientColor), nameof(ShaderParameters.AmbientStrength)
            });
        if (domain is ShaderDomain.Cloth or ShaderDomain.Prop or ShaderDomain.Transparent)
            names.UnionWith(new[]
            {
                nameof(ShaderParameters.UseMatcap), nameof(ShaderParameters.MatcapStrength), nameof(ShaderParameters.MatcapRScale),
                nameof(ShaderParameters.MatcapBScale), nameof(ShaderParameters.MatcapLodScale), nameof(ShaderParameters.UseEmission),
                nameof(ShaderParameters.EmissionColor), nameof(ShaderParameters.EmissionStrength)
            });
        if (domain == ShaderDomain.Emissive)
            names.UnionWith(new[]
            {
                nameof(ShaderParameters.EmissionColor), nameof(ShaderParameters.EmissionStrength)
            });
        if (domain == ShaderDomain.Face)
            names.UnionWith(new[]
            {
                nameof(ShaderParameters.UseSdf), nameof(ShaderParameters.FaceSdfScale),
                nameof(ShaderParameters.FaceDiffuseStrength)
            });
        if (domain == ShaderDomain.Iris)
            names.UnionWith(new[] { nameof(ShaderParameters.UseMatcap05), nameof(ShaderParameters.UseMatcap07) });
        if (domain is ShaderDomain.Iris or ShaderDomain.EyeWhite or ShaderDomain.EyeHighlight or ShaderDomain.BrowLash)
            names.Add(nameof(ShaderParameters.EnableEyeThrough));
        if (domain == ShaderDomain.Hair)
            names.UnionWith(new[] { nameof(ShaderParameters.HighlightStrength), nameof(ShaderParameters.HighlightColor), nameof(ShaderParameters.HairSpecularStyle), nameof(ShaderParameters.RimColor), nameof(ShaderParameters.RimStrength), nameof(ShaderParameters.RimPower) });
        return names;
    }

    private static string DomainLabel(ShaderDomain domain) =>
        DomainOptions.FirstOrDefault(option => option.Value == domain)?.Label ?? domain.ToString();

    private void AddTextureSlot(Panel panel, string label, TextureReference reference, string key)
    {
        var row = new Grid
        {
            Margin = new Thickness(0, 2, 0, 2),
            Background = System.Windows.Media.Brushes.Transparent,
            AllowDrop = true,
            ToolTip = $"可将单张贴图拖到整行任意位置，直接设置 {label}"
        };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(140) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(58) });
        row.Children.Add(new TextBlock { Text = label, Foreground = System.Windows.Media.Brushes.White, VerticalAlignment = VerticalAlignment.Center });
        var path = new TextBox { Text = reference.SourcePath ?? reference.PackagePath ?? string.Empty, IsReadOnly = true, Margin = new Thickness(4, 0, 4, 0), Padding = new Thickness(4) };
        Grid.SetColumn(path, 1); row.Children.Add(path);
        var preview = new Image { Width = 50, Height = 50, Stretch = System.Windows.Media.Stretch.Uniform, Margin = new Thickness(6, 0, 0, 0) };
        var browse = new Button { Content = "选择", Padding = new Thickness(8, 2, 8, 2) };
        browse.Click += (_, _) =>
        {
            var dialog = new OpenFileDialog { Filter = "贴图|*.png;*.jpg;*.jpeg;*.bmp;*.tga;*.dds|所有文件|*.*" };
            if (dialog.ShowDialog() != true) return;
            CommitEditor(refreshGrid: false);
            reference.SourcePath = dialog.FileName;
            reference.PackagePath = null;
            if (_profile is not null)
            {
                MaterialDefaults.ConfigureTextureSelection(_profile, key, selected: true);
                if (key.Equals("highlight", StringComparison.OrdinalIgnoreCase))
                    Log(_profile.Parameters.UseHighlight
                        ? "检测到追加 UV1，已自动启用 Unity Highlight。"
                        : "PMX 未声明追加 UV1，Highlight 不会启用。"
                    );
            }
            Log($"已设置 {label}：{dialog.FileName}");
            BuildEditor();
        };
        Grid.SetColumn(browse, 2); row.Children.Add(browse);
        var clear = new Button { Content = "清除", Padding = new Thickness(8, 2, 8, 2), Margin = new Thickness(4, 0, 0, 0) };
        clear.Click += (_, _) =>
        {
            CommitEditor(refreshGrid: false);
            reference.SourcePath = null;
            reference.PackagePath = null;
            if (_profile is not null) MaterialDefaults.ConfigureTextureSelection(_profile, key, selected: false);
            BuildEditor();
        };
        Grid.SetColumn(clear, 3); row.Children.Add(clear);
        var previewPath = ResolveTexturePreviewPath(reference);
        LoadPreview(preview, previewPath);
        if (previewPath is not null && (previewPath.EndsWith(".tga", StringComparison.OrdinalIgnoreCase) || previewPath.EndsWith(".dds", StringComparison.OrdinalIgnoreCase)))
            preview.ToolTip = "TGA/DDS 会随包使用，但 WPF 首版不提供缩略图预览。";
        Grid.SetColumn(preview, 4); row.Children.Add(preview);
        row.PreviewDragOver += (_, e) =>
        {
            e.Effects = e.Data.GetDataPresent(DataFormats.FileDrop) ? DragDropEffects.Copy : DragDropEffects.None;
            e.Handled = true;
        };
        row.PreviewDrop += (_, e) =>
        {
            var files = ExpandDroppedFiles(e.Data);
            if (files.Length == 1)
            {
                CommitEditor(refreshGrid: false);
                reference.SourcePath = files[0];
                reference.PackagePath = null;
                if (_profile is not null) MaterialDefaults.ConfigureTextureSelection(_profile, key, selected: true);
                Log($"已设置 {label}：{files[0]}");
                BuildEditor();
            }
            else if (files.Length > 1)
            {
                AutoAssignTextures(files);
                BuildEditor();
                Log($"检测到多张贴图，已自动匹配 {files.Length} 个文件，请检查各槽位。");
            }
            e.Handled = true;
        };
        panel.Children.Add(row);
    }

    private string? ResolveTexturePreviewPath(TextureReference reference)
    {
        if (!string.IsNullOrWhiteSpace(reference.SourcePath) && File.Exists(reference.SourcePath)) return reference.SourcePath;
        if (_project is null || string.IsNullOrWhiteSpace(reference.PackagePath)) return null;
        var path = Path.Combine(_project.TemplateRoot, reference.PackagePath.Replace('/', Path.DirectorySeparatorChar));
        return File.Exists(path) ? path : null;
    }

    private CheckBox AddBool(Panel panel, string label, string key, Action<bool> setter, bool value)
    {
        var check = new CheckBox { Content = label, IsChecked = value, Foreground = System.Windows.Media.Brushes.White, Margin = new Thickness(0, 2, 0, 2) };
        _editorReaders.Add(() => setter(check.IsChecked == true));
        panel.Children.Add(check);
        return check;
    }

    private void AddFloat(Panel panel, string label, string key, Action<float> setter, float value)
    {
        var row = new Grid { Margin = new Thickness(0, 2, 0, 2) };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(220) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(110) });
        row.Children.Add(new TextBlock { Text = label, Foreground = System.Windows.Media.Brushes.White, VerticalAlignment = VerticalAlignment.Center });
        var box = new TextBox { Text = value.ToString("0.######", CultureInfo.InvariantCulture), Padding = new Thickness(4) };
        Grid.SetColumn(box, 1); row.Children.Add(box);
        _editorReaders.Add(() => { if (float.TryParse(box.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed)) setter(parsed); });
        panel.Children.Add(row);
    }

    private void AddEnum(Panel panel, string label, Type type, Action<object?> setter, object value)
    {
        var row = new Grid { Margin = new Thickness(0, 2, 0, 2) };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(220) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(180) });
        row.Children.Add(new TextBlock { Text = label, Foreground = System.Windows.Media.Brushes.White, VerticalAlignment = VerticalAlignment.Center });
        var box = new ComboBox { ItemsSource = Enum.GetValues(type), SelectedItem = value };
        Grid.SetColumn(box, 1); row.Children.Add(box);
        _editorReaders.Add(() => setter(box.SelectedItem));
        panel.Children.Add(row);
    }

    private ComboBox AddBlendMode(Panel panel, BlendMode value)
    {
        var row = new Grid { Margin = new Thickness(0, 2, 0, 2) };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(220) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(260) });
        row.Children.Add(new TextBlock
        {
            Text = "透明模式",
            Foreground = System.Windows.Media.Brushes.White,
            VerticalAlignment = VerticalAlignment.Center
        });
        var box = new ComboBox
        {
            ItemsSource = BlendModeOptions,
            SelectedItem = BlendModeOptions.First(option => option.Value == value)
        };
        Grid.SetColumn(box, 1);
        row.Children.Add(box);
        _editorReaders.Add(() =>
        {
            if (box.SelectedItem is BlendModeOption option) _profile!.Parameters.BlendMode = option.Value;
        });
        panel.Children.Add(row);
        return box;
    }

    private void AddColor(Panel panel, string label, PropertyInfo property, ShaderParameters parameters)
    {
        var current = (ColorValue)property.GetValue(parameters)!;
        var row = new Grid { Margin = new Thickness(0, 2, 0, 2) };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(220) });
        for (var i = 0; i < 4; i++) row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(62) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(38) });
        row.Children.Add(new TextBlock { Text = label, Foreground = System.Windows.Media.Brushes.White, VerticalAlignment = VerticalAlignment.Center });
        var boxes = new[] { current.R, current.G, current.B, current.A }.Select(value => new TextBox { Text = value.ToString("0.######", CultureInfo.InvariantCulture), Padding = new Thickness(3), Margin = new Thickness(2, 0, 0, 0) }).ToArray();
        for (var i = 0; i < boxes.Length; i++) { Grid.SetColumn(boxes[i], i + 1); row.Children.Add(boxes[i]); }
        var swatch = new Border { Width = 28, Height = 22, BorderBrush = System.Windows.Media.Brushes.White, BorderThickness = new Thickness(1), Margin = new Thickness(6, 0, 0, 0) };
        Grid.SetColumn(swatch, 5);
        row.Children.Add(swatch);
        void UpdateSwatch()
        {
            var values = boxes.Select((box, index) => float.TryParse(box.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed) ? parsed : index == 3 ? 1f : 0f).ToArray();
            swatch.Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromScRgb(
                Math.Clamp(values[3], 0f, 1f), Math.Clamp(values[0], 0f, 1f), Math.Clamp(values[1], 0f, 1f), Math.Clamp(values[2], 0f, 1f)));
        }
        foreach (var box in boxes) box.TextChanged += (_, _) => UpdateSwatch();
        UpdateSwatch();
        _editorReaders.Add(() =>
        {
            var values = boxes.Select(x => float.TryParse(x.Text, NumberStyles.Float, CultureInfo.InvariantCulture, out var value) ? value : 1f).ToArray();
            property.SetValue(parameters, new ColorValue(values[0], values[1], values[2], values[3]));
        });
        panel.Children.Add(row);
    }

    private void AddLabeledControl(string label, Control control)
    {
        var row = new Grid { Margin = new Thickness(0, 0, 0, 4) };
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(140) });
        row.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
        row.Children.Add(new TextBlock { Text = label, Foreground = System.Windows.Media.Brushes.White, VerticalAlignment = VerticalAlignment.Center });
        Grid.SetColumn(control, 1); row.Children.Add(control);
        EditorPanel.Children.Add(row);
    }

    private void CommitEditor(bool refreshGrid = true)
    {
        if (_profile is null) return;
        foreach (var reader in _editorReaders) reader();
        if (_profileNameBox is not null) _profile.ProfileName = ProjectService.Slugify(_profileNameBox.Text);
        if (_domainBox?.SelectedItem is DomainOption option) _profile.Domain = option.Value;
        if (_pmxBaseBox is not null) _profile.UsePmxBaseTexture = _pmxBaseBox.IsChecked == true;
        if (_castShadowBox is not null) _profile.CastExcellentShadow = _castShadowBox.IsChecked == true;
        if (_pmxBaseBox is not null)
        {
            _profile.Parameters.UseExternalBase = !_profile.UsePmxBaseTexture;
        }
        if (_headBoneBox is not null && !string.IsNullOrWhiteSpace(_headBoneBox.Text) && _project is not null)
            _project.HeadBone = _headBoneBox.Text.Trim();
        if (_materialBindingBoxes.Count > 0)
            ProjectService.SetBindings(_profile, _materialBindingBoxes
                .Where(x => x.IsChecked == true)
                .Select(x => ProjectService.CreateBinding((PmxMaterialInfo)x.Tag)));
        MaterialDefaults.ConfigureHairHighlight(_profile);
        if (refreshGrid) MaterialsGrid.Items.Refresh();
    }

    private void CommitProjectHeader()
    {
        if (_project is null) return;
        _project.RoleName = RoleText.Text.Trim();
        _project.RoleSlug = ProjectService.Slugify(_project.RoleName);
        _project.TemplateRoot = TemplateText.Text;
        _project.PmxPath = PmxText.Text;
        _project.GenerateEmm = GenerateEmmCheck.IsChecked == true;
        _project.IncludeEyeThrough = EyeThroughCheck.IsChecked == true;
        _project.IncludePostProcessing = PostProcessingCheck.IsChecked == true;
    }

    private void ImportTextureFolder()
    {
        if (_profile is null) return;
        var folder = PickFolder();
        if (folder is null) return;
        AutoAssignTextures(DiscoverTextureFiles(folder));
        BuildEditor();
    }

    private static IEnumerable<string> DiscoverTextureFiles(string folder)
    {
        try
        {
            var otherTex = Directory.EnumerateDirectories(folder)
                .FirstOrDefault(path => string.Equals(Path.GetFileName(path), "other tex", StringComparison.OrdinalIgnoreCase));
            var source = otherTex ?? folder;
            var recursive = otherTex is not null
                || string.Equals(Path.GetFileName(folder), "other tex", StringComparison.OrdinalIgnoreCase);
            return Directory.EnumerateFiles(source, "*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly)
                .Where(TextureAutoMatcher.IsSupportedTextureFile)
                .ToArray();
        }
        catch (IOException) { return Array.Empty<string>(); }
        catch (UnauthorizedAccessException) { return Array.Empty<string>(); }
    }

    private void AutoAssignTextures(IEnumerable<string> files)
    {
        if (_profile is null) return;
        var matchResult = TextureAutoMatcher.Suggest(_profile.Domain, files.Where(File.Exists));
        var suggestions = matchResult.Matches.ToDictionary(pair => pair.Key, pair => pair.Value.SourcePath, StringComparer.OrdinalIgnoreCase);
        if (suggestions.Count == 0) return;
        var summary = string.Join(Environment.NewLine, suggestions.Select(pair => $"{pair.Key}: {Path.GetFileName(pair.Value)}"));
        if (matchResult.AmbiguousSlots.Count > 0)
            summary += $"\n\n以下槽位存在同优先级候选，已保留为空以避免错绑：{string.Join("、", matchResult.AmbiguousSlots)}";
        if (MessageBox.Show($"确认使用以下自动匹配结果吗？\n\n{summary}", "确认贴图匹配", MessageBoxButton.YesNo, MessageBoxImage.Question) != MessageBoxResult.Yes) return;
        CommitEditor(refreshGrid: false);
        var slots = new Dictionary<string, TextureReference>(StringComparer.OrdinalIgnoreCase)
        {
            ["Base"] = _profile.Textures.Base,
            ["Normal"] = _profile.Textures.Normal,
            ["Property"] = _profile.Textures.Property,
            ["RD"] = _profile.Textures.Rd,
            ["RS"] = _profile.Textures.Rs,
            ["LUT"] = _profile.Textures.Lut,
            ["SDF"] = _profile.Textures.Sdf,
            ["ST"] = _profile.Textures.St,
            ["ColorMask"] = _profile.Textures.ColorMask,
            ["LipSpecular"] = _profile.Textures.LipSpecular,
            ["HairLine"] = _profile.Textures.HairLine,
            ["Matcap05"] = _profile.Textures.Matcap05,
            ["Matcap07"] = _profile.Textures.Matcap07
        };
        foreach (var pair in suggestions)
        {
            if (!slots.TryGetValue(pair.Key, out var reference)) continue;
            reference.SourcePath = pair.Value;
            reference.PackagePath = null;
            MaterialDefaults.ConfigureTextureSelection(_profile, pair.Key, selected: true);
        }
        MaterialDefaults.ConfigureFeatureFlags(_profile);
        if (suggestions.ContainsKey("ST") && _profile.Domain == ShaderDomain.Hair)
            Log(_profile.Parameters.UseHighlight
                ? "已匹配 ST，并因 PMX 存在追加 UV1 自动启用头发高光。"
                : "已匹配 ST，但 PMX 未声明追加 UV1；生成时将自动关闭头发高光。"
            );
    }

    private static void LoadPreview(System.Windows.Controls.Image image, string? path)
    {
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path)) return;
        try
        {
            if (PreviewCache.TryGetValue(path, out var cached))
            {
                image.Source = cached;
                return;
            }
            var bitmap = new BitmapImage();
            bitmap.BeginInit(); bitmap.UriSource = new Uri(path); bitmap.DecodePixelWidth = 96; bitmap.CacheOption = BitmapCacheOption.OnLoad; bitmap.EndInit();
            bitmap.Freeze();
            PreviewCache[path] = bitmap;
            image.Source = bitmap;
        }
        catch { }
    }

    private void LogValidation(CoreValidationResult result)
    {
        foreach (var message in result.Messages) Log($"{(message.IsError ? "ERROR" : "WARN")} [{message.Code}] {message.Message}");
    }

    private void Log(string message)
    {
        LogText.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}{Environment.NewLine}");
        LogText.ScrollToEnd();
        StatusText.Text = message.Split('\n', StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? "就绪";
    }

    private void ShowError(string title, Exception ex)
    {
        Log($"{title}：{ex.Message}");
        MessageBox.Show(ex.Message, title, MessageBoxButton.OK, MessageBoxImage.Error);
    }

    private static string? PickFolder()
    {
        using var dialog = new WinForms.FolderBrowserDialog { Description = "选择目录" };
        return dialog.ShowDialog() == WinForms.DialogResult.OK ? dialog.SelectedPath : null;
    }

    private static string? FindTemplateRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null)
        {
            foreach (var candidate in new[]
            {
                current.FullName,
                Path.Combine(current.FullName, "ShaderTemplate")
            })
            {
                if (File.Exists(Path.Combine(candidate, "internal", "endfield_shader.hlsl")))
                    return candidate;
            }
            current = current.Parent;
        }
        return null;
    }

    private static string GetDefaultOutputDirectory()
    {
        var userProfile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var root = string.IsNullOrWhiteSpace(userProfile) ? Path.GetTempPath() : userProfile;
        return Path.Combine(root, "EndfieldMME_Generated");
    }

    private static string Friendly(string name)
    {
        var value = System.Text.RegularExpressions.Regex.Replace(name, "([a-z])([A-Z])", "$1 $2");
        return value.Replace("Pmx", "PMX").Replace("Kk", "Kajiya").Replace("Uv", "UV");
    }
}


