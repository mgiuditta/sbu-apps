#!/usr/bin/env python3
"""Generate a photo-library fixture set for Sbu Clean, without any third-party picture.

Scenes are drawn procedurally (sky, hills, buildings, shapes, film grain), then varied the way a
real library varies: exact re-saved copies, near-duplicates (slight crop, brighter), bursts
(the subject moved a little), blurry shots next to sharp ones, screenshots and screen-sized
videos. Every photo carries an EXIF capture date, so the month-by-month timeline has history.

    python3 make_fixtures.py OUT_DIR             # full set to seed a simulator
    python3 make_fixtures.py OUT_DIR --tests     # the small set the unit tests bundle

Seed a simulator with:  xcrun simctl addmedia <udid> OUT_DIR/*
Needs Pillow; videos need ffmpeg (skipped when missing).
"""

import argparse
import datetime as dt
import os
import random
import shutil
import subprocess

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

PHOTO_SIZE = (1600, 1200)
TEST_SIZE = (800, 600)
SCREEN_SIZE = (1179, 2556)


def scene(seed, size=PHOTO_SIZE, shift=0):
    """A landscape-like picture: sky, sun, hills, a few buildings or shapes, grain."""
    rnd = random.Random(seed)
    w, h = size
    img = Image.new("RGB", size)
    draw = ImageDraw.Draw(img)
    top = tuple(rnd.randint(40, 200) for _ in range(3))
    bottom = tuple(min(255, c + rnd.randint(30, 90)) for c in top)
    for y in range(h):
        t = y / h
        draw.line([(0, y), (w, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    sun = rnd.randint(int(w * 0.1), int(w * 0.9)) + shift
    r = rnd.randint(h // 14, h // 7)
    draw.ellipse([sun - r, h // 5 - r, sun + r, h // 5 + r], fill=tuple(rnd.randint(180, 255) for _ in range(3)))
    for layer in range(rnd.randint(2, 4)):
        base = int(h * (0.45 + 0.12 * layer))
        color = tuple(rnd.randint(10, 160) for _ in range(3))
        points = [(0, h)]
        x = 0
        while x <= w:
            points.append((x, base + rnd.randint(-h // 10, h // 10)))
            x += w // rnd.randint(4, 9)
        points += [(w, base), (w, h)]
        draw.polygon(points, fill=color)
    kind = rnd.choice(["buildings", "circles", "trees"])
    for _ in range(rnd.randint(4, 10)):
        x = rnd.randint(0, w) + shift
        y = rnd.randint(h // 2, h)
        s = rnd.randint(h // 20, h // 5)
        color = tuple(rnd.randint(0, 255) for _ in range(3))
        if kind == "buildings":
            draw.rectangle([x, y - 2 * s, x + s, h], fill=color)
            for wy in range(y - 2 * s + 6, h, 14):
                draw.rectangle([x + 4, wy, x + s - 4, wy + 5], fill=(240, 230, 160))
        elif kind == "circles":
            draw.ellipse([x - s, y - s, x + s, y + s], fill=color, outline=(0, 0, 0), width=3)
        else:
            draw.polygon([(x, y - 2 * s), (x - s, y), (x + s, y)], fill=color)
            draw.rectangle([x - s // 8, y, x + s // 8, y + s // 2], fill=(80, 50, 20))
    grain = Image.effect_noise(size, 18).convert("RGB")
    return Image.blend(img, grain, 0.08)


def exif_with(date, comment=None):
    exif = Image.Exif()
    stamp = date.strftime("%Y:%m:%d %H:%M:%S")
    exif[0x0132] = stamp  # DateTime
    ifd = exif.get_ifd(0x8769)
    ifd[0x9003] = stamp  # DateTimeOriginal
    ifd[0x9004] = stamp  # DateTimeDigitized
    if comment:
        ifd[0x9286] = comment  # UserComment
    exif[0x010F] = "Sbu"  # Make
    exif[0x0110] = "Fixture Camera"  # Model
    return exif


def save(img, path, date, quality=92, comment=None):
    kwargs = {"exif": exif_with(date, comment)}
    if path.endswith(".png"):
        img.save(path, **kwargs)
    else:
        img.save(path, quality=quality, **kwargs)
    stamp = date.timestamp()
    os.utime(path, (stamp, stamp))


def crop_brighter(img, crop=0.03, brightness=1.08):
    w, h = img.size
    dx, dy = int(w * crop), int(h * crop)
    return ImageEnhance.Brightness(img.crop((dx, dy, w - dx, h - dy)).resize((w, h))).enhance(brightness)


def screenshot(seed, size=SCREEN_SIZE):
    rnd = random.Random(seed)
    w, h = size
    img = Image.new("RGB", size, (246, 244, 239))
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, w, 140], fill=(230, 228, 222))
    y = 200
    while y < h - 200:
        tall = rnd.randint(80, 260)
        draw.rounded_rectangle([60, y, w - 60, y + tall], 28, fill=tuple(rnd.randint(150, 250) for _ in range(3)))
        for line in range(y + 30, y + tall - 20, 40):
            draw.rectangle([100, line, rnd.randint(300, w - 120), line + 14], fill=(40, 40, 40))
        y += tall + 40
    return img


def video(path, seconds, size, rate, date, pattern):
    if not shutil.which("ffmpeg"):
        return
    stamp = date.strftime("%Y-%m-%dT%H:%M:%S.000000Z")
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-f", "lavfi", "-i", f"{pattern}=size={size}:rate=30",
         "-t", str(seconds), "-c:v", "libx264", "-b:v", rate, "-pix_fmt", "yuv420p",
         "-metadata", f"creation_time={stamp}", path],
        check=True,
    )


def full_set(out):
    now = dt.datetime(2026, 10, 10, 12, 0, 0)
    n = 0

    def name(label, ext="jpg"):
        nonlocal n
        n += 1
        return os.path.join(out, f"{n:03d}-{label}.{ext}")

    # Ordinary photos over two years, two to five per month.
    for month in range(24):
        day = now - dt.timedelta(days=30 * month)
        for i in range(2 + month % 4):
            date = day - dt.timedelta(days=i * 3, hours=i)
            save(scene(month * 100 + i), name("photo"), date)
    # Exact duplicates: the same picture saved twice and three times, days apart.
    for k, copies in ((1, 2), (2, 3), (3, 2)):
        img = scene(9000 + k)
        for c in range(copies):
            save(img, name("duplicate"), now - dt.timedelta(days=40 * k, hours=c * 30), quality=92 - c * 4)
    # Near-duplicates: a slightly cropped, brighter copy a minute later.
    for k in range(3):
        img = scene(9100 + k)
        date = now - dt.timedelta(days=15 + 20 * k)
        save(img, name("near-original"), date)
        save(crop_brighter(img), name("near-copy"), date + dt.timedelta(minutes=1))
    # Bursts: the subject moved a little, seconds apart; one of them blurry.
    for k in range(3):
        date = now - dt.timedelta(days=5 + 33 * k, hours=2)
        for s in range(4):
            img = scene(9200 + k, shift=s * 12)
            if s == 2:
                img = img.filter(ImageFilter.GaussianBlur(1.5))
            save(img, name("burst-blurry" if s == 2 else "burst"), date + dt.timedelta(seconds=s * 2))
    # Screenshots: PNG with the comment Photos reads to file them under Screenshots.
    for k in range(8):
        save(screenshot(9300 + k), name("screenshot", "png"), now - dt.timedelta(days=k * 9, hours=3), comment="Screenshot")
    # Videos of different weight: the heaviest first in the Videos list.
    for k, (seconds, rate) in enumerate(((4, "1M"), (12, "6M"), (25, "12M"), (8, "3M"))):
        video(name("video", "mp4"), seconds, "1920x1080", rate, now - dt.timedelta(days=k * 50 + 2), "testsrc2")
    video(name("screen-recording", "mp4"), 6, "1178x2556", "4M", now - dt.timedelta(days=7), "smptebars")


def test_set(out):
    """Small pictures for the unit tests: names say what the grouping must find."""
    date = dt.datetime(2026, 1, 1, 12)
    for k in range(4):
        save(scene(k, TEST_SIZE), os.path.join(out, f"distinct-{k}.jpg"), date)
    original = scene(9001, TEST_SIZE)
    save(original, os.path.join(out, "dup-a.jpg"), date)
    save(original, os.path.join(out, "dup-b.jpg"), date, quality=90)
    near = scene(9101, TEST_SIZE)
    save(near, os.path.join(out, "near-a.jpg"), date)
    save(crop_brighter(near), os.path.join(out, "near-b.jpg"), date)
    for s in range(3):
        img = scene(9201, TEST_SIZE, shift=s * 3)
        if s == 2:
            img = img.filter(ImageFilter.GaussianBlur(1))
        save(img, os.path.join(out, f"burst-{s}{'-blurry' if s == 2 else ''}.jpg"), date)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("out")
    parser.add_argument("--tests", action="store_true", help="the small set bundled with the unit tests")
    args = parser.parse_args()
    os.makedirs(args.out, exist_ok=True)
    (test_set if args.tests else full_set)(args.out)


if __name__ == "__main__":
    main()
