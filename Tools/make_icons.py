#!/usr/bin/env python3
"""Generate a Sbu app icon: 1024 SVG (marketing, rounded) and 1024 PNG (Xcode, square, no alpha).

Grammar (Design/tokens.json): full field in the app's accent-* (radius-icon, rx 230 at 1024),
one white glyph, stroke icon-stroke (96) with round caps, inside icon-glyph-box (560, centred).

Usage:
  python3 Tools/make_icons.py '{"name": "level", "accent": "accent-level", "glyph": "level"}' \
      [--out Design/icons] [--appiconset Apps/SbuLevel/SbuLevel/Assets.xcassets/AppIcon.appiconset]

`glyph` is a preset name (see GLYPHS) or raw SVG elements in 1024 coordinates, e.g.
'<path d="M232 512 H792"/>'. Elements get the stroke style; do not add fill or stroke yourself.
PNG rasterisation uses macOS `sips` and Pillow.
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOKENS = ROOT / "Design" / "tokens.json"
CANVAS = 1024
RADIUS = 230  # radius-icon 22.5% of 1024, as drawn in the design system icons.

# Glyphs of the nine design-system icons (Design/icons/*.svg).
GLYPHS = {
    "subscriptions": '<path d="M688 352 A232 232 0 1 0 744 512"/><path d="M700 230 L700 372 L560 372"/>',
    "scanner": '<path d="M296 420 V296 H420 M604 296 H728 V420 M728 604 V728 H604 M420 728 H296 V604"/>'
    '<path d="M352 512 H672"/>',
    "level": '<path d="M232 512 H792"/><circle cx="512" cy="512" r="120"/>',
    "noise": '<path d="M352 400 V624 M512 288 V736 M672 440 V584"/>',
    "scan": '<path d="M352 232 H592 L704 344 V792 H352 Z"/><path d="M416 560 H640"/>',
    "habits": '<circle cx="512" cy="512" r="248"/><path d="M400 520 L480 600 L632 440"/>',
    "cards": '<rect x="312" y="360" width="400" height="280" rx="48"/>'
    '<path d="M408 296 H760 A48 48 0 0 1 808 344 V560"/>',
    "block": '<path d="M512 240 L744 328 V520 C744 664 632 752 512 792 C392 752 280 664 280 520 V328 Z"/>',
    "dark": '<path d="M600 268 A248 248 0 1 0 760 640 A200 200 0 0 1 600 268 Z"/>',
}


def token_values() -> tuple[dict, dict]:
    tokens = json.loads(TOKENS.read_text())
    colors = {t["name"]: t["value"]["light"] for t in tokens["color"]["tokens"]}
    strokes = {t["name"]: int(t["value"].removesuffix("px")) for t in tokens["stroke"]["tokens"]}
    return colors, strokes


def svg(accent_hex: str, glyph: str, stroke: int, radius: int) -> str:
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {CANVAS} {CANVAS}" width="{CANVAS}" height="{CANVAS}">\n'
        f'  <rect width="{CANVAS}" height="{CANVAS}" rx="{radius}" fill="{accent_hex}"/>\n'
        f'  <g fill="none" stroke="#FFFFFF" stroke-width="{stroke}" stroke-linecap="round" stroke-linejoin="round">'
        f"{glyph}</g>\n"
        "</svg>\n"
    )


def rasterise(svg_text: str, png: Path) -> None:
    """Render with macOS `sips` (ImageMagick's SVG renderer drops strokes), then drop alpha."""
    from PIL import Image

    with tempfile.TemporaryDirectory() as tmp:
        source = Path(tmp) / "icon.svg"
        source.write_text(svg_text)
        subprocess.run(["sips", "-s", "format", "png", str(source), "--out", str(png)], check=True, capture_output=True)
    Image.open(png).convert("RGB").save(png)


def check_glyph_box(glyph: str, stroke: int, box: int) -> None:
    """Warn when the glyph, including half the stroke, leaves the centred glyph box."""
    from PIL import Image

    with tempfile.TemporaryDirectory() as tmp:
        png = Path(tmp) / "glyph.png"
        rasterise(svg("#000000", glyph, stroke, 0), png)
        bbox = Image.open(png).convert("L").point(lambda v: 255 if v > 127 else 0).getbbox()
    low, high = (CANVAS - box) // 2 - stroke // 2, (CANVAS + box) // 2 + stroke // 2
    if bbox and (min(bbox) < low or max(bbox) > high):
        print(f"warning: glyph ink {bbox} leaves glyph box {low}..{high}", file=sys.stderr)


def write_appiconset(png: Path, folder: Path) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    shutil.copy(png, folder / "AppIcon.png")
    contents = {
        "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("spec", help='JSON {"name", "accent", "glyph"}')
    parser.add_argument("--out", type=Path, default=ROOT / "Design" / "icons", help="folder for sbu-<name>.svg/.png")
    parser.add_argument("--appiconset", type=Path, help="also write AppIcon.appiconset here")
    args = parser.parse_args()

    spec = json.loads(args.spec)
    colors, strokes = token_values()
    if spec["accent"] not in colors or not spec["accent"].startswith("accent-"):
        sys.exit(f"accent must be an accent-* token, one of: {', '.join(c for c in colors if c.startswith('accent-'))}")
    glyph = GLYPHS.get(spec["glyph"], spec["glyph"])
    if not glyph.lstrip().startswith("<"):
        sys.exit(f"glyph must be a preset ({', '.join(GLYPHS)}) or SVG elements")

    stroke = strokes["icon-stroke"]
    check_glyph_box(glyph, stroke, strokes["icon-glyph-box"])

    args.out.mkdir(parents=True, exist_ok=True)
    base = args.out / f"sbu-{spec['name']}"
    base.with_suffix(".svg").write_text(svg(colors[spec["accent"]], glyph, stroke, RADIUS))
    # Xcode masks the icon itself: the PNG is the full square field without alpha.
    rasterise(svg(colors[spec["accent"]], glyph, stroke, 0), base.with_suffix(".png"))
    print(f"{base}.svg, {base}.png")

    if args.appiconset:
        write_appiconset(base.with_suffix(".png"), args.appiconset)
        print(args.appiconset)


if __name__ == "__main__":
    main()
