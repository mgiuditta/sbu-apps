#!/usr/bin/env python3
"""Generate the link previews (Open Graph, 1200x630) for sbu.dev.

One per app with an engraving in Design/icons/source: the app name in Bricolage Grotesque,
closed by the square full stop in its accent, the engraving in `ink` beside it, on `surface`.
One per locale for the home: "Sbu fa una cosa sola" closed by the full stop in `brand`.
Light only: previews are shown on someone else's page, which we don't theme.

Usage: python3 Tools/make_og.py      -> Site/public/og/<name>.png, home-it.png, home-en.png
"""
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
TOKENS = ROOT / "Design" / "tokens.json"
SOURCES = ROOT / "Design" / "icons" / "source"
SPECS = ROOT / "Design" / "icons" / "engravings.json"
DISPLAY = ROOT / "Design" / "fonts" / "BricolageGrotesque-Bold.ttf"
SANS = Path("/System/Library/Fonts/SFNS.ttf")  # ponytail: macOS only, like the rest of Tools
OUT = ROOT / "Site" / "public" / "og"
W, H = 1200, 630
PAD = 72
MARK, GAP = 0.22, 0.06  # mark-size and mark-gap, in em (tokens.json)
TRACKING = -0.035  # display-hero's -2px at 56px, as on the site
HOME = {"it": ["Sbu fa una", "cosa sola"], "en": ["Sbu does", "one thing"]}


def rgb(hex_value: str) -> tuple[int, int, int]:
    h = hex_value.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def light() -> dict:
    return {t["name"]: rgb(t["value"]["light"]) for t in json.loads(TOKENS.read_text())["color"]["tokens"]}


def title(draw: ImageDraw.ImageDraw, lines: list[str], size: int, y: int, ink, stop) -> None:
    """Lines on their baselines from y, the last one closed by the full stop."""
    font = ImageFont.truetype(str(DISPLAY), size)
    # PIL has no letter-spacing: place each glyph at its kerned offset plus the tracking.
    width = lambda text: font.getlength(text) + len(text) * size * TRACKING
    for i, line in enumerate(lines):
        baseline = y + int(size * 1.02 * (i + 1))
        for j, char in enumerate(line):
            draw.text((PAD + width(line[:j]), baseline), char, font=font, fill=ink, anchor="ls")
    end = PAD + width(lines[-1]) + size * GAP
    side = size * MARK
    draw.rectangle([end, baseline - side, end + side, baseline], fill=stop)


def footer(draw: ImageDraw.ImageDraw, colors: dict) -> None:
    font = ImageFont.truetype(str(SANS), 34)
    draw.text((PAD, H - PAD), "sbu.dev", font=font, fill=colors["ink-muted"], anchor="ls")


def app_card(name: str, accent: str, colors: dict) -> Image.Image:
    image = Image.new("RGB", (W, H), colors["surface"])
    mask = Image.open(SOURCES / f"sbu-{name}.png").convert("L").resize((H - 40, H - 40), Image.LANCZOS)
    image.paste(Image.new("RGB", mask.size, colors["ink"]), (W - mask.width - 20, 20), mask)
    draw = ImageDraw.Draw(image)
    title(draw, ["Sbu", name.capitalize()], 132, PAD + 40, colors["ink"], colors[accent])
    footer(draw, colors)
    return image


def home_card(lines: list[str], colors: dict) -> Image.Image:
    image = Image.new("RGB", (W, H), colors["surface"])
    draw = ImageDraw.Draw(image)
    title(draw, lines, 150, PAD + 20, colors["ink"], colors["brand"])
    footer(draw, colors)
    return image


def main() -> None:
    colors = light()
    OUT.mkdir(parents=True, exist_ok=True)
    for name, spec in json.loads(SPECS.read_text()).items():
        if (SOURCES / f"sbu-{name}.png").exists():
            app_card(name, spec["accent"], colors).save(OUT / f"{name}.png", optimize=True)
    for locale, lines in HOME.items():
        home_card(lines, colors).save(OUT / f"home-{locale}.png", optimize=True)
    print(f"wrote {len(list(OUT.glob('*.png')))} previews to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
