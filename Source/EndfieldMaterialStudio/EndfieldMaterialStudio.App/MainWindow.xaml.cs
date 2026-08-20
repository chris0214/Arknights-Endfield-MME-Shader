using System.Collections.ObjectModel;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using EndfieldMaterialStudio.Core;
using Microsoft.Win32;

namespace EndfieldMaterialStudio.App;

public partial class MainWindow : Window
{
    private StudioProject? _project;
    private MaterialAssignment? _selectedMaterial;
    private bool _updatingEditor;
    private readonly ObservableCollection<MaterialAssignment> _materials = new();

    public MainWindow()
    {
        InitializeComponent();
        RoleCombo.ItemsSource = Enum.GetValues<MaterialRole>();
        EyeThroughParticipationCombo.ItemsSource = new[]
        {
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.Auto, "自动（按材质类型）"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.Ignore, "排除，不参与眼透"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.Iris, "虹膜 / 眼睛"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.Highlight, "眼睛高光"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.Sclera, "眼白"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.BrowLash, "眉毛 / 睫毛"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.HairDepth, "头发深度"),
            new KeyValuePair<EyeThroughParticipation, string>(EyeThroughParticipation.ShiftedDepth, "偏移深度")
        };
        BaseTextureModeCombo.ItemsSource = new[]
        {
            new KeyValuePair<PmxBaseTextureMode, string>(PmxBaseTextureMode.Inherit, "沿用 PMX 原贴图"),
            new KeyValuePair<PmxBaseTextureMode, string>(PmxBaseTextureMode.Override, "手动替换（写入输出 PMX）"),
            new KeyValuePair<PmxBaseTextureMode, string>(PmxBaseTextureMode.None, "无基础贴图")
        };
        MaterialsGrid.ItemsSource = _materials;
        RuntimePathBox.Text = FindRuntimeRoot() ?? string.Empty;
        MaterialEditor.IsEnabled = false;
        Log("新工具已启动。EndfieldMME 运行时只读，GUI 仅生成 FX 包装与 EMM。");
    }

    private void ImportPmx_Click(object sender, RoutedEventArgs e)
        => SelectPmx();

    private void BrowsePmx_Click(object sender, RoutedEventArgs e)
        => SelectPmx();

    private void SelectPmx()
    {
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Filter = "PMX 模型 (*.pmx)|*.pmx",
            Title = "选择普通 PMX 模型",
            InitialDirectory = ExistingDirectory(_project?.PmxPath)
        };
        if (dialog.ShowDialog() != true) return;
        var runtime = RuntimePathBox.Text;
        if (!Directory.Exists(runtime))
        {
            runtime = PickFolder("选择已验证的 EndfieldMME 文件夹") ?? string.Empty;
            if (!Directory.Exists(runtime)) return;
        }
        var output = Directory.Exists(OutputPathBox.Text)
            ? OutputPathBox.Text
            : Path.Combine(Path.GetDirectoryName(dialog.FileName)!, "Endfield_Output");
        try
        {
            SetProject(ProjectFactory.Create(dialog.FileName, runtime, output));
            Log($"已导入 PMX：{dialog.FileName}");
            Log("已按材质名称完成初始分类，请逐项确认右侧类型和贴图槽。");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void BrowseRuntime_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择已验证的 EndfieldMME 文件夹", RuntimePathBox.Text);
        if (selected is null) return;
        var errors = RuntimeContract.Validate(selected).Where(message => message.IsError).ToArray();
        if (errors.Length > 0)
        {
            ShowError(new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.ToString()))));
            return;
        }
        RuntimePathBox.Text = selected;
        if (_project is not null) _project.RuntimeRoot = selected;
        Log($"运行时目录：{selected}");
    }

    private void BrowseOutput_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择角色包输出目录", OutputPathBox.Text);
        if (selected is null) return;
        OutputPathBox.Text = selected;
        if (_project is not null) _project.OutputDirectory = selected;
        Log($"输出目录：{selected}");
    }

    private void OpenProject_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new Microsoft.Win32.OpenFileDialog { Filter = "Endfield Studio 工程 (*.endfieldstudio.json)|*.endfieldstudio.json|JSON (*.json)|*.json" };
        if (dialog.ShowDialog() != true) return;
        try
        {
            SetProject(ProjectFactory.Load(dialog.FileName));
            Log($"已打开工程：{dialog.FileName}");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void SaveProject_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        var dialog = new Microsoft.Win32.SaveFileDialog
        {
            Filter = "Endfield Studio 工程 (*.endfieldstudio.json)|*.endfieldstudio.json",
            FileName = ProjectFactory.SanitizeProjectName(_project!.ProjectName) + ".endfieldstudio.json"
        };
        if (dialog.ShowDialog() != true) return;
        try
        {
            ProjectFactory.Save(_project!, dialog.FileName);
            Log($"工程已保存：{dialog.FileName}");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void AutoMatch_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) return;
        var modelDirectory = Path.GetDirectoryName(_project.PmxPath)!;
        var roots = new List<string> { modelDirectory };
        var otherTex = Directory.GetDirectories(modelDirectory, "*", SearchOption.TopDirectoryOnly)
            .FirstOrDefault(path => Path.GetFileName(path).Contains("other tex", StringComparison.OrdinalIgnoreCase));
        if (otherTex is not null) roots.Add(otherTex);
        var runtimeTextures = Path.Combine(_project.RuntimeRoot, "textures");
        if (Directory.Exists(runtimeTextures)) roots.Add(runtimeTextures);
        try
        {
            var matchMessages = TextureAutoMatcher.Assign(_project, overwriteExisting: true, roots.ToArray());
            RefreshEditor();
            MaterialsGrid.Items.Refresh();
            Log($"自动匹配完成。扫描目录：{string.Join("；", roots)}");
            if (matchMessages.Count > 0)
                Log(string.Join(Environment.NewLine, matchMessages));
            WriteValidation();
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void GenerateEyeThrough_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        try
        {
            var result = EyeThroughProjectService.Ensure(_project!);
            RefreshMaterialCollection();
            PmxPathBox.Text = _project!.PmxPath;
            Log($"眼透派生 PMX：{(result.Created ? "新建" : "复用")} {result.DerivedPmxPath}");
            foreach (var overlay in result.Overlays)
                Log($"  #{overlay.OverlayMaterialIndex} {overlay.OverlayMaterialName} <- #{overlay.SourceMaterialIndex} {overlay.SourceMaterialName}");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void Validate_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        WriteValidation();
    }

    private void GeneratePackage_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        try
        {
            WriteValidation();
            var result = new PackageBuilder().Build(_project!);
            Log($"生成完成：{result.OutputDirectory}");
            Log($"EMM：{result.EmmPath}");
            Log($"模型：{result.ModelPath}");
            StatusText.Text = "角色包生成完成。";
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void MaterialsGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        _selectedMaterial = MaterialsGrid.SelectedItem as MaterialAssignment;
        RefreshEditor();
    }

    private void RoleCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null || RoleCombo.SelectedItem is not MaterialRole role) return;
        _selectedMaterial.Role = role;
        MaterialsGrid.Items.Refresh();
        SelectedMaterialHint.Text = $"#{_selectedMaterial.MaterialIndex} · {role}";
    }

    private void EyeThroughParticipation_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null ||
            EyeThroughParticipationCombo.SelectedValue is not EyeThroughParticipation participation) return;
        _selectedMaterial.EyeThrough = participation;
        _selectedMaterial.Role = participation switch
        {
            EyeThroughParticipation.Iris => MaterialRole.Iris,
            EyeThroughParticipation.Highlight => MaterialRole.EyeHighlight,
            EyeThroughParticipation.Sclera => MaterialRole.EyeWhite,
            EyeThroughParticipation.BrowLash => MaterialRole.BrowLash,
            _ => _selectedMaterial.Role
        };
        RoleCombo.SelectedItem = _selectedMaterial.Role;
        MaterialsGrid.Items.Refresh();
        SelectedMaterialHint.Text = $"#{_selectedMaterial.MaterialIndex} · {_selectedMaterial.Role} · 眼透：{participation}";
    }

    private void BaseTextureMode_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null ||
            BaseTextureModeCombo.SelectedValue is not PmxBaseTextureMode mode) return;
        _selectedMaterial.BaseTextureMode = mode;
        _selectedMaterial.UsePmxBaseTexture = mode == PmxBaseTextureMode.Inherit;
        if (mode == PmxBaseTextureMode.Inherit)
            _selectedMaterial.Textures.Base = _selectedMaterial.PmxBaseTexture;
        UpdateBaseTextureControls(mode);
        MaterialsGrid.Items.Refresh();
    }

    private void TextureBox_Changed(object sender, TextChangedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null || sender is not TextBox box || box.Tag is not string slot) return;
        SetTexture(_selectedMaterial.Textures, slot, NullIfWhiteSpace(box.Text));
    }

    private void BrowseTexture_Click(object sender, RoutedEventArgs e)
    {
        if (_selectedMaterial is null || sender is not Button button || button.Tag is not string slot) return;
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Filter = "贴图|*.png;*.jpg;*.jpeg;*.bmp;*.tga;*.dds|所有文件|*.*",
            InitialDirectory = Path.GetDirectoryName(_project?.PmxPath ?? string.Empty)
        };
        if (dialog.ShowDialog() != true) return;
        SetTexture(_selectedMaterial.Textures, slot, dialog.FileName);
        if (slot == "Base")
        {
            _selectedMaterial.BaseTextureMode = PmxBaseTextureMode.Override;
            _selectedMaterial.UsePmxBaseTexture = false;
        }
        RefreshEditor();
    }

    private void ClearMaterialTextures_Click(object sender, RoutedEventArgs e)
    {
        if (_selectedMaterial is null) return;
        var basePath = _selectedMaterial.Textures.Base;
        _selectedMaterial.Textures = new TextureSlots { Base = basePath };
        RefreshEditor();
    }

    private void ProjectHeader_Changed(object sender, RoutedEventArgs e) => CommitHeader();
    private void ProjectHeader_Changed(object sender, TextChangedEventArgs e) => CommitHeader();

    private bool CommitHeader()
    {
        if (_project is null) return false;
        if (!string.IsNullOrWhiteSpace(RuntimePathBox.Text)) _project.RuntimeRoot = Path.GetFullPath(RuntimePathBox.Text);
        if (!string.IsNullOrWhiteSpace(OutputPathBox.Text)) _project.OutputDirectory = Path.GetFullPath(OutputPathBox.Text);
        _project.ProjectName = string.IsNullOrWhiteSpace(ProjectNameBox.Text) ? "EndfieldCharacter" : ProjectNameBox.Text.Trim();
        _project.HeadBone = string.IsNullOrWhiteSpace(HeadBoneBox.Text) ? "頭" : HeadBoneBox.Text.Trim();
        _project.EnableEyeThrough = EyeThroughCheck.IsChecked == true;
        _project.GenerateDerivedPmx = DerivedPmxCheck.IsChecked == true;
        return true;
    }

    private void SetProject(StudioProject project)
    {
        _project = project;
        _selectedMaterial = null;
        PmxPathBox.Text = project.PmxPath;
        RuntimePathBox.Text = project.RuntimeRoot;
        OutputPathBox.Text = project.OutputDirectory;
        HeadBoneBox.Text = project.HeadBone;
        ProjectNameBox.Text = project.ProjectName;
        EyeThroughCheck.IsChecked = project.EnableEyeThrough;
        DerivedPmxCheck.IsChecked = project.GenerateDerivedPmx;
        RefreshMaterialCollection();
        StatusText.Text = $"已载入 {project.Materials.Count} 个 PMX 材质。";
        foreach (var message in ProjectValidator.ValidatePmxDependencies(project)
                     .Where(message => message.Code == "PMX_TEXTURE_FALLBACK"))
            Log(message.ToString());
    }

    private void RefreshMaterialCollection()
    {
        _materials.Clear();
        if (_project is not null)
            foreach (var material in _project.Materials.OrderBy(material => material.MaterialIndex)) _materials.Add(material);
        MaterialsGrid.SelectedIndex = _materials.Count > 0 ? 0 : -1;
    }

    private void RefreshEditor()
    {
        _updatingEditor = true;
        try
        {
            MaterialEditor.IsEnabled = _selectedMaterial is not null;
            if (_selectedMaterial is null)
            {
                SelectedMaterialTitle.Text = "选择一个材质";
                SelectedMaterialHint.Text = string.Empty;
                return;
            }
            var material = _selectedMaterial;
            SelectedMaterialTitle.Text = material.MaterialName;
            var pmxBaseState = material.PmxBaseTexture switch
            {
                null or "" => "无",
                var path when File.Exists(path) => path,
                var path when Directory.Exists(path) => $"{path}（这是文件夹，不能作为贴图）",
                var path => $"{path}（文件不存在）"
            };
            SelectedMaterialHint.Text = $"#{material.MaterialIndex} · {material.Role} · PMX Base: {pmxBaseState}";
            RoleCombo.SelectedItem = material.Role;
            EyeThroughParticipationCombo.SelectedValue = material.EyeThrough;
            BaseTextureModeCombo.SelectedValue = material.EffectiveBaseTextureMode;
            UpdateBaseTextureControls(material.EffectiveBaseTextureMode);
            BaseBox.Text = material.Textures.Base ?? string.Empty;
            NormalBox.Text = material.Textures.Normal ?? string.Empty;
            PropertyBox.Text = material.Textures.Property ?? string.Empty;
            RdBox.Text = material.Textures.Rd ?? string.Empty;
            RsBox.Text = material.Textures.Rs ?? string.Empty;
            LutBox.Text = material.Textures.Lut ?? string.Empty;
            SdfBox.Text = material.Textures.Sdf ?? string.Empty;
            StBox.Text = material.Textures.St ?? string.Empty;
            ColorMaskBox.Text = material.Textures.ColorMask ?? string.Empty;
            LipSpecularBox.Text = material.Textures.LipSpecular ?? string.Empty;
            HairLineBox.Text = material.Textures.HairLine ?? string.Empty;
        }
        finally
        {
            _updatingEditor = false;
        }
    }

    private void UpdateBaseTextureControls(PmxBaseTextureMode mode)
    {
        var canEdit = mode == PmxBaseTextureMode.Override;
        BaseBox.IsEnabled = canEdit;
        BaseBrowseButton.IsEnabled = canEdit;
    }

    private void WriteValidation()
    {
        if (_project is null) return;
        var messages = ProjectValidator.Validate(_project);
        if (messages.Count == 0)
        {
            Log("检查通过：材质绑定、必要贴图和运行时文件完整。", clear: true);
            StatusText.Text = "检查通过。";
            return;
        }
        Log(string.Join(Environment.NewLine, messages), clear: true);
        var errors = messages.Count(message => message.IsError);
        StatusText.Text = errors == 0 ? $"检查完成：{messages.Count} 条提示。" : $"检查失败：{errors} 个错误。";
    }

    private void Log(string message, bool clear = false)
    {
        if (clear) LogBox.Clear();
        LogBox.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}{Environment.NewLine}");
        LogBox.ScrollToEnd();
    }

    private void ShowError(Exception exception)
    {
        Log($"失败：{exception.Message}");
        StatusText.Text = "操作失败，请查看日志。";
        System.Windows.MessageBox.Show(this, exception.Message, "Endfield Material Studio", MessageBoxButton.OK, MessageBoxImage.Error);
    }

    private static string? FindRuntimeRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null)
        {
            foreach (var candidate in new[]
            {
                Path.Combine(current.FullName, "ShaderTemplate"),
                Path.Combine(current.FullName, "EndfieldMME"),
                current.FullName
            })
            {
                if (File.Exists(Path.Combine(candidate, "EndfieldHair_Final.fx")) &&
                    File.Exists(Path.Combine(candidate, "internal", "endfield_shader.hlsl"))) return candidate;
            }
            current = current.Parent;
        }
        return null;
    }

    private static string? PickFolder(string description, string? initialDirectory = null)
    {
        var dialog = new Microsoft.Win32.OpenFolderDialog
        {
            Title = description,
            Multiselect = false,
            InitialDirectory = Directory.Exists(initialDirectory) ? initialDirectory : null
        };
        return dialog.ShowDialog() == true ? dialog.FolderName : null;
    }

    private static string? ExistingDirectory(string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return null;
        if (Directory.Exists(path)) return path;
        var directory = Path.GetDirectoryName(path);
        return Directory.Exists(directory) ? directory : null;
    }

    private static string? NullIfWhiteSpace(string value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static void SetTexture(TextureSlots textures, string slot, string? value)
    {
        switch (slot)
        {
            case "Base": textures.Base = value; break;
            case "Normal": textures.Normal = value; break;
            case "Property": textures.Property = value; break;
            case "Rd": textures.Rd = value; break;
            case "Rs": textures.Rs = value; break;
            case "Lut": textures.Lut = value; break;
            case "Sdf": textures.Sdf = value; break;
            case "St": textures.St = value; break;
            case "ColorMask": textures.ColorMask = value; break;
            case "LipSpecular": textures.LipSpecular = value; break;
            case "HairLine": textures.HairLine = value; break;
        }
    }
}
