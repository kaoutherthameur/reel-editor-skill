# ref-03: "Kinetic word chain → arrow wipe → portfolio wheel → search lens"

Source: `ref-03.mov`, a phone screen recording of a Pinterest video (1016×1730, 60 fps, 12.4 s). The real video area is **x 76–940, y 45–1582 (864×1536, 9:16)**. The Pinterest player UI (back button, expand button, progress bar) is not part of the design. The **source animation is 30 fps**: the recording shows every frame twice.
The **first 3.73 s is a paused player** with a play button. The design starts at **rec 3.73 s = video 0.00 s**. Times below are given as recording time (`rec`) and **video time (`v`)**, where `v = rec − 3.73`. Only the first ~8.7 s of the 20 s design was captured.

## What it is
A flat 2D, agency-style brand reel on a single solid violet field. Short kinetic word chains in one geometric sans with coral doodle accents ("Design is ✸ your passion ?" → "Let's create something ↗"). The small arrow then becomes a **giant arrow that flies across the frame and leaves "AMAZING" behind it**. The letters drop out, and a **fan of portfolio cards on a huge wheel** spins in under a white outline "search pill" typing "Amazing". The wheel falls away and a **neon-outline magnifying glass** drops in, its lens filling with coral to show "Developers".
**Short name:** *"Arrow-wipe word reveal + portfolio card wheel"* (the card wheel is the reusable hero beat).

No 3D, no glass, no blur, no grain. It is all flat vector + 2D transforms. It feels premium because of timing, restraint and the hand-drawn accents.

## Elements & materials
Frame = 864×1536 measured. Multiply by 1.25 for 1080×1920.

| Element | Size (rel. to frame) | Colour | Material / style |
|---|---|---|---|
| Background | full | **#5F5ACC** (95,90,204), perfectly flat, no gradient/vignette/grain | solid fill |
| Body words ("Design is", "your passion", "Let's create something") | cap+descender ≈ 42 px ≈ **2.7 % of height** (~52 px @1080w). The full line spans ~85 % of width | #FFFFFF | geometric sans (Gilroy-like; free stand-ins: *Outfit*, *Urbanist*, *Plus Jakarta Sans*). **Medium/SemiBold, sentence case**, normal tracking. Not bold |
| Starburst ✸ | Ø ≈ 56 px (6.5 % W) | coral **#FF9191** (anti-aliased edges read ~#E98C9D) | 14–16-point spiky star, flat fill |
| Hand-drawn ellipse around "Design is" | ~210×60 px | coral | ~2 px open stroke, loose loop that overshoots its start (marker doodle) |
| Hand-drawn underline under "your passion" | ~320 px wide | coral | ~2 px scribble with one zig-zag kink |
| "?" badge | Ø ≈ 30 px | coral disc, white glyph | flat circle. The glyph spins/morphs in |
| Small arrow ↗ | ~45 px box | coral | thick stroke, square caps |
| Giant arrow ↗ | ~400×400 px box (≈46 % W), shaft ≈ 50 px thick | coral #FF9191 | flat, square ends, 45° |
| "AMAZING" | cap height ≈ 115 px (**7.5 % H**), spans ~80 % W, top of frame (y ≈ 170–285) | white | same family, **Bold, ALL CAPS**, tight-normal tracking |
| Portfolio cards (×~12 visible across the shot) | **≈ 200×344 px = 23 % W**, aspect ≈ 0.58 (≈ 9:16-ish portrait), corner radius ≈ 16 px (8 % of card width) | white cards, B/W photos, violet #5F5ACC + coral/pink accents | flat print-style social-post designs. Each card overlaps its left neighbour by ~15–20 % (**z-order rises left→right**). Very soft, small drop shadow at the lower edges (estimate: 0 4px 12px rgba(0,0,0,.2)) |
| Card wheel | wheel centre ≈ **(415, 1385)**, i.e. horizontally centred and **90 % down the frame**. Inner radius ≈ 477 px (55 % W), outer ≈ 830 px. Angular pitch ≈ 17–18° per card | n/a | each card is placed radially (its vertical axis points at the wheel centre) |
| Search pill | ≈ 368×88 px (43 % W), centred on the frame (432, 771) | white stroke ~3 px, **no fill** | capsule outline overlaid on the cards |
| Pill text "Amazing" | ~64 px | white | **Regular/Light**, sentence case. It overflows the right end of the pill (intentionally loose) |
| Magnifier | lens Ø ≈ 238 px (28 % W), centre ≈ (167, 559). Capsule handle down-right at 45°, total ≈ 370×370 px | white stroke ~4 px + **soft white outer glow** (≈ 8–10 px blur, ~35 % opacity) | outline only. The lens is a mask |
| Lens fill | = lens disc | coral #FF9191 | a coral disc that slides inside the circular mask (rises from the bottom, exits sideways) |
| Lens words "Strat(egy)" → "Developers" | ~22–30 px | white | SemiBold, clipped by the lens |

## Timeline
Eases are estimates from frame tracking (centroid/bbox at 60 fps over 30 fps source).

| rec s | v s | What moves | From → To | Ease / dur | Stagger / notes |
|---|---|---|---|---|---|
| 3.73–4.10 | 0.00–0.37 | Starburst pops at centre (434, 769) | scale ≈ 1.4 → 1.0 (area 3360 → 1750 px²), opacity 1 | power2.out, ~0.3 s | probably a slow continuous spin (estimate) |
| 4.20–4.60 | 0.47–0.87 | "Design", then "is", enter left of the star; star slides right | words: opacity 0→1, y +12→0. Star x 434→520 | power2.out ~0.3 s | "is" ≈ 0.12 s after "Design". The line re-centres as it grows |
| 4.65–4.95 | 0.92–1.22 | Coral ellipse draws around "Design is" | stroke draw 0→100 % | power1.inOut ~0.3 s | undraws ~5.3 |
| 4.70–5.25 | 0.97–1.52 | "your" then "passion" fade/slide in on the right; whole line slides left to re-centre | star x 520→362 (−160 px); words opacity 0→(0.4)→1 | power2.inOut ~0.5 s | "passion" ≈ 0.25 s after "your" |
| 5.25–5.45 | 1.52–1.72 | Underline scribble draws L→R; "?" badge pops at right end | stroke 0→100 %; badge scale 0→1 | power2.out ~0.2 s | badge glyph rotates/morphs into "?" by ~5.75 |
| 5.45–5.80 | 1.72–2.07 | Hold | n/a | n/a | full line spans x 71–801 |
| 5.80–6.30 | 2.07–2.57 | Exit L→R | each element opacity 1→0 (slight x drift) | power1.in ~0.15 s each | stagger ≈ 0.07 s: Design → is → ✸ → your → passion → ? |
| 6.38–6.85 | 2.65–3.12 | "Let's create" rises in; "something" lands from slightly above; small arrow grows at right | text y +45→0 px, opacity 0→1. "something" sits ~20 px high then settles to baseline. Arrow scale 0→1 from its tail | power3.out ~0.4 s | "something" ≈ 0.1 s after "Let's create" |
| 6.85–7.20 | 3.12–3.47 | Hold | n/a | n/a | n/a |
| 7.20–7.53 | 3.47–3.80 | **Anticipation**: arrow swells, text sinks | arrow scale 1→≈2.1 (45→93 px). Text y +0→+75 px, slight x drift left | power2.in ~0.33 s | builds into the cut |
| **7.55** | 3.82 | **Hard cut** to an extreme close-up of the arrow shaft at the left edge | n/a | n/a | reads as a "zoom into the arrow" |
| 7.55–7.83 | 3.82–4.10 | Giant arrow travels up-right into view | head from off-frame bottom-left to centroid ≈ (250, 420) | power2.out ~0.28 s | n/a |
| 7.83–8.20 | 4.10–4.47 | Arrow **rides right and exits**. "AMAZING" letters appear in its wake | arrow x +≈ 2900 px/s (linear/power1.in), cropped at the right edge. Each letter opacity 0→0.4→1 in ~0.07 s just behind the arrow head | linear | effectively a per-letter stagger of ≈ 0.045 s, synced to the arrow x |
| 8.17–8.45 | 4.44–4.72 | Word settles | "AMAZING" x −≈ 90 px | power2.out ~0.3 s | n/a |
| 8.40–8.72 | 4.67–4.99 | **Letters drop out one by one** from the left | each letter y 0 → +300…+600 px (off its row) | power2.in ~0.3 s each | stagger ≈ 0.05 s A→M→A→Z… |
| **8.73** | 5.00 | **Hard cut** to the card wheel, already spinning | n/a | n/a | only ~5 cards are on screen at the upper-right of the arc; more feed in from the right |
| 8.73–9.85 | 5.00–6.12 | **Wheel spin #1** (counter-clockwise: cards travel right→left over the top) | rotation ≈ +41° → 0 | angular speed 40 → **99°/s peak at 8.98** → 25°/s at 9.3 → 5°/s at 9.8. Feels like power3.inOut whose first ~15 % is before the cut, or expo.out with a short ramp | ≈ 2.3 cards of travel |
| 8.78–8.95 | 5.05–5.22 | Search pill draws on over the wheel | a horizontal white line opens into a capsule (width/height from 0) | power3.out ~0.2 s | n/a |
| 8.90–9.60 | 5.17–5.87 | "Amazing" types in the pill | characters 0→7 | steps, ~0.1 s/char | the text overflows the pill's right end |
| 9.85–10.85 | 6.12–7.12 | **Wheel spin #2** | rotation 0 → −14° | sine/power2.inOut ~1.0 s (peak ~25°/s) | ≈ 0.8 card |
| 10.90–11.45 | 7.17–7.72 | **Wheel + pill fall out the bottom** | wheel y 0 → +900 px (top edge y 572→588→628→704→854 at 0.1 s steps) | power2.in ~0.5 s | rotation keeps drifting slightly |
| 11.22–11.80 | 7.49–8.07 | Magnifier drops in from top-left (overlaps the wheel exit) | centroid y ≈ 120 → 596, x ≈ 190 → 205 | power3.out ~0.55 s | lens shows "Strat…" (white text, masked) |
| 11.45–11.75 | 7.72–8.02 | Coral fill rises inside the lens; "Developers" replaces "Strategy" | disc y +lensØ → 0 inside the circle mask | power2.out ~0.3 s | the old word is pushed out as the disc rises |
| 11.80–12.05 | 8.07–8.32 | Hold | n/a | n/a | n/a |
| 12.05–12.40 | 8.32–8.67 | Magnifier slides right and tilts (handle turns more vertical); coral disc slides out to the left inside the mask | magnifier x +≈ 200 px, rotate ≈ +15–20°. Disc x 0 → −lensØ | power2.in ~0.35 s | the recording ends at 12.4 |

## Camera / 3D
- **There is no 3D camera and no perspective, DOF, blur or parallax.** Everything happens in screen plane: translate, scale, rotateZ, opacity, and stroke draw-on.
- The wheel is a 2D `rotateZ` of a container whose pivot sits far below the visible area (90 % down the frame). This gives the arc a "ferris-wheel" sweep without any perspective.
- The "camera move" at 7.55 s is faked with a **hard cut to an oversized arrow**, not a real zoom. The 0.33 s swell before it does the work of a push-in.
- Transitions are hard cuts (7.55, 8.73) or element-driven (the wheel falls while the magnifier drops in). There are no crossfades.

## Why it looks premium
1. **One palette, three colours**: flat violet #5F5ACC, coral #FF9191 and white. Busy card content is fenced into the wheel; everything else is empty space.
2. **Small body text** (~2.7 % of height) with lots of air, against one huge moment ("AMAZING" at 7.5 % height plus a 46 %-wide arrow). The scale contrast is the drama.
3. **Hand-drawn coral doodles** (loose ellipse, kinked underline, spinning "?") add a human touch to strict geometric type.
4. **Motion-linked reveals.** The arrow *causes* the letters to appear. The line *re-centres* as words join. The pill *opens from a line*. Nothing just fades on without a reason.
5. **Anticipation before every big beat**: the arrow swells before the cut, and the wheel is already moving when it is cut to.
6. **Asymmetric eases**: fast-in/long-settle spins and gravity drops (`power2.in`) for exits.
7. **Weight discipline**: Medium for sentences, Bold only for the one shout word, Regular/Light inside the search pill.

**What would make it look cheap:**
- Crossfading between beats.
- Linear rotation of the wheel.
- Centring the wheel pivot on screen (you'd see the whole circle).
- Cards without overlap or without a radial orientation.
- Bold body text.
- Adding gradients, glows or drop shadows to the text.
- Letters that fade on all at once instead of being swept on by the arrow.
- Doodles drawn as perfect geometric ellipses.

## How to rebuild in HyperFrames
**Plain DOM + CSS 2D transforms + inline SVG strokes, one paused GSAP timeline.** No Three.js or shaders are needed.

- Stage: 1080×1920, `background:#5F5ACC`. Font: Outfit/Urbanist (500 for body, 700 for AMAZING, 300–400 for the pill).
- **Word chain**: put each word in its own `<span>` inside a flex row. Re-centring: compute final x offsets per state ahead of time (measure once at build, not at seek time) and tween the row's `x` between states. Do not rely on layout reflow during seek.
- **Doodles**: SVG `<path>` with `stroke-dasharray = length`, tween `strokeDashoffset` length→0 (draw) and 0→−length (undraw). Starburst: an SVG polygon. "?" badge: `scale` from 0 with `back.out(2)`, glyph `rotation` from −180.
- **Arrow wipe**: an SVG arrow in a container. Tween the container's x across the frame. Each letter of "AMAZING" (spans) gets `opacity 0→1` at a timeline position equal to when the arrow head passes its x: `t_i = t0 + (letterX_i − arrowStartX)/speed`. Compute these from static numbers, not the DOM at seek time. Letter drop: `tl.to(letters,{y:600,duration:.3,ease:"power2.in",stagger:.05})`.
- **Card wheel**: a `#wheel` div with `transform-origin` at the wheel centre (≈ x 50 %, y 90 % of the frame; set the wheel element to 1080×1920 and use `transform-origin: 519px 1731px` at 1080 scale). Card *i* is absolutely positioned with its top at radius R_out ≈ 1040 px and rotated by `θ_i = θ0 + i*17.5°`:
  `transform: rotate(θ_i) translateY(-R) ` applied on a child whose origin is the wheel centre. Card size 250×430 px, `border-radius:20px`, `box-shadow:0 5px 15px rgba(0,0,0,.18)`. Set `z-index` so it increases left→right.
  Tweens:
  `tl.fromTo('#wheel',{rotation:44},{rotation:0,duration:1.2,ease:"power3.inOut"},5.0-0.18)`. Start it just before the cut so the first frame is already moving.
  `tl.to('#wheel',{rotation:-14,duration:1.0,ease:"sine.inOut"},6.12)`
  `tl.to('#wheel',{y:1150,duration:.55,ease:"power2.in"},7.17)`
- **Search pill**: SVG `<rect rx=h/2>` with no fill and a 3–4 px white stroke. Tween `scaleY 0.04→1` and `scaleX 0.6→1` (power3.out, 0.2 s). Typing: a GSAP `TextPlugin` or a stepped tween of an integer `chars` index whose `onUpdate` writes `textContent`. It must be deterministic: derive the text from `Math.floor(progress*7)`.
- **Magnifier**: SVG circle + rounded-rect handle, stroke white 5 px, `filter: drop-shadow(0 0 10px rgba(255,255,255,.45))`. Lens content: a `<div>` with `clip-path:circle()` (or SVG clipPath) containing the coral disc and the word stack. Tween the disc's `yPercent 100→0` (power2.out 0.3 s), the word stack's `yPercent` to swap "Strategy"→"Developers", and the exit with disc `xPercent 0→−100` + magnifier `x:+250, rotation:18, ease:"power2.in"`.
- **Seek-safety**: one `gsap.timeline({paused:true})` registered for HyperFrames. No `Math.random` (hard-code doodle paths and card order; if jitter is needed use a seeded PRNG). No CSS animations or `setTimeout`. Hard cuts are `tl.set(sceneA,{autoAlpha:0},t)` / `tl.set(sceneB,{autoAlpha:1},t)`. All text measurement happens once before the timeline is built.
- Render at 30 fps to match the source. 60 fps also works if you want it smoother.

## Reuse recipe
- **Card wheel behind the talking head**: put a matted cut-out of the creator in front and the wheel behind, with the pivot below his chest so the arc frames his head like a halo. Card content = real screenshots: AI tool UIs, tweets, headlines, his own past reels. The pill types the topic in Derja or Latin ("ChatGPT", "Agents", "Automation"). It works as a "here's everything I tested" or "10 tools in 60 s" opener.
- **Arrow-wipe word reveal**: a punch transition into a key claim. Swap "AMAZING" for one word ("GRATUIT", "FASTER", "2026"). The arrow can be any brand glyph (cursor, lightning, the creator's logo mark).
- **Search lens**: a section header for "what are we looking for?" The lens word swaps between two terms (the misconception, then the real answer).
- **Word chain with doodles**: subtitle-adjacent kinetic text for a hook sentence (≤ 6 words), with doodles marking the key word.

Parameters to vary:
- Background (keep a single flat colour; brand violet or a deep ink #121018 with lime accents).
- Accent colour.
- Card count and pitch (15–20°).
- Wheel pivot y (85–100 % of frame; lower = flatter arc).
- Spin amounts (one big ~40° spin + one small ~14° nudge).
- Typing speed (0.08–0.12 s/char).
- Arrow speed (2500–3500 px/s at 1080w).
- Drop stagger (0.04–0.07 s).

Keep the eases asymmetric and the transitions as cuts.

## Key frames
- **rec 5.60 s / v 1.87**: full word chain "Design is ✸ your passion ?" with both doodles → `ref-03_t5.6.png`
- **rec 7.95 s / v 4.22**: giant arrow mid-flight with "AMAZI…" appearing in its wake → `ref-03_t7.95.png`
- **rec 8.60 s / v 4.87**: letter cascade dropping out ("ᴀMAZING" stepped baseline)
- **rec 9.70 s / v 5.97**: card wheel settled with the "Amazing" search pill → `ref-03_t9.7.png`
- **rec 11.25 s / v 7.52**: wheel falling while the magnifier drops in (overlap)
- **rec 11.90 s / v 8.17**: glowing magnifier with the coral-filled lens "Developers" → `ref-03_t11.9.png`
