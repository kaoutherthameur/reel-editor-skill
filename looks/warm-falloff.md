# Look: warm-falloff ("M")

Approved 2026-10-09 as the alternative to pop. Natural moody: warmer, slightly muted, the light falls off away from the face
(room edges, corners and the lower frame get darker), room about −0.5 EV under the subject. Never looks cut out.
Use when the creator asks for a warmer / moodier / more cinematic feel, or filmed with a side key light and darker room.

## Run (from Content-Creator/)
```bash
python3 .claude/skills/reel-editor/scripts/look_warm.py videos/<slug>/source.mov videos/<slug> [--start s] [--duration s]
```
Writes `graded.mov` + `matte.mov` (upright: the script detects upside-down iPhone files from the face landmarks and flips them).
About 1.5 min per 5 s of footage (per-frame Vision face track + numpy grade, all cores). Then `subject.webm` as usual.

## What it does (parameters in the script, `P`)
- Global: warm balance (+0.09 R, −0.14 B), saturation 0.90, soft S-curve (0.10), faded blacks (0.018).
- Light falloff: elliptical around the face (1.35 × face width, 1.6–2.5 × face height, longer downward), down to 0.42 at the edges. Applied to everything, person included, so there is no edge.
- Room gap: 0.72 (≈ −0.5 EV) through the person matte blurred 22 px.
- Face position smoothed over 9 frames (no light jitter).

## Rules (learned the hard way, do not exceed)
- Room never darker than ≈ −0.5 EV under the subject: beyond that a light halo appears around the head and shoulders (the wall is usually brighter than the face in the footage). Rejected: "night" relight (room −3.6 EV, simulated side key, practical lights): "still look fake".
- No simulated key light on the face: real shadows only come from filming.
- No cool/teal colour filter on top: the creator tested it and kept plain warm-falloff.
- A darker room has to come from filming: light 50–80 cm from the face and dimmed, aimed slightly in front of the subject, subject 1.5 m+ from the wall, dark top, iPhone exposure locked at −1, HDR off.

## Stage with this look
Same day stage (paper background, cream acrylic) as pop. The "night" stage (deep green everywhere, translucent cards) belongs to the rejected night relight and is not part of this look.
