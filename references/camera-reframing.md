# Selective talking-head camera reframing

Use framing as visual punctuation: focus attention, build anticipation, or separate two thoughts. Default to a steady shot. This is an optional treatment inside TALK, not a new scene transition or a required effect on every beat.

Reference: [Jason Pham's reel about MrBeast-style editing](https://www.instagram.com/reel/DXL9nodDevc/) (viewed 2026-10-10). The transferable idea is gradual scale movement contrasted with a sudden framing change. The settings below are starting suggestions for our style, not measured values from the reel or a claim about retention.

## Choose the move from the spoken beat

| Move | Use | Starting treatment |
|---|---|---|
| Hold | Setup, calm explanation, expressive gestures, readable UI, or a moment that already has enough movement | Stable framing; let the delivery carry it |
| Push | An important point develops or anticipation builds | 1.00 → 1.04–1.08 over roughly 2–4 s |
| Pull | Reveal surrounding context or let a point settle | Start slightly tighter (e.g. 1.06), gradually return to 1.00 |
| Punch | A surprising claim, reaction or punchline needs a distinct accent | Instant modest crop change (e.g. 1.00 → 1.10), then hold |
| Reset | The next sentence starts after a gradual move | Cut instantly back to the base crop at that boundary, then hold |

Scale is relative to the existing full-frame crop. Keep it at or above 1.00 to avoid revealing empty edges; check source sharpness before enlarging. Choose the origin near the subject's eyes and keep it stable throughout the move and reset.

## Restraint and planning

- Record purpose, exact start/end or cut time, and scale in the edit-plan camera column. A row can say `hold — UI reveal carries attention`.
- Useful pattern: steady setup → gentle push during the main point → snap wider for the next idea → steady hold. Do not loop it through the whole reel or alternate in/out on every sentence.
- Treat ~3 s as a moment to review attention, not a timer that triggers a zoom. Change framing when the meaning or delivery warrants it; let an engaging shot breathe.
- Prefer one dominant attention cue. If an acrylic card arrives, a library effect unfolds, or B-roll changes, leave the camera steady unless it serves a separate clear purpose. Captions alone do not require a camera change.
- Reserve stronger punches for stronger moments. Avoid pumping back and forth within one thought and stacking a zoom, text pop and whoosh on the same ordinary word.
- Keep zooms silent by default. A deliberate accent can use an already-approved kit role when it fits; a missing sound still follows the existing SFX approval workflow.
- Keep the hook's typography, SPLIT pop-out, library choreography and screen-recording camera treatment as designed. Full-frame talking-head reframing belongs mainly in TALK; TALK+UI needs extra room for its overlays.

## Build in the existing face rig

- The templates already animate `#rig` for FULL ↔ SPLIT and `#rigMove` for the conveyor. Give camera reframing its own inner footage transforms; do not add a second scale writer to either existing rig.
- For example, add an absolute `inset:0` wrapper around the room video inside `#roomClip`, and an identical wrapper around the subject video inside `#subjWrap`. Use the same scale, position and transform origin on both wrappers. Keep the original clipping, layer order and video timing intact. This preserves behind-the-head graphics without moving them with the footage.
- Keep hook type, captions, UI, card borders/shadows and the glass canvas outside these camera transforms. They retain their safe-zone positions. Check enlarged gestures/head against overlays.
- Initialize the wrappers' neutral scale/position in CSS. Schedule absolute values on the main paused GSAP timeline; use `fromTo` with `immediateRender:false` for repeated moves and `tl.set` for instant framing cuts. Use a gentle `sine.inOut` for push/pull; no bounce, blur or whip. Do not use playback callbacks or competing CSS transforms.
- Snap cuts land on a rendered frame (30 fps). Preserve the recording and audio timing; this is a crop change, not a footage cut or a source-speed effect.
- End camera motion before FULL → SPLIT starts and return the wrappers to neutral at the planned sentence boundary. If the scene exits by conveyor, hold the final crop during travel and reset only once fully off-screen, before its next entrance. Do not hide a visible reset inside a moving transition. New FULL layers such as `#faceB` must match the incoming neutral crop and the swap frame.
- Liquid glass over the face samples pre-extracted footage. Keep the camera neutral throughout those windows unless the sampled frames reproduce the exact camera transform; otherwise the refraction slips against the visible image.

## Verify the result

Watch at normal speed to judge rhythm and restraint. Inspect before/at/after each instant framing cut, the widest/tightest crop, and handoffs to SPLIT or the conveyor. Check stable eye position, identical room/matte alignment, no empty edges, safe-zone legibility, and no jump when seeking backward and forward. If removing a zoom leaves the point equally clear and the pacing intact, prefer the steady shot.
