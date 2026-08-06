"""Replace Endfield controller meshes with a tiny invisible triangle.

The PMX geometry, texture table, and material table are rebuilt. Morph names,
order, and panel assignments are preserved while their payloads are normalized
to harmless bone-0 morphs. Bones, display frames, rigid bodies, joints, and any
later PMX sections remain byte-for-byte identical to the source controller.
"""

from __future__ import annotations

import argparse
import hashlib
import struct
from dataclasses import dataclass
from pathlib import Path

from build_hair_controller import (
    PmxError,
    Reader,
    _skip_materials,
    _skip_morph_payload,
    _skip_vertices,
    locate_layout,
    pack_index,
    pack_text,
)


CONTROLLER_NAMES = (
    "Endfield_controller.pmx",
    "EndfieldHair_controller_Range5.pmx",
    "EndfieldFace_controller.pmx",
    "EndfieldSkin_controller.pmx",
    "EndfieldCloth_controller.pmx",
)

TRIANGLE_SIZE = 0.001


@dataclass(frozen=True)
class MeshLayout:
    mesh_offset: int
    bone_offset: int
    vertex_count: int
    index_count: int
    texture_count: int
    material_count: int


@dataclass(frozen=True)
class MorphSpec:
    name: str
    english_name: str
    panel: int


@dataclass(frozen=True)
class MorphLayout:
    specs: tuple[MorphSpec, ...]
    display_offset: int


def locate_mesh(data: bytes) -> MeshLayout:
    layout = locate_layout(data)
    values = {
        "additional_uv_count": layout.additional_uv_count,
        "vertex_index_size": layout.vertex_index_size,
        "texture_index_size": layout.texture_index_size,
        "bone_index_size": layout.bone_index_size,
    }
    reader = Reader(data)
    reader.pos = layout.metadata_end

    vertex_count = reader.i32()
    reader.pos -= 4
    _skip_vertices(reader, values)

    index_count = reader.i32()
    if index_count < 0:
        raise PmxError("negative surface index count")
    reader.skip(index_count * layout.vertex_index_size)

    texture_count = reader.i32()
    if texture_count < 0:
        raise PmxError("negative texture count")
    for _ in range(texture_count):
        reader.text(layout.encoding)

    material_count = reader.i32()
    reader.pos -= 4
    _skip_materials(reader, values, layout.encoding)

    return MeshLayout(
        mesh_offset=layout.metadata_end,
        bone_offset=reader.pos,
        vertex_count=vertex_count,
        index_count=index_count,
        texture_count=texture_count,
        material_count=material_count,
    )


def read_morph_layout(data: bytes) -> MorphLayout:
    layout = locate_layout(data)
    values = {
        "vertex_index_size": layout.vertex_index_size,
        "material_index_size": layout.material_index_size,
        "bone_index_size": layout.bone_index_size,
        "morph_index_size": layout.morph_index_size,
        "rigid_index_size": layout.rigid_index_size,
    }
    reader = Reader(data)
    reader.pos = layout.morph_offset
    count = reader.i32()
    if count < 0:
        raise PmxError("negative morph count")
    specs = []
    for _ in range(count):
        name = reader.text(layout.encoding)
        english_name = reader.text(layout.encoding)
        panel = reader.u8()
        morph_type = reader.u8()
        offset_count = reader.i32()
        _skip_morph_payload(reader, morph_type, offset_count, values)
        specs.append(MorphSpec(name, english_name, panel))
    return MorphLayout(tuple(specs), reader.pos)


def build_vertex(position: tuple[float, float, float], layout) -> bytes:
    return b"".join(
        (
            struct.pack("<3f", *position),
            struct.pack("<3f", 0.0, 0.0, 1.0),
            struct.pack("<2f", 0.0, 0.0),
            b"\x00" * (layout.additional_uv_count * 16),
            b"\x00",  # BDEF1
            pack_index(0, layout.bone_index_size),
            struct.pack("<f", 0.0),  # no edge expansion
        )
    )


def build_material(layout) -> bytes:
    return b"".join(
        (
            pack_text("Controller", layout.encoding),
            pack_text("Controller", layout.encoding),
            struct.pack("<4f", 0.0, 0.0, 0.0, 0.0),  # transparent diffuse
            struct.pack("<3f", 0.0, 0.0, 0.0),
            struct.pack("<f", 0.0),
            struct.pack("<3f", 0.0, 0.0, 0.0),
            b"\x00",  # single-sided, no ground/self shadow, no edge
            struct.pack("<4f", 0.0, 0.0, 0.0, 0.0),
            struct.pack("<f", 0.0),
            pack_index(-1, layout.texture_index_size),
            pack_index(-1, layout.texture_index_size),
            b"\x00",  # sphere mode: disabled
            b"\x01\x00",  # shared toon 0; no texture-table dependency
            pack_text("Tiny invisible runtime controller mesh.", layout.encoding),
            struct.pack("<i", 3),
        )
    )


def build_minimal_mesh(layout) -> bytes:
    vertices = b"".join(
        build_vertex(position, layout)
        for position in (
            (0.0, 0.0, 0.0),
            (TRIANGLE_SIZE, 0.0, 0.0),
            (0.0, TRIANGLE_SIZE, 0.0),
        )
    )
    indices = b"".join(
        pack_index(index, layout.vertex_index_size) for index in (0, 1, 2)
    )
    return b"".join(
        (
            struct.pack("<i", 3),
            vertices,
            struct.pack("<i", 3),
            indices,
            struct.pack("<i", 0),  # textures
            struct.pack("<i", 1),
            build_material(layout),
        )
    )


def build_neutral_morph(spec: MorphSpec, layout) -> bytes:
    if layout.bone_count < 1:
        raise PmxError("controller must contain at least one bone")
    return b"".join(
        (
            pack_text(spec.name, layout.encoding),
            pack_text(spec.english_name, layout.encoding),
            struct.pack("<BBi", spec.panel, 2, 1),
            pack_index(0, layout.bone_index_size),
            struct.pack("<7f", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0),
        )
    )


def build_neutral_morphs(specs: tuple[MorphSpec, ...], layout) -> bytes:
    return struct.pack("<i", len(specs)) + b"".join(
        build_neutral_morph(spec, layout) for spec in specs
    )


def minimize_controller(source: Path, output: Path) -> None:
    source_data = source.read_bytes()
    source_layout = locate_layout(source_data)
    source_mesh = locate_mesh(source_data)
    source_morphs = read_morph_layout(source_data)

    output_data = b"".join(
        (
            source_data[: source_mesh.mesh_offset],
            build_minimal_mesh(source_layout),
            source_data[source_mesh.bone_offset : source_layout.morph_offset],
            build_neutral_morphs(source_morphs.specs, source_layout),
            source_data[source_morphs.display_offset :],
        )
    )

    output_layout = locate_layout(output_data)
    output_mesh = locate_mesh(output_data)
    output_morphs = read_morph_layout(output_data)

    if output_mesh.vertex_count != 3 or output_mesh.index_count != 3:
        raise PmxError("generated controller is not a single triangle")
    if output_mesh.texture_count != 0 or output_mesh.material_count != 1:
        raise PmxError("generated controller has an unexpected texture/material table")
    if output_layout.bone_count != source_layout.bone_count:
        raise PmxError("bone count changed while minimizing controller geometry")
    if output_morphs.specs != source_morphs.specs:
        raise PmxError("morph names or panel assignments changed")
    if (
        output_data[output_morphs.display_offset :]
        != source_data[source_morphs.display_offset :]
    ):
        raise PmxError("display-frame or later PMX data was modified")

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(output_data)
    digest = hashlib.sha256(output_data).hexdigest().upper()
    print(
        f"wrote: {output}\n"
        f"geometry: {output_mesh.vertex_count} vertices, "
        f"{output_mesh.index_count // 3} triangle\n"
        f"neutral morphs: {len(output_morphs.specs)}\n"
        f"bytes: {len(output_data)}\n"
        f"sha256: {digest}"
    )


def parse_args() -> argparse.Namespace:
    project_root = Path(__file__).resolve().parents[1]
    workspace_root = project_root.parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, default=workspace_root)
    parser.add_argument(
        "--output-dir", type=Path, default=project_root / "controller"
    )
    parser.add_argument(
        "--sync-sources",
        action="store_true",
        help="also replace source-directory copies after outputs validate",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source_dir = args.source_dir.resolve()
    output_dir = args.output_dir.resolve()
    for index, name in enumerate(CONTROLLER_NAMES):
        if index:
            print()
        source = source_dir / name
        output = output_dir / name
        minimize_controller(source, output)
        if args.sync_sources and source != output:
            source.write_bytes(output.read_bytes())
            print(f"synced: {source}")


if __name__ == "__main__":
    main()
