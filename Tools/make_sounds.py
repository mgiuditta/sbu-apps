#!/usr/bin/env python3
"""Synthesize the Sbu Habits reminder sounds from sine waves: no recorded or third-party audio.

Usage: python3 Tools/make_sounds.py
Writes Apps/SbuHabits/SbuHabits/Sounds/<Name>.caf (16-bit PCM, 44.1 kHz, mono), each under a
second, far within the 30 s iOS allows for a notification sound. Needs macOS `afconvert`.
"""
import math
import struct
import subprocess
import tempfile
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "Apps" / "SbuHabits" / "SbuHabits" / "Sounds"
RATE = 44_100

# Each sound is a list of notes: (start s, frequency Hz, length s, peak 0-1).
SOUNDS = {
    # Punto: one soft, short tone, like a full stop.
    "SbuPunto": [(0.0, 880.0, 0.45, 0.55)],
    # Carta: two notes a fourth apart, light as a page turning.
    "SbuCarta": [(0.0, 659.25, 0.35, 0.45), (0.16, 880.0, 0.5, 0.45)],
}


def note(t: float, frequency: float, length: float, peak: float) -> float:
    """A sine with a quick attack and an exponential decay, plus a quiet octave for warmth."""
    if t < 0 or t > length:
        return 0.0
    attack = min(t / 0.008, 1.0)
    decay = math.exp(-t * 6.0 / length)
    tone = math.sin(2 * math.pi * frequency * t) + 0.25 * math.sin(4 * math.pi * frequency * t)
    return peak * attack * decay * tone / 1.25


def render(notes: list[tuple[float, float, float, float]]) -> bytes:
    total = max(start + length for start, _, length, _ in notes) + 0.05
    frames = bytearray()
    for i in range(int(total * RATE)):
        t = i / RATE
        sample = sum(note(t - start, frequency, length, peak) for start, frequency, length, peak in notes)
        frames += struct.pack("<h", int(max(-1.0, min(1.0, sample)) * 32_767))
    return bytes(frames)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as scratch:
        for name, notes in SOUNDS.items():
            wav = Path(scratch) / f"{name}.wav"
            with wave.open(str(wav), "wb") as file:
                file.setnchannels(1)
                file.setsampwidth(2)
                file.setframerate(RATE)
                file.writeframes(render(notes))
            caf = OUT / f"{name}.caf"
            subprocess.run(["afconvert", "-f", "caff", "-d", "LEI16", str(wav), str(caf)], check=True)
            print(f"wrote {caf.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
