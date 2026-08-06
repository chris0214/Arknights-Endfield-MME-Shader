"""Build the Endfield post-processing controller from the global template."""

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


MODE_MORPHS = (
    "GT模式",
    "AgX模式",
    "Neutral模式",
    "ACES模式",
    "原色模式",
)

COMMON_MORPHS = (
    "曝光+",
    "曝光-",
    "対比+",
    "対比-",
    "飽和+",
    "飽和-",
)

CURVE_MORPHS = (
    "Log2曲線+",
    "Log2曲線-",
    "GT対比+",
    "GT対比-",
    "GT肩部+",
    "GT肩部-",
    "AgX対比+",
    "AgX対比-",
    "AgX飽和+",
    "AgX飽和-",
    "Neutral肩部+",
    "Neutral肩部-",
    "Neutral脱色+",
    "Neutral脱色-",
    "ACES白点+",
    "ACES白点-",
)

BLOOM_MORPHS = (
    "Bloom強+",
    "Bloom強-",
    "Bloom閾値+",
    "Bloom閾値-",
    "Bloom柔+",
    "Bloom柔-",
    "Bloom半径+",
    "Bloom半径-",
    "Bloom範囲+",
    "Bloom範囲-",
    "Bloom赤+",
    "Bloom赤-",
    "Bloom緑+",
    "Bloom緑-",
    "Bloom藍+",
    "Bloom藍-",
    "Bloom確認",
)

OUTPUT_MORPHS = (
    "Dither強+",
    "Dither強-",
)

WHITE_BALANCE_MORPHS = (
    "色温暖",
    "色温冷",
    "色偏緑",
    "色偏紫",
)

SHARPEN_MORPHS = (
    "鋭化強",
)

CONTROLLER_MORPHS = (
    MODE_MORPHS
    + COMMON_MORPHS
    + CURVE_MORPHS
    + BLOOM_MORPHS
    + OUTPUT_MORPHS
    + WHITE_BALANCE_MORPHS
    + SHARPEN_MORPHS
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
    common_start = len(MODE_MORPHS)
    curve_start = common_start + len(COMMON_MORPHS)
    bloom_start = curve_start + len(CURVE_MORPHS)
    output_start = bloom_start + len(BLOOM_MORPHS)
    white_balance_start = output_start + len(OUTPUT_MORPHS)
    sharpen_start = white_balance_start + len(WHITE_BALANCE_MORPHS)
    frames = (
        build_display_frame(layout, "色調模式", range(len(MODE_MORPHS))),
        build_display_frame(
            layout,
            "全局調整",
            range(common_start, curve_start),
        ),
        build_display_frame(
            layout,
            "曲線細節",
            range(curve_start, bloom_start),
        ),
        build_display_frame(
            layout,
            "Bloom調整",
            range(bloom_start, output_start),
        ),
        build_display_frame(
            layout,
            "出力調整",
            range(output_start, white_balance_start),
        ),
        build_display_frame(
            layout,
            "白平衡",
            range(white_balance_start, sharpen_start),
        ),
        build_display_frame(
            layout,
            "鋭化調整",
            range(sharpen_start, len(CONTROLLER_MORPHS)),
        ),
    )
    return struct.pack("<i", 8) + root + b"".join(frames)


def build_controller(source: Path, output: Path) -> None:
    project_root = Path(__file__).resolve().parents[1]
    contract = (
        project_root / "internal" / "endfield_post_controls.inc"
    ).read_text(encoding="cp932")
    shader_names = tuple(
        re.findall(r'string\s+item\s*=\s*"([^"]+)"', contract)
    )
    if shader_names != CONTROLLER_MORPHS:
        raise PmxError(
            "post CONTROLOBJECT items do not match the PMX morph profile"
        )

    source_data = source.read_bytes()
    layout = locate_layout(source_data)
    description = (
        "Endfield post-processing runtime controller. "
        "All-zero morphs select the baked Log2 preset."
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
        default=controller_root / "EndfieldPost_controller.pmx",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    build_controller(args.source.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
