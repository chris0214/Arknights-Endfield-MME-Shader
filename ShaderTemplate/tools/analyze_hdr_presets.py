import json
import math
import argparse
from pathlib import Path

import bpy
import numpy as np


PRESETS = [
    "brown_photostudio_02_4k.hdr",
    "monochrome_studio_02_4k.hdr",
    "ferndale_studio_01_4k.hdr",
    "studio_small_09_4k.hdr",
    "abandoned_hopper_terminal_04_4k.hdr",
    "abandoned_tank_farm_03_4k.hdr",
    "abandoned_tank_farm_04_4k.hdr",
]
THUMB_WIDTH = 512
THUMB_HEIGHT = 256


def aces_tonemap(color):
    a = 2.51
    b = 0.03
    c = 2.43
    d = 0.59
    e = 0.14
    return np.clip((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0)


def downsample_area(rgb, width, height):
    source_height, source_width = rgb.shape[:2]
    if source_width % width or source_height % height:
        raise RuntimeError(f"Unexpected HDR size: {source_width}x{source_height}")
    block_x = source_width // width
    block_y = source_height // height
    return rgb.reshape(height, block_y, width, block_x, 3).mean(axis=(1, 3))


def save_png(path, rgb):
    height, width = rgb.shape[:2]
    rgba = np.ones((height, width, 4), dtype=np.float32)
    rgba[:, :, :3] = rgb
    image = bpy.data.images.new(path.stem, width=width, height=height, alpha=True)
    image.pixels.foreach_set(np.flipud(rgba).reshape(-1))
    image.filepath_raw = str(path)
    image.file_format = "PNG"
    image.save()
    bpy.data.images.remove(image)


def main():
    parser = argparse.ArgumentParser(description="Analyze HDR environment presets and write previews.")
    script_root = Path(__file__).resolve().parents[1]
    parser.add_argument("--source-root", type=Path, default=script_root.parent,
                        help="Directory containing the *_4k.hdr files.")
    parser.add_argument("--output", type=Path,
                        default=script_root / "docs" / "reference" / "hdr_presets",
                        help="Directory for previews and analysis.json.")
    args = parser.parse_args()
    root = args.source_root.resolve()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    report = []
    previews = []

    for file_name in PRESETS:
        path = root / file_name
        image = bpy.data.images.load(str(path), check_existing=False)
        width, height = image.size
        pixels = np.empty(width * height * 4, dtype=np.float32)
        image.pixels.foreach_get(pixels)
        rgba = pixels.reshape(height, width, 4)
        rgb = np.flipud(rgba[:, :, :3]).astype(np.float64)
        bpy.data.images.remove(image)

        luminance = np.maximum(
            rgb[:, :, 0] * 0.2126
            + rgb[:, :, 1] * 0.7152
            + rgb[:, :, 2] * 0.0722,
            1e-8,
        )
        percentiles = np.percentile(luminance, [50.0, 75.0, 90.0, 95.0, 99.0, 99.9])
        average_rgb = rgb.mean(axis=(0, 1))
        normalized_rgb = average_rgb / max(float(average_rgb.mean()), 1e-8)
        geometric_mean = float(np.exp(np.mean(np.log(luminance))))

        thumbnail = downsample_area(rgb, THUMB_WIDTH, THUMB_HEIGHT)
        exposure = 0.18 / max(geometric_mean, 1e-8)
        preview = np.power(aces_tonemap(thumbnail * exposure), 1.0 / 2.2)
        preview_path = output / f"{path.stem}.png"
        save_png(preview_path, preview.astype(np.float32))
        previews.append(preview)

        report.append(
            {
                "id": path.stem,
                "source": file_name,
                "size": [int(width), int(height)],
                "geometric_mean_luminance": geometric_mean,
                "mean_rgb": [float(value) for value in average_rgb],
                "normalized_mean_rgb": [float(value) for value in normalized_rgb],
                "luminance_percentiles": {
                    key: float(value)
                    for key, value in zip(
                        ["p50", "p75", "p90", "p95", "p99", "p99_9"],
                        percentiles,
                    )
                },
                "max_luminance": float(luminance.max()),
                "preview_exposure": float(exposure),
            }
        )

    rows = math.ceil(len(previews) / 2)
    gutter = 8
    sheet_width = THUMB_WIDTH * 2 + gutter
    sheet_height = THUMB_HEIGHT * rows + gutter * (rows - 1)
    sheet = np.full((sheet_height, sheet_width, 3), 0.04, dtype=np.float32)
    for index, preview in enumerate(previews):
        row = index // 2
        column = index % 2
        x = column * (THUMB_WIDTH + gutter)
        y = row * (THUMB_HEIGHT + gutter)
        sheet[y : y + THUMB_HEIGHT, x : x + THUMB_WIDTH] = preview
    save_png(output / "contact_sheet.png", sheet)

    with (output / "analysis.json").open("w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=True, indent=2)

    for item in report:
        print(json.dumps(item, ensure_ascii=True))


if __name__ == "__main__":
    main()
