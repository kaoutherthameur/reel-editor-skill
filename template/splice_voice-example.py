#!/usr/bin/env python3
"""Splice the 60 s voice: original 0-33.19 + new VO (cleaned, 1.08x, pitch kept) + original 37.53-44.45.
Writes audio/voice_60.wav and vo_map.json (VO source segments -> composition times)."""
import json, subprocess, numpy as np
from scipy.io import wavfile
SR = 48000
def seg(path, a, b, tempo=1.0):
    af = f"atrim={a}:{b},asetpts=PTS-STARTPTS" + (f",atempo={tempo}" if tempo != 1 else "")
    x = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-af", af, "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True).stdout
    x = np.frombuffer(x, np.float32).copy(); f = int(0.015 * SR)
    x[:f] *= np.linspace(0, 1, f); x[-f:] *= np.linspace(1, 0, f)
    return x
sil = lambda d: np.zeros(int(d * SR), np.float32)
MAIN, VO, T = "audio/voice_studio.wav", "../prompt-library-vo/audio/voice_studio.wav", 1.08
CUT1, CUT2, END = 33.19, 37.53, 44.45
vo = [(1.60, 5.11, 0.18), (6.79, 9.16, 0.22), (11.70, 17.63, 0.18), (18.09, 19.08, 0.12), (20.71, 22.69, 0.35), (23.79, 28.65, 0.25)]
parts, t, vmap = [seg(MAIN, 0, CUT1)], CUT1, []
for a, b, gap in vo:
    parts.append(sil(gap)); t += gap
    x = seg(VO, a, b, T); parts.append(x)
    vmap.append({"src": [a, b], "comp": [round(t, 3), round(t + len(x) / SR, 3)]}); t += len(x) / SR
parts.append(sil(0.15)); t += 0.15
shift = t - CUT2
parts.append(seg(MAIN, CUT2, END))
y = np.concatenate(parts)
wavfile.write("audio/voice_60.wav", SR, y)
json.dump({"cut1": CUT1, "vo_end": round(t, 3), "shift": round(shift, 3), "tempo": T, "vo": vmap, "total": round(len(y) / SR, 3)}, open("vo_map.json", "w"), indent=1)
print(open("vo_map.json").read())
