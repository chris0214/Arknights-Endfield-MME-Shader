"""Build the Endfield clothing controller from the global PMX template."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
from pathlib import Path

from build_hair_controller import (
    PmxError,
    build_morph,
    locate_layout,
    pack_index,
    pack_text,
    read_morph_names,
)


TONE_MORPHS = (
    "衣服亮部+", "衣服亮部-", "衣服暗部+", "衣服暗部-",
    "明暗曲線+", "明暗曲線-", "RD色強+", "RD色強-", "LUT強+", "LUT強-",
)
AO_MORPHS = ("暗部AO+", "暗部AO-", "亮部AO+", "亮部AO-")
SURFACE_MORPHS = (
    "金属度+", "金属度-", "粗度+", "粗度-",
    "反射度+", "反射度-", "RS強+", "RS強-",
    "法線強+", "法線強-", "法線Y反向",
)
SPECULAR_MORPHS = (
    "高光強+", "高光強-", "広域高光+", "広域高光-",
    "異方高光+", "異方高光-", "異方程度+", "異方程度-",
    "異方軸+", "異方軸-", "異方粗度+", "異方粗度-",
)
ENV_MORPHS = (
    "環境模式", "FGD閉", "環境高光+", "環境高光-",
    "反射模糊+", "反射模糊-",
    "環境旋転+", "環境旋転-",
    "環境AO+", "環境AO-", "環境赤+", "環境赤-", "環境緑+", "環境緑-",
    "環境青+", "環境青-",
)
RIM_MORPHS = (
    "辺光強+", "辺光強-", "辺光幅+", "辺光幅-",
    "屏幕辺光強+", "屏幕辺光強-",
    "屏幕辺光幅+", "屏幕辺光幅-",
    "辺光硬+", "辺光硬-", "辺光色切",
    "辺光赤+", "辺光赤-", "辺光緑+", "辺光緑-", "辺光青+", "辺光青-",
)
SHADOW_MORPHS = (
    "陰影強+", "陰影強-", "陰影柔+",
    "陰影柔-", "陰影位置+", "陰影位置-",
    "直射陰影底+", "直射陰影底-", "環境陰影+", "環境陰影-",
)
CONTROLLER_MORPHS = (
    TONE_MORPHS + AO_MORPHS + SURFACE_MORPHS + SPECULAR_MORPHS
    + ENV_MORPHS + RIM_MORPHS + SHADOW_MORPHS
)


def build_display_frame(layout, name: str, indices: range) -> bytes:
    elements = b"".join(
        b"\x01" + pack_index(index, layout.morph_index_size)
        for index in indices
    )
    return b"".join((
        pack_text(name, layout.encoding),
        pack_text(name, layout.encoding),
        struct.pack("<Bi", 1, len(indices)),
        elements,
    ))


def build_display_frames(layout) -> bytes:
    root_elements = b"\x00" + pack_index(0, layout.bone_index_size)
    root = b"".join((
        pack_text("Root", layout.encoding),
        pack_text("Root", layout.encoding),
        struct.pack("<Bi", 1, 1),
        root_elements,
    ))
    groups = (
        ("衣服明暗", TONE_MORPHS),
        ("衣服AO", AO_MORPHS),
        ("衣服表面", SURFACE_MORPHS),
        ("衣服高光", SPECULAR_MORPHS),
        ("衣服環境", ENV_MORPHS),
        ("衣服辺光", RIM_MORPHS),
        ("衣服陰影", SHADOW_MORPHS),
    )
    frames = []
    start = 0
    for name, morphs in groups:
        frames.append(build_display_frame(
            layout, name, range(start, start + len(morphs))))
        start += len(morphs)
    return struct.pack("<i", 1 + len(frames)) + root + b"".join(frames)


def build_controller(source: Path, output: Path) -> None:
    project_root = Path(__file__).resolve().parents[1]
    contract = (
        project_root / "internal" / "endfield_cloth_controls.inc"
    ).read_text(encoding="cp932")
    shader_names = tuple(
        re.findall(r'string\s+item\s*=\s*"([^"]+)"', contract)
    )
    if shader_names != CONTROLLER_MORPHS:
        raise PmxError(
            "cloth CONTROLOBJECT items do not match the PMX morph profile"
        )

    source_data = source.read_bytes()
    layout = locate_layout(source_data)
    description = (
        "Endfield clothing runtime controller. "
        "Morphs are read by MME CONTROLOBJECT."
    )
    metadata = b"".join((
        pack_text(output.stem, layout.encoding),
        pack_text(output.stem, layout.encoding),
        pack_text(description, layout.encoding),
        pack_text(description, layout.encoding),
    ))
    morphs = b"".join(
        build_morph(name, layout) for name in CONTROLLER_MORPHS
    )
    output_data = b"".join((
        source_data[:layout.fixed_header_end],
        metadata,
        source_data[layout.metadata_end:layout.morph_offset],
        struct.pack("<i", len(CONTROLLER_MORPHS)),
        morphs,
        build_display_frames(layout),
        source_data[layout.rigid_body_offset:],
    ))

    names = read_morph_names(output_data)
    if names != CONTROLLER_MORPHS:
        raise PmxError("generated morph names do not match the shader contract")

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(output_data)
    digest = hashlib.sha256(output_data).hexdigest().upper()
    print(f"wrote: {output}")
    print(f"morphs: {len(names)}")
    print(f"bytes: {len(output_data)}")
    print(f"sha256: {digest}")


def parse_args() -> argparse.Namespace:
    project_root = Path(__file__).resolve().parents[1]
    controller_root = project_root / "controller"
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source", type=Path,
        default=controller_root / "Endfield_controller.pmx")
    parser.add_argument(
        "--output", type=Path,
        default=controller_root / "EndfieldCloth_controller.pmx")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    build_controller(args.source.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
