using System.Diagnostics;
using System.Text;

namespace EndfieldShaderTool.Core;

public sealed record FxcResult(string FilePath, bool Succeeded, string Output);

public static class FxcCompiler
{
    public static string? Find()
    {
        var candidates = new[]
        {
            Environment.GetEnvironmentVariable("FXC_PATH"),
            @"C:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\Utilities\bin\x86\fxc.exe",
            @"C:\Program Files (x86)\Windows Kits\10\bin\x64\fxc.exe",
            @"C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\fxc.exe"
        };
        return candidates.FirstOrDefault(path => !string.IsNullOrWhiteSpace(path) && File.Exists(path));
    }

    public static IReadOnlyList<FxcResult> CompileDirectory(string outputDirectory, string? executable = null)
        => CompileFiles(Directory.GetFiles(outputDirectory, "*.fx", SearchOption.AllDirectories), executable);

    public static void WritePackageValidationStatus(string packageDirectory, IReadOnlyList<FxcResult> results)
    {
        var unverified = Path.Combine(packageDirectory, "FXC_UNVERIFIED.txt");
        var validated = Path.Combine(packageDirectory, "FXC_VALIDATED.txt");
        if (results.Count > 0 && results.All(x => x.Succeeded))
        {
            if (File.Exists(unverified)) File.Delete(unverified);
            var lines = new[] { "All generated role FX files passed fxc.exe validation." }
                .Concat(results.Select(x => "PASS " + Path.GetRelativePath(packageDirectory, x.FilePath)));
            File.WriteAllLines(validated, lines, new UTF8Encoding(false));
            return;
        }

        if (File.Exists(validated)) File.Delete(validated);
        var report = new List<string> { "This package has not passed fxc.exe validation." };
        report.AddRange(results.Select(x => $"{(x.Succeeded ? "PASS" : "FAIL")} {Path.GetRelativePath(packageDirectory, x.FilePath)}\r\n{x.Output}"));
        File.WriteAllLines(unverified, report, new UTF8Encoding(false));
    }

    public static IReadOnlyList<FxcResult> CompileFiles(IEnumerable<string> files, string? executable = null)
    {
        executable ??= Find();
        if (string.IsNullOrWhiteSpace(executable) || !File.Exists(executable))
            throw new FileNotFoundException("找不到 fxc.exe。请安装 DirectX SDK 或在设置中指定 FXC_PATH。", executable);

        var inputFiles = files
            .Where(File.Exists)
            .Select(Path.GetFullPath)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
        if (inputFiles.Length == 0) return Array.Empty<FxcResult>();

        // Legacy fxc rejects Unicode search directories. Stage each package in an
        // ASCII-only temporary directory while keeping the original path in results.
        var stages = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var stagedFiles = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var file in inputFiles)
        {
            var root = FindPackageRoot(file);
            if (root is null)
            {
                // Standalone FX files can still be compiled when their path is ASCII.
                if (file.All(ch => ch < 128)) stagedFiles[file] = file;
                else stagedFiles[file] = StageStandalone(file);
                continue;
            }

            if (!stages.TryGetValue(root, out var stage))
            {
                stage = CreateStageDirectory();
                CopyDirectory(root, stage);
                stages[root] = stage;
            }
            stagedFiles[file] = Path.Combine(stage, Path.GetRelativePath(root, file));
        }

        var results = new List<FxcResult>();
        try
        {
            foreach (var file in inputFiles)
            {
                var stagedFile = stagedFiles[file];
                var output = Path.Combine(CreateStageDirectory(), "output.fxo");
                try
                {
                    var stagedPackageRoot = FindPackageRoot(stagedFile);
                    var start = new ProcessStartInfo(executable)
                    {
                        // Keep both the working directory and all shader arguments ASCII.
                        WorkingDirectory = Path.GetDirectoryName(stagedFile)!,
                        UseShellExecute = false,
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        CreateNoWindow = true,
                        StandardOutputEncoding = Encoding.Default,
                        StandardErrorEncoding = Encoding.Default
                    };
                    start.ArgumentList.Add("/nologo");
                    start.ArgumentList.Add("/Gec");
                    start.ArgumentList.Add("/T");
                    start.ArgumentList.Add("fx_5_0");
                    start.ArgumentList.Add("/Fo");
                    start.ArgumentList.Add(output);
                    start.ArgumentList.Add("/I");
                    start.ArgumentList.Add(Path.GetDirectoryName(stagedFile)!);
                    if (stagedPackageRoot is not null)
                    {
                        start.ArgumentList.Add("/I");
                        start.ArgumentList.Add(stagedPackageRoot);
                    }
                    start.ArgumentList.Add(stagedFile);
                    using var process = Process.Start(start) ?? throw new InvalidOperationException("无法启动 fxc.exe。");
                    var stdoutTask = process.StandardOutput.ReadToEndAsync();
                    var stderrTask = process.StandardError.ReadToEndAsync();
                    if (!process.WaitForExit(120000))
                    {
                        try { process.Kill(true); } catch { }
                        results.Add(new FxcResult(file, false, "fxc 超时（120 秒）。"));
                        continue;
                    }
                    Task.WaitAll(stdoutTask, stderrTask);
                    var stdout = stdoutTask.Result;
                    var stderr = stderrTask.Result;
                    results.Add(new FxcResult(file, process.ExitCode == 0, (stdout + Environment.NewLine + stderr).Trim()));
                }
                catch (Exception ex)
                {
                    results.Add(new FxcResult(file, false, ex.Message));
                }
                finally
                {
                    try
                    {
                        var outputRoot = Path.GetDirectoryName(output);
                        if (outputRoot is not null && Directory.Exists(outputRoot)) Directory.Delete(outputRoot, true);
                    }
                    catch { }
                }
            }
        }
        finally
        {
            foreach (var stage in stages.Values) TryDelete(stage);
            foreach (var staged in stagedFiles.Values.Where(x => !inputFiles.Contains(x, StringComparer.OrdinalIgnoreCase)))
            {
                var root = FindStageRoot(staged);
                if (root is not null) TryDelete(root);
            }
        }
        return results;
    }

    private static string? FindPackageRoot(string file)
    {
        var current = new DirectoryInfo(Path.GetDirectoryName(file)!);
        while (current is not null)
        {
            var internalDirectory = Path.Combine(current.FullName, "internal");
            if (File.Exists(Path.Combine(internalDirectory, "endfield_shader.hlsl")) ||
                File.Exists(Path.Combine(internalDirectory, "endfield_post.hlsl")))
                return current.FullName;
            current = current.Parent;
        }
        return null;
    }

    private static string CreateStageDirectory()
    {
        var baseDirectory = Path.GetTempPath();
        if (baseDirectory.Any(ch => ch >= 128)) baseDirectory = @"C:\tmp";
        Directory.CreateDirectory(baseDirectory);
        var path = Path.Combine(baseDirectory, "endfield_fxc_" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(path);
        return path;
    }

    private static string StageStandalone(string file)
    {
        var stage = CreateStageDirectory();
        File.Copy(file, Path.Combine(stage, Path.GetFileName(file)), true);
        return Path.Combine(stage, Path.GetFileName(file));
    }

    private static void CopyDirectory(string source, string destination)
    {
        foreach (var directory in Directory.GetDirectories(source, "*", SearchOption.AllDirectories))
            Directory.CreateDirectory(Path.Combine(destination, Path.GetRelativePath(source, directory)));
        foreach (var file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            var dest = Path.Combine(destination, Path.GetRelativePath(source, file));
            Directory.CreateDirectory(Path.GetDirectoryName(dest)!);
            File.Copy(file, dest, true);
        }
    }

    private static string? FindStageRoot(string path)
    {
        var current = new DirectoryInfo(Path.GetDirectoryName(path)!);
        while (current is not null)
        {
            if (current.Name.StartsWith("endfield_fxc_", StringComparison.OrdinalIgnoreCase)) return current.FullName;
            current = current.Parent;
        }
        return null;
    }

    private static void TryDelete(string path)
    {
        try { if (Directory.Exists(path)) Directory.Delete(path, true); } catch { }
    }
}


