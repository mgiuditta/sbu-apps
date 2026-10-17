#!/usr/bin/env python3
"""Generate a Sbu app icon: an engraved instrument on paper, closed by the full stop.

Grammar (Design/README.md, CLAUDE.md): the real instrument behind the app, engraved in
warm black (`ink`) on paper (`paper`), centred, with the square full stop in the app's
`accent-*` at the bottom right. Since v5 the engraving sits on the notebook grid (8x8 cells of
128 px, multiply), is scaled 20% past its frame so it bleeds off the edges and reads at 60 px,
has its tone levelled to one ink density across apps, and the full stop is one whole grid cell,
one cell in from the bottom-right corner. Dark: the engraving in light ink on warm black, the square
in the accent's dark value. Tinted: the dark variant in greys, for iOS to tint. Inversa, the one
alternate icon (ADR-0013): paper engraving on ink, the square in `accent-on-ink-*`.

Subjects live in Design/icons/engravings.json ({name: {accent, subject}}). The engraving is
kept as an ink mask in Design/icons/source/sbu-<name>.png (white, alpha = ink), so icons
rebuild without calling a model and the site can mask with it in every browser.

Usage:
  python3 Tools/make_icons.py level [--appiconset Apps/SbuLevel/SbuLevel/Assets.xcassets/AppIcon.appiconset]
      [--artwork Apps/SbuLevel/SbuLevel/Assets.xcassets/AppIconArtwork.imageset]
  python3 Tools/make_icons.py habits --watch-appiconset Apps/SbuHabits/SbuHabitsWatch/Assets.xcassets/AppIcon.appiconset
  python3 Tools/make_icons.py level --inverse Apps/SbuLevel/SbuLevel/Assets.xcassets/AppIcon-Inversa.appiconset
  python3 Tools/make_icons.py level --generate          # new engraving from Gemini (GEMINI_API_KEY)
  python3 Tools/make_icons.py level --from-image raw.png # engraving from an image you supply

Writes Design/icons/sbu-<name>.png (light, 1024, no alpha); with --appiconset also the dark and tinted variants.
With --watch-appiconset, a watchOS icon: the dark variant shrunk into the square inscribed in the
circle watchOS masks the icon to, so the engraving and the full stop are never cropped.
"""
import argparse
import base64
import json
import os
import sys
import urllib.request
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps, ImageStat

ROOT = Path(__file__).resolve().parent.parent
TOKENS = ROOT / "Design" / "tokens.json"
ICONS = ROOT / "Design" / "icons"
SPECS = ICONS / "engravings.json"
CANVAS = 1024
MARGIN = 0.15  # space around the engraving, as a fraction of its longer side
GRID = 8  # cells per side of the notebook grid under the engraving (128 px at 1024)
GRID_LINE = 4  # grid line width at 1024 px
ZOOM = 1.2  # the engraving is scaled past its frame and cropped at the edges
INK_TONE = 85  # mean ink alpha inside the subject's silhouette, the same for every app
WATCH_SAFE = 0.70  # watchOS: side of the composed icon, as a fraction of the canvas (inscribed square is 0.707)
MODEL = "gemini-2.5-flash-image"
STYLE = (
    "Single subject, centered, filling about 70% of a square frame, generous empty margin. "
    "Fine copperplate engraving / etching style with dense crosshatching and stipple, "
    "warm near-black ink on plain flat off-white paper background, no paper texture, no color, "
    "no border, no frame, no text, no letters, no shadow on the ground, crisp lines that stay legible when small."
)


def rgb(hex_value: str) -> tuple[int, int, int]:
    h = hex_value.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def colors() -> dict:
    return {t["name"]: t["value"] for t in json.loads(TOKENS.read_text())["color"]["tokens"]}


def subject_box(ink: Image.Image, cell: int = 8) -> tuple[int, int, int, int] | None:
    """Bounding box of the subject, ignoring specks of dust that would push it off centre.

    On a grid of `cell` pixels, grown by one cell so the strokes of the engraving join up, the
    subject is the largest connected blob; a speck away from it is a blob of its own. The box is
    then measured on the full-size ink inside that blob's area.
    """
    w, h = ink.size
    gw, gh = max(1, w // cell), max(1, h // cell)
    grid = ink.resize((gw, gh), Image.BOX).point(lambda v: 255 if v else 0).filter(ImageFilter.MaxFilter(3))
    on = grid.load()
    seen: set[tuple[int, int]] = set()
    best: list[tuple[int, int]] = []
    for start in ((x, y) for y in range(gh) for x in range(gw)):
        if on[start] == 0 or start in seen:
            continue
        blob, stack = [], [start]
        seen.add(start)
        while stack:
            x, y = stack.pop()
            blob.append((x, y))
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < gw and 0 <= ny < gh and on[nx, ny] and (nx, ny) not in seen:
                    seen.add((nx, ny))
                    stack.append((nx, ny))
        if len(blob) > len(best):
            best = blob
    if not best:
        return None
    xs, ys = [x for x, _ in best], [y for _, y in best]
    area = (min(xs) * w // gw, min(ys) * h // gh, (max(xs) + 1) * w // gw, (max(ys) + 1) * h // gh)
    inner = ink.crop(area).getbbox()
    return (area[0] + inner[0], area[1] + inner[1], area[0] + inner[2], area[1] + inner[3]) if inner else None


def ink_mask(image: Image.Image) -> Image.Image:
    """Greyscale engraving -> mask where white is ink, cropped to the subject and centred."""
    grey = ImageOps.autocontrast(ImageOps.grayscale(image), cutoff=0.5)
    paper = 200  # anything lighter is paper
    grey = grey.point(lambda v: 255 if v >= paper else int(v * 255 / paper))
    ink = grey.point(lambda v: 255 if v < 180 else 0)
    box = subject_box(ink)
    if box is None:
        sys.exit("no ink found in the image")
    grey = grey.crop(box)
    w, h = grey.size
    side = max(w, h)
    pad = int(side * MARGIN)
    framed = Image.new("L", (side + 2 * pad, side + 2 * pad), 255)
    framed.paste(grey, ((side - w) // 2 + pad, (side - h) // 2 + pad))
    return ImageOps.invert(framed.resize((CANVAS, CANVAS), Image.LANCZOS))


def generate(subject: str) -> Image.Image:
    key = os.environ.get("GEMINI_API_KEY") or sys.exit("GEMINI_API_KEY is not set")
    body = {
        "contents": [{"parts": [{"text": f"Illustration: {subject}. {STYLE}"}]}],
        "generationConfig": {"responseModalities": ["IMAGE"], "imageConfig": {"aspectRatio": "1:1"}},
    }
    request = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent",
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json", "x-goog-api-key": key},
    )
    reply = json.load(urllib.request.urlopen(request, timeout=180))
    for part in reply["candidates"][0]["content"]["parts"]:
        if "inlineData" in part:
            from io import BytesIO

            return Image.open(BytesIO(base64.b64decode(part["inlineData"]["data"])))
    sys.exit("the model returned no image: " + json.dumps(reply)[:300])


def zoom(mask: Image.Image) -> Image.Image:
    """Scale the engraving by ZOOM around the centre and crop what falls off the canvas."""
    side = mask.width
    crop = round(side / ZOOM)
    offset = (side - crop) // 2
    return mask.crop((offset, offset, offset + crop, offset + crop)).resize((side, side), Image.LANCZOS)


def level_tone(mask: Image.Image) -> Image.Image:
    """Levels on the ink: a gamma that brings the mean ink inside the silhouette to INK_TONE.

    ponytail: one gamma per icon, bisected; dense crosshatching lightens, a thin outline darkens.
    """
    silhouette = mask.filter(ImageFilter.GaussianBlur(12)).point(lambda v: 255 if v > 12 else 0)
    low, high = 0.2, 5.0
    for _ in range(24):
        gamma = (low * high) ** 0.5
        levelled = mask.point(lambda v, g=gamma: round(255 * (v / 255) ** g))
        if ImageStat.Stat(levelled, silhouette).mean[0] > INK_TONE:
            low = gamma
        else:
            high = gamma
    return levelled


def compose(mask: Image.Image, line: str, ground: str, stop: str | None, grid: str | None = None) -> Image.Image:
    """Ground, grid, engraving (multiply on light grounds), then the full stop on one grid cell."""
    canvas = mask.width
    cell = canvas / GRID
    paper = Image.new("RGB", mask.size, rgb(ground))
    if grid:
        draw = ImageDraw.Draw(paper)
        width = max(1, round(GRID_LINE * canvas / CANVAS))
        for i in range(1, GRID):
            at = round(i * cell)
            draw.rectangle([at - width // 2, 0, at - width // 2 + width - 1, canvas], fill=rgb(grid))
            draw.rectangle([0, at - width // 2, canvas, at - width // 2 + width - 1], fill=rgb(grid))
    if luminance(ground) > luminance(line):
        engraving = Image.composite(Image.new("RGB", mask.size, rgb(line)), Image.new("RGB", mask.size, "white"), mask)
        icon = ImageChops.multiply(paper, engraving)
    else:
        icon = Image.composite(Image.new("RGB", mask.size, rgb(line)), paper, mask)
    if stop:
        # One whole cell, one cell in from the bottom-right corner.
        start, end = round((GRID - 2) * cell), round((GRID - 1) * cell)
        ImageDraw.Draw(icon).rectangle([start, start, end - 1, end - 1], fill=rgb(stop))
    return icon


def luminance(hex_value: str) -> int:
    return sum(rgb(hex_value))


def write_appiconset(icons: dict, folder: Path) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob("*.png"):
        old.unlink()
    images = []
    for variant, image in icons.items():
        image.save(folder / f"AppIcon-{variant}.png")
        entry = {"filename": f"AppIcon-{variant}.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}
        if variant != "light":
            entry["appearances"] = [{"appearance": "luminosity", "value": variant}]
        images.append(entry)
    (folder / "Contents.json").write_text(json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, indent=2) + "\n")


def write_watch_appiconset(mask: Image.Image, line: str, ground: str, stop: str, grid: str, folder: Path) -> None:
    """watchOS crops the icon to a circle: compose inside its safe square, on the same ground."""
    inner = int(CANVAS * WATCH_SAFE)
    icon = Image.new("RGB", (CANVAS, CANVAS), rgb(ground))
    offset = (CANVAS - inner) // 2
    icon.paste(compose(mask.resize((inner, inner), Image.LANCZOS), line, ground, stop, grid), (offset, offset))
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob("*.png"):
        old.unlink()
    icon.save(folder / "AppIcon-watch.png")
    entry = {"filename": "AppIcon-watch.png", "idiom": "universal", "platform": "watchos", "size": "1024x1024"}
    (folder / "Contents.json").write_text(json.dumps({"images": [entry], "info": {"author": "xcode", "version": 1}}, indent=2) + "\n")


def write_artwork(icons: dict, folder: Path) -> None:
    """Same icon for SbuAppIconView, light and dark."""
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.iterdir():
        if old.name != "Contents.json":
            old.unlink()
    images = []
    for variant in ("light", "dark"):
        name = f"AppIconArtwork-{variant}.png"
        icons[variant].resize((512, 512), Image.LANCZOS).save(folder / name)
        entry = {"filename": name, "idiom": "universal"}
        if variant == "dark":
            entry["appearances"] = [{"appearance": "luminosity", "value": "dark"}]
        images.append(entry)
    (folder / "Contents.json").write_text(json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("name", help="app name in Design/icons/engravings.json, like level")
    source_group = parser.add_mutually_exclusive_group()
    source_group.add_argument("--generate", action="store_true", help="draw a new engraving with Gemini")
    source_group.add_argument("--from-image", type=Path, help="use this image as the engraving")
    parser.add_argument("--appiconset", type=Path, help="also write this AppIcon.appiconset")
    parser.add_argument("--artwork", type=Path, help="also write this AppIconArtwork.imageset")
    parser.add_argument("--watch-appiconset", type=Path, help="also write this watchOS AppIcon.appiconset (dark, circle-safe)")
    parser.add_argument("--inverse", type=Path, help="also write the Inversa alternate icon to this AppIcon-Inversa.appiconset")
    args = parser.parse_args()

    specs = json.loads(SPECS.read_text())
    spec = specs.get(args.name) or sys.exit(f"{args.name} is not in {SPECS.relative_to(ROOT)}")
    palette = colors()
    accent = palette.get(spec["accent"]) or sys.exit(f"unknown accent token {spec['accent']}")

    source = ICONS / "source" / f"sbu-{args.name}.png"
    if args.generate or args.from_image:
        raw = generate(spec["subject"]) if args.generate else Image.open(args.from_image)
        source.parent.mkdir(parents=True, exist_ok=True)
        mask = ink_mask(raw)
        Image.merge("LA", (Image.new("L", mask.size, 255), mask)).save(source)
    if not source.exists():
        sys.exit(f"{source.relative_to(ROOT)} is missing: run with --generate or --from-image")
    mask = level_tone(zoom(Image.open(source).getchannel("A")))

    ink, surface, grid = palette["ink"], palette["paper"], palette["grid"]
    variants = {
        "light": compose(mask, ink["light"], surface["light"], accent["light"], grid["light"]),
        "dark": compose(mask, ink["dark"], ink["light"], accent["dark"], grid["dark"]),
        "tinted": ImageOps.grayscale(compose(mask, "#ffffff", "#000000", "#ffffff", grid["dark"])).convert("RGB"),
    }
    # Design/icons keeps the light icon; the variants go only into the app's asset catalog.
    variants["light"].save(ICONS / f"sbu-{args.name}.png")
    print(ICONS.relative_to(ROOT) / f"sbu-{args.name}.png")
    if args.appiconset:
        write_appiconset(variants, args.appiconset)
        print(args.appiconset)
    if args.artwork:
        write_artwork(variants, args.artwork)
        print(args.artwork)
    if args.inverse:
        on_ink = palette.get(spec["accent"].replace("accent-", "accent-on-ink-"), accent)
        write_appiconset({"light": compose(mask, surface["light"], ink["light"], on_ink["light"], grid["dark"])}, args.inverse)
        print(args.inverse)
    if args.watch_appiconset:
        write_watch_appiconset(mask, ink["dark"], ink["light"], accent["dark"], grid["dark"], args.watch_appiconset)
        print(args.watch_appiconset)


if __name__ == "__main__":
    main()
