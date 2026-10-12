#!/usr/bin/env python3
"""Download the App Store top-paid charts and enrich each app with public iTunes Lookup data.

Usage: python3 Tools/discover.py [--countries it us] [--limit 50] [--no-screenshots]
Writes research/<app-id>/meta.json and research/<app-id>/screenshots/NN.<ext>.
Only public App Store data: chart RSS, iTunes Lookup API, listing screenshots.
"""
import argparse
import json
import re
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RESEARCH = ROOT / "research"
CHART = "https://rss.marketingtools.apple.com/api/v2/{cc}/apps/top-paid/{limit}/apps.json"
LOOKUP = "https://itunes.apple.com/lookup?id={ids}&country={cc}&entity=software"


def fetch(url: str, attempts: int = 3) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": "sbu-apps-discover/1.0"})
    for attempt in range(1, attempts + 1):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return response.read()
        except OSError:
            if attempt == attempts:
                raise
            time.sleep(2 * attempt)
    raise AssertionError("unreachable")


def full_size(url: str) -> str:
    """Lookup returns ~392px thumbnails; ask the CDN for a width the vision model can read."""
    return re.sub(r"/\d+x\d+bb\.(png|jpg)$", r"/1170x0w.\1", url)


def chart(cc: str, limit: int) -> list[dict]:
    return json.loads(fetch(CHART.format(cc=cc, limit=limit)))["feed"]["results"]


def lookup(ids: list[str], cc: str) -> dict[str, dict]:
    results = json.loads(fetch(LOOKUP.format(ids=",".join(ids), cc=cc)))["results"]
    return {str(r["trackId"]): r for r in results if "trackId" in r}


def meta(app: dict, ranks: dict[str, int], cc: str) -> dict:
    return {
        "id": str(app["trackId"]),
        "name": app.get("trackName"),
        "developer": app.get("artistName"),
        "bundle_id": app.get("bundleId"),
        "store_country": cc,
        "ranks": ranks,
        "price": app.get("price"),
        "formatted_price": app.get("formattedPrice"),
        "currency": app.get("currency"),
        "genre": app.get("primaryGenreName"),
        "genres": app.get("genres", []),
        "description": app.get("description"),
        "release_notes": app.get("releaseNotes"),
        "version": app.get("version"),
        "current_version_release_date": app.get("currentVersionReleaseDate"),
        "rating": app.get("averageUserRating"),
        "rating_count": app.get("userRatingCount"),
        "minimum_os": app.get("minimumOsVersion"),
        "url": app.get("trackViewUrl"),
        "screenshot_urls": app.get("screenshotUrls", []),
    }


def download_screenshots(info: dict) -> int:
    folder = RESEARCH / info["id"] / "screenshots"
    folder.mkdir(parents=True, exist_ok=True)
    saved = 0
    for index, url in enumerate(info["screenshot_urls"], start=1):
        target = folder / f"{index:02d}{Path(url).suffix or '.jpg'}"
        if not target.exists():
            target.write_bytes(fetch(full_size(url)))
        saved += 1
    return saved


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--countries", nargs="+", default=["it", "us"])
    parser.add_argument("--limit", type=int, default=50, choices=[10, 25, 50, 100])
    parser.add_argument("--no-screenshots", action="store_true")
    args = parser.parse_args()

    ranks: dict[str, dict[str, int]] = {}
    first_country: dict[str, str] = {}
    for cc in args.countries:
        for rank, entry in enumerate(chart(cc, args.limit), start=1):
            ranks.setdefault(entry["id"], {})[cc] = rank
            first_country.setdefault(entry["id"], cc)

    apps: list[dict] = []
    for cc in args.countries:
        ids = [app_id for app_id, country in first_country.items() if country == cc]
        for app_id, app in lookup(ids, cc).items():
            apps.append(meta(app, ranks[app_id], cc))

    for info in apps:
        folder = RESEARCH / info["id"]
        folder.mkdir(parents=True, exist_ok=True)
        (folder / "meta.json").write_text(json.dumps(info, ensure_ascii=False, indent=2) + "\n")

    if not args.no_screenshots:
        with ThreadPoolExecutor(max_workers=8) as pool:
            shots = sum(pool.map(download_screenshots, apps))
        print(f"{shots} screenshots")

    for info in sorted(apps, key=lambda a: min(a["ranks"].values())):
        ranks_text = " ".join(f"{cc}#{rank}" for cc, rank in info["ranks"].items())
        print(f"{info['id']:>12}  {ranks_text:<14} {info['formatted_price'] or '':>8}  {info['name']}")
    print(f"{len(apps)} apps -> {RESEARCH.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()
