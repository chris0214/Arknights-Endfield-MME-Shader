using System.Text;
using System.Text.RegularExpressions;

namespace EndfieldMaterialStudio.Core;

/// <summary>
/// Rewrites only the DefaultEffect metadata in the packaged ZMD shadow host.
/// The authoritative runtime and the HgShadow rendering implementation remain untouched.
/// </summary>
public static class ZmdAutoRoutePatcher
{
    private static readonly (string Effect, int ExpectedCount)[] Targets =
    {
        ("ZMDshadow_ViewportMap.fxsub", 2),
        ("ZMDshadow_ShadowMap.fxsub", 1)
    };

    static ZmdAutoRoutePatcher() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    public static void PatchFile(string path)
    {
        var source = File.ReadAllBytes(path);
        var patched = Build(source);
        File.WriteAllBytes(path, patched);
    }

    public static byte[] Build(byte[] source)
    {
        var encoding = Encoding.GetEncoding(
            932,
            EncoderFallback.ExceptionFallback,
            DecoderFallback.ExceptionFallback);
        var text = encoding.GetString(source);
        var newline = text.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";

        foreach (var (effect, expectedCount) in Targets)
        {
            var legacyPattern =
                $"string\\s+DefaultEffect\\s*=\\s*\"self\\s*=\\s*hide;\"\\s*" +
                $"\"\\*\\s*=\\s*{Regex.Escape(effect)};\"\\s*;";
            var legacyCount = Regex.Matches(text, legacyPattern, RegexOptions.CultureInvariant).Count;
            if (legacyCount > 0)
            {
                text = Regex.Replace(
                    text,
                    legacyPattern,
                    _ => BuildRoutingBlock(effect, newline),
                    RegexOptions.CultureInvariant);
            }

            var routedRule = $"\"*.pmx = {effect};\"";
            var routedCount = Regex.Matches(text, Regex.Escape(routedRule), RegexOptions.CultureInvariant).Count;
            if (routedCount != expectedCount)
                throw new InvalidDataException($"ZMD 自动路由块数量异常：{effect}，期望 {expectedCount}，实际 {routedCount}。");
        }

        return encoding.GetBytes(text);
    }

    private static string BuildRoutingBlock(string effect, string newline) =>
        "string DefaultEffect =" + newline +
        "        \"self = hide;\"" + newline +
        "        \"*controller*.pmx = hide;\"" + newline +
        "        \"EndfieldEyeThrough*.x = hide;\"" + newline +
        "        \"EndfieldPost*.x = hide;\"" + newline +
        "        \"ZMDshadow*.x = hide;\"" + newline +
        $"        \"*.pmd = {effect};\"" + newline +
        $"        \"*.pmx = {effect};\"" + newline +
        "        \"*.x = hide;\"" + newline +
        "        \"* = hide;\"" + newline +
        "        ;";
}
