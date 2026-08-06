"""Build the Endfield body-skin controller from the global PMX template."""

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
    "皮膚亮部+",
    "皮膚亮部-",
    "皮膚暗部+",
    "皮膚暗部-",
    "明暗曲線+",
    "明暗曲線-",
    "RD色強+",
    "RD色強-",
    "LUT強+",
    "LUT強-",
)

SSS_MORPHS = (
    "SSS範囲+",
    "SSS範囲-",
    "SSS強+",
    "SSS強-",
    "SSS赤+",
    "SSS赤-",
    "SSS緑+",
    "SSS緑-",
    "SSS青+",
    "SSS青-",
)

SHADOW_MORPHS = (
    "陰影強+",
    "陰影強-",
    "陰影柔+",
    "陰影柔-",
    "陰影位置+",
    "陰影位置-",
)

SPECULAR_MORPHS = (
    "微高光強+",
    "微高光強-",
)

RIM_MORPHS = (
    "辺光強+",
    "辺光強-",
    "辺光幅+",
    "辺光幅-",
    "辺光赤+",
    "辺光赤-",
    "辺光緑+",
    "辺光緑-",
    "辺光青+",
    "辺光青-",
    "屏幕辺光強+",
    "屏幕辺光強-",
    "屏幕辺光幅+",
    "屏幕辺光幅-",
    "辺光色切",
    "辺光硬+",
    "辺光硬-",
)

CONTROLLER_MORPHS = (
    TONE_MORPHS
    + SSS_MORPHS
    + SHADOW_MORPHS
    + SPECULAR_MORPHS
    + RIM_MORPHS
)


def build_display_frame(layout, name: str, indices: range) -> bytes:
    elements = b"".join(
        b"\x01" + pack_index(index, layout.morph_index_size)
        for index in indices
    )
    return b"".join(
        (
            pack_text(name, layout.encoding),
            pack_text(name, layout.encoding),
            struct.pack("<Bi", 1, len(indices)),
            elements,
        )
    )


def build_display_frames(layout) -> bytes:
    root_elements = b"\x00" + pack_index(0, layout.bone_index_size)
    root = b"".join(
        (
            pack_text("Root", layout.encoding),
            pack_text("Root", layout.encoding),
            struct.pack("<Bi", 1, 1),
            root_elements,
        )
    )
    starts = (
        0,
        len(TONE_MORPHS),
        len(TONE_MORPHS) + len(SSS_MORPHS),
        len(TONE_MORPHS) + len(SSS_MORPHS) + len(SHADOW_MORPHS),
        len(TONE_MORPHS)
        + len(SSS_MORPHS)
        + len(SHADOW_MORPHS)
        + len(SPECULAR_MORPHS),
    )
    groups = (
        ("皮膚明暗", TONE_MORPHS),
        ("皮膚SSS", SSS_MORPHS),
        ("皮膚陰影", SHADOW_MORPHS),
        ("皮膚高光", SPECULAR_MORPHS),
        ("皮膚辺光", RIM_MORPHS),
    )
    frames = tuple(
        build_display_frame(
            layout, name, range(start, start + len(morphs))
        )
        for start, (name, morphs) in zip(starts, groups)
    )
    return struct.pack("<i", 1 + len(frames)) + root + b"".join(frames)


def build_controller(source: Path, output: Path) -> None:
    project_root = Path(__file__).resolve().parents[1]
    contract = (
        project_root / "internal" / "endfield_skin_controls.inc"
    ).read_text(encoding="cp932")
    shader_names = tuple(
        re.findall(r'string\s+item\s*=\s*"([^"]+)"', contract)
    )
    if shader_names != CONTROLLER_MORPHS:
        raise PmxError(
            "skin CONTROLOBJECT items do not match the PMX morph profile"
        )

    source_data = source.read_bytes()
    layout = locate_layout(source_data)
    description = (
        "Endfield body-skin runtime controller. "
        "Morphs are read by MME CONTROLOBJECT."
    )
    metadata = b"".join(
        (
            pack_text(output.stem, layout.encoding),
            pack_text(output.stem, layout.encoding),
            pack_text(description, layout.encoding),
            pack_text(description, layout.encoding),
        )
    )
    morphs = b"".join(
        build_morph(name, layout) for name in CONTROLLER_MORPHS
    )
    output_data = b"".join(
        (
            source_data[: layout.fixed_header_end],
            metadata,
            source_data[layout.metadata_end : layout.morph_offset],
            struct.pack("<i", len(CONTROLLER_MORPHS)),
            morphs,
            build_display_frames(layout),
            source_data[layout.rigid_body_offset :],
        )
    )

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
        "--source",
        type=Path,
        default=controller_root / "Endfield_controller.pmx",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=controller_root / "EndfieldSkin_controller.pmx",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    build_controller(args.source.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
