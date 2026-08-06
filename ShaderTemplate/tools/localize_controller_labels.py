"""Convert controller morph labels to CP932-safe Chinese-readable Han text."""

from __future__ import annotations

import argparse
import base64
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

GLOBAL = {
    "Bright+": "亮部+", "Bright++": "亮部++", "Bright-": "亮部-",
    "Dark+": "暗部+", "Dark++": "暗部++", "Dark-": "暗部-",
    "Saturation+": "全局飽和+", "Saturation++": "全局飽和++",
    "Saturation-": "全局飽和-", "Brightness+": "全局亮度+",
    "Brightness++": "全局亮度++", "Brightness-": "全局亮度-",
    "LightIntensity+": "灯光強+", "LightIntensity++": "灯光強++",
    "LightIntensity-": "灯光強-", "LightR+": "灯光赤+",
    "LightG+": "灯光緑+", "LightB+": "灯光青+",
    "Day+": "日光強+", "Day-": "日光強-",
    "Ramp+": "明暗線+", "Ramp-": "明暗線-",
    "Shadow+": "陰影強+", "Shadow-": "陰影強-",
    "SelfShadow+": "自陰影+", "SelfShadow++": "自陰影++",
    "SelfShadow-": "自陰影-", "Specular+": "全局高光+",
    "Specular++": "全局高光++", "Specular-": "全局高光-",
    "Rim+": "全局辺光+", "Rim-": "全局辺光-",
    "HairSpecUp": "髪高光上移", "HairSpecDown": "髪高光下移",
    "HairSaturation+": "髪飽和+", "HairSaturation-": "髪飽和-",
    "HairBrightness+": "髪亮度+", "HairBrightness-": "髪亮度-",
    "HairExposure+": "髪曝光+", "HairExposure-": "髪曝光-",
    "RainAmount": "雨量",
    "RainDropSize+": "雨滴大小+", "RainDropSize-": "雨滴大小-",
    "RainDropFade+": "雨滴消散+", "RainDropFade-": "雨滴消散-",
}

HAIR = {
    "HighlightIntensity+": "高光強+", "HighlightIntensity-": "高光強-",
    "HighlightUp": "高光上移", "HighlightDown": "高光下移",
    "UpperRatio+": "上層比+", "UpperRatio-": "上層比-",
    "UpperSharpness+": "上層硬+", "UpperSharpness-": "上層硬-",
    "LowerSoftness+": "下層柔+", "LowerSoftness-": "下層柔-",
    "LayerBlend+": "分層混+", "LayerBlend-": "分層混-",
    "HighlightWarmth+": "高光暖+", "HighlightWarmth-": "高光暖-",
    "MiddleSaturation+": "中層飽和+", "MiddleSaturation-": "中層飽和-",
    "UpperR+": "上層赤+", "UpperR-": "上層赤-",
    "UpperG+": "上層緑+", "UpperG-": "上層緑-",
    "UpperB+": "上層青+", "UpperB-": "上層青-",
    "MiddleR+": "中層赤+", "MiddleR-": "中層赤-",
    "MiddleG+": "中層緑+", "MiddleG-": "中層緑-",
    "MiddleB+": "中層青+", "MiddleB-": "中層青-",
    "BaseR+": "基色赤+", "BaseR-": "基色赤-",
    "BaseG+": "基色緑+", "BaseG-": "基色緑-",
    "BaseB+": "基色青+", "BaseB-": "基色青-",
    "BaseSaturation+": "基色飽和+", "BaseSaturation-": "基色飽和-",
    "BaseBrightness+": "基色亮度+", "BaseBrightness-": "基色亮度-",
    "BaseExposure+": "基色曝光+", "BaseExposure-": "基色曝光-",
    "HairRim+": "辺光強+", "HairRim-": "辺光強-",
    "OuterHNormal+": "外層法線+", "OuterHNormal-": "外層法線-",
    "HighlightScaleX+": "高光横幅+", "HighlightScaleX-": "高光横幅-",
    "HighlightScaleY+": "高光縦厚+", "HighlightScaleY-": "高光縦厚-",
    "Jaggedness+": "鋸歯強+", "Jaggedness-": "鋸歯強-",
    "JaggedFrequencyX+": "鋸歯密度+", "JaggedFrequencyX-": "鋸歯密度-",
    "TopLight+": "頂光強+", "TopLight-": "頂光強-",
    "TopLightOffset+": "頂光位置+", "TopLightOffset-": "頂光位置-",
    "DarkLineStrength+": "暗線強+", "DarkLineStrength-": "暗線強-",
    "DarkLineSaturation+": "暗線飽和+", "DarkLineSaturation-": "暗線飽和-",
    "FaceShadowLeft": "髪影左移", "FaceShadowRight": "髪影右移",
    "FaceShadowUp": "髪影上移", "FaceShadowDown": "髪影下移",
    "FaceShadowStrength+": "髪影強+", "FaceShadowStrength-": "髪影強-",
    "FaceShadowBrightness+": "髪影亮+", "FaceShadowBrightness-": "髪影亮-",
    "FaceShadowR+": "髪影赤+", "FaceShadowR-": "髪影赤-",
    "FaceShadowG+": "髪影緑+", "FaceShadowG-": "髪影緑-",
    "FaceShadowB+": "髪影青+", "FaceShadowB-": "髪影青-",
    "HairRimWidth+": "辺光幅+", "HairRimWidth-": "辺光幅-",
    "HairRimContrast+": "辺光硬+", "HairRimContrast-": "辺光硬-",
    "HairRimColorMode": "辺光色切",
    "HairRimR+": "辺光赤+", "HairRimR-": "辺光赤-",
    "HairRimG+": "辺光緑+", "HairRimG-": "辺光緑-",
    "HairRimB+": "辺光青+", "HairRimB-": "辺光青-",
}

FACE = {
    "SDFSharpness+": "SDF鋭度+", "SDFSharpness-": "SDF鋭度-",
    "RDColor+": "RD色強+", "RDColor-": "RD色強-",
    "AO+": "AO強+", "AO-": "AO強-",
    "LipSpec+": "唇高光+", "LipSpec-": "唇高光-",
    "LipMove+": "唇高光移+", "LipMove-": "唇高光移-",
    "LipFade+": "唇高光淡+", "LipFade-": "唇高光淡-",
    "RimWidth+": "辺光幅+", "RimWidth-": "辺光幅-",
    "RimStrength+": "辺光強+", "RimStrength-": "辺光強-",
    "RimContrast+": "辺光硬+", "RimContrast-": "辺光硬-",
    "RimColorMode": "辺光色切",
    "RimR+": "辺光赤+", "RimR-": "辺光赤-",
    "RimG+": "辺光緑+", "RimG-": "辺光緑-",
    "RimB+": "辺光青+", "RimB-": "辺光青-",
    "IrisBrightness+": "虹膜亮度+", "IrisBrightness-": "虹膜亮度-",
    "IrisSaturation+": "虹膜飽和+", "IrisSaturation-": "虹膜飽和-",
    "IrisParallax+": "瞳孔視差+", "IrisParallax-": "瞳孔視差-",
    "Matcap05+": "眼反射05+", "Matcap05-": "眼反射05-",
    "Matcap07+": "眼反射07+", "Matcap07-": "眼反射07-",
    "EyeHL+": "眼高光+", "EyeHL-": "眼高光-",
    "EyeWhite+": "眼白亮度+", "EyeWhite-": "眼白亮度-",
}

SKIN = {
    "SkinLight+": "皮膚亮部+", "SkinLight-": "皮膚亮部-",
    "SkinDark+": "皮膚暗部+", "SkinDark-": "皮膚暗部-",
    "RampCurve+": "明暗曲線+", "RampCurve-": "明暗曲線-",
    "RDColor+": "RD色強+", "RDColor-": "RD色強-",
    "LUT+": "LUT強+", "LUT-": "LUT強-",
    "SSSRange+": "SSS範囲+", "SSSRange-": "SSS範囲-",
    "SSSStrength+": "SSS強+", "SSSStrength-": "SSS強-",
    "SSSR+": "SSS赤+", "SSSR-": "SSS赤-",
    "SSSG+": "SSS緑+", "SSSG-": "SSS緑-",
    "SSSB+": "SSS青+", "SSSB-": "SSS青-",
    "ShadowStrength+": "陰影強+", "ShadowStrength-": "陰影強-",
    "ShadowSoftness+": "陰影柔+", "ShadowSoftness-": "陰影柔-",
    "ShadowCenter+": "陰影位置+", "ShadowCenter-": "陰影位置-",
    "SkinSpecStrength+": "微高光強+", "SkinSpecStrength-": "微高光強-",
    "RimStrength+": "辺光強+", "RimStrength-": "辺光強-",
    "RimWidth+": "辺光幅+", "RimWidth-": "辺光幅-",
    "RimR+": "辺光赤+", "RimR-": "辺光赤-",
    "RimG+": "辺光緑+", "RimG-": "辺光緑-",
    "RimB+": "辺光青+", "RimB-": "辺光青-",
    "ScreenRimStrength+": "屏幕辺光強+", "ScreenRimStrength-": "屏幕辺光強-",
    "ScreenRimWidth+": "屏幕辺光幅+", "ScreenRimWidth-": "屏幕辺光幅-",
    "RimColorMode": "辺光色切",
    "RimContrast+": "辺光硬+", "RimContrast-": "辺光硬-",
}

CLOTH = {
    "ClothLight+": "衣服亮部+", "ClothLight-": "衣服亮部-",
    "ClothDark+": "衣服暗部+", "ClothDark-": "衣服暗部-",
    "RampCurve+": "明暗曲線+", "RampCurve-": "明暗曲線-",
    "RDColor+": "RD色強+", "RDColor-": "RD色強-",
    "LUT+": "LUT強+", "LUT-": "LUT強-",
    "AODark+": "暗部AO+", "AODark-": "暗部AO-",
    "AOLight+": "亮部AO+", "AOLight-": "亮部AO-",
    "Metallic+": "金属度+", "Metallic-": "金属度-",
    "Roughness+": "粗度+", "Roughness-": "粗度-",
    "Reflectivity+": "反射度+", "Reflectivity-": "反射度-",
    "RS+": "RS強+", "RS-": "RS強-",
    "NormalStrength+": "法線強+", "NormalStrength-": "法線強-",
    "NormalFlipY": "法線Y反向",
    "Specular+": "高光強+", "Specular-": "高光強-",
    "BroadSpecular+": "広域高光+", "BroadSpecular-": "広域高光-",
    "AnisoSpecular+": "異方高光+", "AnisoSpecular-": "異方高光-",
    "AnisoAmount+": "異方程度+", "AnisoAmount-": "異方程度-",
    "AnisoAxis+": "異方軸+", "AnisoAxis-": "異方軸-",
    "AnisoRoughness+": "異方粗度+", "AnisoRoughness-": "異方粗度-",
    "EnvMode": "環境模式", "FGDOff": "FGD閉",
    "EnvSpecular+": "環境高光+", "EnvSpecular-": "環境高光-",
    "MatcapBlur+": "反射模糊+", "MatcapBlur-": "反射模糊-",
    "EnvRotation+": "環境旋転+", "EnvRotation-": "環境旋転-",
    "EnvAO+": "環境AO+", "EnvAO-": "環境AO-",
    "EnvR+": "環境赤+", "EnvR-": "環境赤-",
    "EnvG+": "環境緑+", "EnvG-": "環境緑-",
    "EnvB+": "環境青+", "EnvB-": "環境青-",
    "RimStrength+": "辺光強+", "RimStrength-": "辺光強-",
    "RimWidth+": "辺光幅+", "RimWidth-": "辺光幅-",
    "ScreenRimStrength+": "屏幕辺光強+", "ScreenRimStrength-": "屏幕辺光強-",
    "ScreenRimWidth+": "屏幕辺光幅+", "ScreenRimWidth-": "屏幕辺光幅-",
    "RimContrast+": "辺光硬+", "RimContrast-": "辺光硬-",
    "RimColorMode": "辺光色切",
    "RimR+": "辺光赤+", "RimR-": "辺光赤-",
    "RimG+": "辺光緑+", "RimG-": "辺光緑-",
    "RimB+": "辺光青+", "RimB-": "辺光青-",
    "ShadowStrength+": "陰影強+", "ShadowStrength-": "陰影強-",
    "ShadowSoftness+": "陰影柔+", "ShadowSoftness-": "陰影柔-",
    "ShadowCenter+": "陰影位置+", "ShadowCenter-": "陰影位置-",
    "DirectShadowFloor+": "直射陰影底+", "DirectShadowFloor-": "直射陰影底-",
    "EnvShadow+": "環境陰影+", "EnvShadow-": "環境陰影-",
}


def build_outline_mapping() -> dict[str, str]:
    mapping: dict[str, str] = {}
    parts = (
        ("髪", "頭髪"),
        ("顔", "面部"),
        ("肌", "皮膚"),
        ("服", "衣服"),
    )
    controls = (
        ("幅+", "描辺寛度+"), ("幅-", "描辺寛度-"),
        ("強+", "描辺強度+"), ("強-", "描辺強度-"),
        ("硬+", "描辺対比度+"), ("硬-", "描辺対比度-"),
        ("色切", "描辺色模式"),
        ("赤+", "描辺紅+"), ("赤-", "描辺紅-"),
        ("緑+", "描辺緑+"), ("緑-", "描辺緑-"),
        ("青+", "描辺藍+"), ("青-", "描辺藍-"),
    )
    for old_part, new_part in parts:
        for old_control, new_control in controls:
            mapping[old_part + old_control] = new_part + new_control
    return mapping


OUTLINE = build_outline_mapping()


TARGETS = (
    ("internal/endfield_global_controls.inc", GLOBAL, "cp932"),
    ("internal/endfield_rain_controls.inc", GLOBAL, "cp932"),
    ("internal/endfield_controls.inc", GLOBAL, "cp932"),
    ("tools/build_hair_controller.py", HAIR, "utf-8"),
    ("internal/endfield_hair_controls.inc", HAIR, "cp932"),
    ("internal/endfield_hair_controls_c5.inc", HAIR, "cp932"),
    ("docs/hair_controller_spec.md", HAIR, "utf-8"),
    ("tools/build_face_controller.py", FACE, "utf-8"),
    ("internal/endfield_face_controls.inc", FACE, "cp932"),
    ("internal/endfield_eye_controls.inc", FACE, "cp932"),
    ("docs/face_controller_spec.md", FACE, "utf-8"),
    ("docs/face_rendering_analysis.md", FACE, "utf-8"),
    ("tools/build_skin_controller.py", SKIN, "utf-8"),
    ("internal/endfield_skin_controls.inc", SKIN, "cp932"),
    ("docs/skin_controller_spec.md", SKIN, "utf-8"),
    ("tools/build_cloth_controller.py", CLOTH, "utf-8"),
    ("internal/endfield_cloth_controls.inc", CLOTH, "cp932"),
    ("docs/cloth_controller_spec.md", CLOTH, "utf-8"),
    ("internal/endfield_outline_controls.cp932", OUTLINE, "cp932"),
    ("docs/controller_spec.md", GLOBAL, "utf-8"),
)


def read_source(path: Path) -> str:
    data = path.read_bytes()
    for encoding in ("utf-8", "cp932"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            pass
    raise UnicodeError(f"cannot decode {path}")


def localize(
    path: Path,
    mapping: dict[str, str],
    encoding: str,
    output: Path | None = None,
    stdout_base64: bool = False,
) -> None:
    text = read_source(path)
    for old, new in mapping.items():
        if path.suffix.lower() == ".md":
            text = text.replace(old, new)
        else:
            text = text.replace(f'"{old}"', f'"{new}"')
    unresolved = [old for old in mapping if f'"{old}"' in text]
    if unresolved:
        raise ValueError(f"unresolved labels in {path}: {unresolved}")
    if encoding == "cp932":
        text.encode("cp932")
    else:
        for label in mapping.values():
            label.encode("cp932")
    if stdout_base64:
        print(base64.b64encode(text.encode(encoding)).decode("ascii"))
        return
    destination = output or path
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(text, encoding=encoding, newline="")
    print(f"localized: {path.relative_to(ROOT)} -> {destination} ({encoding})")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--only",
        action="append",
        default=[],
        help="localize only this project-relative target; may be repeated",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="write one selected target to a separate output path",
    )
    parser.add_argument(
        "--stdout-base64",
        action="store_true",
        help="emit one selected localized target as Base64",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    selected = set(args.only)
    known = {relative for relative, _, _ in TARGETS}
    unknown = selected - known
    if unknown:
        raise ValueError(f"unknown localization targets: {sorted(unknown)}")
    if args.output and len(selected) != 1:
        raise ValueError("--output requires exactly one --only target")
    if args.stdout_base64 and len(selected) != 1:
        raise ValueError("--stdout-base64 requires exactly one --only target")
    if args.stdout_base64 and args.output:
        raise ValueError("--stdout-base64 and --output are mutually exclusive")
    for relative, mapping, encoding in TARGETS:
        if selected and relative not in selected:
            continue
        localize(
            ROOT / relative,
            mapping,
            encoding,
            args.output,
            args.stdout_base64,
        )


if __name__ == "__main__":
    main()
