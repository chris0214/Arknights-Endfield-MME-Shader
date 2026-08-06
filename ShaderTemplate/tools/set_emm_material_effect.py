"""Set one PMD material effect in a legacy CP936 MME scene file."""

from __future__ import annotations

import argparse
from pathlib import Path


def set_material_effect(
    emm: Path,
    model_key: str,
    material_index: int,
    effect_path: str,
) -> None:
    raw = emm.read_bytes()
    newline = "\r\n" if b"\r\n" in raw else "\n"
    text = raw.decode("cp936")
    lines = text.splitlines()
    target = f"{model_key}[{material_index}]"
    replacement = f"{target} = {effect_path}"

    effect_start = next(
        (index for index, line in enumerate(lines) if line == "[Effect]"),
        None,
    )
    if effect_start is None:
        raise ValueError("EMM file has no [Effect] section")

    effect_end = next(
        (
            index
            for index in range(effect_start + 1, len(lines))
            if lines[index].startswith("[")
        ),
        len(lines),
    )
    matching = [
        index
        for index in range(effect_start + 1, effect_end)
        if lines[index].split("=", 1)[0].strip() == target
    ]
    if len(matching) > 1:
        raise ValueError(f"duplicate EMM binding: {target}")
    if matching:
        lines[matching[0]] = replacement
    else:
        insert_at = effect_end
        for index in range(effect_start + 1, effect_end):
            key = lines[index].split("=", 1)[0].strip()
            if key.startswith(model_key + "["):
                try:
                    current_index = int(
                        key[len(model_key) + 1 : key.index("]")]
                    )
                except (ValueError, IndexError):
                    continue
                if current_index > material_index:
                    insert_at = index
                    break
        lines.insert(insert_at, replacement)

    updated = newline.join(lines) + newline
    emm.write_bytes(updated.encode("cp936"))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("emm", type=Path)
    parser.add_argument("model_key")
    parser.add_argument("material_index", type=int)
    parser.add_argument("effect_path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    set_material_effect(
        args.emm.resolve(),
        args.model_key,
        args.material_index,
        args.effect_path,
    )


if __name__ == "__main__":
    main()
