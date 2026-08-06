using System.Buffers.Binary;
using System.Text;

namespace EndfieldShaderTool.Core;

public sealed class PmxMorphUpdateResult
{
    public required IReadOnlyList<string> MorphNames { get; init; }
    public required IReadOnlyList<string> AddedMorphNames { get; init; }
    public IReadOnlyList<string> RenamedMorphNames { get; init; } = [];
    public IReadOnlyList<string> RemovedMorphNames { get; init; } = [];
}

public static class PmxControllerMorphEditor
{
    public static readonly IReadOnlyList<string> EndfieldMorphNames =
    [
        "Bright+", "Bright++", "Bright-", "Dark+", "Dark++", "Dark-",
        "Saturation+", "Saturation++", "Saturation-", "Brightness+", "Brightness++", "Brightness-",
        "Exposure+", "Exposure++", "Exposure-",
        "SkinSaturation+", "SkinSaturation++", "SkinSaturation-",
        "SkinBrightness+", "SkinBrightness++", "SkinBrightness-",
        "SkinContrast+", "SkinContrast++", "SkinContrast-",
        "SkinTintR+", "SkinTintR++", "SkinTintR-", "SkinTintG+", "SkinTintG++", "SkinTintG-",
        "SkinTintB+", "SkinTintB++", "SkinTintB-", "SkinExposure+", "SkinExposure++", "SkinExposure-",
        "FaceSaturation+", "FaceSaturation++", "FaceSaturation-",
        "FaceBrightness+", "FaceBrightness++", "FaceBrightness-",
        "FaceContrast+", "FaceContrast++", "FaceContrast-",
        "FaceTintR+", "FaceTintR++", "FaceTintR-", "FaceTintG+", "FaceTintG++", "FaceTintG-",
        "FaceTintB+", "FaceTintB++", "FaceTintB-", "FaceExposure+", "FaceExposure++", "FaceExposure-",
        "HairSaturation+", "HairSaturation++", "HairSaturation-",
        "HairBrightness+", "HairBrightness++", "HairBrightness-",
        "HairContrast+", "HairContrast++", "HairContrast-",
        "HairTintR+", "HairTintR++", "HairTintR-", "HairTintG+", "HairTintG++", "HairTintG-",
        "HairTintB+", "HairTintB++", "HairTintB-", "HairExposure+", "HairExposure++", "HairExposure-",
        "SelfShadow+", "SelfShadow++", "SelfShadow-", "Highlight+", "Highlight++", "Highlight-",
        "LightIntensity+", "LightIntensity++", "LightIntensity-",
        "Specular+", "Specular++", "Specular-", "RimShadow+", "RimShadow++", "RimShadow-",
        "SkinNormal", "RampShadow+", "RampShadow++", "RampShadow-",
        "RampLight+", "RampLight++", "RampLight-",
        "MatcapAtlas+", "MatcapAtlas-",
        "Ramp+", "Ramp-", "Normal+", "Normal++", "Normal-", "Matcap+", "Matcap++", "Matcap-",
        "Emission+", "Emission++", "Emission-", "Ambient+", "Ambient++", "Ambient-",
        "EMS+", "EMS++",
        "FaceShadow+", "FaceShadow-", "Flicker",
        "PostExposure+", "PostExposure-", "PostBloom+", "PostBloom++",
        "PostThreshold+", "PostThreshold-", "PostScatter+", "PostScatter-",
        "PostContrast+", "PostContrast-", "PostSaturation+", "PostSaturation-",
        "PostCurve+", "PostCurve++", "PostBlur+", "PostBlur-", "Tonemap", "TonemapGT",
        "LUT+", "LUT++", "Dither+", "Dither++",
        "Temperature+", "Temperature-", "Tint+", "Tint-"
    ];

    public static readonly IReadOnlyList<string> CameraLightMorphNames =
    [
        "CameraLight", "LightYaw+", "LightYaw-", "LightYaw++", "LightYaw--",
        "LightPitch+", "LightPitch-"
    ];

    public static readonly IReadOnlyList<string> DeprecatedMorphNames =
    [
        "FaceSelfShadow", "FaceShadowOffset+", "FaceShadowOffset-", "SkinBRDF+", "SkinBRDF-",
        "PostBloom-", "PostCurve-"
    ];

    private static readonly IReadOnlyDictionary<string, string> RenamedMorphNames =
        new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["PostBloom-"] = "PostBloom++",
            ["PostCurve-"] = "PostCurve++"
        };

    public static IReadOnlyList<string> ReadMorphNames(string path)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("PMX controller was not found.", path);
        return Parse(File.ReadAllBytes(path)).MorphNames;
    }

    public static PmxMorphUpdateResult EnsureEndfieldMorphs(string path, bool includeCameraLight = false)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("PMX controller was not found.", path);
        var layout = Parse(File.ReadAllBytes(path));
        var legacyMorphNames = layout.MorphTextFields
            .Select(field => field.Value)
            .Where(name => name.StartsWith("Snow", StringComparison.Ordinal) && name.Length > "Snow".Length)
            .Distinct(StringComparer.Ordinal)
            .ToDictionary(name => name, name => name["Snow".Length..], StringComparer.Ordinal);
        var legacyRename = RenameMorphs(path, legacyMorphNames);
        var schemaRename = RenameMorphs(path, RenamedMorphNames);
        var removed = RemoveMorphs(path, DeprecatedMorphNames);
        var backendRemoved = includeCameraLight
            ? new PmxMorphUpdateResult { MorphNames = ReadMorphNames(path), AddedMorphNames = [] }
            : RemoveMorphs(path, CameraLightMorphNames);
        IReadOnlyList<string> requiredMorphNames = includeCameraLight
            ? EndfieldMorphNames.Concat(CameraLightMorphNames).ToArray()
            : EndfieldMorphNames;
        var ensured = EnsureMorphs(path, requiredMorphNames);
        return new PmxMorphUpdateResult
        {
            MorphNames = ensured.MorphNames,
            AddedMorphNames = ensured.AddedMorphNames,
            RenamedMorphNames = legacyRename.RenamedMorphNames.Concat(schemaRename.RenamedMorphNames).ToArray(),
            RemovedMorphNames = removed.RemovedMorphNames.Concat(backendRemoved.RemovedMorphNames).ToArray()
        };
    }

    public static PmxMorphUpdateResult RenameMorphs(string path, IReadOnlyDictionary<string, string> mappings)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("PMX controller was not found.", path);
        ArgumentNullException.ThrowIfNull(mappings);
        var bytes = File.ReadAllBytes(path);
        var layout = Parse(bytes);
        var existing = layout.MorphNames.ToHashSet(StringComparer.Ordinal);
        var replacements = layout.MorphTextFields
            .Where(field => mappings.TryGetValue(field.Value, out var replacement) &&
                            (!field.IsPrimary || !existing.Contains(replacement)))
            .Select(field => (Field: field, Replacement: mappings[field.Value]))
            .ToArray();
        if (replacements.Length == 0)
        {
            return new PmxMorphUpdateResult { MorphNames = layout.MorphNames, AddedMorphNames = [] };
        }

        using var output = new MemoryStream(bytes.Length);
        var cursor = 0;
        foreach (var replacement in replacements.OrderBy(x => x.Field.LengthOffset))
        {
            var field = replacement.Field;
            var encoded = layout.Encoding.GetBytes(replacement.Replacement);
            output.Write(bytes, cursor, field.LengthOffset - cursor);
            WriteInt32(output, encoded.Length);
            output.Write(encoded);
            cursor = field.DataOffset + field.ByteLength;
        }
        output.Write(bytes, cursor, bytes.Length - cursor);
        WriteFileAtomically(path, output.ToArray());

        var updatedNames = ReadMorphNames(path);
        return new PmxMorphUpdateResult
        {
            MorphNames = updatedNames,
            AddedMorphNames = [],
            RenamedMorphNames = replacements.Select(x => $"{x.Field.Value} -> {x.Replacement}").Distinct().ToArray()
        };
    }

    public static PmxMorphUpdateResult EnsureMorphs(string path, IEnumerable<string> morphNames)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("PMX controller was not found.", path);
        ArgumentNullException.ThrowIfNull(morphNames);

        var requested = morphNames
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Distinct(StringComparer.Ordinal)
            .ToArray();
        if (requested.Any(name => name.Any(ch => ch > 0x7f)))
            throw new ArgumentException("Controller morph names must be ASCII.", nameof(morphNames));

        var bytes = File.ReadAllBytes(path);
        var layout = Parse(bytes);
        var existing = layout.MorphNames.ToHashSet(StringComparer.Ordinal);
        var missing = requested.Where(name => !existing.Contains(name)).ToArray();
        if (missing.Length == 0)
        {
            return new PmxMorphUpdateResult
            {
                MorphNames = layout.MorphNames,
                AddedMorphNames = []
            };
        }
        if (layout.VertexCount <= 0)
            throw new PmxFormatException("The controller has no vertex available for a zero-offset control morph.");

        using var output = new MemoryStream(bytes.Length + missing.Sum(name => 32 + name.Length * 2));
        output.Write(bytes, 0, layout.MorphCountOffset);
        WriteInt32(output, checked(layout.MorphNames.Count + missing.Length));
        var originalMorphStart = layout.MorphCountOffset + sizeof(int);
        output.Write(bytes, originalMorphStart, layout.MorphDataEnd - originalMorphStart);
        foreach (var name in missing) WriteZeroOffsetVertexMorph(output, layout.Encoding, layout.VertexIndexSize, name);
        output.Write(bytes, layout.MorphDataEnd, bytes.Length - layout.MorphDataEnd);

        WriteFileAtomically(path, output.ToArray());

        var updatedNames = ReadMorphNames(path);
        foreach (var name in missing)
            if (!updatedNames.Contains(name, StringComparer.Ordinal))
                throw new PmxFormatException($"Failed to add controller morph '{name}'.");

        return new PmxMorphUpdateResult
        {
            MorphNames = updatedNames,
            AddedMorphNames = missing
        };
    }

    public static PmxMorphUpdateResult RemoveMorphs(string path, IEnumerable<string> morphNames)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("PMX controller was not found.", path);
        ArgumentNullException.ThrowIfNull(morphNames);

        var requested = morphNames
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Distinct(StringComparer.Ordinal)
            .ToHashSet(StringComparer.Ordinal);
        var bytes = File.ReadAllBytes(path);
        var layout = Parse(bytes);
        var removed = layout.MorphEntries.Where(entry => requested.Contains(entry.Name)).ToArray();
        if (removed.Length == 0)
        {
            return new PmxMorphUpdateResult
            {
                MorphNames = layout.MorphNames,
                AddedMorphNames = [],
                RemovedMorphNames = []
            };
        }

        using var output = new MemoryStream(bytes.Length - removed.Sum(entry => entry.EndOffset - entry.StartOffset));
        output.Write(bytes, 0, layout.MorphCountOffset);
        WriteInt32(output, checked(layout.MorphNames.Count - removed.Length));
        foreach (var entry in layout.MorphEntries)
        {
            if (requested.Contains(entry.Name)) continue;
            output.Write(bytes, entry.StartOffset, entry.EndOffset - entry.StartOffset);
        }
        output.Write(bytes, layout.MorphDataEnd, bytes.Length - layout.MorphDataEnd);
        WriteFileAtomically(path, output.ToArray());

        var updatedNames = ReadMorphNames(path);
        if (removed.Any(entry => updatedNames.Contains(entry.Name, StringComparer.Ordinal)))
            throw new PmxFormatException("Failed to remove one or more deprecated controller morphs.");
        return new PmxMorphUpdateResult
        {
            MorphNames = updatedNames,
            AddedMorphNames = [],
            RemovedMorphNames = removed.Select(entry => entry.Name).ToArray()
        };
    }

    private static PmxMorphLayout Parse(byte[] bytes)
    {
        var reader = new PmxBinaryReader(bytes);
        if (Encoding.ASCII.GetString(reader.ReadBytes(4)) != "PMX ")
            throw new PmxFormatException("The file is not a PMX model.");
        var version = reader.ReadSingle();
        if (version < 1.99f || version > 2.11f)
            throw new PmxFormatException($"Unsupported PMX version {version}.");

        var headerSize = reader.ReadByte();
        var globals = reader.ReadBytes(headerSize);
        if (globals.Length < 8) throw new PmxFormatException("PMX header is too short.");
        var encoding = globals[0] == 0 ? Encoding.Unicode : Encoding.UTF8;
        var additionalUv = globals[1];
        var vertexIndexSize = globals[2];
        var textureIndexSize = globals[3];
        var materialIndexSize = globals[4];
        var boneIndexSize = globals[5];
        var morphIndexSize = globals[6];
        var rigidIndexSize = globals[7];
        foreach (var size in new[] { vertexIndexSize, textureIndexSize, materialIndexSize, boneIndexSize, morphIndexSize, rigidIndexSize })
            if (size is not (1 or 2 or 4)) throw new PmxFormatException("PMX contains an unsupported index size.");

        for (var index = 0; index < 4; index++) _ = reader.ReadText(encoding);

        var vertexCount = ReadCount(reader, "vertex");
        for (var index = 0; index < vertexCount; index++)
        {
            reader.Skip(12 + 12 + 8 + additionalUv * 16);
            var weightType = reader.ReadByte();
            switch (weightType)
            {
                case 0: reader.Skip(boneIndexSize); break;
                case 1: reader.Skip(boneIndexSize * 2 + 4); break;
                case 2 or 4: reader.Skip(boneIndexSize * 4 + 16); break;
                case 3: reader.Skip(boneIndexSize * 2 + 40); break;
                default: throw new PmxFormatException($"Unknown PMX vertex weight type {weightType}.");
            }
            reader.Skip(4);
        }

        reader.Skip(checked(ReadCount(reader, "surface index") * vertexIndexSize));
        var textureCount = ReadCount(reader, "texture");
        for (var index = 0; index < textureCount; index++) _ = reader.ReadText(encoding);

        var materialCount = ReadCount(reader, "material");
        for (var index = 0; index < materialCount; index++)
        {
            _ = reader.ReadText(encoding);
            _ = reader.ReadText(encoding);
            reader.Skip(16 + 12 + 4 + 12 + 1 + 16 + 4);
            reader.Skip(textureIndexSize * 2 + 1);
            var toonShared = reader.ReadByte();
            reader.Skip(toonShared == 0 ? textureIndexSize : 1);
            _ = reader.ReadText(encoding);
            _ = ReadCount(reader, "material surface index");
        }

        var boneCount = ReadCount(reader, "bone");
        for (var index = 0; index < boneCount; index++)
        {
            _ = reader.ReadText(encoding);
            _ = reader.ReadText(encoding);
            reader.Skip(12 + boneIndexSize + 4);
            var flags = reader.ReadUInt16();
            reader.Skip((flags & 0x0001) != 0 ? boneIndexSize : 12);
            if ((flags & (0x0100 | 0x0200)) != 0) reader.Skip(boneIndexSize + 4);
            if ((flags & 0x0400) != 0) reader.Skip(12);
            if ((flags & 0x0800) != 0) reader.Skip(24);
            if ((flags & 0x2000) != 0) reader.Skip(4);
            if ((flags & 0x0020) != 0)
            {
                reader.Skip(boneIndexSize + 8);
                var linkCount = ReadCount(reader, "IK link");
                for (var link = 0; link < linkCount; link++)
                {
                    reader.Skip(boneIndexSize);
                    if (reader.ReadByte() != 0) reader.Skip(24);
                }
            }
        }

        var morphCountOffset = reader.Position;
        var morphCount = ReadCount(reader, "morph");
        var names = new List<string>(morphCount);
        var morphTextFields = new List<PmxMorphTextField>(morphCount * 2);
        var morphEntries = new List<PmxMorphEntry>(morphCount);
        for (var index = 0; index < morphCount; index++)
        {
            var morphStart = reader.Position;
            var nameField = ReadTextField(reader, encoding, isPrimary: true);
            names.Add(nameField.Value);
            morphTextFields.Add(nameField);
            morphTextFields.Add(ReadTextField(reader, encoding, isPrimary: false));
            reader.Skip(1);
            var morphType = reader.ReadByte();
            var entryCount = ReadCount(reader, "morph entry");
            var entrySize = morphType switch
            {
                0 => morphIndexSize + 4,
                1 => vertexIndexSize + 12,
                2 => boneIndexSize + 28,
                >= 3 and <= 7 => vertexIndexSize + 16,
                8 => materialIndexSize + 113,
                9 => morphIndexSize + 4,
                10 => rigidIndexSize + 25,
                _ => throw new PmxFormatException($"Unknown PMX morph type {morphType}.")
            };
            reader.Skip(checked(entryCount * entrySize));
            morphEntries.Add(new PmxMorphEntry(nameField.Value, morphStart, reader.Position));
        }

        return new PmxMorphLayout(
            encoding,
            vertexIndexSize,
            vertexCount,
            morphCountOffset,
            reader.Position,
            names,
            morphTextFields,
            morphEntries);
    }

    private static PmxMorphTextField ReadTextField(PmxBinaryReader reader, Encoding encoding, bool isPrimary)
    {
        var lengthOffset = reader.Position;
        var byteLength = reader.ReadInt32();
        var dataOffset = reader.Position;
        var value = encoding.GetString(reader.ReadBytes(byteLength));
        return new PmxMorphTextField(lengthOffset, dataOffset, byteLength, value, isPrimary);
    }

    private static void WriteFileAtomically(string path, byte[] bytes)
    {
        var temporaryPath = path + ".snowtmp_" + Guid.NewGuid().ToString("N");
        try
        {
            File.WriteAllBytes(temporaryPath, bytes);
            _ = Parse(File.ReadAllBytes(temporaryPath));
            File.Move(temporaryPath, path, true);
        }
        finally
        {
            if (File.Exists(temporaryPath)) File.Delete(temporaryPath);
        }
    }

    private static int ReadCount(PmxBinaryReader reader, string label)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > 10_000_000) throw new PmxFormatException($"Invalid PMX {label} count {count}.");
        return count;
    }

    private static void WriteZeroOffsetVertexMorph(Stream output, Encoding encoding, int vertexIndexSize, string name)
    {
        WriteText(output, encoding, name);
        WriteText(output, encoding, name);
        output.WriteByte(4);
        output.WriteByte(1);
        WriteInt32(output, 1);
        output.Write(new byte[vertexIndexSize + 12]);
    }

    private static void WriteText(Stream output, Encoding encoding, string value)
    {
        var bytes = encoding.GetBytes(value);
        WriteInt32(output, bytes.Length);
        output.Write(bytes);
    }

    private static void WriteInt32(Stream output, int value)
    {
        Span<byte> bytes = stackalloc byte[sizeof(int)];
        BinaryPrimitives.WriteInt32LittleEndian(bytes, value);
        output.Write(bytes);
    }

    private sealed record PmxMorphLayout(
        Encoding Encoding,
        int VertexIndexSize,
        int VertexCount,
        int MorphCountOffset,
        int MorphDataEnd,
        IReadOnlyList<string> MorphNames,
        IReadOnlyList<PmxMorphTextField> MorphTextFields,
        IReadOnlyList<PmxMorphEntry> MorphEntries);

    private sealed record PmxMorphTextField(int LengthOffset, int DataOffset, int ByteLength, string Value, bool IsPrimary);
    private sealed record PmxMorphEntry(string Name, int StartOffset, int EndOffset);
}


