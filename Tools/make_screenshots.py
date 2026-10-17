#!/usr/bin/env python3
"""Turn an app's raw `fastlane snapshot` screenshots into its App Store screenshots.

One 1320×2868 image per screenshot (2 to 5), each slide composed on its own: the layouts live in
Tools/screenshots/store.html. Every screenshot shows the app in use (guideline 2.3.3).
Per app it reads everything from the repo: the accent from Design/tokens.json, the titles from
fastlane/screenshots/<lang>/title.strings ("Title. Subtitle." splits at the first full stop), and
the slides from fastlane/screenshots/scenes.json:
  {"01-main": {"layout": "hero" | "tilt-l" | "tilt-r" | "detail" | "flat",
               "engraving": "icon" | "subject": "<what Gemini engraves>",
               "zoom": [x0, y0, x1, y1],                       # detail: the screen region to enlarge
               "mark": {"shape": "circle" | "underline", "box": [x0, y0, x1, y1]}}}  # ink on a real value
Boxes are pixels of the raw screenshot. Without scenes.json the slides alternate tilted phones on the
icon engraving. A "subject" is engraved once with --engrave (Tools/make_icons.py style, GEMINI_API_KEY)
into Design/icons/scenes/sbu-<app>-<key>.png and kept, like the icon masks.

Writes `<raw name>_framed.png` next to each raw screenshot;
`deliver` uploads only the framed ones when they exist. Renders with Chrome headless.

Usage:
  python3 Tools/make_screenshots.py              # every app with snapshots
  python3 Tools/make_screenshots.py habits moon
  python3 Tools/make_screenshots.py habits --preview   # open all slices side by side in Chrome
  python3 Tools/make_screenshots.py subscriptions --engrave   # engrave the scenes still missing, then render
"""
import argparse
import functools
import json
import re
import subprocess
import sys
import threading
import urllib.parse
import webbrowser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parent.parent
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SIZE = (1320, 2868)
DEVICE = "iPhone 17 Pro Max"


# Store screenshots are 1320 px wide for a 440 pt screen: 3 px per point.
SCALE = 3


def light_tokens():
    """Colors and shadow (light values), the full stop's gap, and the grid, full stop and cartiglio
    measures scaled to the screenshot, from Design/tokens.json."""
    design = json.loads((ROOT / "Design/tokens.json").read_text())
    tokens = design["color"]["tokens"] + design["shadow"]["tokens"]
    values = {t["name"]: t["value"]["light"] for t in tokens}
    values.update({t["name"]: f'{int(t["value"].rstrip("%")) / 100}em' for t in design["mark"]["tokens"]})
    for group in ("grid", "full-stop", "figure"):
        for t in design[group]["tokens"]:
            value = t["value"]
            if value.endswith("px"):
                values[t["name"]] = f'{int(value.removesuffix("px")) * SCALE}px'
            elif value.endswith("%"):
                values[t["name"]] = f'{int(value.rstrip("%")) / 100}em'
            else:
                values[t["name"]] = value
    return values


def catalogue_number(app):
    """The app's `order` from its site content file, for the cartiglio; None without one."""
    content = ROOT / "Site/src/content/apps" / f"{app}.md"
    found = content.exists() and re.search(r"^order:\s*(\d+)", content.read_text(), re.M)
    return int(found.group(1)) if found else None


def drop_shadow(box_shadow):
    """`x y blur spread color` -> `x y blur color`: CSS drop-shadow() (which follows the bezel's
    transparent outline, unlike box-shadow) takes no spread."""
    x, y, blur, _spread, color = box_shadow.split(" ", 4)
    return f"{x} {y} {blur} {color}"


def read_titles(path):
    """title.strings: `"01-main" = "Title. Subtitle.";` -> {key: (title, subtitle)}."""
    titles = {}
    for key, text in re.findall(r'"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)";', path.read_text()):
        title, _, subtitle = text.partition(". ")
        titles[key] = (title.rstrip("."), subtitle)
    return titles


def raw_shots(folder):
    return sorted(p for p in folder.glob(f"{DEVICE}-*.png") if "_framed" not in p.name)


def scene_mask(app, key):
    return ROOT / "Design/icons/scenes" / f"sbu-{app}-{key}.png"


def read_scenes(app):
    path = ROOT / "Apps" / f"Sbu{app.capitalize()}" / "fastlane/screenshots/scenes.json"
    return json.loads(path.read_text()) if path.exists() else {}


def engrave(app):
    """Engrave every scene subject that has no mask yet."""
    from make_icons import generate, ink_mask

    for key, scene in read_scenes(app).items():
        out = scene_mask(app, key)
        if "subject" in scene and not out.exists():
            mask = ink_mask(generate(scene["subject"]))
            out.parent.mkdir(parents=True, exist_ok=True)
            Image.merge("LA", (Image.new("L", mask.size, 255), mask)).save(out)
            print(out.relative_to(ROOT))


def app_config(app, lang_dir, colors):
    titles = read_titles(lang_dir / "title.strings")
    scenes = read_scenes(app)
    icon = f"/Design/icons/source/sbu-{app}.png"
    shots = []
    images = raw_shots(lang_dir)
    for i, image in enumerate(images):
        key = image.stem.removeprefix(f"{DEVICE}-")
        if key not in titles:
            sys.exit(f"{image}: no title for {key!r} in {lang_dir / 'title.strings'}")
        title, subtitle = titles[key]
        scene = scenes.get(key, {"layout": "flat" if i == len(images) - 1 else ("tilt-l", "tilt-r")[i % 2]})
        engraving = icon
        if "subject" in scene:
            mask = scene_mask(app, key)
            if not mask.exists():
                sys.exit(f"{mask.relative_to(ROOT)} is missing: run with --engrave")
            engraving = "/" + mask.relative_to(ROOT).as_posix()
        shots.append({"image": "/" + image.relative_to(ROOT).as_posix(), "title": title, "subtitle": subtitle,
                      "layout": scene["layout"], "engraving": engraving,
                      "zoom": scene.get("zoom"), "mark": scene.get("mark")})
    if not 2 <= len(shots) <= 5:
        sys.exit(f"{lang_dir}: {len(shots)} screenshots, the layout takes 2 to 5 (run fastlane snapshot)")
    number = catalogue_number(app)
    return {
        "cartiglio": " / ".join(["SBU", *([f"{number:02d}"] if number else []), app.upper()]),
        "tokens": {
            "paper": colors["paper"], "grid": colors["grid"], "surface-raised": colors["surface-raised"], "line": colors["line"], "sunken": colors["surface-sunken"], "ink": colors["ink"],
            "ink-muted": colors["ink-muted"], "brand": colors["brand"], "accent": colors[f"accent-{app}"],
            "mark-gap": colors["mark-gap"], "shadow": drop_shadow(colors["shadow-marketing"]),
            "grid-cell": colors["grid-cell"], "grid-line-width": colors["grid-line-width"], "grid-offset": colors["grid-offset"],
            "full-stop-hero": colors["full-stop-hero"], "cartiglio-size": colors["cartiglio-size"],
            "cartiglio-tracking": colors["cartiglio-tracking"], "title-stretch": f'{colors["figure-width-mid"]}%',
        },
        "shots": shots,
    }


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *_):
        pass


def serve():
    server = ThreadingHTTPServer(("127.0.0.1", 0), functools.partial(QuietHandler, directory=ROOT))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return f"http://127.0.0.1:{server.server_port}/Tools/screenshots/store.html"


def shoot(url, out):
    # ponytail: headless Chrome sometimes leaves the bottom ~70px of the window unpainted when the
    # 3D phones are heavy, so render a taller window and keep the top SIZE.
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                    "--run-all-compositor-stages-before-draw",
                    f"--window-size={SIZE[0]},{SIZE[1] + 200}", "--virtual-time-budget=20000", f"--screenshot={out}", url],
                   check=True, capture_output=True)
    with Image.open(out) as image:
        if image.size != (SIZE[0], SIZE[1] + 200):
            sys.exit(f"{out}: {image.size}, expected {SIZE[0]}×{SIZE[1] + 200}")
        return image.crop((0, 0) + SIZE).convert("RGB")  # App Store Connect rejects alpha


def render(url, out):
    """Headless Chrome now and then skips tiles of the tilted phones, never the same way twice:
    a slice is kept once two renders in a row agree."""
    previous = shoot(url, out)
    for _ in range(5):
        image = shoot(url, out)
        if ImageChops.difference(image, previous).getbbox() is None:
            break
        previous = image
    else:
        print(f"warning: {out.name} never rendered the same twice, check it by eye")
    image.save(out)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("apps", nargs="*", help="app names (habits, moon…); default: every app with snapshots")
    parser.add_argument("--preview", action="store_true", help="open the slices side by side instead of writing PNGs")
    parser.add_argument("--engrave", action="store_true", help="engrave the missing scene subjects with Gemini first")
    args = parser.parse_args()

    colors = light_tokens()
    apps = args.apps or sorted(p.name.removeprefix("Sbu").lower() for p in (ROOT / "Apps").iterdir()
                               if any((p / "fastlane/screenshots").glob(f"*/{DEVICE}-*.png")))
    base = serve()
    for app in apps:
        if args.engrave:
            engrave(app)
        folder = ROOT / "Apps" / f"Sbu{app.capitalize()}" / "fastlane/screenshots"
        for lang_dir in sorted(d for d in folder.iterdir() if (d / "title.strings").exists() and raw_shots(d)):
            config = urllib.parse.quote(json.dumps(app_config(app, lang_dir, colors)))
            if args.preview:
                webbrowser.get("open -a 'Google Chrome' %s").open(f"{base}#{config}")
                continue
            for old in lang_dir.glob("*_framed.png"):
                old.unlink()
            shots = raw_shots(lang_dir)
            outs = [s.with_name(f"{s.stem}_framed.png") for s in shots]
            for i, out in enumerate(outs):
                render(f"{base}?slice={i}#{config}", out)
            print(f"{app} {lang_dir.name}: {len(outs)} screenshots")
    if args.preview:
        input("Preview open in Chrome. Press Return to stop the server.")


if __name__ == "__main__":
    main()
