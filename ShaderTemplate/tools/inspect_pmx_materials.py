"""Inspect PMX material contracts without modifying the source model."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

from build_hair_controller import PmxError, Reader, _validate_index_size


def read_index(reader: Reader, size: int, signed: bool = True) -> int:
    formats = {
        (1, True): "<b",
        (2, True): "<h",
        (4, True): "<i",
        (1, False): "<B",
        (2, False): "<H",
        (4, False): "<I",
    }
    return reader.unpack(formats[(size, signed)])[0]


def read_vec(reader: Reader, count: int) -> tuple[float, ...]:
    return reader.unpack("<" + "f" * count)


def read_pmx(path: Path) -> dict[str, object]:
    reader = Reader(path.read_bytes())
    if reader.read(4) != b"PMX ":
        raise PmxError("not a PMX file")
    version = reader.f32()
    header_size = reader.u8()
    settings = reader.read(header_size)
    if len(settings) < 8:
        raise PmxError("PMX global settings are shorter than 8 bytes")

    encoding = "utf-16-le" if settings[0] == 0 else "utf-8"
    additional_uv_count = settings[1]
    vertex_index_size = _validate_index_size(settings[2], "vertex")
    texture_index_size = _validate_index_size(settings[3], "texture")
    bone_index_size = _validate_index_size(settings[5], "bone")

    metadata = [reader.text(encoding) for _ in range(4)]

    vertex_count = reader.i32()
    vertices: list[tuple[float, float, float]] = []
    for _ in range(vertex_count):
        position = read_vec(reader, 3)
        reader.skip(12 + 8 + additional_uv_count * 16)
        weight_type = reader.u8()
        if weight_type == 0:
            reader.skip(bone_index_size)
        elif weight_type == 1:
            reader.skip(bone_index_size * 2 + 4)
        elif weight_type in (2, 4):
            reader.skip(bone_index_size * 4 + 16)
        elif weight_type == 3:
            reader.skip(bone_index_size * 2 + 4 + 36)
        else:
            raise PmxError(f"unsupported vertex weight type: {weight_type}")
        reader.skip(4)
        vertices.append(position)

    surface_index_count = reader.i32()
    surface_indices = [
        read_index(reader, vertex_index_size, signed=False)
        for _ in range(surface_index_count)
    ]

    texture_count = reader.i32()
    textures = [reader.text(encoding) for _ in range(texture_count)]

    material_count = reader.i32()
    materials: list[dict[str, object]] = []
    first_surface_index = 0
    for material_index in range(material_count):
        name = reader.text(encoding)
        name_en = reader.text(encoding)
        diffuse = read_vec(reader, 4)
        specular = read_vec(reader, 3)
        specular_power = reader.f32()
        ambient = read_vec(reader, 3)
        flags = reader.u8()
        edge_color = read_vec(reader, 4)
        edge_size = reader.f32()
        texture_index = read_index(reader, texture_index_size)
        sphere_index = read_index(reader, texture_index_size)
        sphere_mode = reader.u8()
        shared_toon = reader.u8()
        if shared_toon == 0:
            toon_index = read_index(reader, texture_index_size)
        elif shared_toon == 1:
            toon_index = reader.u8()
        else:
            raise PmxError(f"invalid shared toon flag: {shared_toon}")
        memo = reader.text(encoding)
        material_surface_count = reader.i32()
        last_surface_index = first_surface_index + material_surface_count
        material_indices = surface_indices[first_surface_index:last_surface_index]
        unique_indices = sorted(set(material_indices))

        if unique_indices:
            points = [vertices[index] for index in unique_indices]
            bounds_min = [min(point[axis] for point in points) for axis in range(3)]
            bounds_max = [max(point[axis] for point in points) for axis in range(3)]
        else:
            bounds_min = bounds_max = [0.0, 0.0, 0.0]

        materials.append(
            {
                "index": material_index,
                "name": name,
                "name_en": name_en,
                "surface_index_start": first_surface_index,
                "surface_index_count": material_surface_count,
                "triangle_count": material_surface_count // 3,
                "unique_vertex_count": len(unique_indices),
                "bounds_min": bounds_min,
                "bounds_max": bounds_max,
                "diffuse": diffuse,
                "specular": specular,
                "specular_power": specular_power,
                "ambient": ambient,
                "flags": flags,
                "double_sided": bool(flags & 0x01),
                "ground_shadow": bool(flags & 0x02),
                "self_shadow_map": bool(flags & 0x04),
                "self_shadow": bool(flags & 0x08),
                "edge_enabled": bool(flags & 0x10),
                "edge_color": edge_color,
                "edge_size": edge_size,
                "texture_index": texture_index,
                "texture": textures[texture_index]
                if 0 <= texture_index < len(textures)
                else None,
                "sphere_index": sphere_index,
                "sphere_texture": textures[sphere_index]
                if 0 <= sphere_index < len(textures)
                else None,
                "sphere_mode": sphere_mode,
                "shared_toon": bool(shared_toon),
                "toon_index": toon_index,
                "memo": memo,
            }
        )
        first_surface_index = last_surface_index

    if first_surface_index != surface_index_count:
        raise PmxError(
            "material surface counts do not consume the complete index buffer"
        )

    return {
        "path": str(path),
        "version": version,
        "metadata": metadata,
        "vertex_count": vertex_count,
        "surface_index_count": surface_index_count,
        "texture_count": texture_count,
        "textures": textures,
        "material_count": material_count,
        "materials": materials,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("pmx", type=Path)
    parser.add_argument("--match", default="")
    parser.add_argument("--json", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    result = read_pmx(args.pmx.resolve())
    match = args.match.casefold()
    materials = result["materials"]
    if match:
        materials = [
            material
            for material in materials
            if match in str(material["name"]).casefold()
            or match in str(material["name_en"]).casefold()
            or match in str(material["memo"]).casefold()
        ]
    if args.json:
        print(json.dumps(materials, ensure_ascii=False, indent=2))
        return
    for material in materials:
        print(
            f"[{material['index']:03}] {material['name']} / {material['name_en']} "
            f"tris={material['triangle_count']} texture={material['texture']!r} "
            f"flags=0x{material['flags']:02X} alpha={material['diffuse'][3]:.3f}"
        )


if __name__ == "__main__":
    main()
