# ref-01: "Apple-style UI morph showcase" (glass dock + profile card morph)

Source: `ref-01.mov`, a phone screen recording of a Pinterest video. It is 1016x1730 and 7.16 s long. The container says 60 fps, but the recording is variable-frame-rate at about 30 fps (205 frames). Pinterest chrome is a white border with a back-arrow button at the top left; ignore both. The real video area is about x42-974, y44-1700, so roughly 932x1656, which is about 9:16.

Frame gaps: a dropped-frame gap from **3.00 s to 3.37 s** (0.37 s missing), plus small gaps at 3.92 and 5.35. Whatever happens in the preview between 3.00 and 3.37 s was not captured.

Analysis files (sheets, crops, tracking scripts) are in the session scratchpad, `.../scratchpad/motion-ref-01/`.

---

## What it is

A creator's "how I made it" breakdown card, from motion designer "varculin". A static, vertical blue-gradient poster stacks three elements:
1. A 16:9 **preview window** that plays a looping Apple-style UI animation.
2. The **After Effects timeline** used to make it.
3. The **Premiere timeline** used to make it.

The motion is all inside the preview. It plays two Apple-style micro-interactions:
- **(A) A Liquid-Glass dock is born.** A glass capsule springs open horizontally, app icons pop in one after another, and a white pointer dot hovers across them with magnification.
- **(B) An Instagram profile card.** A pointing-hand cursor clicks "Follow", the button changes to "Following", then the whole card collapses into a square avatar tile with a slight 3D tilt.

**Short name:** *"Apple UI micro-interaction showcase"*. The two effects inside it are "glass dock spring-open" and "card-to-avatar morph".

The layout itself never moves. There is no camera move. Only the preview content animates, along with the Premiere playhead and hard swaps of the AE screenshot.

### Loop structure (from the Premiere playhead)
The Premiere playhead moves at real-time speed, about 26.7 px/s on the ruler, and wraps inside the 3.00-3.37 s gap. So the preview is one looping clip ("Apple Follow.mp4") of **about 10.5-11 s** (estimate). In that clip's own time (src):

- src ≈ 0.0-4.0 s: dock sequence. Recorded at 3.37-7.16 s.
- src ≈ 4.0-7.3 s: **not in this recording**. Probably the dock turning into or handing off to the profile card.
- src ≈ 7.3-10.4 s: Follow click, then morph to avatar tile, then hold. Recorded at 0.00-3.00 s.

---

## Elements & materials

Sizes are given as a fraction of the 932-px-wide video frame (W) or 1656-px-tall frame (H), plus the measured pixels at 1016 px capture width.

### Page background
- Vertical gradient. Top right is light periwinkle `#91AEEF`, with a lighter glow in the upper-right corner. Upper middle is royal blue `#4964DD`, and around y≈55% it is `#4D6CD4`. Lower down it goes `#3A51AA`, then `#2C4088`, ending in deep navy `#1F2E5F` at the bottom.
- The bottom ~20% darkens like a vignette.
- Grain: none visible. There is mild compression softness only.

### Wordmark "varculin" (static)
- Centred, top at about 19% of H. About 29% of W wide, x-height about 3% of H.
- Lowercase, rounded geometric sans. It looks like Quicksand / Comfortaa / Nunito at Bold or Semibold, with a single-storey "a".
- Colour is only slightly lighter than the background (`#7A90CF` to `#8CA0E0`). A small dark drop shadow, offset 1-2 px down and right, makes it look debossed or embossed.
- Deliberately low contrast, like a watermark rather than a headline.

### Preview window (the hero)
- Placement: 85% of W wide (793 px), x 112-905. 445 px tall (27% of H), y 428-873. Aspect is **16:9**. Corner radius about 34-38 px.
- Rim: a crisp 2-3 px light stroke (`#B4CEFB` at the top, darker `#3141C0` at the bottom edge), like a glossy glass bezel. There is a faint dark outer shadow.
- Content background: a **macOS Monterey-style wallpaper** of layered soft blue ridges.
  - Colours: light ridge `#B5CFFC`, mid `#415EBE`, top-left `#3844C4`, bottom-left almost black-navy `#04072F`.
  - The wallpaper is static, with no parallax.

#### Scene B elements (profile)
- **Profile card:**
  - White `#FDFDFD`, about 82% of the preview width (649 px) by 66% of the preview height (294 px). Radius about 26-30 px.
  - Very soft shadow. No glass.
  - Centred horizontally (cx = 508), slightly below the vertical centre.
- **Avatar:**
  - Circle about 190 px across (≈ 0.65 × card height).
  - Contains a cut-out person over a light-blue sunburst (alternating `#7FC4F5` and white rays).
  - Sits at the left with about 50 px padding.
- **Name row:**
  - "varculin" in black, regular or medium weight, about 26 px, followed by the blue Instagram verified badge.
  - The **Follow** button sits to the right. It is 128×34 px, `#1CA0EF`, radius about 6 px, with white "Follow" in regular weight.
  - After the click it becomes **Following**: 136×34, grey `#A8A8A9`, white text.
- **Stats:**
  - "**12** posts **35** followers **24** following". Numbers bold, labels regular, about 20 px.
- **Bio:**
  - 4 lines of regular weight, about 20 px, Helvetica/SF-like, black.
  - Has a ✨ and ✏️ emoji.
- **Instagram app tile:**
  - About 80 px with a gradient and white glyph.
  - Sits **half off the card's bottom-right corner**, overlapping the edge, with a small drop shadow.
- **Defocused Instagram glyph (bokeh):**
  - A huge, heavily blurred Instagram logo (pink/red/white rings, `#F87679` / `#E5ACBE`) at the preview's top-left corner, cropped by the window.
  - Gaussian blur around 25-35 px at this scale (estimate).
  - It sells foreground depth of field. It is only present in scene B.
- **Cursor:**
  - The classic macOS pixel **pointing-hand** cursor, black outline with white fill, very large (about 75 px tall, about 17% of the preview height).
  - Its pixelated edges are left visible, a deliberately retro and tactile touch.

#### Scene A elements (dock)
- **Glass capsule (dock):**
  - Final size 627 × 118 px: 79% of the preview width, 26% of its height. Fully rounded.
  - Centred (cx 508, cy about 667, slightly below the preview centre).
  - **Material is liquid glass:**
    - Body: a white tint of about 12-18%. The inside reads `#4663F2` where the outside is `#394CDA`.
    - Backdrop: lightly frosted, blur about 4-8 px (estimate).
    - Rim: a bright **1.5-2 px white rim all round**, strongest on the top edge (`#DAECFD`) and a little softer on the bottom edge (`#A7C5FC`). There is a faint inner glow along the edges.
    - Shadow: a soft, wide drop shadow below, about 20-28 px blur, offset y about 8 px, dark blue at about 35%. That shadow is why the diff bbox is about 40 px larger than the visible capsule.
    - **Refraction:** the bright diagonal wallpaper ridge is visibly **displaced and magnified inside the capsule** compared with outside, and the edges bend it like a lens (see `ref-01_t3.52.png`).
- **App icons:**
  - Instagram (gradient tile), App Store (blue tile), Discord (blurple glyph only, no tile), and WhatsApp (green bubble glyph).
  - Each is about 60-64 px, about 53% of the capsule height.
  - Centres are evenly spaced about 140 px apart (x ≈ 302 / 436 / 577 / 719), and the icon row is centred in the capsule.
- **Pointer dot:**
  - The iPadOS-style circular pointer: a solid white circle about 24 px across (about 3% of the preview width) with a soft edge or glow.
  - It rests just below each icon's centre, at y ≈ the icon's lower edge.

### Lower panels: "screenshots in glass device frames" (static layout)
- **After Effects timeline:**
  - x 133-892 (≈81% of W), y 901-1088. About 4:1.
  - Dark UI (`#1E1E1E`-ish) with red, blue and lavender keyframe bars.
- **Premiere timeline:**
  - x 273-760 (≈52% of W), y 1115-1360. About 2:1.
  - Teal audio clips, and a white "Apple Follow.mp4" video clip.
- **Frame material:**
  - A thick, glossy, **bevelled phone-like bezel**, radius about 40 px.
  - Bright white specular highlight along the top-left and bottom curves, with a dark inner bevel.
  - The screenshots are soft or low-resolution, and that is fine because they are context, not hero.
- **Slight 3D tilt:** each panel is about 2.5% wider at the bottom than the top (740 → 759 px over 160 px of height). That is roughly `rotateX(5-8deg)`, with the top leaning away (estimate).
- **Spacing:** vertical gaps between preview, AE panel and Premiere panel are about 28 px each. The stack narrows as it goes down (85% → 81% → 52% of W), which builds a visual pyramid.

---

## Timeline

`t` is recording time. Values are in capture pixels (1016-wide frame). Durations and eases are fitted from frame-by-frame tracking at about 30 fps, so treat eases as estimates.

### Scene B: Follow click (src ≈ 7.3 s)

| t (s) | Element | From → To | Ease / duration (est.) |
|---|---|---|---|
| 0.00-0.90 | Hand cursor resting on Follow | Tiny drift of a few px, otherwise still | linear |
| 0.90-0.97 | **Press** on the Follow button | Blue width 128 → 86 px, collapsing toward its own centre (x≈698). The cursor also appears to scale down slightly | `power2.in`, about 0.07-0.1 s |
| 0.97-1.00 | Colour and label swap | Blue "Follow" → grey "Following", label crossfade | Cut or crossfade over about 0.03 s |
| 1.00-1.15 | **Release** | Grey pill grows from about 84 px to its final about 136 px. A slight overshoot is possible, but the cursor occludes it, so this is an estimate | `power2.out` / `back.out(1.4)`, about 0.2 s |
| 1.00-1.25 | Hand cursor | Slow drift right, about 10 px | sine |
| 1.25-1.40 | Hand cursor exits right | About +150 px, off the card edge, with **horizontal motion blur** | `power2.in`, about 0.15 s |
| 1.40-1.55 | Hold | Static | n/a |

### Scene B: Card-to-avatar morph (src ≈ 8.0-8.7 s)

| t (s) | Element | From → To | Ease / duration (est.) |
|---|---|---|---|
| 1.55-2.20 | **Card container width** | 649 → 255 px, symmetric about cx = 508. Normalised progress: 14% at 0.18 s, 35% at 0.28 s, 57% at 0.35 s, 79% at 0.42 s, 91% at 0.48 s, 97% at 0.55 s | **`power2.inOut`, 0.65 s**. Peak speed about 1300 px/s near the midpoint |
| 1.60-2.20 | Card container height | 294 → 252 px. Content-driven: the avatar keeps its size and the box hugs it with even padding | Same ease, slightly delayed (`power2.inOut` 0.6 s) |
| 1.60-2.20 | Card vertical position | Centre-y 651 → **673 (dip +22 px at about 1.95)** → 649. A small downward arc | `sine.inOut` out and back |
| 1.70-2.07 | **3D tilt** | 0 → about rotateZ -2.5° and rotateY ≈ 8-12°, right edge nearer (right edge about 6% taller than the left at 1.80 s) → 0 by 2.07 | `power2.inOut`, about 0.2 s in and 0.2 s out (estimate) |
| 1.60-2.20 | Interior content | Avatar shifts right with the left edge (x 175 → 250 in a crop, ≈ +75 px). The text block also moves right but is **clipped by the collapsing right edge** (overflow hidden), so name, stats and bio wipe away. Nothing fades or scales | Same as width |
| 1.65-2.05 | Verified badge | Detaches from beside the name and flies to the **top-right corner inside the square**, ≈ +30 px x and -17 px y. It does not get clipped | `power2.inOut`, about 0.4 s |
| 1.55-2.20 | Instagram tile | Rides the card's bottom-right corner, ending half-overlapping the square's corner | Same as width |
| 2.20-3.00 | Avatar tile | Hold, static | n/a |
| 3.00-3.37 | (Loop wrap, not captured) | The avatar tile leaves, probably via a quick fade or scale (unknown) | n/a |

### Scene A: Glass dock (src ≈ 0-4 s)

| t (s) | Element | From → To | Ease / duration (est.) |
|---|---|---|---|
| ~3.39 | Capsule appears | First visible frame (3.417) is already a **tall narrow capsule** 64 × 116 px at full height. The birth itself is inside the gap (probably a pop or scale from a dot in under 0.05 s) | n/a |
| 3.42-3.72 | **Capsule width expands** (height stays at 118) | 64 → 620 px, centred. Nearly constant speed, about 1950 px/s | Spring, see below |
| 3.72-3.82 | Overshoot | → **667 px (+7.5%)** | spring |
| 3.82-4.08 | Undershoot | → 602 px (-3%) | spring |
| 4.08-4.40 | Second, small overshoot | → about 630 (+1%), then settles at **620-627** by about 4.5 | spring |
| | **Spring fit** | Damped period ≈ 0.55 s and damping ratio ζ ≈ 0.6-0.65 (ω_n ≈ 14-15 rad/s). Equivalent to SwiftUI `.spring(response: 0.45, dampingFraction: 0.63)`. About 1.0 s to settle | |
| 3.98-4.60 | **Icons pop in**, left → right | Each scales from 0 to 1 about its own centre at full opacity. App Store size track: 11 → 24 → 38 → 50 → 62 → 68 → **70 (peak, +9%)** → 66 → 62-64 | Grow ≈ 0.35 s with a near-linear rise, overshoot ≈ 8-10%, settled by about 0.6 s. ≈ `back.out(1.7)` 0.55 s, or a spring with ζ ≈ 0.55 |
| | Stagger | IG starts 3.98, App Store about 4.05, Discord about 4.12, WhatsApp about 4.20. **About 0.07-0.08 s** apart | |
| 4.25-4.45 | Capsule | A slight +1-4% width breath while the icons overshoot. It might just be the spring tail (estimate) | |
| 4.45-5.25 | Hold | Static | n/a |
| 5.25-5.70 | **Pointer dot enters** from the preview's bottom-right corner (x≈900, y≈845) | Moves to just below the WhatsApp centre (715, 665). Steps shrink each frame: 19 → 41 → 21 → 16 → 13 → 12 → 9 → 8 px | `power3.out`, about 0.45 s |
| 5.60-5.85 | **WhatsApp magnify** | Scale 1 → **1.16** (56 → 65 px) about its centre, no lift | `power2.out`, about 0.25 s |
| 5.75-6.07 | Pointer idle drift | About 15 px left, slowly | linear / sine |
| 6.07-6.37 | Pointer → Discord | x 700 → 584 (≈ -130 px) | `power2.inOut`, about 0.3 s |
| 6.10-6.30 | WhatsApp un-magnify | 1.16 → 1 | `power2.inOut`, about 0.2 s |
| 6.20-6.45 | Discord magnify | 1 → about 1.15 | `power2.out`, about 0.25 s |
| 6.37-6.63 | Pointer idle drift | About 15 px left | linear |
| 6.63-7.10 | Pointer → App Store | x 571 → 437. Steps 4, 5, 6, 7, 11, 12, 16, 17, 17, 13, 10, 6, 6, 2, 2 px: a clear S-curve | `power2.inOut` / `sine.inOut`, about 0.47 s |
| 6.65-7.00 | App Store magnify | 65 → **76 px (×1.17)** | `power2.out`, about 0.35 s |
| (≥7.16) | (continues off-recording) | | |

### Background / panels (whole time)

| t (s) | Element | Behaviour |
|---|---|---|
| all | Premiere playhead | Linear at real-time speed, wraps at the loop point |
| 0.35, 1.07, 1.53, 3.37, 6.03, 6.70 | AE panel | **Single-frame hard swap** to a different scroll position of the layer list. It is a screen recording, not animated |
| all | Page, wordmark, panel frames | Fully static (frame-diff ≈ 0) |

---

## Camera / 3D

- **No camera move at all.** The poster layout is locked off: no drift, zoom or parallax.
- **Preview window** is flat, with no perspective.
- **Lower panels** carry a slight static `rotateX` of about 5-8°, top away. They are 2.5% wider at the bottom, which gives a "tablet lying back" feel.
- **Card morph** is the only dynamic 3D. Halfway through the collapse the card briefly yaws (rotateY ≈ 8-12°, right side toward the viewer) and rolls (rotateZ ≈ -2.5°), then flattens as it lands. Perspective is moderate, estimated around 1200-1600 px at this card size.
- **Depth of field** is faked with one element: the huge, heavily blurred Instagram logo in the top-left foreground of scene B. Everything else is sharp.
- **Shadows give layering:** the glass capsule casts a soft blue shadow on the wallpaper, and the white card and IG tile carry light shadows.

---

## Why it looks premium

1. **Real Apple physics.** The capsule opens on an under-damped spring: about 7% overshoot, one undershoot, a tiny second bounce, then settle. It is not a simple ease-out. The icons pop with about 9% overshoot. The pointer uses `power3.out` to arrive and in-out S-curves between targets. Ease-outs alone would look like "AI slop".
2. **One continuous object.** The card *becomes* the avatar tile. The container collapses with overflow clipping while the avatar stays the same size. Nothing crossfades, so the eye tracks one object.
3. **A tiny 3D wobble during the morph** (≈ 10° yaw and 2.5° roll that resolve to 0). It gives the change weight and life, but it is so small it never reads as a "3D effect".
4. **Glass that actually refracts.** The wallpaper ridge visibly bends and offsets inside the capsule. Add the bright thin rim on top, a softer bottom rim and a soft coloured drop shadow. A flat `backdrop-filter: blur()` with a white border looks cheap by comparison.
5. **Generous stillness.** Long holds (≈0.8 s after the morph, ≈0.8 s after the dock settles) and slow idle drifts of the pointer. Motion only happens when something changes state.
6. **Staggered rhythm.** Icon stagger is about 0.07 s, left to right, and magnify-on-hover only affects the hovered icon.
7. **Limited palette.** Everything sits in a monochrome blue world (wallpaper, background, glass), so the white card and the coloured app icons pop.
8. **Tactile details.** The pixel-art hand cursor with motion blur on exit, the press squish on the button, and the badge that flies to the tile corner.
9. **Honest context.** The real AE and Premiere timelines sit in glossy bezels, so the poster says "crafted", not "generated".

**What makes it look cheap if missed:**
- Linear or ease-out-only motion.
- Scaling the capsule with `scaleX`, which squashes the round ends. Animate the *width* or the clip.
- Crossfading card → avatar instead of morphing the container.
- Opaque glass with no refraction or rim, or a hard black drop shadow.
- Icons that fade in instead of scale-popping.
- Magnifying all icons at once.
- A pointer that teleports, or moves at constant speed.
- Any grain or noise on the clean UI. The reference has none.

---

## How to rebuild in HyperFrames

**Approach: DOM + CSS (with CSS 3D for the tilt).** Three.js is not needed. The only "shader-like" need is the glass refraction, and that can be done with DOM layering (below).

### Structure
```
#stage (1080x1920, bg: linear-gradient(180deg,#91AEEF 0%,#5A74E2 22%,#4964DD 45%,#3A51AA 75%,#1F2E5F 100%) + radial highlight top-right)
  .wordmark            ("varculin" → creator handle; Quicksand 700, color #8CA0E0, text-shadow 1px 2px 2px rgba(10,20,80,.35))
  .preview  (16:9, w=85%, radius 36px, overflow:hidden, border 2.5px solid rgba(190,215,255,.9), box-shadow 0 10px 30px rgba(10,20,80,.35))
     .wallpaper (img, cover)
     .sceneA
        .glass    (absolute, centred, height 26.5% of preview, border-radius 999px)
           .glass-refract  (clip: inherit; contains a COPY of .wallpaper, positioned to align with the outer one,
                            transform: scale(1.08) translate(..); filter: blur(4px) saturate(1.3) brightness(1.08))
           .glass-tint     (background: rgba(255,255,255,.14))
           .glass-rim      (box-shadow: inset 0 1.5px 0 rgba(255,255,255,.95), inset 0 -1.5px 0 rgba(200,225,255,.6),
                            inset 0 0 0 1.5px rgba(255,255,255,.35), inset 0 0 18px rgba(255,255,255,.18))
           shadow on .glass: 0 10px 26px rgba(15,30,120,.35)
           .icons > .icon x4 (60px, transform-origin center)
        .pointer  (24px white circle, box-shadow 0 0 8px rgba(255,255,255,.6), 0 2px 6px rgba(0,0,40,.25))
     .sceneB (perspective: 1400px)
        .bokeh-ig (big IG glyph, filter: blur(30px), opacity .85, top-left, partly off-frame)
        .card (white, radius 28px, overflow:hidden, transform-style:preserve-3d; width/height animated)
           .avatar  .name  .badge  .follow-btn  .stats  .bio
        .ig-tile (positioned from card's bottom-right corner, follows it)
        .hand-cursor (macOS pointing-hand PNG, image-rendering: pixelated, ~75px)
  .panel.ae  (screen-recording video in bezel; transform: perspective(1200px) rotateX(6deg))
  .panel.pr  (same)
```

- For the bezels, use `border-radius: 40px; border: 3px solid #e9eef8;` with `box-shadow: inset 0 0 0 2px #2a2d33, 0 8px 24px rgba(0,0,30,.35), inset 0 2px 1px rgba(255,255,255,.8)`, plus a pseudo-element with a white top-left specular gradient.
- **Refraction trick, seek-safe:**
  - Put a duplicate of the wallpaper inside the capsule, scaled about 1.08 around the capsule centre and shifted a few px, so the ridge visibly offsets. Lightly blur and brighten it.
  - For lens edges, add a second copy scaled about 1.15, masked to only the outer 10 px ring with `mask: radial/ellipse` or an inset-border mask.
  - Optional upgrade: an SVG `feDisplacementMap` filter on the copy layer with a static, pre-made capsule displacement map. That is deterministic.
  - Avoid relying on `backdrop-filter: url(#svg)`.
  - Recompute the copy's offset every frame from the capsule width, inside the same GSAP timeline (`onUpdate`), so it stays aligned while the capsule grows.

### Spring ease (deterministic, no physics state)
```js
// Closed-form under-damped spring as a GSAP ease. p in [0,1] maps to t = p*dur seconds.
const spring = (zeta = 0.63, wn = 14.5, dur = 1.0) => p => {
  if (p >= 1) return 1;
  const t = p * dur, wd = wn * Math.sqrt(1 - zeta * zeta);
  return 1 - Math.exp(-zeta * wn * t) * (Math.cos(wd * t) + (zeta * wn / wd) * Math.sin(wd * t));
};
```
This gives about 7-8% overshoot. For the icons use `spring(0.55, 16, 0.6)` or plain `back.out(1.7)`.

### GSAP tween list (one paused master timeline; times are scene-relative)
```js
const tl = gsap.timeline({ paused: true });

// --- Scene A: dock (0.0 - 4.0) ---
tl.set('.glass', { width: 64, opacity: 1 }, 0)                // optionally from scale 0.6/opacity 0 over 0.06 s
  .to('.glass', { width: 624, duration: 1.0, ease: spring(0.63, 14.5, 1.0) }, 0.03)
  .from('.icon', { scale: 0, duration: 0.55, ease: 'back.out(1.7)', stagger: 0.075 }, 0.6)
  .fromTo('.pointer', { x: P_ENTER.x, y: P_ENTER.y, opacity: 0 },
          { x: WA.x, y: WA.y + 30, opacity: 1, duration: 0.45, ease: 'power3.out' }, 1.85)
  .to('.icon.wa', { scale: 1.16, duration: 0.25, ease: 'power2.out' }, 2.2)
  .to('.pointer', { x: '-=15', duration: 0.32, ease: 'none' }, 2.38)
  .to('.pointer', { x: DC.x, duration: 0.30, ease: 'power2.inOut' }, 2.7)
  .to('.icon.wa', { scale: 1, duration: 0.2, ease: 'power2.inOut' }, 2.73)
  .to('.icon.dc', { scale: 1.15, duration: 0.25, ease: 'power2.out' }, 2.83)
  .to('.pointer', { x: '-=15', duration: 0.26, ease: 'none' }, 3.0)
  .to('.pointer', { x: AP.x, duration: 0.47, ease: 'power2.inOut' }, 3.26)
  .to('.icon.dc', { scale: 1, duration: 0.25, ease: 'power2.inOut' }, 3.3)
  .to('.icon.ap', { scale: 1.17, duration: 0.35, ease: 'power2.out' }, 3.28);
  // (the unseen src 4-7.3 s segment: design your own handoff, e.g. click App Store, then dock morphs into the card)

// --- Scene B: follow + morph (offset B0) ---
tl.to('.hand', { x: '+=3', y: '-=2', duration: 0.9, ease: 'sine.inOut' }, B0)
  .to('.hand', { scale: 0.92, duration: 0.07, ease: 'power2.in', yoyo: true, repeat: 1 }, B0 + 0.9)
  .to('.follow-btn', { width: 86, duration: 0.07, ease: 'power2.in' }, B0 + 0.9)
  .set('.follow-btn', { className: 'follow-btn is-following' }, B0 + 0.97) // grey + "Following"
  .to('.follow-btn', { width: 136, duration: 0.2, ease: 'back.out(1.4)' }, B0 + 0.97)
  .to('.hand', { x: '+=12', duration: 0.25, ease: 'sine.inOut' }, B0 + 1.0)
  .to('.hand', { x: '+=170', duration: 0.15, ease: 'power2.in' }, B0 + 1.25)
  // morph
  .to('.card', { width: 255, duration: 0.65, ease: 'power2.inOut' }, B0 + 1.55)
  .to('.card', { height: 252, duration: 0.6, ease: 'power2.inOut' }, B0 + 1.6)
  .to('.card', { y: '+=22', duration: 0.33, ease: 'sine.inOut', yoyo: true, repeat: 1 }, B0 + 1.6)
  .to('.card', { rotationY: 10, rotationZ: -2.5, duration: 0.2, ease: 'power2.inOut', yoyo: true, repeat: 1 }, B0 + 1.7)
  .to('.badge', { x: 30, y: -17, duration: 0.4, ease: 'power2.inOut' }, B0 + 1.65);
```

- **Motion blur on the exiting hand:** add an `onUpdate` that sets `filter: blur(Npx)` from the per-frame x-velocity (deterministic, since it is derived from the tween), or simply tween `filter: 'blur(4px)'` over the same 0.15 s.
- **Seek-safety:**
  - Use one paused master timeline and drive it with `tl.seek(t)`. No `setTimeout`, no CSS transitions or animations, no `requestAnimationFrame` physics, no unseeded `Math.random`.
  - The spring is closed-form, so it is fully seekable.
  - The background screen recordings (AE and Premiere) must be framework-owned `<video>` clips, so HyperFrames controls their time.
  - Animate `width`, not `scaleX`, on the capsule and card so the radii stay round. If performance matters, use `clip-path: inset(0 X round 999px)` on a fixed-size element instead.

---

## Reuse recipe (for the Derja AI/tech talking-head reels)

1. **"Here's what I built" breakdown poster (closest to the reference).**
   - Top: a 16:9 preview window playing a short screen recording or UI animation of the AI tool or result.
   - Below: one or two glossy-bezel panels showing *how* it was made: the prompt, n8n/Make workflow, code or Claude chat. Tilt them with `rotateX(6deg)`.
   - Your handle replaces "varculin" as the low-contrast embossed wordmark.
   - Works as a B-roll cutaway or as a 2-3 s hook frame.
2. **Behind the speaker.**
   - Use a matted cut-out of the creator in the lower 55% of the frame. Put the preview window in the top 35%, playing the glass dock, with icons = the AI tools he is about to talk about (ChatGPT, Claude, Gemini, Perplexity…).
   - Sync each icon's magnify to the word in the VO.
   - The pointer dot is the "attention cursor".
3. **Explainer: "tool stack" beat.**
   - The glass capsule springs open, tool icons pop with a stagger, and the pointer visits each one as it is named.
   - End with a click on one tool, then the card-to-tile morph of that tool's profile card or a screenshot.
4. **Social CTA end card.**
   - Profile card with a real screenshot of his Instagram/TikTok header. The Follow → Following click, then the morph to an avatar tile, is a natural "follow for more" outro.
5. **Real content in the cards.**
   - Swap the card's interior for an actual screenshot or screen recording (a ChatGPT answer, a dashboard). The width-collapse-with-clip morph works on any content.

**Parameters to vary:**
- Spring: ζ 0.5-0.75 (bounciness) and ω_n 12-18 (speed).
- Icon count 3-6, stagger 0.05-0.1 s, hover scale 1.12-1.2.
- Capsule height 22-30% of the preview.
- Glass: tint 8-20% white, backdrop blur 3-10 px, refraction scale 1.04-1.12.
- Morph target size (square, circle, or a pill such as a logo lockup), tilt amount (rotateY 6-14°, rotateZ ±1-3°), morph duration 0.5-0.8 s.
- Palette: the reference is monochrome blue. For your brand, swap the wallpaper and background as a matched pair, keeping one hue family plus a dark base.
- Wallpaper: any soft, layered gradient landscape. The refraction needs some contrasting diagonal shape to be visible.
- Cursor style: macOS hand (playful and retro) or iPad dot (modern). Don't mix them in one scene.

---

## Key frames

| t (s) | Why |
|---|---|
| **0.95** | Follow press: hand cursor on the squished blue button. Saved as `ref-01_t0.95.png` |
| **1.88** | Mid-morph: card half collapsed, tilted in 3D, text clipping, badge in flight. Saved as `ref-01_t1.88.png` |
| 2.50 | Morph result: square avatar tile with badge in the top-right and IG tile overlapping its corner |
| **3.52** | Glass capsule stretching. Shows refraction of the wallpaper ridge, the rim light and the shadow. Saved as `ref-01_t3.52.png` |
| 4.60 | Dock settled with all four icons. Best view of the final glass material |
| **6.97** | Pointer dot on App Store, icon magnified ×1.17, plus the full poster layout with tilted panels. Saved as `ref-01_t6.97.png` |
