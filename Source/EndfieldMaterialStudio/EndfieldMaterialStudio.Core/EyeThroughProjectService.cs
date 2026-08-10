namespace EndfieldMaterialStudio.Core;

public static class EyeThroughProjectService
{
    public static EyeThroughBuildResult Ensure(StudioProject project)
    {
        var iris = project.Materials.Where(material => material.Role == MaterialRole.Iris)
            .Select(material => material.MaterialIndex).ToArray();
        var brow = project.Materials.Where(material => material.Role == MaterialRole.BrowLash)
            .Select(material => material.MaterialIndex).ToArray();
        var result = PmxEyeThroughBuilder.Ensure(project.PmxPath, iris, brow);
        Apply(project, result);
        return result;
    }

    public static void Apply(StudioProject project, EyeThroughBuildResult result)
    {
        var derivedModel = PmxReader.Read(result.DerivedPmxPath);
        foreach (var overlay in result.Overlays)
        {
            if (project.Materials.Any(material => material.MaterialIndex == overlay.OverlayMaterialIndex)) continue;
            var source = project.Materials.Single(material => material.MaterialIndex == overlay.SourceMaterialIndex);
            var derived = derivedModel.Materials.Single(material => material.Index == overlay.OverlayMaterialIndex);
            project.Materials.Add(new MaterialAssignment
            {
                MaterialIndex = derived.Index,
                MaterialName = derived.Name,
                EnglishName = derived.EnglishName,
                Role = overlay.OverlayRole,
                UsePmxBaseTexture = source.UsePmxBaseTexture,
                PmxBaseTexture = source.PmxBaseTexture,
                Textures = Clone(source.Textures)
            });
        }
        project.PmxPath = result.DerivedPmxPath;
    }

    private static TextureSlots Clone(TextureSlots source) => new()
    {
        Base = source.Base,
        Normal = source.Normal,
        Property = source.Property,
        Rd = source.Rd,
        Rs = source.Rs,
        Lut = source.Lut,
        Sdf = source.Sdf,
        St = source.St,
        ColorMask = source.ColorMask,
        LipSpecular = source.LipSpecular,
        HairLine = source.HairLine
    };
}
