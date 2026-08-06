"""Build the dedicated Endfield hair controller from the global PMX template.

The source controller supplies known-good geometry and bones. This tool replaces
its morph and display-frame sections with the production Range5 neutral bone
morph contract. The global controller is never modified.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
from dataclasses import dataclass
from pathlib import Path


HAIR_MORPHS = (
    "高光強+",
    "高光強-",
    "高光上移",
    "高光下移",
    "上層比+",
    "上層比-",
    "上層硬+",
    "上層硬-",
    "下層柔+",
    "下層柔-",
    "分層混+",
    "分層混-",
    "高光暖+",
    "高光暖-",
    "中層飽和+",
    "中層飽和-",
    "上層赤+",
    "上層赤-",
    "上層緑+",
    "上層緑-",
    "上層青+",
    "上層青-",
    "中層赤+",
    "中層赤-",
    "中層緑+",
    "中層緑-",
    "中層青+",
    "中層青-",
    "基色赤+",
    "基色赤-",
    "基色緑+",
    "基色緑-",
    "基色青+",
    "基色青-",
    "基色飽和+",
    "基色飽和-",
    "基色亮度+",
    "基色亮度-",
    "基色曝光+",
    "基色曝光-",
    "辺光強+",
    "辺光強-",
)

C5_HAIR_MORPHS = HAIR_MORPHS + (
    "外層法線+",
    "外層法線-",
    "高光横幅+",
    "高光横幅-",
    "高光縦厚+",
    "高光縦厚-",
    "鋸歯強+",
    "鋸歯強-",
    "鋸歯密度+",
    "鋸歯密度-",
    "頂光強+",
    "頂光強-",
    "頂光位置+",
    "頂光位置-",
    "暗線強+",
    "暗線強-",
    "暗線飽和+",
    "暗線飽和-",
    "髪影左移",
    "髪影右移",
    "髪影上移",
    "髪影下移",
    "髪影強+",
    "髪影強-",
    "髪影亮+",
    "髪影亮-",
    "髪影赤+",
    "髪影赤-",
    "髪影緑+",
    "髪影緑-",
    "髪影青+",
    "髪影青-",
    "辺光幅+",
    "辺光幅-",
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


class PmxError(ValueError):
    pass


class Reader:
    def __init__(self, data: bytes) -> None:
        self.data = data
        self.pos = 0

    def read(self, size: int) -> bytes:
        end = self.pos + size
        if size < 0 or end > len(self.data):
            raise PmxError(f"unexpected EOF at {self.pos}, requested {size} bytes")
        value = self.data[self.pos:end]
        self.pos = end
        return value

    def unpack(self, fmt: str):
        size = struct.calcsize(fmt)
        return struct.unpack(fmt, self.read(size))

    def u8(self) -> int:
        return self.unpack("<B")[0]

    def u16(self) -> int:
        return self.unpack("<H")[0]

    def i32(self) -> int:
        return self.unpack("<i")[0]

    def f32(self) -> float:
        return self.unpack("<f")[0]

    def skip(self, size: int) -> None:
        self.read(size)

    def text(self, encoding: str) -> str:
        byte_count = self.i32()
        if byte_count < 0:
            raise PmxError(f"negative PMX text length at {self.pos - 4}")
        return self.read(byte_count).decode(encoding)


@dataclass(frozen=True)
class Layout:
    fixed_header_end: int
    metadata_end: int
    morph_offset: int
    rigid_body_offset: int
    encoding: str
    vertex_index_size: int
    texture_index_size: int
    material_index_size: int
    bone_index_size: int
    morph_index_size: int
    rigid_index_size: int
    additional_uv_count: int
    bone_count: int


def _validate_index_size(size: int, label: str) -> int:
    if size not in (1, 2, 4):
        raise PmxError(f"unsupported {label} index size: {size}")
    return size


def _skip_index(reader: Reader, size: int) -> None:
    reader.skip(size)


def _skip_vertices(reader: Reader, layout_values: dict[str, int]) -> None:
    vertex_count = reader.i32()
    if vertex_count < 0:
        raise PmxError("negative vertex count")
    bone_size = layout_values["bone_index_size"]
    add_uv = layout_values["additional_uv_count"]
    for _ in range(vertex_count):
        reader.skip(12 + 12 + 8 + add_uv * 16)
        weight_type = reader.u8()
        if weight_type == 0:  # BDEF1
            reader.skip(bone_size)
        elif weight_type == 1:  # BDEF2
            reader.skip(bone_size * 2 + 4)
        elif weight_type in (2, 4):  # BDEF4 / QDEF
            reader.skip(bone_size * 4 + 16)
        elif weight_type == 3:  # SDEF
            reader.skip(bone_size * 2 + 4 + 36)
        else:
            raise PmxError(f"unsupported vertex weight type: {weight_type}")
        reader.skip(4)  # edge scale


def _skip_materials(reader: Reader, values: dict[str, int], encoding: str) -> None:
    material_count = reader.i32()
    if material_count < 0:
        raise PmxError("negative material count")
    for _ in range(material_count):
        reader.text(encoding)
        reader.text(encoding)
        reader.skip(16 + 12 + 4 + 12)
        reader.skip(1 + 16 + 4)
        reader.skip(values["texture_index_size"] * 2)
        reader.skip(1)
        shared_toon = reader.u8()
        if shared_toon == 0:
            reader.skip(values["texture_index_size"])
        elif shared_toon == 1:
            reader.skip(1)
        else:
            raise PmxError(f"invalid shared toon flag: {shared_toon}")
        reader.text(encoding)
        reader.skip(4)


def _skip_bones(reader: Reader, bone_size: int, encoding: str) -> int:
    bone_count = reader.i32()
    if bone_count < 0:
        raise PmxError("negative bone count")
    for _ in range(bone_count):
        reader.text(encoding)
        reader.text(encoding)
        reader.skip(12)
        reader.skip(bone_size + 4)
        flags = reader.u16()
        if flags & 0x0001:
            reader.skip(bone_size)
        else:
            reader.skip(12)
        if flags & (0x0100 | 0x0200):
            reader.skip(bone_size + 4)
        if flags & 0x0400:
            reader.skip(12)
        if flags & 0x0800:
            reader.skip(24)
        if flags & 0x2000:
            reader.skip(4)
        if flags & 0x0020:
            reader.skip(bone_size + 4 + 4)
            link_count = reader.i32()
            if link_count < 0:
                raise PmxError("negative IK link count")
            for _ in range(link_count):
                reader.skip(bone_size)
                has_limits = reader.u8()
                if has_limits:
                    reader.skip(24)
    return bone_count


def _skip_morph_payload(
    reader: Reader,
    morph_type: int,
    count: int,
    values: dict[str, int],
) -> None:
    if count < 0:
        raise PmxError("negative morph offset count")
    if morph_type in (0, 9):
        stride = values["morph_index_size"] + 4
    elif morph_type == 1:
        stride = values["vertex_index_size"] + 12
    elif morph_type == 2:
        stride = values["bone_index_size"] + 28
    elif 3 <= morph_type <= 7:
        stride = values["vertex_index_size"] + 16
    elif morph_type == 8:
        stride = values["material_index_size"] + 1 + 112
    elif morph_type == 10:
        stride = values["rigid_index_size"] + 1 + 24
    else:
        raise PmxError(f"unsupported morph type: {morph_type}")
    reader.skip(count * stride)


def locate_layout(data: bytes) -> Layout:
    reader = Reader(data)
    if reader.read(4) != b"PMX ":
        raise PmxError("not a PMX file")
    version = reader.f32()
    if version not in (2.0, 2.1):
        raise PmxError(f"unsupported PMX version: {version}")
    header_size = reader.u8()
    settings = reader.read(header_size)
    if len(settings) < 8:
        raise PmxError("PMX global settings are shorter than 8 bytes")
    fixed_header_end = reader.pos
    encoding = "utf-16-le" if settings[0] == 0 else "utf-8"
    values = {
        "additional_uv_count": settings[1],
        "vertex_index_size": _validate_index_size(settings[2], "vertex"),
        "texture_index_size": _validate_index_size(settings[3], "texture"),
        "material_index_size": _validate_index_size(settings[4], "material"),
        "bone_index_size": _validate_index_size(settings[5], "bone"),
        "morph_index_size": _validate_index_size(settings[6], "morph"),
        "rigid_index_size": _validate_index_size(settings[7], "rigid body"),
    }
    if values["additional_uv_count"] > 4:
        raise PmxError("additional UV count exceeds PMX limit")

    for _ in range(4):
        reader.text(encoding)
    metadata_end = reader.pos

    _skip_vertices(reader, values)
    index_count = reader.i32()
    if index_count < 0:
        raise PmxError("negative surface index count")
    reader.skip(index_count * values["vertex_index_size"])

    texture_count = reader.i32()
    if texture_count < 0:
        raise PmxError("negative texture count")
    for _ in range(texture_count):
        reader.text(encoding)

    _skip_materials(reader, values, encoding)
    bone_count = _skip_bones(reader, values["bone_index_size"], encoding)
    morph_offset = reader.pos

    morph_count = reader.i32()
    if morph_count < 0:
        raise PmxError("negative morph count")
    for _ in range(morph_count):
        reader.text(encoding)
        reader.text(encoding)
        reader.skip(1)
        morph_type = reader.u8()
        offset_count = reader.i32()
        _skip_morph_payload(reader, morph_type, offset_count, values)

    display_count = reader.i32()
    if display_count < 0:
        raise PmxError("negative display-frame count")
    for _ in range(display_count):
        reader.text(encoding)
        reader.text(encoding)
        reader.skip(1)
        element_count = reader.i32()
        if element_count < 0:
            raise PmxError("negative display-frame element count")
        for _ in range(element_count):
            element_type = reader.u8()
            if element_type == 0:
                reader.skip(values["bone_index_size"])
            elif element_type == 1:
                reader.skip(values["morph_index_size"])
            else:
                raise PmxError(f"invalid display-frame element type: {element_type}")

    return Layout(
        fixed_header_end=fixed_header_end,
        metadata_end=metadata_end,
        morph_offset=morph_offset,
        rigid_body_offset=reader.pos,
        encoding=encoding,
        bone_count=bone_count,
        **values,
    )


def pack_text(value: str, encoding: str) -> bytes:
    encoded = value.encode(encoding)
    return struct.pack("<i", len(encoded)) + encoded


def pack_index(value: int, size: int) -> bytes:
    formats = {1: "<b", 2: "<h", 4: "<i"}
    try:
        return struct.pack(formats[size], value)
    except (KeyError, struct.error) as exc:
        raise PmxError(f"cannot encode index {value} in {size} bytes") from exc


def build_morph(name: str, layout: Layout) -> bytes:
    if layout.bone_count < 1:
        raise PmxError("source controller must contain at least one bone")
    return b"".join(
        (
            pack_text(name, layout.encoding),
            pack_text(name, layout.encoding),
            struct.pack("<BBi", 4, 2, 1),  # Other panel, bone morph, one offset
            pack_index(0, layout.bone_index_size),
            struct.pack("<7f", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0),
        )
    )


def build_display_frames(layout: Layout, morph_names: tuple[str, ...]) -> bytes:
    root_elements = b"\x00" + pack_index(0, layout.bone_index_size)
    hair_elements = b"".join(
        b"\x01" + pack_index(index, layout.morph_index_size)
        for index in range(len(morph_names))
    )
    root = b"".join(
        (
            pack_text("Root", layout.encoding),
            pack_text("Root", layout.encoding),
            struct.pack("<Bi", 1, 1),
            root_elements,
        )
    )
    facial = b"".join(
        (
            pack_text("頭髪控制", layout.encoding),
            pack_text("頭髪控制", layout.encoding),
            struct.pack("<Bi", 1, len(morph_names)),
            hair_elements,
        )
    )
    return struct.pack("<i", 2) + root + facial


def read_morph_names(data: bytes) -> tuple[str, ...]:
    layout = locate_layout(data)
    reader = Reader(data)
    reader.pos = layout.morph_offset
    count = reader.i32()
    names = []
    values = {
        "vertex_index_size": layout.vertex_index_size,
        "material_index_size": layout.material_index_size,
        "bone_index_size": layout.bone_index_size,
        "morph_index_size": layout.morph_index_size,
        "rigid_index_size": layout.rigid_index_size,
    }
    for _ in range(count):
        names.append(reader.text(layout.encoding))
        reader.text(layout.encoding)
        panel = reader.u8()
        morph_type = reader.u8()
        offset_count = reader.i32()
        if panel != 4 or morph_type != 2 or offset_count != 1:
            raise PmxError("generated controller contains a non-neutral hair morph")
        _skip_morph_payload(reader, morph_type, offset_count, values)
    return tuple(names)


def build_controller(
    source: Path,
    output: Path,
    morph_names: tuple[str, ...],
    contract_names: tuple[str, ...],
) -> None:
    internal_root = Path(__file__).resolve().parents[1] / "internal"
    shader_contract = "\n".join(
        (internal_root / contract_name).read_text(encoding="cp932")
        for contract_name in contract_names
    )
    shader_names = tuple(
        re.findall(r'string\s+item\s*=\s*"([^"]+)"', shader_contract)
    )
    if shader_names != morph_names:
        raise PmxError(
            "shader CONTROLOBJECT items do not match the selected morph profile"
        )

    source_data = source.read_bytes()
    layout = locate_layout(source_data)

    metadata = b"".join(
        (
            pack_text(output.stem, layout.encoding),
            pack_text(output.stem, layout.encoding),
            pack_text(
                "Endfield hair runtime controller. Morphs are read by MME CONTROLOBJECT.",
                layout.encoding,
            ),
            pack_text(
                "Endfield hair runtime controller. Morphs are read by MME CONTROLOBJECT.",
                layout.encoding,
            ),
        )
    )
    morphs = b"".join(build_morph(name, layout) for name in morph_names)
    output_data = b"".join(
        (
            source_data[: layout.fixed_header_end],
            metadata,
            source_data[layout.metadata_end : layout.morph_offset],
            struct.pack("<i", len(morph_names)),
            morphs,
            build_display_frames(layout, morph_names),
            source_data[layout.rigid_body_offset :],
        )
    )

    names = read_morph_names(output_data)
    if names != morph_names:
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
        default=None,
    )
    args = parser.parse_args()
    if args.output is None:
        args.output = controller_root / "EndfieldHair_controller_Range5.pmx"
    return args


def main() -> None:
    args = parse_args()
    build_controller(
        args.source.resolve(),
        args.output.resolve(),
        C5_HAIR_MORPHS,
        (
            "endfield_hair_controls.inc",
            "endfield_hair_controls_c5.inc",
        ),
    )


if __name__ == "__main__":
    main()
