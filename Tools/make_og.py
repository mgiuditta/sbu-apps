#!/usr/bin/env python3
"""Generate the link previews (Open Graph, 1200x630) for sbu.dev, in the Quaderno direction (v5).

Paper with the notebook grid, drawn at 2x (a preview is shown at about half its width, so one cell is
2 x grid-cell). One per app with an engraving in Design/icons/source: a Plex Mono cartiglio
(SBU / NN / SLUG), the app name in Bricolage Grotesque variable at 800 and width 87, closed by the
full stop in its accent (exactly one cell), the engraving in `ink` beside it. One per locale for the
home: "App a pagamento, rifatte gratis" closed by the full stop in `brand`. Light only: previews are shown on
someone else's page, which we don't theme.

Usage: python3 Tools/make_og.py      -> Site/public/og/<name>.png, home-it.png, home-en.png
"""
import json
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
TOKENS = ROOT / "Design" / "tokens.json"
SOURCES = ROOT / "Design" / "icons" / "source"
SPECS = ROOT / "Design" / "icons" / "engravings.json"
CONTENT = ROOT / "Site" / "src" / "content" / "apps"
DISPLAY = ROOT / "Design" / "fonts" / "BricolageGrotesque-Variable.ttf"
MONO = ROOT / "Design" / "fonts" / "IBMPlexMono-Medium.ttf"
OUT = ROOT / "Site" / "public" / "og"
W, H = 1200, 630
SCALE = 2  # preview pixels per CSS pixel
HOME = {
    "it": (["App a pagamento,", "rifatte gratis"], "sbu.dev · app per iPhone, senza abbonamento"),
    "en": (["Paid apps,", "remade free"], "sbu.dev · iPhone apps, no subscription"),
}


def rgb(hex_value: str) -> tuple[int, int, int]:
    h = hex_value.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def px(value: str) -> int:
    return int(value.removesuffix("px"))


def load() -> tuple[dict, dict]:
    """Light colors, and the grid, full stop and type measures (in preview pixels) from tokens.json."""
    design = json.loads(TOKENS.read_text())
    colors = {t["name"]: rgb(t["value"]["light"]) for t in design["color"]["tokens"]}
    tokens = {t["name"]: t["value"] for group in ("grid", "full-stop", "figure", "mark") for t in design[group]["tokens"]}
    m = {
        "cell": px(tokens["grid-cell"]) * SCALE,
        "line": px(tokens["grid-line-width"]) * SCALE,
        "stop": px(tokens["full-stop-hero"]) * SCALE,
        "gap": int(tokens["mark-gap"].rstrip("%")) / 100,
        "wdth": int(tokens["figure-width-mid"]),
        "cartiglio": px(tokens["cartiglio-size"]) * SCALE,
        "tracking": int(tokens["cartiglio-tracking"].rstrip("%")) / 100,
    }
    return colors, m


def paper(colors: dict, m: dict) -> Image.Image:
    """Paper with the grid: 1-cell squares, lines in `grid`. Lines fall on x = 0, cell, 2 cells…, so the
    two-cell margin is on a line, as the site's margin is."""
    image = Image.new("RGB", (W, H), colors["paper"])
    draw = ImageDraw.Draw(image)
    for x in range(0, W, m["cell"]):
        draw.rectangle([x, 0, x + m["line"] - 1, H], fill=colors["grid"])
    for y in range(0, H, m["cell"]):
        draw.rectangle([0, y, W, y + m["line"] - 1], fill=colors["grid"])
    return image


def display(size: int, m: dict) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(str(DISPLAY), size)
    # Axes in the font's order: opsz, wght, wdth. opsz follows the size, as `auto` does on the site.
    axes = {a["name"]: a for a in font.get_variation_axes()}
    opsz = max(axes[b"Optical size"]["minimum"], min(axes[b"Optical size"]["maximum"], size / SCALE))
    font.set_variation_by_axes([opsz, 800, m["wdth"]])
    return font


def cartiglio(draw: ImageDraw.ImageDraw, text: str, x: int, baseline: int, colors: dict, m: dict) -> None:
    """Plex Mono Medium, upper case, tracked by cartiglio-tracking, in ink-muted. PIL has no letter-spacing:
    each glyph goes at its advance plus the tracking."""
    font = ImageFont.truetype(str(MONO), m["cartiglio"])
    text = text.upper()
    step = m["cartiglio"] * m["tracking"]
    for j, char in enumerate(text):
        draw.text((x + font.getlength(text[:j]) + j * step, baseline), char, font=font, fill=colors["ink-muted"], anchor="ls")


def fit(lines: list[str], size: int, room: int, m: dict) -> int:
    """The largest size up to `size` at which every line, and the last one's full stop, fits in `room`."""
    while size > m["cell"]:
        font = display(size, m)
        widths = [font.getlength(line) for line in lines]
        widths[-1] += size * m["gap"] + m["stop"]
        if max(widths) <= room:
            break
        size -= SCALE * 2
    return size


def title(draw: ImageDraw.ImageDraw, lines: list[str], size: int, first: int, x: int, colors: dict, stop, m: dict, pitch: int) -> None:
    """Lines on the grid's rows, one every `pitch` (a whole number of cells) from baseline `first`; the last
    one closed by the full stop, one cell, on the baseline."""
    font = display(size, m)
    for i, line in enumerate(lines):
        baseline = first + pitch * i
        draw.text((x, baseline), line, font=font, fill=colors["ink"], anchor="ls")
    end = x + font.getlength(lines[-1]) + size * m["gap"]
    draw.rectangle([end, baseline - m["stop"], end + m["stop"] - 1, baseline - 1], fill=stop)


def order(name: str) -> int | None:
    """The app's catalogue number, from its content file on the site, if it has one."""
    content = CONTENT / f"{name}.md"
    found = content.exists() and re.search(r"^order:\s*(\d+)", content.read_text(), re.M)
    return int(found.group(1)) if found else None


def app_card(name: str, accent: str, colors: dict, m: dict) -> Image.Image:
    image = paper(colors, m)
    cell = m["cell"]
    side = cell * 11
    mask = Image.open(SOURCES / f"sbu-{name}.png").getchannel("A").resize((side, side), Image.LANCZOS)
    image.paste(Image.new("RGB", mask.size, colors["ink"]), (W - side - cell, cell), mask)
    draw = ImageDraw.Draw(image)
    number = order(name)
    cartiglio(draw, " / ".join(["sbu", *([f"{number:02d}"] if number else []), name]), cell * 2, cell * 2 - cell // 3, colors, m)
    lines = ["Sbu", name.capitalize()]
    # Three cells a line; a long name gets smaller so it stops a cell short of the engraving.
    size = fit(lines, cell * 3, W - side - cell * 4, m)
    # The line pitch stays a whole number of cells: the size rounded up to the grid.
    title(draw, lines, size, cell * 6, cell * 2, colors, colors[accent], m, -(-size // cell) * cell)
    cartiglio(draw, "sbu.dev", cell * 2, cell * 12 - cell // 3, colors, m)
    return image


def home_card(lines: list[str], line: str, colors: dict, m: dict) -> Image.Image:
    image = paper(colors, m)
    cell = m["cell"]
    draw = ImageDraw.Draw(image)
    title(draw, lines, cell * 3, cell * 6, cell * 2, colors, colors["brand"], m, cell * 3)
    cartiglio(draw, line, cell * 2, cell * 12 - cell // 3, colors, m)
    return image


def main() -> None:
    colors, m = load()
    OUT.mkdir(parents=True, exist_ok=True)
    for name, spec in json.loads(SPECS.read_text()).items():
        if (SOURCES / f"sbu-{name}.png").exists():
            app_card(name, spec["accent"], colors, m).save(OUT / f"{name}.png", optimize=True)
    for locale, (lines, line) in HOME.items():
        home_card(lines, line, colors, m).save(OUT / f"home-{locale}.png", optimize=True)
    print(f"wrote {len(list(OUT.glob('*.png')))} previews to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
