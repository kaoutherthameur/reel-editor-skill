#!/usr/bin/env python3
"""Synthesised house SFX for reel-editor (no samples, no licences, deterministic).

  python3 make_sfx.py [out_dir]      -> writes WAV options + audition.wav (all options in a row, 1 s apart)

Families
  glass-*   glass / UI elements: game-menu select, hologram, Zac-style blob squish, crystal tap, soft confirm
  wind-*    light air for side-to-side moves and the full-screen -> pop-out change
Each option is short, soft-attack and mastered around -18 dBFS peak so it sits under the voice.
"""
import sys
from pathlib import Path

import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, sosfilt

SR = 48000
rng = np.random.default_rng(7)
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets" / "sfx" / "options"
OUT.mkdir(parents=True, exist_ok=True)


def t(d):
    return np.arange(int(SR * d)) / SR


def env(n, a=0.005, r=0.2, curve=4.0):
    x = np.arange(n) / SR
    att = np.clip(x / max(a, 1e-4), 0, 1)
    rel = np.exp(-curve * np.clip(x - a, 0, None) / max(r, 1e-4))
    return att * rel


def bp(x, lo, hi, order=2):
    return sosfilt(butter(order, [lo, hi], btype="band", fs=SR, output="sos"), x)


def lp(x, f, order=2):
    return sosfilt(butter(order, f, btype="low", fs=SR, output="sos"), x)


def hp(x, f, order=2):
    return sosfilt(butter(order, f, btype="high", fs=SR, output="sos"), x)


def sweep(f0, f1, d, shape="exp"):
    n = int(SR * d)
    if shape == "exp":
        f = f0 * (f1 / f0) ** (np.arange(n) / n)
    else:
        f = np.linspace(f0, f1, n)
    return np.sin(2 * np.pi * np.cumsum(f) / SR), f


def room(x, decay=0.35, mix=0.18):
    """tiny synthetic reverb: decaying filtered noise impulse response"""
    n = int(SR * decay)
    ir = rng.standard_normal(n) * np.exp(-6 * np.arange(n) / n)
    ir = lp(ir, 6000)
    dry = np.concatenate([x, np.zeros(n)])
    wet = np.convolve(x, ir)
    wet = np.pad(wet, (0, max(0, len(dry) - len(wet))))[: len(dry)]
    wet /= np.max(np.abs(wet)) + 1e-9
    return dry * (1 - mix) + wet * mix * np.max(np.abs(x))


def stereo(x, width=0.0, delay_ms=6):
    d = int(SR * delay_ms / 1000)
    l = x
    r = np.concatenate([np.zeros(d), x[:-d]]) if width else x
    return np.stack([l * (1 - width / 2), r * (1 - width / 2) + l * width / 2], axis=1)


def master(x, peak_db=-18):
    x = x / (np.max(np.abs(x)) + 1e-9) * 10 ** (peak_db / 20)
    fade = int(SR * 0.01)
    x[-fade:] *= np.linspace(1, 0, fade)[:, None] if x.ndim == 2 else np.linspace(1, 0, fade)
    return x.astype(np.float32)


def save(name, x, width=0.25):
    if x.ndim == 1:
        x = stereo(x, width)
    x = master(x)
    wavfile.write(OUT / f"{name}.wav", SR, x)
    return x


S = {}

# ---- glass / UI ------------------------------------------------------------
# G1 game menu select: two bright blips stepping up a fifth (classic "option select")
def blip(f, d=0.07):
    tt = t(d)
    tone = 0.7 * np.sin(2 * np.pi * f * tt) + 0.3 * np.sign(np.sin(2 * np.pi * f * tt)) * 0.35
    return lp(tone, 7000) * env(len(tt), 0.002, 0.05)
g1 = np.concatenate([blip(1046), np.zeros(int(SR * 0.035)), blip(1568, 0.11)])
S["glass-1-game-select"] = save("glass-1-game-select", room(g1, 0.3, 0.22))

# G2 hologram: rising FM chirp with shimmer partials and an airy band
d = 0.42
s1, f = sweep(520, 2300, 0.22)
mod = np.sin(2 * np.pi * 31 * t(0.22)) * 0.4
holo = np.sin(2 * np.pi * np.cumsum(f * (1 + 0.02 * mod)) / SR) + 0.35 * np.sin(2 * np.pi * np.cumsum(f * 2.01) / SR)
holo = holo * env(len(holo), 0.01, 0.16, 3)
shimmer = bp(rng.standard_normal(int(SR * d)), 5000, 11000) * env(int(SR * d), 0.02, 0.25, 3) * 0.25
holo = np.concatenate([holo, np.zeros(int(SR * d) - len(holo))]) + shimmer
S["glass-2-hologram"] = save("glass-2-hologram", room(holo, 0.45, 0.3), 0.6)

# G3 Zac blob squish: wet low "bloop" (pitch dive) + gooey up-bloop + filtered squelch noise
a, _ = sweep(460, 120, 0.13)
b, _ = sweep(150, 330, 0.12)
blob = np.concatenate([a * env(len(a), 0.003, 0.12, 2), b * env(len(b), 0.004, 0.1, 3) * 0.8])
sq = lp(bp(rng.standard_normal(len(blob)), 200, 1800), 1500) * env(len(blob), 0.002, 0.08, 5) * 0.5
blob = np.tanh((blob + sq) * 2.2)
S["glass-3-zac-squish"] = save("glass-3-zac-squish", room(lp(blob, 5000), 0.25, 0.12), 0.15)

# G4 crystal tap: glassy high partial cluster, fast decay, ringing tail
tt = t(0.6)
cr = sum(amp * np.sin(2 * np.pi * fr * tt) * np.exp(-tt * dk) for fr, amp, dk in
         [(2637, 1.0, 9), (3951, 0.55, 12), (5274, 0.35, 15), (7040, 0.18, 20)])
cr *= np.clip(tt / 0.002, 0, 1)
S["glass-4-crystal-tap"] = save("glass-4-crystal-tap", room(cr, 0.35, 0.2), 0.4)

# G5 soft confirm (clean, premium, Apple-like): soft sine dyad
tt = t(0.45)
cf = (np.sin(2 * np.pi * 880 * tt) + 0.6 * np.sin(2 * np.pi * 1318.5 * tt) + 0.15 * np.sin(2 * np.pi * 1760 * tt)) * env(len(tt), 0.012, 0.22, 3)
S["glass-5-soft-confirm"] = save("glass-5-soft-confirm", room(cf, 0.3, 0.15), 0.3)

# G6 split + snap (for liquid glass split/merge): stretchy rising squish ending in a soft pop
s6, _ = sweep(180, 620, 0.22)
stretch = s6 * env(len(s6), 0.02, 0.2, 1.5) * 0.7 + lp(rng.standard_normal(len(s6)), 900) * 0.15 * env(len(s6), 0.02, 0.2, 2)
pop, _ = sweep(900, 520, 0.05)
pop = pop * env(len(pop), 0.001, 0.04, 4)
g6 = np.concatenate([stretch, pop])
S["glass-6-split-snap"] = save("glass-6-split-snap", room(np.tanh(g6 * 1.6), 0.3, 0.15), 0.3)

# ---- light wind ------------------------------------------------------------
def wind(d, lo0, hi0, lo1, hi1, peak=0.45, name="", width=0.7):
    n = int(SR * d)
    noise = rng.standard_normal(n)
    # sweep the band in 8 blocks, crossfaded
    out = np.zeros(n)
    blocks = 16
    for i in range(blocks):
        p = i / (blocks - 1)
        lo = lo0 + (lo1 - lo0) * p
        hi = hi0 + (hi1 - hi0) * p
        seg = bp(noise, lo, hi)
        w = np.exp(-0.5 * ((np.arange(n) / n - p) / (0.5 / blocks)) ** 2)
        out += seg * w
    x = np.arange(n) / n
    shape = np.where(x < peak, (x / peak) ** 1.6, ((1 - x) / (1 - peak)) ** 2.2)
    return save(name, hp(out * shape, 120), width)

S["wind-1-airy-swish"] = wind(0.75, 500, 1800, 1500, 5200, 0.45, "wind-1-airy-swish")
S["wind-2-soft-gust"] = wind(1.1, 250, 900, 500, 1600, 0.5, "wind-2-soft-gust", 0.8)
S["wind-3-breath-pass"] = wind(0.6, 900, 3500, 600, 2200, 0.35, "wind-3-breath-pass", 0.5)

# ---- audition: all options in a row, 1 s silence between
gap = np.zeros((SR, 2), dtype=np.float32)
order = list(S)
aud = np.concatenate([np.concatenate([S[k], gap]) for k in order])
wavfile.write(OUT / "audition.wav", SR, aud)
pos = 0.0
lines = []
for k in order:
    lines.append(f"{pos:5.2f}s  {k}")
    pos += len(S[k]) / SR + 1.0
(OUT / "audition.txt").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
print("->", OUT)
