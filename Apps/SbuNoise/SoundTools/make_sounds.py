#!/usr/bin/env python3
"""Builds the loops of the Sbu Noise catalog into SbuNoise/Sounds/<id>.caf.

Two kinds of sound, both listed in sounds.json:

- "recording": a CC0 recording from Freesound. The script downloads the public HQ preview of the
  page (the licence was read on that page and is recorded in sounds.json), cuts the window, folds
  the seam with an equal-power crossfade so the loop has no gap, matches the loudness of the
  generated noises and encodes it.
- "synth": made here from shaped noise. Everything is periodic over the loop length (spectra
  built on the loop's own FFT bins, envelopes with whole cycles), so the loop has no seam at all.

Output: AAC 96 kbps stereo, 44.1 kHz, in CAF, with PAD frames of wrap-around before and after the
loop. `AVAudioFile` drops the AAC priming frames (LoopLoadingTests) and SoundEngine.loadLoop skips
the padding, so the loop plays exactly as written.

Run once at development time; the app never touches the network.
    python3 SoundTools/make_sounds.py [--cache DIR] [--only ID ...]
Needs numpy and ffmpeg (decoding the MP3 previews); encodes with macOS afconvert.
"""
import argparse
import json
import os
import subprocess
import sys
import tempfile
import urllib.request
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "SbuNoise", "Sounds")
RATE = 44_100
# The generated noises play at about 0.18 RMS (NoiseGenerator): recordings land near it.
TARGET_RMS_DB = -19.0
PEAK = 0.79  # -2 dBFS: room for the AAC overshoot
# Frames of the loop's own end and start added before and after it. AAC cannot rebuild the very
# first and last samples of a file exactly (its frames overlap their neighbours), which would
# tick at the seam; the padding takes that error, and SoundEngine.loadLoop skips it.
PAD = 4096


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cache", default=os.path.join(tempfile.gettempdir(), "sbu-noise-sources"))
    parser.add_argument("--only", nargs="*")
    args = parser.parse_args()
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(args.cache, exist_ok=True)
    manifest = json.load(open(os.path.join(HERE, "sounds.json")))
    for sound in manifest["sounds"]:
        if args.only and sound["id"] not in args.only:
            continue
        if sound["kind"] == "recording":
            audio = recording(sound, args.cache)
        else:
            audio = SYNTHS[sound["synth"]](sound["seconds"], np.random.default_rng(sound.get("seed", 1)))
            audio = normalize(audio)
        encode(audio, os.path.join(OUT, sound["id"] + ".caf"), sound.get("format", "aac"))
        print(f'{sound["id"]}: {len(audio) / RATE:.0f} s')


# MARK: Recordings

def recording(sound, cache):
    path = os.path.join(cache, sound["id"] + ".mp3")
    if not os.path.exists(path):
        request = urllib.request.Request(sound["preview"], headers={"User-Agent": "sbu-noise make_sounds"})
        with urllib.request.urlopen(request, timeout=120) as response, open(path, "wb") as file:
            file.write(response.read())
    audio = decode(path)
    fade = sound.get("crossfade", 3.0)
    start = int(sound["start"] * RATE)
    length = int(sound["seconds"] * RATE)
    window = audio[start:start + length + int(fade * RATE)]
    if len(window) < length + int(fade * RATE):
        sys.exit(f'{sound["id"]}: the source is too short for start {sound["start"]} + {sound["seconds"]} s')
    if sound.get("widen"):
        window = widen(window, sound["widen"])
    return normalize(loop(window, length))


def decode(path):
    raw = subprocess.run(
        ["ffmpeg", "-v", "quiet", "-i", path, "-f", "f32le", "-ac", "2", "-ar", str(RATE), "-"],
        capture_output=True, check=True,
    ).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).astype(np.float64)


def loop(window, length):
    """Folds the tail past `length` over the head with an equal-power crossfade: the last sample
    of the loop runs straight into the first, as it did in the recording."""
    tail = window[length:]
    fade = len(tail)
    t = np.linspace(0, np.pi / 2, fade)[:, None]
    out = window[:length].copy()
    out[:fade] = window[:fade] * np.sin(t) + tail * np.cos(t)
    return out


def widen(audio, amount):
    """More side signal for a near-mono recording, by a short delay on one side."""
    delay = int(0.012 * RATE)
    shifted = np.roll(audio[:, 1], delay)
    audio = audio.copy()
    audio[:, 1] = (1 - amount) * audio[:, 1] + amount * shifted
    return audio


# MARK: Synthesis (periodic over the loop)

def shaped_noise(seconds, rng, gain_at):
    """Noise whose spectrum follows `gain_at(frequencies)`, exactly periodic over `seconds`."""
    n = int(seconds * RATE)
    freqs = np.fft.rfftfreq(n, 1 / RATE)
    gain = gain_at(np.maximum(freqs, 1.0))
    gain[0] = 0
    channels = []
    for _ in range(2):
        spectrum = (rng.standard_normal(len(freqs)) + 1j * rng.standard_normal(len(freqs))) * gain
        channels.append(np.fft.irfft(spectrum, n))
    audio = np.stack(channels, axis=1)
    return audio / np.sqrt(np.mean(audio ** 2))


def envelope(seconds, rng, cycles, depth):
    """A smooth periodic swell between 1 - depth and 1 + depth, made of whole cycles."""
    n = int(seconds * RATE)
    t = np.arange(n) / n
    curve = np.zeros(n)
    for k in cycles:
        curve += rng.uniform(0.3, 1) * np.cos(2 * np.pi * k * t + rng.uniform(0, 2 * np.pi))
    curve /= np.max(np.abs(curve))
    return (1 + depth * curve)[:, None]


def band(low, high, slope=0.0):
    def gain(f):
        g = 1 / (1 + (low / f) ** 4) / (1 + (f / high) ** 4)
        return g * (f / 1000) ** slope
    return gain


def tone(seconds, hertz, level):
    """A hum with whole cycles over the loop."""
    n = int(seconds * RATE)
    cycles = round(hertz * seconds)
    t = np.arange(n) / n
    return (level * np.sin(2 * np.pi * cycles * t))[:, None] * np.ones((1, 2))


def wind(seconds, rng):
    low = shaped_noise(seconds, rng, band(80, 500, -1)) * envelope(seconds, rng, range(2, 9), 0.6)
    mid = shaped_noise(seconds, rng, band(300, 1500, -1)) * envelope(seconds, rng, range(3, 12), 0.8)
    high = shaped_noise(seconds, rng, band(900, 2800, -0.5)) * envelope(seconds, rng, range(4, 15), 0.9)
    return low + 0.5 * mid + 0.15 * high


def air_conditioner(seconds, rng):
    air = shaped_noise(seconds, rng, band(60, 2500, -0.8))
    rumble = shaped_noise(seconds, rng, band(30, 200, -1.5))
    hum = tone(seconds, 120, 0.04) + tone(seconds, 240, 0.015)
    return air * envelope(seconds, rng, [1, 2], 0.03) + 0.6 * rumble + hum


def airplane(seconds, rng):
    cabin = shaped_noise(seconds, rng, band(25, 700, -1.2))
    hiss = shaped_noise(seconds, rng, band(1500, 6000, 0))
    hum = tone(seconds, 98, 0.05) + tone(seconds, 196, 0.02)
    return cabin * envelope(seconds, rng, [1, 3], 0.05) + 0.05 * hiss + hum


def drops(seconds, rng):
    """Water dripping: Poisson drops, each a short sine that rises in pitch (a bubble), over a
    faint trickle."""
    n = int(seconds * RATE)
    out = 0.04 * shaped_noise(seconds, rng, band(200, 3000, -1))
    time = 0.0
    while True:
        time += rng.exponential(0.45)
        if time >= seconds:
            break
        f0 = rng.uniform(700, 2200)
        decay = rng.uniform(0.012, 0.04)
        length = int(decay * 6 * RATE)
        t = np.arange(length) / RATE
        freq = f0 * (1 + 0.6 * t / (decay * 6))
        drop = np.sin(2 * np.pi * np.cumsum(freq) / RATE) * np.exp(-t / decay) * rng.uniform(0.3, 1)
        pan = rng.uniform(0.2, 0.8)
        index = (int(time * RATE) + np.arange(length)) % n  # tails wrap: the loop has no seam
        out[index, 0] += drop * (1 - pan)
        out[index, 1] += drop * pan
    return out


def bell(frequency, seconds, decay):
    t = np.arange(int(seconds * RATE)) / RATE
    partials = [(1, 1.0), (2.76, 0.5), (5.40, 0.25), (8.93, 0.12)]
    sound = sum(level * np.sin(2 * np.pi * frequency * ratio * t) * np.exp(-t * ratio / decay) for ratio, level in partials)
    attack = np.minimum(1, t / 0.004)
    return sound * attack


def chimes(seconds, rng):
    """A soft four-note bell figure every four seconds: the alarm tone Rintocchi."""
    n = int(seconds * RATE)
    out = np.zeros((n, 2))
    notes = [1046.5, 1318.5, 1568.0, 1760.0]
    for bar in range(int(seconds // 4)):
        for step, frequency in enumerate(notes):
            start = int((bar * 4 + step * 0.35) * RATE)
            ring = bell(frequency, 2.5, 0.8)
            index = (start + np.arange(len(ring))) % n
            pan = 0.35 + 0.1 * step
            out[index, 0] += ring * (1 - pan)
            out[index, 1] += ring * pan
    return out


def beeps(seconds, rng):
    """The classic alarm clock: four short beeps, then a rest, every two seconds."""
    n = int(seconds * RATE)
    out = np.zeros(n)
    t = np.arange(int(0.08 * RATE)) / RATE
    beep = np.sin(2 * np.pi * 1000 * t) * np.sin(np.pi * t / 0.08) ** 0.5
    for bar in range(int(seconds // 2)):
        for step in range(4):
            start = int((bar * 2 + step * 0.16) * RATE)
            out[start:start + len(beep)] += beep
    return np.stack([out, out], axis=1)


SYNTHS = {"wind": wind, "air_conditioner": air_conditioner, "airplane": airplane, "drops": drops, "chimes": chimes, "beeps": beeps}


# MARK: Output

def normalize(audio):
    audio = audio - audio.mean(axis=0)
    rms = np.sqrt(np.mean(audio ** 2))
    audio = audio * (10 ** (TARGET_RMS_DB / 20) / rms)
    peak = np.max(np.abs(audio))
    if peak > PEAK:
        # Soft knee above 0.6, so crackles and wave crests are rounded rather than clipped.
        knee = 0.6
        over = np.abs(audio) > knee
        audio[over] = np.sign(audio[over]) * (knee + (PEAK - knee) * np.tanh((np.abs(audio[over]) - knee) / (PEAK - knee)))
    return audio


def encode(audio, path, codec="aac"):
    """AAC for the loops; IMA4 for the notification sound, which iOS only plays as linear PCM,
    IMA4, µLaw or aLaw, under 30 seconds."""
    with tempfile.TemporaryDirectory() as folder:
        source = os.path.join(folder, "loop.wav")
        pcm = (np.clip(audio, -1, 1) * 32767).astype("<i2")
        with wave.open(source, "wb") as file:
            file.setnchannels(2)
            file.setsampwidth(2)
            file.setframerate(RATE)
            file.writeframes(pcm.tobytes())
        if codec == "aac":
            pcm = np.concatenate([pcm[-PAD:], pcm, pcm[:PAD]])
            with wave.open(source, "wb") as file:
                file.setnchannels(2)
                file.setsampwidth(2)
                file.setframerate(RATE)
                file.writeframes(pcm.tobytes())
            subprocess.run(["afconvert", "-f", "caff", "-d", "aac", "-b", "96000", source, path], check=True)
        else:
            subprocess.run(["afconvert", "-f", "caff", "-d", "ima4", source, path], check=True)


if __name__ == "__main__":
    main()
