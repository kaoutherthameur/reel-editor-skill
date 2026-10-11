# ref-05 — 3D cover-flow card carousel (reveal + stepping)

Source: `ref-05.mov` (phone screen recording of a Pinterest video, 1016×1730, 60 fps, 9.3 s). Times below are recording time. Values are estimates from frame sheets and edge tracking (`metrics2.txt` in the scratch work); treat eases as fits, not exact.

## What it is
A centred portrait card sits alone, then two side cards slide out from behind it and the trio becomes a cover-flow carousel that steps one card every ~2.3 s: the side card swings to the front and grows, the old centre card slides back to the side. **Effect name: "cover-flow card carousel".**

## Elements & materials
- **Background:** flat light grey (~#F3F3F3) with a soft darker grey gradient band at the bottom ~15% (floor/fade). Nothing else; no grid.
- **Centre card:** portrait, ~33% of frame width, ~3:4.3, radius ~11% of card width (very round). Soft shadow, no border. Content types seen: (a) gradient poster (grey → orange radial glow) with a small icon on top, two-line title "Trade Forex / Around The Clock" in **medium weight, Title Case, white, centred**, and a tiny 3-line body text near the bottom; (b) full-bleed photo/3D render (orange machine render, person in dim room with "Rise" logotype).
- **Side cards:** same shape, ~78% of the centre card's height, sit about half hidden behind it, slightly yawed in 3D (inner edge recedes, ~10–15°, estimate). Slightly darker (no explicit dim layer visible; mostly shading from the yaw).
- **Pager pill:** tiny grey rounded pill (~6% card width) under the centre card, visible from the reveal on.
- **Typography:** only inside cards; medium/regular weights, small, quiet. No bold headline anywhere — part of the premium feel.

## Timeline
| Time (s) | What moves | From → to | Ease / duration (estimate) |
|---|---|---|---|
| 0.0–1.85 | Centre card alone, grey (placeholder) | tiny drift only (≈ 5 px settle in first 0.4 s) | — |
| 1.90–2.50 | Side cards slide out from behind the centre card, horizontally, symmetric | left edge 297 → 96 px, right edge 719 → 918 px (≈ 200 px each side); fast start (≈ 110 px in the first 0.17 s) then long glide | **expo/power4.out, ~0.6 s**, both sides together |
| 1.95–2.40 | Centre card colour fills in (grey → orange gradient), side card images appear | crossfade | power2.out ~0.4 s |
| 2.0–2.5 | Pager pill appears under the card | fade + slight rise | ~0.3 s |
| ≈3.9–4.5 | **Step 1:** right card swings to centre and grows to full size, comes to front (z-swap mid-move); centre card shrinks and slides left behind; left card exits behind and re-enters on the right | horizontal shift ≈ one card slot (~38% frame width); scale 0.78 ↔ 1.0; yaw ±12° → 0 | **power3.inOut ~0.55 s**, then a tiny settle (~0.15 s) |
| ≈6.3–6.9 | Step 2: same motion, next card ("Rise" photo) to centre | same | same |
| ≈8.4–9.0 | Step 3: back to the first card (loop) | same | same |

Rhythm: one step every ~2.2–2.4 s; motion is ~0.55 s of each interval, the rest is a still hold. Hold stillness is what makes it calm and premium.

## Camera / 3D
Static camera, mild perspective (~1400–1800 px equivalent). Cards live on a shallow arc: centre card closest (z ≈ 0, scale 1), side cards pushed back (z ≈ −200 px) and yawed toward the centre. No depth-of-field blur, no parallax on the background.

## Why it looks premium
- Long, quiet holds between short, decisive moves; nothing jitters.
- Very round radii, soft shadows, no borders, no glow.
- Content does the talking: real renders/photos, tiny quiet type.
- The reveal (sides sliding out from behind) gives a "deck opening" moment before the loop starts.
Cheap if missed: linear or bouncy easing, side cards at the same size (no depth), sharp corners, heavy bold text on the cards, harsh drop shadows, cards stepping without a hold.

## How to rebuild in HyperFrames
- **CSS 3D, no Three.js needed.** Stage `perspective: 1600px`; each card absolutely centred (flex/inset, no CSS transform), GSAP sets `x`, `z`, `rotationY`, `scale`, `zIndex` per slot.
- Slots: `C = {x:0, z:0, ry:0, s:1, zi:3}`, `L = {x:-0.38W, z:-200, ry:12, s:0.78, zi:2}`, `R = {x:+0.38W, z:-200, ry:-12, s:0.78, zi:2}`, `H` (hidden, behind centre) = `{x:0, z:-260, ry:0, s:0.7, zi:1, opacity:0}`.
- Reveal: cards start in `H` behind the centre card, then `L`/`R` with `expo.out` 0.6 s; centre card content crossfades placeholder → real image.
- Step: tween every card to its next slot with `power3.inOut` 0.55 s; switch `zIndex` at the midpoint with `tl.set` (z-order swap); add a 0.15 s `sine.out` settle.
- Seek-safe: one paused timeline, slots as data, no randomness. Avoid `backdrop-filter` on the cards (not needed here).
- Re-skin to our palette: background paper `#F7EDE2` (or the deep green scene), card text cream/green, pager pill bordo at 40% opacity.

## Reuse recipe
- **"Here are 3 tools / 3 examples"**: each step lands on the card for the item being named; time steps to the transcript words.
- **Behind the speaker (pop-out SPLIT)**: carousel on the top stage, or full-frame behind the cut-out with cards passing behind the head.
- **Before/after or prompt → result**: centre card = prompt, side cards = generated images.
- Parameters: number of cards (3–5), slot spacing (0.32–0.42 W), side scale (0.72–0.82), yaw (8–15°), hold length (1.5–2.5 s, matched to speech).
- Assets needed: 3–5 real screenshots/images/renders in portrait crops.

## Key frames
0.5 (single grey card), 2.1 (sides mid-slide), 2.6 (trio settled), 4.2 (step mid-move, z-swap), 6.8 (photo card centred), 8.7 (loop back). Stills saved: `ref-05_t0.5.png`, `ref-05_t2.6.png`, `ref-05_t4.2.png`, `ref-05_t6.8.png`.
