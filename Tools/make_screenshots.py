#!/usr/bin/env python3
"""Turn an app's raw `fastlane snapshot` screenshots into its App Store screenshots.

One panorama on paper cut into one 1320×2868 image per screenshot (2 to 5): the layout lives in
Tools/screenshots/store.html (decided in #437). Its closing card with the Sbu logo is not written:
App Review wants every screenshot to show the app in use (guideline 2.3.3).
Per app it reads everything from the repo: the accent from Design/tokens.json, the icon
engraving from Design/icons/source/sbu-<app>.png, the titles from
fastlane/screenshots/<lang>/title.strings ("Title. Subtitle." splits at the first full stop).

Writes `<raw name>_framed.png` next to each raw screenshot;
`deliver` uploads only the framed ones when they exist. Renders with Chrome headless.

Usage:
  python3 Tools/make_screenshots.py              # every app with snapshots
  python3 Tools/make_screenshots.py habits moon
  python3 Tools/make_screenshots.py habits --preview   # open all slices side by side in Chrome
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

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SIZE = (1320, 2868)
DEVICE = "iPhone 17 Pro Max"


def light_tokens():
    """Colors, shadow (light values) and the full stop's proportions from Design/tokens.json."""
    design = json.loads((ROOT / "Design/tokens.json").read_text())
    tokens = design["color"]["tokens"] + design["shadow"]["tokens"]
    values = {t["name"]: t["value"]["light"] for t in tokens}
    values.update({t["name"]: f'{int(t["value"].rstrip("%")) / 100}em' for t in design["mark"]["tokens"]})
    return values


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


def app_config(app, lang_dir, colors):
    titles = read_titles(lang_dir / "title.strings")
    shots = []
    for image in raw_shots(lang_dir):
        key = image.stem.removeprefix(f"{DEVICE}-")
        if key not in titles:
            sys.exit(f"{image}: no title for {key!r} in {lang_dir / 'title.strings'}")
        title, subtitle = titles[key]
        shots.append({"image": "/" + image.relative_to(ROOT).as_posix(), "title": title, "subtitle": subtitle})
    if not 2 <= len(shots) <= 5:
        sys.exit(f"{lang_dir}: {len(shots)} screenshots, the layout takes 2 to 5 (run fastlane snapshot)")
    return {
        "engraving": f"/Design/icons/source/sbu-{app}.png",
        "tokens": {
            "surface": colors["surface"], "sunken": colors["surface-sunken"], "ink": colors["ink"],
            "ink-muted": colors["ink-muted"], "brand": colors["brand"], "accent": colors[f"accent-{app}"],
            "mark-size": colors["mark-size"], "mark-gap": colors["mark-gap"], "shadow": drop_shadow(colors["shadow-marketing"]),
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


def render(url, out):
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                    f"--window-size={SIZE[0]},{SIZE[1]}", "--virtual-time-budget=5000", f"--screenshot={out}", url],
                   check=True, capture_output=True)
    with Image.open(out) as image:
        if image.size != SIZE:
            sys.exit(f"{out}: {image.size}, expected {SIZE}")
        image.convert("RGB").save(out)  # App Store Connect rejects alpha


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("apps", nargs="*", help="app names (habits, moon…); default: every app with snapshots")
    parser.add_argument("--preview", action="store_true", help="open the slices side by side instead of writing PNGs")
    args = parser.parse_args()

    colors = light_tokens()
    apps = args.apps or sorted(p.name.removeprefix("Sbu").lower() for p in (ROOT / "Apps").iterdir()
                               if any((p / "fastlane/screenshots").glob(f"*/{DEVICE}-*.png")))
    base = serve()
    for app in apps:
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
