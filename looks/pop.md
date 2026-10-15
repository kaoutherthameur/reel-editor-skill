# Look: pop (default)

Approved 2026-10-07. Light, clean, airy: the room stays bright, the face is lifted a little.
Use when the creator asks for nothing else, and for footage filmed in the usual bright room.

## Run
```bash
swift .claude/skills/reel-editor/scripts/grade.swift videos/<slug>/source.mov videos/<slug> --frames <t1>,<t2> --look pop   # stills first
swift .claude/skills/reel-editor/scripts/grade.swift videos/<slug>/source.mov videos/<slug> --look pop
```
Writes `graded.mov` (H.264 Rec.709) + `matte.mov`.

## What it does
One global grade (same white balance and curve everywhere) + a small, wide-feathered person/room exposure gap:
subject +0.12 EV, room −0.5 EV, room saturation 0.90, room blur 5 px, S-curve lo .225 / hi .775, vibrance .08, vignette .32.

## Rules
- Judge colour only on the AVFoundation stills (`--frames`), never on ffmpeg grabs of iPhone HEVC/HLG.
- Never split white balance between person and room, never lift shadows or sharpen only the person (v1/v2 looked "very very artificial").
- Known bug: some iPhone files (HLG, cinematic mode, stored landscape with a rotation) come out upside down in `graded.mov`/`matte.mov` while the stills are upright. Check one frame; if upside down, flip both with `-vf hflip,vflip`.
