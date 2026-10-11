#!/usr/bin/env python3
"""Look "warm-falloff" (M): natural moody grade for talking-head footage.
Global warm, slightly muted grade + soft S-curve + light falloff from the face (applied to the whole image, no cut-out)
+ a small, very soft person/room gap (room ~ -0.5 EV). Approved 2026-10-09. Never push the room darker: beyond ~ -0.5 EV
a halo appears around the head because the wall is usually brighter than the face in the footage.

usage (run from Content-Creator/):
  python3 .claude/skills/reel-editor/scripts/look_warm.py <source.mov> <out_dir> [--start s] [--duration s]
writes <out_dir>/graded.mov (H.264, 1080x1920, 30 fps) + <out_dir>/matte.mov (person matte, same timing).
Then build subject.webm with the alphamerge command in SKILL.md, exactly as for the pop look.
"""
import argparse, json, os, shutil, subprocess, sys
from multiprocessing import Pool
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter

HERE = Path(__file__).resolve().parent
P = dict(far=0.42, gap=0.72, warm=0.09, sat=0.90, feather=22, curve=0.10, fade=0.018)
H, W = 1920, 1080
lin = lambda x: np.where(x <= 0.04045, x / 12.92, ((x + 0.055) / 1.055) ** 2.4)
srgb = lambda x: np.where(x <= 0.0031308, x * 12.92, 1.055 * np.clip(x, 0, None) ** (1 / 2.4) - 0.055)
_yy, _xx = np.mgrid[0:H, 0:W].astype(np.float32)
_CTX = {}

def grade_frame(args):
    work, name, cx, cy, fw, fh = args
    L = lin(np.asarray(Image.open(f"{work}/f/{name}").convert("RGB"), np.float32) / 255)
    d = np.sqrt(((_xx - cx) / (fw * 1.35)) ** 2 + ((_yy - (cy + fh * 0.1)) / (fh * (1.6 + 0.9 * (_yy > cy)))) ** 2)
    fall = P["far"] + (1 - P["far"]) * np.exp(-np.clip(d - 0.45, 0, None) ** 2 * 1.3)
    m = np.asarray(Image.open(f"{work}/m/{name}").convert("L").filter(ImageFilter.GaussianBlur(P["feather"])), np.float32) / 255
    G = (fall * (P["gap"] + (1 - P["gap"]) * m))[..., None]
    o = L * G * np.array([1 + P["warm"], 1.0, 1 - P["warm"] * 1.6])
    lu = (o * [0.2126, 0.7152, 0.0722]).sum(-1, keepdims=True); o = lu + (o - lu) * P["sat"]
    s = np.clip(srgb(o), 0, 1)
    s = s + P["curve"] * (s - 0.5) * (1 - np.abs(2 * s - 1))
    s = P["fade"] + s * (1 - P["fade"])
    Image.fromarray((np.clip(s, 0, 1) * 255).astype(np.uint8)).save(f"{work}/out/{name}")

def run(cmd, **kw):
    subprocess.run(cmd, check=True, **kw)

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source"); ap.add_argument("out_dir")
    ap.add_argument("--start", type=float, default=0.0); ap.add_argument("--duration", type=float)
    a = ap.parse_args()
    out = Path(a.out_dir).resolve(); work = out / "_warm_work"
    shutil.rmtree(work, ignore_errors=True); (work / "f").mkdir(parents=True); (work / "m").mkdir(); (work / "out").mkdir()
    # 1. decode through AVFoundation (correct colour) + person matte, no grade
    cmd = ["swift", str(HERE / "grade.swift"), a.source, str(work), "--look", "none", "--start", str(a.start)]
    if a.duration: cmd += ["--duration", str(a.duration)]
    run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    run(["ffmpeg", "-v", "error", "-y", "-i", str(work / "graded.mov"), str(work / "f/%04d.png")])
    run(["ffmpeg", "-v", "error", "-y", "-i", str(work / "matte.mov"), "-vf", "format=gray", str(work / "m/%04d.png")])
    # 2. face track (+ orientation check: some iPhone files come out of grade.swift upside down)
    run(["swift", str(HERE / "faces.swift"), str(work / "f")], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    faces = json.load(open(work / "faces.json"))
    ok = [f for f in faces if f.get("nose") and f.get("eyes")]
    if not ok: sys.exit("no face found: this look needs a talking head")
    upside = np.median([np.mean([p[1] for p in f["eyes"]]) > np.mean([p[1] for p in f["nose"]]) for f in ok]) > 0.5
    if upside:
        print("frames are upside down -> flipping")
        for sub in ("f", "m"):
            for p in sorted((work / sub).glob("*.png")):
                Image.open(p).transpose(Image.Transpose.ROTATE_180).save(p)
        run(["swift", str(HERE / "faces.swift"), str(work / "f")], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        faces = json.load(open(work / "faces.json"))
    # 3. smoothed face position (no light jitter), frames without a face reuse the previous one
    rows, last = [], None
    for f in faces:
        if f.get("box") and f.get("nose"): last = [*np.array(f["nose"]).mean(0), f["box"][2], f["box"][3]]
        rows.append(last)
    first = next(r for r in rows if r is not None); arr = np.array([r if r is not None else first for r in rows])
    k = 9; pad = np.pad(arr, ((k // 2, k // 2), (0, 0)), mode="edge"); sm = np.stack([pad[i:i + len(arr)] for i in range(k)]).mean(0)
    # 4. grade every frame
    jobs = [(str(work), f["f"], *sm[i]) for i, f in enumerate(faces)]
    with Pool(os.cpu_count() or 8) as pool:
        for i, _ in enumerate(pool.imap_unordered(grade_frame, jobs, chunksize=4)):
            if i % 300 == 0: print(f"  frame {i}/{len(jobs)}", flush=True)
    # 5. encode graded.mov + matte.mov (upright)
    out.mkdir(parents=True, exist_ok=True)
    run(["ffmpeg", "-v", "error", "-y", "-framerate", "30", "-i", str(work / "out/%04d.png"), "-c:v", "libx264", "-crf", "14",
         "-preset", "medium", "-pix_fmt", "yuv420p", str(out / "graded.mov")])
    run(["ffmpeg", "-v", "error", "-y", "-framerate", "30", "-i", str(work / "m/%04d.png"), "-c:v", "libx264", "-crf", "16",
         "-pix_fmt", "yuv420p", str(out / "matte.mov")])
    shutil.rmtree(work)
    print(f"look warm-falloff -> {out / 'graded.mov'} ({len(jobs)} frames){' [flipped]' if upside else ''}")

if __name__ == "__main__":
    main()
