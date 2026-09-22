using System.Text;
using System.Text.RegularExpressions;

namespace EndfieldMaterialStudio.Core;

/// <summary>
/// Rewrites only the packaged eye-through host's DefaultEffect metadata.
/// The authoritative host, mask, and generated capture algorithms remain untouched.
/// </summary>
public static class EyeThroughAutoRoutePatcher
{
    private const string LegacyRule = "* = EndfieldEyeThrough_Mask.fxsub;";
    private const string TargetRule = "*Endfield*.pmx = EndfieldEyeThrough_Capture.fxsub;";
    private const string GenericPmxRule = "*.pmx = EndfieldEyeThrough_Mask.fxsub;";

    public static void PatchFile(string path)
    {
        var source = File.ReadAllBytes(path);
        File.WriteAllBytes(path, Build(source));
    }

    public static byte[] Build(byte[] source)
    {
        var encoding = new UTF8Encoding(false, true);
        var text = encoding.GetString(source);
        var newline = text.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";
        var legacyPattern =
            "string\\s+DefaultEffect\\s*=\\s*\"" +
            Regex.Escape(LegacyRule) +
            "\"\\s*;";
        var legacyCount = Regex.Matches(text, legacyPattern, RegexOptions.CultureInvariant).Count;

        if (legacyCount == 1)
        {
            text = Regex.Replace(
                text,
                legacyPattern,
                _ => BuildRoutingBlock(newline),
                RegexOptions.CultureInvariant);
        }

        ValidateRouting(text, legacyCount);
        return encoding.GetBytes(text);
    }

    public static void PatchFaceDepthFile(string path, string modelFileName, bool enabled)
    {
        var encoding = new UTF8Encoding(false, true);
        File.WriteAllText(path, BuildFaceDepthRouting(File.ReadAllText(path, encoding), modelFileName, enabled), encoding);
    }

    public static string BuildFaceDepthRouting(string text, string modelFileName, bool enabled)
    {
        if (string.IsNullOrWhiteSpace(modelFileName) || modelFileName.IndexOfAny(new[] { '*', '?', ';', '=', '"', '\r', '\n', '/', '\\' }) >= 0)
            throw new InvalidDataException("Face depth routing requires a literal PMX file name.");
        const string target = @"shared\s+texture2D\s+EndfieldFaceDepth_RT\s*:\s*OFFSCREENRENDERTARGET\s*<(?<body>[\s\S]*?)>;";
        var matches = Regex.Matches(text, target, RegexOptions.CultureInvariant);
        if (matches.Count != 1) throw new InvalidDataException("Expected one EndfieldFaceDepth_RT target.");
        const string effect = "string\\s+DefaultEffect\\s*=\\s*(?:\"[^\"]*\"\\s*)+;";
        var block = matches[0].Value;
        if (Regex.Matches(block, effect).Count != 1) throw new InvalidDataException("Expected one face-depth DefaultEffect.");
        var routing = enabled
            ? $"string DefaultEffect = \"{modelFileName} = EndfieldFaceDepth_Capture.fxsub;\" \"* = hide;\";"
            : "string DefaultEffect = \"* = hide;\";";
        var patched = Regex.Replace(block, effect, _ => routing);
        return text[..matches[0].Index] + patched + text[(matches[0].Index + matches[0].Length)..];
    }

    private static void ValidateRouting(string text, int legacyCount)
    {
        var targetCount = Count(text, $"\"{TargetRule}\"");
        var controllerCount = Count(text, "\"*controller*.pmx = hide;\"");
        var genericPmxCount = Count(text, $"\"{GenericPmxRule}\"");
        if (targetCount != 1 || controllerCount != 1 || genericPmxCount != 1)
        {
            throw new InvalidDataException(
                $"眼透自动路由块数量异常：旧规则 {legacyCount}，目标 {targetCount}，控制器 {controllerCount}，普通 PMX {genericPmxCount}。");
        }

        var controller = text.IndexOf("\"*controller*.pmx = hide;\"", StringComparison.Ordinal);
        var target = text.IndexOf($"\"{TargetRule}\"", StringComparison.Ordinal);
        var genericPmx = text.IndexOf($"\"{GenericPmxRule}\"", StringComparison.Ordinal);
        if (!(controller < target && target < genericPmx))
            throw new InvalidDataException("眼透自动路由顺序异常：控制器排除、派生 PMX Capture、普通 PMX Mask 必须依次出现。");
    }

    private static int Count(string text, string value) =>
        Regex.Matches(text, Regex.Escape(value), RegexOptions.CultureInvariant).Count;

    private static string BuildRoutingBlock(string newline) =>
        "string DefaultEffect =" + newline +
        "        \"self = hide;\"" + newline +
        "        \"*controller*.pmx = hide;\"" + newline +
        "        \"ZMDshadow*.x = hide;\"" + newline +
        "        \"EndfieldPost*.x = hide;\"" + newline +
        "        \"EndfieldEyeThrough*.x = hide;\"" + newline +
        $"        \"{TargetRule}\"" + newline +
        "        \"*.pmd = EndfieldEyeThrough_Mask.fxsub;\"" + newline +
        $"        \"{GenericPmxRule}\"" + newline +
        "        \"*.x = EndfieldEyeThrough_Mask.fxsub;\"" + newline +
        "        \"* = EndfieldEyeThrough_Mask.fxsub;\"" + newline +
        "        ;";
}
