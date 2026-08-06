"""Rebuild the global controller from its CP932 shader binding contract."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
from pathlib import Path

from build_hair_controller import (
    PmxError,
    Reader,
    build_morph,
    locate_layout,
    pack_index,
    pack_text,
    read_morph_names,
)


RAIN_CONTROLLER_BONE = "全ての親"
RAIN_MORPH_OFFSETS = (
    ("雨量", (1.0, 0.0, 0.0)),
    ("雨滴大小+", (0.0, 1.0, 0.0)),
    ("雨滴大小-", (0.0, -1.0, 0.0)),
    ("雨滴消散+", (0.0, 0.0, 1.0)),
    ("雨滴消散-", (0.0, 0.0, -1.0)),
)


def contract_names(root: Path, filename: str) -> tuple[str, ...]:
    text = (root / filename).read_text(encoding="cp932")
    return tuple(re.findall(r'string\s+item\s*=\s*"([^"]+)"', text))


def display_frame(layout, name: str, indices: range) -> bytes:
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


def build_display_frames(
    layout, color_count: int, rain_count: int, total: int
) -> bytes:
    root_elements = b"\x00" + pack_index(0, layout.bone_index_size)
    root = b"".join((
        pack_text("Root", layout.encoding),
        pack_text("Root", layout.encoding),
        struct.pack("<Bi", 1, 1),
        root_elements,
    ))
    color = display_frame(layout, "全局色調", range(color_count))
    rain_end = color_count + rain_count
    rain = display_frame(layout, "雨水控制", range(color_count, rain_end))
    light = display_frame(layout, "全局灯光", range(rain_end, total))
    return struct.pack("<i", 4) + root + color + rain + light


def build_bone_morph(name: str, layout, translation: tuple[float, float, float]) -> bytes:
    if layout.bone_count < 1:
        raise PmxError("source controller must contain at least one bone")
    return b"".join((
        pack_text(name, layout.encoding),
        pack_text(name, layout.encoding),
        struct.pack("<BBi", 4, 2, 1),
        pack_index(0, layout.bone_index_size),
        struct.pack("<7f", *translation, 0.0, 0.0, 0.0, 1.0),
    ))


def read_bone_morph_translations(
    data: bytes,
) -> tuple[tuple[str, tuple[float, float, float]], ...]:
    layout = locate_layout(data)
    reader = Reader(data)
    reader.pos = layout.morph_offset
    count = reader.i32()
    index_format = {1: "<b", 2: "<h", 4: "<i"}[layout.bone_index_size]
    result = []
    for _ in range(count):
        name = reader.text(layout.encoding)
        reader.text(layout.encoding)
        panel = reader.u8()
        morph_type = reader.u8()
        offset_count = reader.i32()
        if panel != 4 or morph_type != 2 or offset_count != 1:
            raise PmxError("global controller must contain one-offset bone morphs")
        bone_index = struct.unpack(
            index_format, reader.read(layout.bone_index_size)
        )[0]
        translation = reader.unpack("<3f")
        rotation = reader.unpack("<4f")
        if bone_index != 0 or rotation != (0.0, 0.0, 0.0, 1.0):
            raise PmxError("global controller morph targets an unexpected bone transform")
        result.append((name, translation))
    return tuple(result)


def build_controller(source: Path, output: Path) -> None:
    internal = Path(__file__).resolve().parents[1] / "internal"
    color_names = contract_names(internal, "endfield_global_controls.inc")
    rain_contract = contract_names(internal, "endfield_rain_controls.inc")
    if rain_contract != (RAIN_CONTROLLER_BONE,):
        raise PmxError("rain shader must read the packed root-bone controller")
    rain_names = tuple(name for name, _ in RAIN_MORPH_OFFSETS)
    light_names = contract_names(internal, "endfield_controls.inc")
    morph_names = color_names + rain_names + light_names
    if len(set(morph_names)) != len(morph_names):
        raise PmxError("global controller contains duplicate morph labels")

    source_data = source.read_bytes()
    layout = locate_layout(source_data)
    description = "Endfield global runtime controller. CP932 Chinese labels."
    metadata = b"".join((
        pack_text(output.stem, layout.encoding),
        pack_text(output.stem, layout.encoding),
        pack_text(description, layout.encoding),
        pack_text(description, layout.encoding),
    ))
    rain_offsets = dict(RAIN_MORPH_OFFSETS)
    morphs = b"".join(
        build_bone_morph(name, layout, rain_offsets[name])
        if name in rain_offsets
        else build_morph(name, layout)
        for name in morph_names
    )
    output_data = b"".join((
        source_data[:layout.fixed_header_end],
        metadata,
        source_data[layout.metadata_end:layout.morph_offset],
        struct.pack("<i", len(morph_names)),
        morphs,
        build_display_frames(
            layout, len(color_names), len(rain_names), len(morph_names)
        ),
        source_data[layout.rigid_body_offset:],
    ))
    if read_morph_names(output_data) != morph_names:
        raise PmxError("generated global morph names are invalid")
    expected_translations = tuple(
        (name, rain_offsets.get(name, (0.0, 0.0, 0.0)))
        for name in morph_names
    )
    if read_bone_morph_translations(output_data) != expected_translations:
        raise PmxError("generated global morph translations are invalid")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(output_data)
    digest = hashlib.sha256(output_data).hexdigest().upper()
    print(f"wrote: {output}")
    print(f"morphs: {len(morph_names)}")
    print(f"bytes: {len(output_data)}")
    print(f"sha256: {digest}")


def main() -> None:
    root = Path(__file__).resolve().parents[1] / "controller"
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=root / "Endfield_controller.pmx")
    parser.add_argument("--output", type=Path, default=root / "Endfield_controller.pmx")
    args = parser.parse_args()
    build_controller(args.source.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
