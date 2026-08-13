using System.Buffers.Binary;
using System.Text;

namespace EndfieldMaterialStudio.Core;

public sealed class PmxFormatException : Exception
{
    public PmxFormatException(string message) : base(message) { }
}

internal sealed class PmxBinaryReader
{
    private readonly byte[] _data;
    private int _offset;

    public PmxBinaryReader(byte[] data) => _data = data;
    public int Position => _offset;

    public byte ReadByte()
    {
        Ensure(1);
        return _data[_offset++];
    }

    public byte[] ReadBytes(int count)
    {
        if (count < 0) throw new PmxFormatException("Negative byte count.");
        Ensure(count);
        var value = new byte[count];
        Buffer.BlockCopy(_data, _offset, value, 0, count);
        _offset += count;
        return value;
    }

    public void Skip(int count) => _ = ReadBytes(count);
    public float ReadSingle() => BitConverter.Int32BitsToSingle(ReadInt32());
    public short ReadInt16() { Ensure(2); var value = BinaryPrimitives.ReadInt16LittleEndian(_data.AsSpan(_offset, 2)); _offset += 2; return value; }
    public ushort ReadUInt16() { Ensure(2); var value = BinaryPrimitives.ReadUInt16LittleEndian(_data.AsSpan(_offset, 2)); _offset += 2; return value; }
    public int ReadInt32() { Ensure(4); var value = BinaryPrimitives.ReadInt32LittleEndian(_data.AsSpan(_offset, 4)); _offset += 4; return value; }
    public string ReadText(Encoding encoding)
    {
        var size = ReadInt32();
        if (size < 0 || size > _data.Length) throw new PmxFormatException("Invalid PMX text size.");
        return encoding.GetString(ReadBytes(size));
    }

    public int ReadIndex(int size)
    {
        return size switch
        {
            1 => unchecked((sbyte)ReadByte()),
            2 => ReadInt16(),
            4 => ReadInt32(),
            _ => throw new PmxFormatException($"Unsupported PMX index size {size}.")
        };
    }

    private void Ensure(int count)
    {
        if (count > _data.Length - _offset) throw new PmxFormatException($"Unexpected end of PMX at byte {_offset}.");
    }
}

public static class PmxReader
{
    private static readonly string[] TextureFallbackDirectories = ["other tex", "other_tex"];

    public static string? ResolveTextureFilePath(string pmxPath, string? texturePath)
    {
        return ResolveTexture(pmxPath, texturePath)?.ResolvedPath;
    }

    public static PmxTextureResolution? ResolveTexture(string pmxPath, string? texturePath)
    {
        if (string.IsNullOrWhiteSpace(texturePath) || string.IsNullOrWhiteSpace(pmxPath)) return null;

        var fullPmxPath = Path.GetFullPath(pmxPath);
        var modelDirectory = Path.GetDirectoryName(fullPmxPath)!;
        var normalized = texturePath.Trim()
            .Replace('/', Path.DirectorySeparatorChar)
            .Replace('\\', Path.DirectorySeparatorChar);
        string directPath;
        try
        {
            directPath = Path.GetFullPath(Path.Combine(modelDirectory, normalized));
        }
        catch (Exception exception) when (exception is ArgumentException or NotSupportedException or PathTooLongException)
        {
            return new PmxTextureResolution
            {
                DeclaredPath = texturePath,
                DirectPath = normalized,
                ResolvedPath = normalized,
                Exists = false
            };
        }
        if (File.Exists(directPath))
        {
            return new PmxTextureResolution
            {
                DeclaredPath = texturePath,
                DirectPath = directPath,
                ResolvedPath = directPath,
                Exists = true
            };
        }

        if (!Path.IsPathRooted(normalized) && Directory.Exists(modelDirectory))
        {
            var fileName = Path.GetFileName(normalized);
            if (!string.IsNullOrWhiteSpace(fileName))
            {
                var fallbackRoots = Directory.EnumerateDirectories(modelDirectory, "*", SearchOption.TopDirectoryOnly)
                    .Select(path => (Path: path, Name: Path.GetFileName(path)))
                    .Where(item => !string.IsNullOrWhiteSpace(item.Name))
                    .ToDictionary(item => item.Name!, item => item.Path, StringComparer.OrdinalIgnoreCase);
                foreach (var directoryName in TextureFallbackDirectories)
                {
                    if (!fallbackRoots.TryGetValue(directoryName, out var fallbackRoot)) continue;
                    var fallbackPath = Path.Combine(fallbackRoot, fileName);
                    if (!File.Exists(fallbackPath)) continue;
                    return new PmxTextureResolution
                    {
                        DeclaredPath = texturePath,
                        DirectPath = directPath,
                        ResolvedPath = Path.GetFullPath(fallbackPath),
                        Exists = true,
                        UsedFallback = true,
                        FallbackDirectory = Path.GetFileName(fallbackRoot)
                    };
                }
            }
        }

        return new PmxTextureResolution
        {
            DeclaredPath = texturePath,
            DirectPath = directPath,
            ResolvedPath = directPath,
            Exists = false
        };
    }

    public static IReadOnlyList<PmxTextureDependency> ResolveTextureDependencies(PmxModelInfo model)
    {
        if (string.IsNullOrWhiteSpace(model.FilePath))
            throw new ArgumentException("PMX model info does not contain a file path.", nameof(model));

        var dependencies = new List<PmxTextureDependency>();
        foreach (var material in model.Materials)
        {
            Add(material, PmxTextureKind.Base, material.TexturePath);
            if (material.SphereMode != 0)
                Add(material, PmxTextureKind.Sphere, material.SphereTexturePath);
            Add(material, PmxTextureKind.Toon, material.ToonTexturePath);
        }
        return dependencies;

        void Add(PmxMaterialInfo material, PmxTextureKind kind, string? declaredPath)
        {
            var resolution = ResolveTexture(model.FilePath, declaredPath);
            if (resolution is null) return;
            dependencies.Add(new PmxTextureDependency
            {
                MaterialIndex = material.Index,
                MaterialName = material.Name,
                Kind = kind,
                Resolution = resolution
            });
        }
    }

    public static PmxModelInfo Read(string path)
    {
        if (!File.Exists(path)) throw new FileNotFoundException("PMX file was not found.", path);
        return Read(File.ReadAllBytes(path), Path.GetFullPath(path));
    }

    public static PmxModelInfo Read(byte[] bytes, string filePath = "")
    {
        var reader = new PmxBinaryReader(bytes);
        var magic = Encoding.ASCII.GetString(reader.ReadBytes(4));
        if (magic != "PMX ") throw new PmxFormatException("The file is not a PMX model.");
        var version = reader.ReadSingle();
        if (version < 1.99f || version > 2.11f) throw new PmxFormatException($"Unsupported PMX version {version}.");

        var headerSize = reader.ReadByte();
        var globals = reader.ReadBytes(headerSize);
        if (globals.Length < 8) throw new PmxFormatException("PMX header is too short.");
        var encoding = globals[0] == 0 ? Encoding.Unicode : Encoding.UTF8;
        var encodingName = globals[0] == 0 ? "UTF-16LE" : "UTF-8";
        var additionalUv = globals[1];
        var vertexIndexSize = globals[2];
        var textureIndexSize = globals[3];
        var materialIndexSize = globals[4];
        var boneIndexSize = globals[5];
        var morphIndexSize = globals[6];
        var rigidIndexSize = globals[7];
        foreach (var size in new[] { vertexIndexSize, textureIndexSize, materialIndexSize, boneIndexSize, morphIndexSize, rigidIndexSize })
            if (size is not (1 or 2 or 4)) throw new PmxFormatException("PMX contains an unsupported index size.");

        for (var i = 0; i < 4; i++) _ = reader.ReadText(encoding);

        var vertexCount = ReadCount(reader, "vertex");
        var additionalUv1 = additionalUv >= 1 ? new List<(float U, float V)>(vertexCount) : null;
        for (var i = 0; i < vertexCount; i++)
        {
            reader.Skip(12 + 12 + 8);
            if (additionalUv1 is not null)
            {
                additionalUv1.Add((reader.ReadSingle(), reader.ReadSingle()));
                reader.Skip(8 + (additionalUv - 1) * 16);
            }
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

        var surfaceIndexCount = ReadCount(reader, "surface index");
        var surfaceIndices = new List<int>(surfaceIndexCount);
        for (var i = 0; i < surfaceIndexCount; i++) surfaceIndices.Add(reader.ReadIndex(vertexIndexSize));
        var textures = new List<string>();
        var textureCount = ReadCount(reader, "texture");
        for (var i = 0; i < textureCount; i++) textures.Add(reader.ReadText(encoding));

        var materials = new List<PmxMaterialInfo>();
        var materialCount = ReadCount(reader, "material");
        var materialSurfaceOffset = 0;
        for (var i = 0; i < materialCount; i++)
        {
            var name = reader.ReadText(encoding);
            var englishName = reader.ReadText(encoding);
            reader.Skip(16 + 12 + 4 + 12 + 1 + 16 + 4);
            var textureIndex = reader.ReadIndex(textureIndexSize);
            var sphereIndex = reader.ReadIndex(textureIndexSize);
            var sphereMode = reader.ReadByte();
            var toonShared = reader.ReadByte();
            var toonIndex = toonShared == 0 ? reader.ReadIndex(textureIndexSize) : reader.ReadByte();
            _ = reader.ReadText(encoding);
            var materialSurfaceCount = ReadCount(reader, "material surface index");
            materials.Add(new PmxMaterialInfo
            {
                Index = i,
                Name = name,
                EnglishName = englishName,
                TexturePath = ResolveTexturePath(textures, textureIndex),
                SphereTexturePath = ResolveTexturePath(textures, sphereIndex),
                SphereMode = sphereMode,
                ToonTexturePath = toonShared == 0 ? ResolveTexturePath(textures, toonIndex) : null,
                AdditionalUvCount = additionalUv,
                HasUsableUv1 = HasUsableUv1(
                    additionalUv1,
                    surfaceIndices,
                    materialSurfaceOffset,
                    materialSurfaceCount)
            });
            materialSurfaceOffset += materialSurfaceCount;
        }

        var bones = new List<string>();
        var boneCount = ReadCount(reader, "bone");
        for (var i = 0; i < boneCount; i++)
        {
            bones.Add(reader.ReadText(encoding));
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
                reader.Skip(boneIndexSize + 4 + 4);
                var linkCount = ReadCount(reader, "IK link");
                for (var link = 0; link < linkCount; link++)
                {
                    reader.Skip(boneIndexSize);
                    if (reader.ReadByte() != 0) reader.Skip(24);
                }
            }
        }

        return new PmxModelInfo
        {
            FilePath = filePath,
            Version = version,
            Encoding = encodingName,
            AdditionalUvCount = additionalUv,
            BoneNames = bones,
            Materials = materials
        };
    }

    private static int ReadCount(PmxBinaryReader reader, string label)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > 10_000_000) throw new PmxFormatException($"Invalid PMX {label} count {count}.");
        return count;
    }

    private static bool HasUsableUv1(
        IReadOnlyList<(float U, float V)>? uv1,
        IReadOnlyList<int> surfaceIndices,
        int start,
        int count)
    {
        if (uv1 is null || count < 3 || start < 0 || start + count > surfaceIndices.Count) return false;

        for (var offset = start; offset + 2 < start + count; offset += 3)
        {
            var i0 = surfaceIndices[offset];
            var i1 = surfaceIndices[offset + 1];
            var i2 = surfaceIndices[offset + 2];
            if ((uint)i0 >= uv1.Count || (uint)i1 >= uv1.Count || (uint)i2 >= uv1.Count) continue;

            var a = uv1[i0];
            var b = uv1[i1];
            var c = uv1[i2];
            var determinant = (b.U - a.U) * (c.V - a.V) - (b.V - a.V) * (c.U - a.U);
            if (MathF.Abs(determinant) > 1e-8f) return true;
        }
        return false;
    }

    private static string? ResolveTexturePath(IReadOnlyList<string> textures, int index)
    {
        if (index < 0 || index >= textures.Count) return null;
        return textures[index];
    }
}


