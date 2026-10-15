# ref-04 — Glass portfolio folder that opens toward the camera

Source: `ref-04.mov`, a phone screen recording of a Pinterest video (1016×1730 at 60 fps, 5.05 s). The real video area is x 42–974, y 45–1700 (932×1655, about 9:16). The back-arrow button at top-left and the white fade at the bottom (y > ~1450) are Pinterest UI; ignore them. The underlying animation is about 30 fps, because the recording shows each frame twice.

## What it is

A frosted violet glass **folder icon** labelled "Ae ПОРТФОЛИО" floats in a dark indigo void. It slowly grows toward the camera and swivels in 3D. As it opens, three UI "profile cards" (phone-screen screenshots) rise out of the pocket and fan apart: one tilts left, one stays upright, one tilts right. It holds, then plays the same move in reverse and loops.

**Short name:** "3D glass folder reveal" (folder pop-and-fan).

## Elements & materials

Percentages are of the video width (932 px) unless stated.

| Element | Size / geometry | Colour | Material / styling |
|---|---|---|---|
| **Background** | full frame | Top and bottom edges near-black navy `#01001E`. Mid-frame `#0D054B` → `#08023C`, a soft violet vignette centred slightly above the folder. | Flat gradient with no texture. Grain, if any, is hidden by compression (estimate). |
| **Floor glow** | Soft ellipse under the folder, about 60% wide | `#1A173F` right under the folder, fading to `#05022A` about 250 px lower | A faint "light spill" under the object. It gets slightly brighter when the folder is open (`#19163F` → `#25214A`). It sells the idea that the folder is lit and floating. |
| **Back panel** | Plain rounded rectangle, radius about 3% of its width. Its top edge sits about 0.35× the folder height above the front pocket's lower edge. | Deeper violet `#3B1D9A`–`#4A2AB0` | Semi-opaque glass, darker than the front. A thin lavender rim on the top edge. Mostly hidden behind the cards when open; only its top-right corner peeks out. |
| **Front pocket** | Closed: about 48% wide. Open: about 71% wide (bounding box). Top edge is **stepped**: a raised tab on the left ~35–40% of the width, a 45–55° diagonal step down, then a flat lower edge across the rest. Corners rounded (radius about 2.5% of the pocket width). | Body gradient: `#5A35C0` at top-left → `#6249AF` in the middle → `#371F89` at bottom-right. Overall about `#5B3BC4` at roughly 75–85% opacity. | **Frosted glass.** Strong backdrop blur: cards behind it are smeared to soft shapes, roughly 10–14 px blur at 1080 width (estimate). There is also a milky lavender lift where white cards sit behind (`#B59FF0`). **Rim light:** a 2–3 px bright lavender/pink stroke (`#C9A6FF` → `#E6B8FF`) on all edges, brightest on the top, left and bottom edges. It has a slight outer bloom and reads like an edge-lit acrylic sheet. There is no hard drop shadow; the floor glow replaces it. |
| **Label** | Bottom-left of the pocket, about 5% of the pocket height in from the edges | Badge: blue rounded square (Adobe "Ae" style) `#2A2F8A` with `#C8CCFF` text. Word: white `#FFFFFF` with a soft white glow. | "ПОРТФОЛИО" in a **bold condensed** display sans (Bebas Neue / Druk Condensed-like), all caps, tight tracking. Cap height is about 6% of the pocket height. The word spans about 33–36% of the pocket width. The badge is the same height as the caps. The label sits **in** the glass (it moves with the pocket). |
| **Card C (centre)** | Portrait card, about 23–25% of frame width, aspect ~0.78 (wider than a phone). Corner radius ~6% of its width. | Dark UI `#15131F` with a violet ring `#7B5CFF` behind a portrait photo | A real app screenshot (profile page: photo, name line "Артем \| Мобильная съ…", 4 grey action buttons). Sharp when above the pocket, frosted when behind it. A subtle 1 px light border. |
| **Card R (right)** | Similar size, white UI (`#F4F2F8`) | White and light grey with dark text | Instagram-style profile header (avatar, stats "84 / 1826 / 502"). Rotated clockwise. |
| **Card L (left)** | Similar size, top half dark (`#1B1A24`) with a white lower body | — | Profile with a video header ("…ОЙ ВИДЕОГРАФ"). Rotated counter-clockwise. Its white body shows through the frosted pocket as a diagonal milky band. |

Typography elsewhere: none. The only type is the label, and it is **bold**, not light.

## Timeline

Progress is measured from the folder's bounding box (width 447 → 660 px, height 351 → 512 px in recording pixels, about **×1.46**). Times are in seconds of the recording.

| # | Start–end (s) | What moves | From → to | Ease / duration | Notes |
|---|---|---|---|---|---|
| 0 | 0.00–0.08 | Nothing (closed hold) | — | — | This is the tail of the previous loop. |
| 1 | 0.08–1.55 | **Folder group**: scale, yaw, roll, and the pocket's tilt | scale 1.00 → 1.46 · yaw ≈ −5° → +18° (left side swings toward the camera) · roll 0 → about +6° clockwise · pocket pitch 0 → about 20–25° (top edge falls toward the viewer and lower on screen). Centre x stays put (+10 px). Centre y moves up about 20 px. | **sine.inOut / power2.inOut, about 1.45 s.** Measured progress: 0.25 s 5%, 0.45 s 15%, 0.55 s 24%, 0.65 s 36%, 0.75 s 49%, 0.85 s 59%, 1.05 s 78%, 1.25 s 92%, 1.45 s 99%. Peak speed is around 0.6–0.8 s. | No overshoot and no bounce. It reads as a slow, weighty, continuous move. |
| 2a | 0.35–1.65 | **Card R** rises out of the pocket | Hidden behind the back panel (y +35% of the card height) → about 45% of the card above the pocket. Rotation about +8° → +28°. | Same in-out, starting about 0.30 s after the folder | First to break the silhouette (around 0.40 s, behind the tab). |
| 2b | 0.45–1.75 | **Card C** rises | Fully inside and blurred → top ~60% above the pocket's lower lip. Rotation ≈ 0° → +2°. | in-out, stagger +0.10 s | Becomes sharp as it clears the frosted pane (around 0.85–1.0 s): a natural "reveal by exiting the glass". |
| 2c | 0.55–1.75 | **Card L** rises | Inside → ~40% above. Rotation about −5° → −25°. | in-out, stagger +0.10 s | Appears last, from behind the left tab. |
| 2d | 1.45–1.65 (+ a jump at 1.92) | All cards **keep rising** about 10 px after the folder has stopped | — | Ease-out tail of about 0.2–0.4 s | At 1.92 s there is a one-frame 13 px jump. That is an edit seam in the source (forward clip to reversed clip), **not** a design choice. Rebuild it as a smooth settle. |
| 3 | 1.65–2.55 | Hold (fully open) | Static: no float or drift was measurable (bounding box steady to ±1 px). | — | About 0.9 s of rest. |
| 4 | 2.55–3.00 | Cards sink first | Cards drop about 25 px while the folder barely changes | in-out, about 0.45 s | The reverse of 2d: cards lead the close. |
| 5 | 2.95–4.40 | **Folder closes**: the exact time-mirror of beat 1 | All values reverse (width at time t equals width at time 4.45 − t, within 2 px) | sine.inOut, about 1.45 s | Cards slide back behind the frosted pane and blur again. |
| 6 | 4.40–4.85 | Closed hold | — | — | — |
| 7 | 4.85–5.05 | Starts opening again | — | — | Seamless loop. |

**Summary:** a yoyo loop of about 4.45 s. Open about 1.5 s (in-out), hold about 0.9 s, close about 1.5 s (mirrored), hold about 0.45 s. Cards stagger about 0.1 s apart (right, then centre, then left) and lag the folder by about 0.3 s on the way out and lead it on the way back.

## Camera / 3D

- **Perspective:** moderate. The open pocket's left edge projects about 20% taller than its right edge, which suggests about `perspective: 1400–1800px` at 1080 width (estimate). There is **no camera move**: the camera is locked and all motion is object motion.
- **Angles:** Closed is near-frontal (yaw about −5°, the right edge slightly nearer; the back panel's top tilts up to the right about 2°). Open: yaw about +18°, roll about +6° clockwise (the bottom edge slopes down to the right about 7°), and the front pocket pitched forward about 20–25° on a bottom hinge. Those angles are estimates from edge slopes.
- **Depth layering (back to front):** back panel → Card L / Card R (rotated, slightly behind) → Card C → frosted front pocket → label. The cards sit about 10–30 px "inside" the folder (shallow Z). Parallax between them comes from the yaw.
- **DOF:** none optically. All "softness" is the glass's backdrop blur. Everything outside the glass is crisp. No motion blur was seen at peak speed (the motion is slow).

## Why it looks premium

1. **Reveal by exiting glass.** The cards are blurred while inside the frosted pocket and sharpen as they clear its edge. This is the single most important detail. Without real backdrop blur the effect looks like a flat PNG sandwich.
2. **Edge-lit rims.** Thin, bright lavender strokes with a small bloom make the panels read as acrylic or glass, not flat purple shapes. Missing or thick (4 px+) rims look cheap.
3. **Slow, symmetrical in-out motion** (about 1.5 s) with no bounce: calm and expensive. A snappy back.out or elastic ease would make it feel like a template.
4. **Compound 3D:** scale, yaw, roll and pocket pitch all move together on one ease. Doing only a 2D scale looks like clip art.
5. **Real content on the cards** (real UI screenshots, a real face). Lorem or placeholder cards would kill it.
6. **Staggered fan** (about 0.1 s apart, with opposite rotations of −25°/0°/+28°) plus cards that settle a beat after the folder.
7. **A restrained palette:** one hue family (indigo to violet to lavender) with white only on the cards and the label, plus the soft floor glow.
8. **Cheap tells to avoid:** drop shadows under the folder, a glossy gradient "Web 2.0" shine, an unblurred pocket, all cards moving in sync, the folder drifting off centre, or a mismatched label font (a geometric or rounded sans instead of a bold condensed one).

## How to rebuild in HyperFrames

**Approach: DOM + CSS 3D** (no Three.js needed). Every element is a flat plane, and `backdrop-filter` gives the frosted pocket for free. Use Three.js only if you want real refraction or caustics, which this reference does not show.

```
#stage            perspective: 1600px; perspective-origin: 50% 45%;
 └ #folder        transform-style: preserve-3d; width: 46% (closed), centred at 50%/50%
    ├ .back       rounded rect, rgba(70,40,175,.85), 2px rim (inset box-shadow + outer glow), translateZ(-24px)
    ├ .card.L/C/R real screenshots (img), border-radius 6%, 1px rgba(255,255,255,.12) border,
    │             transform-origin: 50% 100%, translateZ(-12..-4px)
    ├ .front      clip-path / SVG path for the stepped top edge (tab left 38%, 50° step),
    │             background: linear-gradient(160deg, rgba(98,70,215,.78), rgba(55,31,137,.88));
    │             backdrop-filter: blur(12px) saturate(1.2);
    │             rim: SVG stroke 2.5px #D9B4FF + drop-shadow(0 0 6px #B98CFF) (clip-path kills box-shadow,
    │             so draw the rim as an SVG path on top);
    │             transform-origin: 50% 100% (bottom hinge)
    │   └ .label  "Ae" badge + "ПОРТФОЛИО" (Bebas Neue / Anton / Oswald 700, uppercase, letter-spacing .01em,
    │             white, text-shadow 0 0 12px rgba(255,255,255,.45))
 └ #glow          radial-gradient ellipse under the folder, rgba(80,70,180,.25) → 0, blend: screen
```

**GSAP (one paused timeline, seek-safe, all values fixed; no `Math.random`):**

```js
const tl = gsap.timeline({ paused: true, defaults: { ease: "sine.inOut" } });
// OPEN
tl.fromTo("#folder", { scale: 1, rotationY: -5, rotationZ: 0, y: 0 },
                     { scale: 1.46, rotationY: 18, rotationZ: 6, y: -20, duration: 1.45 }, 0.08)
  .fromTo(".front",  { rotationX: 0 }, { rotationX: 22, duration: 1.45 }, 0.08)   // top falls toward viewer
  .fromTo("#glow",   { opacity: .7 }, { opacity: 1, duration: 1.45 }, 0.08)
  .fromTo(".card.R", { yPercent: 35, rotation: 8 },  { yPercent: -45, rotation: 28, duration: 1.3 }, 0.35)
  .fromTo(".card.C", { yPercent: 40, rotation: 0 },  { yPercent: -60, rotation: 2,  duration: 1.3 }, 0.45)
  .fromTo(".card.L", { yPercent: 40, rotation: -5 }, { yPercent: -40, rotation: -25, duration: 1.2 }, 0.55)
// HOLD to 2.55, then CLOSE (mirror; the cards lead)
  .to(".card", { yPercent: "+=8", duration: 0.45 }, 2.55)
  .to(".card.L", { yPercent: 40, rotation: -5, duration: 1.3 }, 2.75)
  .to(".card.C", { yPercent: 40, rotation: 0,  duration: 1.3 }, 2.80)
  .to(".card.R", { yPercent: 35, rotation: 8,  duration: 1.3 }, 2.85)
  .to("#folder", { scale: 1, rotationY: -5, rotationZ: 0, y: 0, duration: 1.45 }, 2.95)
  .to(".front",  { rotationX: 0, duration: 1.45 }, 2.95)
  .to("#glow",   { opacity: .7, duration: 1.45 }, 2.95);
// total ≈ 4.45 s; loop by repeating the block or using yoyo on a sub-timeline (avoid repeat:-1 for render)
```

Notes:
- The "sharpen on exit" happens on its own because `backdrop-filter` only blurs what is behind `.front`. Check the renderer: if headless Chrome drops backdrop-filter inside `preserve-3d`, fall back to two copies of each card. One is blurred (`filter: blur(12px)`) and clipped to the pocket shape; the other is sharp and clipped to the area above it, with the same transforms on both.
- `backdrop-filter` plus 3D transforms can create a flattening context. Keep `.front` a direct child, test with a still at t = 1.0 s, and if needed fake the pocket depth with 2D skew instead of rotationX.
- Fonts: load them locally, so the first frame doesn't render in a fallback font.

## Reuse recipe

- **"My toolkit / portfolio / sources" beat** in a talking-head reel. Put the folder in the lower or middle third behind a cut-out of the creator (matte him on top). Swap the label to Derja or Latin ("أدواتي", "PROMPTS", "MY STACK"), and the cards to real screenshots (ChatGPT chat, Claude artifact, a Midjourney grid, a GitHub repo).
- **Explainer scene:** "3 tools that…". Open the folder, then cut or zoom into each card in turn (follow with a scale-to-fullscreen on Card C).
- **Screen recordings as cards:** use muted `<video>` cards (framework-owned playback) so the cards are live.
- **Parameters to vary:**
  - hue (violet `#5B3BC4` → AI-green `#1FA37A` / Claude orange `#D97757`)
  - card count (2–5; spread rotations evenly about ±30°)
  - scale gain (1.3–1.6)
  - yaw end value (12–22°)
  - open duration (1.0 s for energetic reels, 1.5 s for calm)
  - card stagger (0.06–0.12 s)
  - hold length
  - whether it closes at all (for a reel, opening once and then cutting is usually enough)
- Keep: the frosted blur, the thin rim light, an in-out ease with no bounce, and real content on the cards.

## Key frames

- **0.00 s:** closed, near-frontal, centre card frosted behind the pocket (`ref-04_t0.00.png`)
- **0.40 s:** Card R first breaks the folder silhouette
- **0.75 s:** mid-open, peak speed, cards half out and still blurred below the edge (`ref-04_t0.75.png`)
- **1.20 s:** fan nearly complete, Card C sharp above the stepped edge (`ref-04_t1.20.png`)
- **2.25 s:** fully open hold, the hero frame (`ref-04_t2.25.png`)
- **3.65 s:** closing, the mirror of 0.80 s
