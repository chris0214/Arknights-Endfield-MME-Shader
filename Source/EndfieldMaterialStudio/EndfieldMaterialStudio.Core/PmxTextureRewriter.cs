using System.Buffers.Binary;
using System.Text;

namespace EndfieldMaterialStudio.Core;

/// <summary>
/// Rewrites only PMX base-texture indices while preserving every other byte.
/// Replacement paths are appended to the texture table so the source model is
/// never modified and unrelated texture indices remain stable.
/// </summary>
public static class PmxTextureRewriter
{
    public static void Rewrite(
        string sourcePath,
        string destinationPath,
        IReadOnlyDictionary<int, string?> materialBaseTextures)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sourcePath);
        ArgumentException.ThrowIfNullOrWhiteSpace(destinationPath);
        ArgumentNullException.ThrowIfNull(materialBaseTextures);

        var sourceBytes = File.ReadAllBytes(sourcePath);
        var layout = ParseLayout(sourceBytes);
        var textures = layout.Textures.ToList();
        var textureIndices = textures
            .Select((path, index) => (Path: NormalizeTexturePath(path), Index: index))
            .GroupBy(item => item.Path, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(group => group.Key, group => group.First().Index, StringComparer.OrdinalIgnoreCase);
        var rewrittenIndices = new Dictionary<int, int>();

        foreach (var (materialIndex, replacementPath) in materialBaseTextures)
        {
            if ((uint)materialIndex >= layout.MaterialBaseIndexOffsets.Count)
                throw new InvalidDataException($"PMX 不包含材质 #{materialIndex}，无法替换基础贴图。");

            if (replacementPath is null)
            {
                rewrittenIndices[materialIndex] = -1;
                continue;
            }

            var normalized = NormalizeTexturePath(replacementPath);
            if (string.IsNullOrWhiteSpace(normalized) || Path.IsPathRooted(normalized))
                throw new InvalidDataException($"材质 #{materialIndex} 的输出贴图路径必须是安全的相对路径：{replacementPath}");
            if (normalized.Split('/', StringSplitOptions.RemoveEmptyEntries)
                .Any(part => part is "." or ".." || part.Contains(':')))
                throw new InvalidDataException($"材质 #{materialIndex} 的输出贴图路径不安全：{replacementPath}");

            if (!textureIndices.TryGetValue(normalized, out var textureIndex))
            {
                textureIndex = textures.Count;
                EnsureIndexCapacity(textureIndex, layout.TextureIndexSize);
                textures.Add(normalized);
                textureIndices[normalized] = textureIndex;
            }
            rewrittenIndices[materialIndex] = textureIndex;
        }

        using var output = new MemoryStream(sourceBytes.Length + textures.Sum(path => layout.Encoding.GetByteCount(path) + 4));
        output.Write(sourceBytes, 0, layout.TextureCountOffset);
        WriteInt32(output, textures.Count);
        foreach (var texture in textures) WriteText(output, layout.Encoding, texture);

        var tail = sourceBytes.AsSpan(layout.TextureDataEnd).ToArray();
        foreach (var (materialIndex, textureIndex) in rewrittenIndices)
        {
            var absoluteOffset = layout.MaterialBaseIndexOffsets[materialIndex];
            WriteIndex(tail.AsSpan(absoluteOffset - layout.TextureDataEnd, layout.TextureIndexSize), textureIndex, layout.TextureIndexSize);
        }
        output.Write(tail);

        var destination = Path.GetFullPath(destinationPath);
        Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
        File.WriteAllBytes(destination, output.ToArray());
        _ = PmxReader.Read(destination);
    }

    private static Layout ParseLayout(byte[] bytes)
    {
        var reader = new PmxBinaryReader(bytes);
        if (Encoding.ASCII.GetString(reader.ReadBytes(4)) != "PMX ")
            throw new PmxFormatException("文件不是 PMX 模型。");
        var version = reader.ReadSingle();
        if (version < 1.99f || version > 2.11f)
            throw new PmxFormatException($"不支持的 PMX 版本：{version}。");

        var headerSize = reader.ReadByte();
        var globals = reader.ReadBytes(headerSize);
        if (globals.Length < 8) throw new PmxFormatException("PMX 文件头长度无效。");
        var encoding = globals[0] == 0 ? Encoding.Unicode : Encoding.UTF8;
        var additionalUvCount = globals[1];
        var vertexIndexSize = globals[2];
        var textureIndexSize = globals[3];
        var boneIndexSize = globals[5];
        ValidateIndexSize(vertexIndexSize);
        ValidateIndexSize(textureIndexSize);
        ValidateIndexSize(boneIndexSize);

        for (var index = 0; index < 4; index++) _ = reader.ReadText(encoding);
        var vertexCount = ReadCount(reader, "顶点");
        for (var index = 0; index < vertexCount; index++) SkipVertex(reader, additionalUvCount, boneIndexSize);

        var surfaceIndexCount = ReadCount(reader, "面索引");
        reader.Skip(checked(surfaceIndexCount * vertexIndexSize));

        var textureCountOffset = reader.Position;
        var textureCount = ReadCount(reader, "贴图");
        var textures = new List<string>(textureCount);
        for (var index = 0; index < textureCount; index++) textures.Add(reader.ReadText(encoding));
        var textureDataEnd = reader.Position;

        var materialCount = ReadCount(reader, "材质");
        var materialBaseIndexOffsets = new List<int>(materialCount);
        for (var index = 0; index < materialCount; index++)
        {
            _ = reader.ReadText(encoding);
            _ = reader.ReadText(encoding);
            reader.Skip(16 + 12 + 4 + 12 + 1 + 16 + 4);
            materialBaseIndexOffsets.Add(reader.Position);
            reader.Skip(textureIndexSize * 2 + 1);
            var toonShared = reader.ReadByte();
            reader.Skip(toonShared == 0 ? textureIndexSize : 1);
            _ = reader.ReadText(encoding);
            _ = ReadCount(reader, "材质面索引");
        }

        return new Layout(
            encoding,
            textureIndexSize,
            textureCountOffset,
            textureDataEnd,
            textures,
            materialBaseIndexOffsets);
    }

    private static void SkipVertex(PmxBinaryReader reader, int additionalUvCount, int boneIndexSize)
    {
        reader.Skip(12 + 12 + 8 + additionalUvCount * 16);
        switch (reader.ReadByte())
        {
            case 0: reader.Skip(boneIndexSize); break;
            case 1: reader.Skip(boneIndexSize * 2 + 4); break;
            case 2 or 4: reader.Skip(boneIndexSize * 4 + 16); break;
            case 3: reader.Skip(boneIndexSize * 2 + 40); break;
            default: throw new PmxFormatException("PMX 包含未知的顶点权重类型。");
        }
        reader.Skip(4);
    }

    private static int ReadCount(PmxBinaryReader reader, string label)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > 10_000_000) throw new PmxFormatException($"PMX {label}数量无效。");
        return count;
    }

    private static void ValidateIndexSize(int size)
    {
        if (size is not (1 or 2 or 4)) throw new PmxFormatException("PMX 包含不支持的索引尺寸。");
    }

    private static void EnsureIndexCapacity(int index, int size)
    {
        var maximum = size switch { 1 => sbyte.MaxValue, 2 => short.MaxValue, 4 => int.MaxValue, _ => 0 };
        if (index > maximum)
            throw new InvalidDataException($"PMX 的 {size} 字节贴图索引无法容纳新增贴图（索引 {index}）。");
    }

    private static string NormalizeTexturePath(string path) => path.Trim().Replace('\\', '/');

    private static void WriteText(Stream stream, Encoding encoding, string value)
    {
        var bytes = encoding.GetBytes(value);
        WriteInt32(stream, bytes.Length);
        stream.Write(bytes);
    }

    private static void WriteInt32(Stream stream, int value)
    {
        Span<byte> bytes = stackalloc byte[sizeof(int)];
        BinaryPrimitives.WriteInt32LittleEndian(bytes, value);
        stream.Write(bytes);
    }

    private static void WriteIndex(Span<byte> destination, int value, int size)
    {
        switch (size)
        {
            case 1:
                destination[0] = unchecked((byte)(sbyte)value);
                break;
            case 2:
                BinaryPrimitives.WriteInt16LittleEndian(destination, checked((short)value));
                break;
            case 4:
                BinaryPrimitives.WriteInt32LittleEndian(destination, value);
                break;
            default:
                throw new PmxFormatException("PMX 包含不支持的贴图索引尺寸。");
        }
    }

    private sealed record Layout(
        Encoding Encoding,
        int TextureIndexSize,
        int TextureCountOffset,
        int TextureDataEnd,
        IReadOnlyList<string> Textures,
        IReadOnlyList<int> MaterialBaseIndexOffsets);
}
