using System.Buffers.Binary;
using System.Text;

namespace EndfieldShaderTool.Core;

/// <summary>
/// Creates the disposable PMX sibling used by Endfield EyeThrough.  The source
/// model stays byte-for-byte untouched: only the confirmed eye and brow/lash
/// index ranges are duplicated and appended as new draw materials.
/// </summary>
public static class PmxEyeThroughDerivedModelBuilder
{
    public static EyeThroughDerivedModelResult Ensure(EndfieldProject project)
    {
        ArgumentNullException.ThrowIfNull(project);
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath))
            throw new FileNotFoundException("未找到用于生成眼透派生模型的 PMX。", project.PmxPath);

        var sourcePath = Path.GetFullPath(project.PmxPath);
        var sourceModel = project.Model ?? PmxReader.Read(sourcePath);
        project.Model = sourceModel;
        ProjectService.NormalizeMaterialBindings(project);

        var existingEye = sourceModel.Materials.Where(material =>
            MaterialClassifier.Suggest(material) == ShaderDomain.EyeOverlay).ToArray();
        var existingBrow = sourceModel.Materials.Where(material =>
            MaterialClassifier.Suggest(material) == ShaderDomain.BrowOverlay).ToArray();
        if (existingEye.Length > 0 || existingBrow.Length > 0)
        {
            if (existingEye.Length == 0 || existingBrow.Length == 0)
                throw new PmxFormatException("当前 PMX 只包含一类眼透覆盖材质，结构不完整。请使用原始 PMX 重新生成，或先修复该派生模型。");

            return new EyeThroughDerivedModelResult
            {
                SourcePmxPath = sourcePath,
                DerivedPmxPath = sourcePath,
                Status = EyeThroughDerivedModelStatus.AlreadyDerived,
                Overlays = Array.Empty<EyeThroughOverlayBinding>()
            };
        }

        var requested = ResolveSourceMaterials(project, sourceModel);
        var derivedPath = GetDerivedPath(sourcePath);
        if (File.Exists(derivedPath))
        {
            var reused = ValidateExistingDerivedModel(sourcePath, derivedPath, sourceModel, requested);
            return reused;
        }

        var bytes = File.ReadAllBytes(sourcePath);
        var layout = ParseLayout(bytes);
        if (layout.Materials.Count != sourceModel.Materials.Count)
            throw new PmxFormatException("PMX 材质解析结果不一致，已停止生成眼透派生模型。");

        var overlays = BuildOverlays(layout, requested);
        var derivedBytes = BuildDerivedBytes(bytes, layout, overlays);
        var temporaryPath = derivedPath + ".endfieldtmp_" + Guid.NewGuid().ToString("N");
        try
        {
            File.WriteAllBytes(temporaryPath, derivedBytes);
            ValidateDerivedModel(temporaryPath, sourceModel, overlays);
            File.Move(temporaryPath, derivedPath, overwrite: false);
        }
        finally
        {
            if (File.Exists(temporaryPath)) File.Delete(temporaryPath);
        }

        return new EyeThroughDerivedModelResult
        {
            SourcePmxPath = sourcePath,
            DerivedPmxPath = derivedPath,
            Status = EyeThroughDerivedModelStatus.Created,
            Overlays = overlays.Select(item => item.Binding).ToArray()
        };
    }

    /// <summary>
    /// Switches the project to the generated sibling and creates matching FX
    /// profiles. Existing profiles and their user-selected textures are kept.
    /// </summary>
    public static void ApplyToProject(EndfieldProject project, EyeThroughDerivedModelResult result)
    {
        ArgumentNullException.ThrowIfNull(project);
        ArgumentNullException.ThrowIfNull(result);

        if (!File.Exists(result.DerivedPmxPath))
            throw new FileNotFoundException("眼透派生 PMX 不存在。", result.DerivedPmxPath);

        var previousProfiles = project.Profiles.ToArray();
        var derivedModel = PmxReader.Read(result.DerivedPmxPath);
        project.PmxPath = result.DerivedPmxPath;
        project.Model = derivedModel;
        ProjectService.NormalizeMaterialBindings(project);

        foreach (var source in previousProfiles.Where(profile =>
                     profile.Domain is ShaderDomain.Iris or ShaderDomain.BrowLash))
        {
            if (ProjectService.GetBindings(source).Count > 0)
            {
                source.Parameters.EnableEyeThrough = true;
                source.Parameters.GenerateEyeThroughDerivedModel = true;
            }
        }

        foreach (var overlay in result.Overlays)
        {
            if (project.Profiles.Any(profile => profile.Domain == overlay.Domain &&
                                                ProjectService.GetBindings(profile)
                                                    .Any(binding => binding.MaterialIndex == overlay.OverlayMaterialIndex)))
                continue;

            var sourceProfile = previousProfiles.FirstOrDefault(profile =>
                profile.Domain == overlay.SourceDomain &&
                ProjectService.GetBindings(profile)
                    .Any(binding => binding.MaterialIndex == overlay.SourceMaterialIndex));
            if (sourceProfile is null)
                throw new InvalidOperationException($"无法为新增材质“{overlay.OverlayMaterialName}”找到已确认的源材质预设。");

            var material = derivedModel.Materials.FirstOrDefault(item => item.Index == overlay.OverlayMaterialIndex)
                ?? throw new PmxFormatException($"派生 PMX 缺少新增材质 #{overlay.OverlayMaterialIndex}。");
            var profile = ProjectService.CloneProfile(sourceProfile);
            profile.ProfileName = UniqueProfileName(project, overlay.Domain == ShaderDomain.EyeOverlay ? "eye_overlay" : "brow_overlay");
            profile.Domain = overlay.Domain;
            profile.Parameters = MaterialDefaults.CreateParameters(overlay.Domain);
            profile.Parameters.CastCharacterShadow = false;
            profile.Parameters.EnableEyeThrough = false;
            profile.Parameters.GenerateEyeThroughDerivedModel = false;
            profile.CastExcellentShadow = false;
            profile.UsePmxSphereMap = false;
            ProjectService.SetBindings(profile, new[] { ProjectService.CreateBinding(material) });
            project.Profiles.Add(profile);
        }

        ProjectService.NormalizeMaterialBindings(project);
    }

    private static EyeThroughDerivedModelResult ValidateExistingDerivedModel(
        string sourcePath,
        string derivedPath,
        PmxModelInfo sourceModel,
        IReadOnlyList<SourceMaterial> requested)
    {
        var derived = PmxReader.Read(derivedPath);
        if (derived.Materials.Count != sourceModel.Materials.Count + requested.Count)
            throw new PmxFormatException($"已存在的派生 PMX 材质数不匹配，未覆盖：{derivedPath}");

        var appended = derived.Materials.Skip(sourceModel.Materials.Count).ToArray();
        var overlays = new List<EyeThroughOverlayBinding>(requested.Count);
        for (var index = 0; index < requested.Count; index++)
        {
            var expected = requested[index];
            var material = appended[index];
            if (MaterialClassifier.Suggest(material) != expected.OverlayDomain)
                throw new PmxFormatException($"已存在的派生 PMX 覆盖材质顺序不符合当前工程，未覆盖：{derivedPath}");
            overlays.Add(new EyeThroughOverlayBinding(
                expected.MaterialIndex,
                material.Index,
                expected.SourceDomain,
                expected.OverlayDomain,
                expected.MaterialName,
                material.Name));
        }

        return new EyeThroughDerivedModelResult
        {
            SourcePmxPath = sourcePath,
            DerivedPmxPath = derivedPath,
            Status = EyeThroughDerivedModelStatus.ReusedSibling,
            Overlays = overlays
        };
    }

    private static IReadOnlyList<SourceMaterial> ResolveSourceMaterials(EndfieldProject project, PmxModelInfo model)
    {
        var values = new List<SourceMaterial>();
        AddSources(ShaderDomain.Iris, ShaderDomain.EyeOverlay, "眼睛/Iris");
        AddSources(ShaderDomain.BrowLash, ShaderDomain.BrowOverlay, "眉毛睫毛/BrowLash");

        if (values.Count == 0)
            throw new PmxFormatException("当前工程没有可用于眼透的 Iris 或 BrowLash 材质。请先在 GUI 中确认材质类型。");
        if (!values.Any(item => item.SourceDomain == ShaderDomain.Iris))
            throw new PmxFormatException("眼透需要至少一个 Iris（眼睛）材质。请先在 GUI 中为对应材质选择 Iris 类型。");
        if (!values.Any(item => item.SourceDomain == ShaderDomain.BrowLash))
            throw new PmxFormatException("眼透需要至少一个 BrowLash（眉毛/睫毛）材质。请先在 GUI 中为对应材质选择 BrowLash 类型。");
        if (values.Select(item => item.MaterialIndex).Distinct().Count() != values.Count)
            throw new PmxFormatException("同一个 PMX 材质同时被设置为眼睛和眉毛/睫毛，无法安全生成眼透覆盖层。请拆分或修正材质类型。");
        return values;

        void AddSources(ShaderDomain sourceDomain, ShaderDomain overlayDomain, string label)
        {
            var bindings = project.Profiles
                .Where(profile => profile.Domain == sourceDomain)
                .SelectMany(ProjectService.GetBindings)
                .GroupBy(binding => binding.MaterialIndex)
                .Select(group => group.First())
                .OrderBy(binding => binding.MaterialIndex)
                .ToArray();
            foreach (var binding in bindings)
            {
                var material = model.Materials.FirstOrDefault(item => item.Index == binding.MaterialIndex)
                    ?? throw new PmxFormatException($"{label} 绑定引用了不存在的 PMX 材质 #{binding.MaterialIndex}。");
                values.Add(new SourceMaterial(material.Index, material.Name, sourceDomain, overlayDomain));
            }
        }
    }

    private static IReadOnlyList<OverlayBuildItem> BuildOverlays(PmxLayout layout, IReadOnlyList<SourceMaterial> requested)
    {
        var names = layout.Materials.Select(item => item.Name).ToHashSet(StringComparer.Ordinal);
        var englishNames = layout.Materials.Select(item => item.EnglishName).ToHashSet(StringComparer.OrdinalIgnoreCase);
        var result = new List<OverlayBuildItem>(requested.Count);
        foreach (var requestedItem in requested)
        {
            var material = layout.Materials.FirstOrDefault(item => item.Index == requestedItem.MaterialIndex)
                ?? throw new PmxFormatException($"找不到要复制的 PMX 材质 #{requestedItem.MaterialIndex}。");
            if (material.SurfaceIndexCount < 3 || material.SurfaceIndexCount % 3 != 0)
                throw new PmxFormatException($"材质“{material.Name}”没有有效的三角面索引，无法生成眼透覆盖层。");

            var nameBase = requestedItem.OverlayDomain == ShaderDomain.EyeOverlay ? "目透发" : "睫眉透发";
            var englishBase = requestedItem.OverlayDomain == ShaderDomain.EyeOverlay ? "EyeOverlay" : "BrowOverlay";
            var displayName = UniqueName(names, nameBase, material.Name);
            var englishName = UniqueName(englishNames, englishBase, material.EnglishName);
            var overlayIndex = layout.Materials.Count + result.Count;
            var record = RenameMaterialRecord(material.RawRecord, layout.Encoding, displayName, englishName);
            result.Add(new OverlayBuildItem(
                material,
                record,
                new EyeThroughOverlayBinding(
                    material.Index,
                    overlayIndex,
                    requestedItem.SourceDomain,
                    requestedItem.OverlayDomain,
                    material.Name,
                    displayName)));
        }
        return result;
    }

    private static string UniqueName(ISet<string> existing, string preferred, string sourceName)
    {
        var candidate = preferred;
        if (!existing.Add(candidate))
        {
            candidate = $"{sourceName}_{preferred}";
            var suffix = 2;
            while (!existing.Add(candidate)) candidate = $"{sourceName}_{preferred}_{suffix++}";
        }
        return candidate;
    }

    private static byte[] BuildDerivedBytes(byte[] bytes, PmxLayout layout, IReadOnlyList<OverlayBuildItem> overlays)
    {
        var extraIndexCount = overlays.Sum(item => item.Source.SurfaceIndexCount);
        if (extraIndexCount > int.MaxValue - layout.SurfaceIndexCount)
            throw new PmxFormatException("眼透覆盖层的索引数超出 PMX 限制。");

        using var output = new MemoryStream(bytes.Length + extraIndexCount * layout.VertexIndexSize + overlays.Sum(item => item.MaterialRecord.Length));
        output.Write(bytes, 0, layout.SurfaceIndexCountOffset);
        WriteInt32(output, checked(layout.SurfaceIndexCount + extraIndexCount));
        output.Write(bytes, layout.SurfaceIndexDataOffset, layout.SurfaceIndexDataEnd - layout.SurfaceIndexDataOffset);
        foreach (var overlay in overlays)
        {
            var offset = checked(layout.SurfaceIndexDataOffset + overlay.Source.SurfaceIndexStart * layout.VertexIndexSize);
            var length = checked(overlay.Source.SurfaceIndexCount * layout.VertexIndexSize);
            output.Write(bytes, offset, length);
        }

        output.Write(bytes, layout.SurfaceIndexDataEnd, layout.MaterialCountOffset - layout.SurfaceIndexDataEnd);
        WriteInt32(output, checked(layout.Materials.Count + overlays.Count));
        output.Write(bytes, layout.MaterialDataStart, layout.MaterialDataEnd - layout.MaterialDataStart);
        foreach (var overlay in overlays) output.Write(overlay.MaterialRecord);
        output.Write(bytes, layout.MaterialDataEnd, bytes.Length - layout.MaterialDataEnd);
        return output.ToArray();
    }

    private static byte[] RenameMaterialRecord(byte[] record, Encoding encoding, string name, string englishName)
    {
        var reader = new PmxBinaryReader(record);
        _ = reader.ReadText(encoding);
        _ = reader.ReadText(encoding);
        var unchangedOffset = reader.Position;
        using var output = new MemoryStream(record.Length + Math.Max(name.Length, englishName.Length) * 2);
        WriteText(output, encoding, name);
        WriteText(output, encoding, englishName);
        output.Write(record, unchangedOffset, record.Length - unchangedOffset);
        return output.ToArray();
    }

    private static void ValidateDerivedModel(string path, PmxModelInfo source, IReadOnlyList<OverlayBuildItem> overlays)
    {
        var derived = PmxReader.Read(path);
        if (derived.Materials.Count != source.Materials.Count + overlays.Count)
            throw new PmxFormatException("生成后的 PMX 材质数量校验失败。");
        foreach (var overlay in overlays)
        {
            var material = derived.Materials.FirstOrDefault(item => item.Index == overlay.Binding.OverlayMaterialIndex);
            if (material is null || MaterialClassifier.Suggest(material) != overlay.Binding.Domain)
                throw new PmxFormatException($"生成后的 PMX 缺少有效覆盖材质“{overlay.Binding.OverlayMaterialName}”。");
        }
        if (!source.BoneNames.SequenceEqual(derived.BoneNames, StringComparer.Ordinal))
            throw new PmxFormatException("生成后的 PMX 骨骼结构发生变化，已停止写入。");
    }

    private static PmxLayout ParseLayout(byte[] bytes)
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
        ValidateIndexSizes(vertexIndexSize, textureIndexSize, boneIndexSize);

        for (var index = 0; index < 4; index++) _ = reader.ReadText(encoding);
        var vertexCount = ReadCount(reader, "顶点");
        for (var index = 0; index < vertexCount; index++) SkipVertex(reader, additionalUvCount, boneIndexSize);

        var surfaceIndexCountOffset = reader.Position;
        var surfaceIndexCount = ReadCount(reader, "面索引");
        var surfaceIndexDataOffset = reader.Position;
        reader.Skip(checked(surfaceIndexCount * vertexIndexSize));
        var surfaceIndexDataEnd = reader.Position;

        var textureCount = ReadCount(reader, "贴图");
        for (var index = 0; index < textureCount; index++) _ = reader.ReadText(encoding);

        var materialCountOffset = reader.Position;
        var materialCount = ReadCount(reader, "材质");
        var materialDataStart = reader.Position;
        var surfaceIndexStart = 0;
        var materials = new List<RawMaterial>(materialCount);
        for (var index = 0; index < materialCount; index++)
        {
            var start = reader.Position;
            var name = reader.ReadText(encoding);
            var englishName = reader.ReadText(encoding);
            reader.Skip(16 + 12 + 4 + 12 + 1 + 16 + 4);
            reader.Skip(textureIndexSize * 2 + 1);
            var toonShared = reader.ReadByte();
            reader.Skip(toonShared == 0 ? textureIndexSize : 1);
            _ = reader.ReadText(encoding);
            var count = ReadCount(reader, "材质面索引");
            if (count > surfaceIndexCount - surfaceIndexStart)
                throw new PmxFormatException($"材质“{name}”的面索引范围超出 PMX 数据。");
            var end = reader.Position;
            var record = new byte[end - start];
            Buffer.BlockCopy(bytes, start, record, 0, record.Length);
            materials.Add(new RawMaterial(index, name, englishName, surfaceIndexStart, count, record));
            surfaceIndexStart += count;
        }
        if (surfaceIndexStart != surfaceIndexCount)
            throw new PmxFormatException("PMX 材质面索引总数与面索引区不一致。");

        return new PmxLayout(
            encoding,
            vertexIndexSize,
            surfaceIndexCountOffset,
            surfaceIndexCount,
            surfaceIndexDataOffset,
            surfaceIndexDataEnd,
            materialCountOffset,
            materialDataStart,
            reader.Position,
            materials);
    }

    private static void SkipVertex(PmxBinaryReader reader, int additionalUvCount, int boneIndexSize)
    {
        reader.Skip(12 + 12 + 8 + additionalUvCount * 16);
        var weightType = reader.ReadByte();
        switch (weightType)
        {
            case 0: reader.Skip(boneIndexSize); break;
            case 1: reader.Skip(boneIndexSize * 2 + 4); break;
            case 2 or 4: reader.Skip(boneIndexSize * 4 + 16); break;
            case 3: reader.Skip(boneIndexSize * 2 + 40); break;
            default: throw new PmxFormatException($"未知 PMX 顶点权重类型：{weightType}。");
        }
        reader.Skip(4);
    }

    private static void ValidateIndexSizes(params int[] sizes)
    {
        foreach (var size in sizes)
            if (size is not (1 or 2 or 4)) throw new PmxFormatException("PMX 包含不支持的索引尺寸。");
    }

    private static int ReadCount(PmxBinaryReader reader, string label)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > 10_000_000) throw new PmxFormatException($"PMX {label}数量无效。");
        return count;
    }

    private static string GetDerivedPath(string sourcePath)
    {
        var extension = Path.GetExtension(sourcePath);
        var stem = Path.GetFileNameWithoutExtension(sourcePath);
        if (stem.EndsWith("_Endfield_面部材质", StringComparison.OrdinalIgnoreCase)) return sourcePath;
        return Path.Combine(Path.GetDirectoryName(sourcePath)!, $"{stem}_Endfield_面部材质{extension}");
    }

    private static string UniqueProfileName(EndfieldProject project, string requested)
    {
        var candidate = requested;
        var suffix = 2;
        var used = project.Profiles.Select(profile => profile.ProfileName).ToHashSet(StringComparer.OrdinalIgnoreCase);
        while (!used.Add(candidate)) candidate = $"{requested}_{suffix++:00}";
        return candidate;
    }

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

    private sealed record SourceMaterial(int MaterialIndex, string MaterialName, ShaderDomain SourceDomain, ShaderDomain OverlayDomain);
    private sealed record RawMaterial(int Index, string Name, string EnglishName, int SurfaceIndexStart, int SurfaceIndexCount, byte[] RawRecord);
    private sealed record OverlayBuildItem(RawMaterial Source, byte[] MaterialRecord, EyeThroughOverlayBinding Binding);
    private sealed record PmxLayout(
        Encoding Encoding,
        int VertexIndexSize,
        int SurfaceIndexCountOffset,
        int SurfaceIndexCount,
        int SurfaceIndexDataOffset,
        int SurfaceIndexDataEnd,
        int MaterialCountOffset,
        int MaterialDataStart,
        int MaterialDataEnd,
        IReadOnlyList<RawMaterial> Materials);
}

public enum EyeThroughDerivedModelStatus
{
    Created,
    ReusedSibling,
    AlreadyDerived
}

public sealed class EyeThroughDerivedModelResult
{
    public required string SourcePmxPath { get; init; }
    public required string DerivedPmxPath { get; init; }
    public required EyeThroughDerivedModelStatus Status { get; init; }
    public required IReadOnlyList<EyeThroughOverlayBinding> Overlays { get; init; }
}

public sealed record EyeThroughOverlayBinding(
    int SourceMaterialIndex,
    int OverlayMaterialIndex,
    ShaderDomain SourceDomain,
    ShaderDomain Domain,
    string SourceMaterialName,
    string OverlayMaterialName);
