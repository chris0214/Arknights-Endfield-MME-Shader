"""Build the Endfield face-and-eye controller from the global PMX template.

The source controller supplies known-good geometry and bones. This tool replaces
its morph and display-frame sections with neutral bone morphs used by
EndfieldFace_controller.pmx. The global controller is never modified.
"""

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


FACE_MORPHS = (
    "SDF鋭度+",
    "SDF鋭度-",
    "RD色強+",
    "RD色強-",
    "AO強+",
    "AO強-",
    "唇高光+",
    "唇高光-",
    "唇高光移+",
    "唇高光移-",
    "唇高光淡+",
    "唇高光淡-",
    "辺光幅+",
    "辺光幅-",
    "辺光強+",
    "辺光強-",
    "辺光硬+",
    "辺光硬-",
    "辺光色切",
    "辺光赤+",
    "辺光赤-",
    "辺光緑+",
    "辺光緑-",
    "辺光青+",
    "辺光青-",
)

EYE_MORPHS = (
    "虹膜亮度+",
    "虹膜亮度-",
    "虹膜飽和+",
    "虹膜飽和-",
    "瞳孔視差+",
    "瞳孔視差-",
    "眼反射05+",
    "眼反射05-",
    "眼反射07+",
    "眼反射07-",
    "眼高光+",
    "眼高光-",
    "眼白亮度+",
    "眼白亮度-",
)

CONTROLLER_MORPHS = FACE_MORPHS + EYE_MORPHS


def build_display_frame(
    layout,
    name: str,
    indices: range,
) -> bytes:
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
    face = build_display_frame(
        layout, "面部控制", range(len(FACE_MORPHS))
    )
    eye = build_display_frame(
        layout,
        "眼睛控制",
        range(len(FACE_MORPHS), len(CONTROLLER_MORPHS)),
    )
    return struct.pack("<i", 3) + root + face + eye


def build_controller(source: Path, output: Path) -> None:
    project_root = Path(__file__).resolve().parents[1]
    contract = "\n".join(
        (project_root / "internal" / name).read_text(encoding="cp932")
        for name in (
            "endfield_face_controls.inc",
            "endfield_eye_controls.inc",
        )
    )
    shader_names = tuple(
        re.findall(r'string\s+item\s*=\s*"([^"]+)"', contract)
    )
    if shader_names != CONTROLLER_MORPHS:
        raise PmxError(
            "face/eye CONTROLOBJECT items do not match the PMX morph profile"
        )

    source_data = source.read_bytes()
    layout = locate_layout(source_data)
    description = (
        "Endfield face and eye runtime controller. "
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
        default=controller_root / "EndfieldFace_controller.pmx",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    build_controller(args.source.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
