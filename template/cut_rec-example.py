#!/usr/bin/env python3
"""Cut the platform screen recording to the voice-over, frame-exact, with 0.2 s crossfades between steps.
Source: assets/rec/rec-page.mp4 (gen.mp4 -> CFR 30 fps, page area only, 1920x938). Account avatar + credits blurred.
Output assets/rec/rec-edit.mp4 starting at comp 31.0; step boundaries (comp) printed for the camera keys."""
import subprocess
SRC, FPS, X, T0 = "assets/rec/rec-page.mp4", 30, 0.1, 31.0   # X = half crossfade
SEG = [  # rec start, rec end, speed
    (0.2, 2.57, 1), (2.6, 5.86, 1),               # detail page, Use Prompt -> generator
    (5.86, 7.4, 1), (12.0, 12.87, 1),             # prompt before / after the chechia edit
    (17.4, 18.68, 1), (36.3, 37.58, 1),           # Add reference -> dialog, upload -> chechia appears
    (58.2, 60.0, 1), (67.6, 68.91, 1),            # model list, format 4:5
    (86.6, 87.98, 1),                             # Generate
    (88.0, 132.2, 49.1), (132.2, 133.13, 1),      # wait (time-lapse) -> result appears
    (138.6, 140.65, 1), (159.6, 160.3, 1),        # full view, Image to Video panel
]
lens = [round((b - a) / sp * FPS) / FPS for a, b, sp in SEG]      # frame-exact planned lengths
bounds = [T0]
for L in lens: bounds.append(round(bounds[-1] + L, 4))
parts, n = [], len(SEG)
for i, (a, b, sp) in enumerate(SEG):
    pre = X * sp if i > 0 else 0; post = X * sp if i < n - 1 else 0
    frames = round((lens[i] + (X if i > 0 else 0) + (X if i < n - 1 else 0)) * FPS)
    parts.append(f"[0:v]trim=start={a - pre:.4f}:end={b + post + 0.2:.4f},setpts=(PTS-STARTPTS)/{sp},fps={FPS},trim=end_frame={frames},setpts=PTS-STARTPTS[s{i}]")
chain, prev = [], "s0"
for k in range(1, n):
    off = bounds[k] - X - T0
    chain.append(f"[{prev}][s{k}]xfade=transition=fade:duration={2 * X}:offset={off:.4f}[x{k}]"); prev = f"x{k}"
fc = ";".join(parts + chain) + f";[{prev}]split[base][b2];[b2]crop=240:56:1672:2,boxblur=lr=12:lp=3:cr=10:cp=3[blur];[base][blur]overlay=1672:2[out]"
subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", SRC, "-filter_complex", fc, "-map", "[out]", "-an", "-r", str(FPS),
                "-c:v", "libx264", "-crf", "17", "-preset", "medium", "-pix_fmt", "yuv420p", "assets/rec/rec-edit.mp4"], check=True)
print("bounds", bounds)
