# ref-02 — Staggered glass card wall that scrolls up to the next prompt

Source: `ref-02.mov`, a phone screen recording of a Pinterest video (1016×1730 at 60 fps, 4.91 s). The real video area is **x 0–1016, y 72–1284 (1016×1212, about 0.84:1; probably a 4:5 source cropped by Pinterest, estimate)**. Everything below y ≈ 1285 is the Pinterest page. Ignore these Pinterest UI elements: the back-arrow button at top-left, the "expand" button at bottom-right, and the play/pause bar plus hand cursor during 0–1 s. The underlying animation is about **30 fps**; the recording repeats or drops frames, so it is variable frame rate. **0.00–1.00 s is a frozen first frame** while Pinterest buffers. The real motion starts at about 1.0 s.

All pixel values below are in source pixels of the 1016-wide video area. To convert to a 1080×1920 reel, multiply by about 1.063.

## What it is

The frame shows a wall of frosted lavender **glass "AI assistant" chat cards** in three columns, sitting on a static magenta-to-indigo gradient. Each card has a glossy orb avatar ("boddy"), a one-line greeting such as "Hey Susanne, ready for our daily meditation? It's starting… now!", and a "Start typing or speaking…" input row with a mic button. The columns are offset vertically by half a card, like brickwork. In one beat the **whole wall scrolls up by exactly one card pitch**. The columns launch **left → centre → right with a ~0.21 s stagger**. Each column uses a heavy ease-in-out with real vertical motion blur, then keeps drifting slowly upward. The next card ("How is that new moisturiser working for you, Marc?") ends up framed in the centre.

**Short name:** "staggered glass card-wall scroll" (prompt-wall slot scroll).

There is **no 3D**. Cards do not tilt, scale, rotate or change opacity. The depth comes only from glass over a static backdrop, plus motion blur.

## Elements & materials

| Element | Size / geometry (source px, % of width W=1016) | Colour | Material / styling |
|---|---|---|---|
| **Background** | Full frame, **static**. It does not move during the scroll; sampled pixels were unchanged to ±1. | Top-right glow `#C83ED7` (hot magenta). Top-centre `#8F50AA`. Top-left `#741FA2`. Mid and lower-left deep indigo `#120031`–`#120034`. Bottom `#11002A`. | A large soft radial magenta bloom from the top-right corner falls off diagonally into near-black indigo. A darker diagonal swath runs from mid-left to lower-right, with a faint diagonal light shaft from the top-right (estimate). No visible grain (compressed). |
| **Glass card** | **533 × 608** (52.5% W; aspect ≈ 0.88, almost square). Corner radius **≈ 30–34** (≈ 6% of card width). Vertical gap between cards **≈ 112**, so the **pitch is 720** (70.9% W). Horizontal gap between columns **≈ 105**. | Body over the dark area `#5F3C88` (top) → `#655186` (middle) → `#553273` (lower-right). Over the magenta area the same glass reads light pink-lavender. | **Frosted glass:** a heavy backdrop blur (≈ 40–60 px, estimate), so the backdrop shows only as soft colour. Over that sits a white veil (≈ 10–16% white, estimate). A soft **white haze in the lower-left corner** (radial, ≈ 10% white). The **rim is a 1 px hairline that is brightest along the top edge** and fades down the sides (≈ rgba(255,255,255,.35) at the top, .12 at the sides). No visible drop shadow (at most a very faint one, estimate). Because the backdrop is static, a card's tint changes as it slides over the magenta or the dark area. This is the main "real glass" cue. |
| **Orb avatar** | Diameter ≈ 115 (≈ 21% of card width). Inset ≈ 35 from the card's top-left. | Dark core `#1A0838` with a violet/lilac specular highlight at upper-right `#8C6BE0`. | Glossy sphere with a rim light. Tiny "boddy" wordmark centred, white at ~60%. |
| **Message text** | Starts ≈ 50 in from the card's left edge, ≈ 230 below the card top. Font size ≈ **32 px (3.1% W)**, line pitch ≈ 38 (line-height ≈ 1.2). 2–3 lines. | Off-white `#ECE6F5` at ~90%. | **Light/Regular neo-grotesk** (Neue Haas / Inter Display–like, weight ~300–400; **not bold**). Sentence case, tracking ≈ −0.01em. Left-aligned. |
| **Input row** | Bottom ≈ 20% of the card: an inner sub-panel with its own rounded top corners and rim (a pinkish highlight on the left corner). | Slightly lighter than the card body. | A 1 px **hairline divider** with a left-to-right gradient (transparent → white ~70% near the mic). It **overshoots the card's right edge by ≈ 15–20 px**. Placeholder "Start typing or speaking…" ≈ 16 px (half the message size), Regular, ~65% opacity. |
| **Mic button** | Circle ≈ 60 (≈ 6% W). Sits on the divider ≈ 70 in from the card's right edge. | Fill `#1C0733`, 1 px light rim. | White outline mic glyph, ~1.5 px stroke. |
| **Side columns** | Same card size. Only the inner ≈ 135 px of each is visible (cropped by the frame edges). Left column x ≈ −395…138, right column x ≈ 881…1414. | Same glass. The right column is lighter and pinker because it sits over the magenta glow. | Fully sharp: **no depth-of-field**. Their text is cut off by the frame ("…day,", "Hey Lis… are arr…", "Oh, the… I made… to unw…"). |

**Layout offsets (brick pattern):** the column stagger is about half a pitch. Left column ≈ −360, centre 0, right ≈ +356 (right orb at y 762 vs centre orb at y 406). Before the move, the centre card spans y ≈ 300–908 (the hero card is roughly centred, slightly above middle). After the move, the next card sits in the same slot and keeps drifting up.

## Timeline

Tracked with template matching on each column's orb or mic (per frame, ~30 fps). "dy" is negative when moving up.

| t (s) | What moves | From → to | Ease / duration (estimate) | Notes |
|---|---|---|---|---|
| 0.00–1.00 | nothing | — | — | Frozen frame (Pinterest buffering). Ignore. |
| 1.00 → launch | **all three columns creep DOWN** | L +4 px (→1.28), C +10 px (→1.50), R +20 px (→1.72) | ≈ 15–30 px/s, slightly accelerating | Reads as **anticipation**: the wall "inhales" before it flicks up. |
| **1.28 – 2.43** | **Left column** up | 0 → −677 px (≈ 94% of the 720 pitch) | **cubic-bezier(0.38, 0, 0.36, 0.97)** over **1.15 s** (≈ power2.inOut, slightly front-loaded) | Starts first. |
| **1.50 – 2.65** | **Centre column** up | 0 → −677 px | same ease, 1.15 s | **+0.22 s** after left. The hero card exits the top at ~2.0 s. The next card enters from the bottom at ~1.95 s. |
| **1.71 – 2.86** | **Right column** up | 0 → −677 px | same ease, 1.15 s | **+0.21 s** after centre. |
| peak of each move | — | **≈ 40 px per 30-fps frame ≈ 1200 px/s** (≈ 1.2 frame-widths/s) | Reached ≈ 0.35–0.45 s into each column's move | **Directional vertical motion blur** at peak: text smears into vertical streaks (≈ 20–30 px, roughly a 180° shutter). Blur is visible from about 1.6 s to 2.6 s. |
| ~2.45 – 4.90+ | each column's **tail** | the remaining ≈ −43 px of the pitch | Slow continuous drift, ≈ 32 px/s at 3.0 s decaying to ≈ 16 px/s at 4.8 s (≈ sine.out / expo tail over ~2.5 s) | It never fully stops inside the clip. This "alive" drift is part of the look. Fitted rms error 2.7 px for a "1.15 s bezier + linear drift ≈ 28.6 px/s" model. |

Single-curve alternative: one CustomEase over ~3.5 s that covers 0 → 0.94 by ~1.15 s and creeps to 1.0 by 3.5 s. Optionally add a small negative dip at the start for the anticipation (≈ −3% of travel). Example: `CustomEase.create("wall","M0,0 C0.06,-0.03 0.12,-0.03 0.16,0 0.24,0.5 0.3,0.86 0.36,0.93 0.55,0.975 0.75,0.993 1,1")` (estimate; tune by eye).

There is **no** change in opacity, scale, rotation or x on any element. The text does not type in: the next card's text is already there when it enters.

## Camera / 3D

- **Flat, orthographic 2D.** Card widths and corner shapes are identical at every timestamp. There is no perspective, tilt or zoom, and no camera move.
- **Parallax:** none between the columns. Their apparent separation comes only from the **time stagger** (a left-to-right "wave"). The only depth layering is the **static background behind moving glass**: the background acts as an infinitely far layer, and the cards' tint shifts as they slide across it.
- **DOF:** none. Side columns are as sharp as the centre column.
- **Motion blur:** real, vertical, proportional to speed (none at rest, strong at peak).

## Why it looks premium

1. **One pitch, perfectly aligned.** The wall moves exactly one card plus one gap, so the new card lands in the hero slot. Nothing looks "approximately there".
2. **Stagger 0.21 s left → right** turns a plain scroll into a wave or slot-machine roll. Without the stagger it reads like a phone scroll recording.
3. **Anticipation and a long tail.** A small backward creep before launch, a hard ease-in-out, and then a slow drift that never quite stops. Cheap version: linear or plain `power2.out` that hard-stops dead.
4. **Real motion blur** at ~1200 px/s. Without it, 30 fps strobing on crisp text looks like a cheap slideshow.
5. **The glass reacts to the background.** The backdrop is static and the cards blur it, so each card changes tint (pink over the glow, deep violet over the dark) as it travels. Flat semi-transparent rectangles would kill this.
6. **Restraint in the cards.** Light-weight sentence-case type, one hairline rim brightest on top, a gradient divider that overshoots the card edge, and a single glossy orb. Bold text, thick borders, drop shadows or neon glows would turn it into "AI slop".
7. **The brick offset and frame crop** make the wall feel bigger than the frame, like an endless feed. Centred, fully visible cards would look like a template.

## How to rebuild in HyperFrames

**Approach:** DOM plus CSS 2D. No Three.js or 3D transforms are needed.

Structure:
```
.stage (1080×1920, overflow:hidden)
  .bg      static gradient layer (radial magenta top-right → indigo), optional faint diagonal shaft
  .wall    3 × .col (absolute; x = −420 / 256 / 932 for 1080 wide; col offsets −383 / 0 / +383)
    .col > .card × N   (567×646, r≈34, gap 119 → pitch 765 @1080w)
  svg filter #vblur (feGaussianBlur stdDeviation="0 Y") per column, or a CSS filter fallback
```

Glass card CSS (starting values, estimates):
```css
.card{border-radius:34px;position:absolute;width:567px;height:646px;overflow:hidden;
  background:linear-gradient(170deg,rgba(255,255,255,.13),rgba(255,255,255,.06) 55%,rgba(255,255,255,.09));
  backdrop-filter:blur(48px) saturate(125%);
  box-shadow:inset 0 1px 0 rgba(255,255,255,.38), inset 0 0 0 1px rgba(255,255,255,.12);}
.card::after{content:"";position:absolute;inset:0;border-radius:inherit;
  background:radial-gradient(60% 45% at 10% 95%,rgba(255,255,255,.12),transparent 70%);}
.msg{font:300 34px/1.2 "Inter Display","Neue Haas Grotesk",sans-serif;letter-spacing:-.01em;color:rgba(236,230,245,.92)}
.placeholder{font:400 17px/1 inherit;opacity:.65}
.divider{height:1px;right:-18px;background:linear-gradient(90deg,transparent,rgba(255,255,255,.7) 85%)}
```

**Render-safe glass:** if `backdrop-filter` is slow or unreliable in the renderer, use the static backdrop trick. Pre-blur a copy of the background (`filter:blur(48px)`) inside each card and counter-translate it by the card's own stage position. The background is static, so this is exact and deterministic.

GSAP (one paused timeline, seek-safe):
```js
const tl = gsap.timeline({paused:true});
const PITCH = 765, LAND = 0.94*PITCH;           // 1080-wide values
CustomEase.create("wallMain","M0,0 C0.38,0 0.36,0.97 1,1");   // = cubic-bezier(.38,0,.36,.97)
const ANT = [5,11,21];                           // anticipation creep (px @1080w), grows L→R
cols.forEach((col,i)=>{
  const t0 = 0.28 + i*0.21;                      // launch time, relative to scene start
  tl.fromTo(col,{y:base[i]},{y:base[i]+ANT[i],duration:0.5,ease:"sine.in"}, t0-0.5) // creep DOWN
    .to(col,{y:base[i]-LAND,duration:1.15,ease:"wallMain"}, t0)                     // flick up
    .to(col,{y:base[i]-PITCH,duration:2.4,ease:"sine.out"}, t0+1.15);               // tail drift
});
```
(The anticipation offset is +4 / +10 / +20 px in the source for L / C / R. A constant +8–12 px is fine.)

**Motion blur, deterministic:** in the timeline's `onUpdate`, read each column's `y` at `tl.time()` and `tl.time() - 1/60` (seek by evaluating the tweens, or keep an analytic copy of the ease), take `v = |Δy|`, and set `stdDeviation = "0 " + min(v*0.5, 18)` on that column's `feGaussianBlur`. This depends only on time, so it stays seek-safe. A cheaper alternative is to stack 3–5 ghost copies of the column at ±v/4 offsets with low opacity.

Seek-safety: one paused master timeline, no `Math.random()`. Card contents and column order are fixed arrays, or use a seeded PRNG if you generate filler cards. No CSS transitions or `requestAnimationFrame` loops. Fonts must be loaded before the first frame.

## Reuse recipe (Raed's talking-head reels)

- **"Prompt wall" B-roll / explainer scene:** each card holds a real prompt or answer in Derja (e.g. "Ahla, chnowa n7ell lyoum?"), or a cropped screenshot of a real ChatGPT / Claude / Gemini reply. Each VO sentence triggers one scroll beat, and the new hero card is the line he is saying. Hold 1.5–2.5 s between beats; the tail drift keeps the holds alive.
- **Behind a cut-out:** put Raed's matted cut-out over the wall, covering the centre column, with the hero card offset up or right, or use 2 columns plus a peek. Darken the wall about 15% and keep the magenta glow behind his head as a natural rim light.
- **List / "5 tools" format:** one card per tool (logo replaces the orb, name plus a one-line Derja description). Scroll one pitch per item. Can be reversed (scroll down) for a "go back" moment.
- **Parameters to vary:** direction (up/down/sideways with rows), stagger 0.12–0.3 s and order (L→R, centre-out), column count (3 large or 5 small), pitch and card aspect (square for chat, 9:16 for phone screen recordings), glass tint and backdrop palette (brand colours; keep one hot glow plus one deep dark), anticipation size (0–3%), tail drift speed (0–35 px/s), motion-blur strength.
- **Keep:** light-weight type, hairline top rim, exact pitch landing, real backdrop blur, motion blur. For Arabic-script Derja, use a light Arabic sans (e.g. IBM Plex Sans Arabic 300) and right-align inside the card. Latin-script Derja can stay in the grotesk.

## Key frames

- **1.25 s**: rest layout before the move: brick offset, hero card "Hey Susanne…", glass tint over the static gradient (`ref-02_t1.25.png`).
- **1.62 s**: the left column is mid-flick, centre just launching, right still creeping down (stagger visible).
- **1.88 s**: the centre card at near-peak speed with vertical motion-blurred text; the right column has not started yet (`ref-02_t1.88.png`).
- **2.20 s**: the hero card has left the frame and the next card ("How is that new moisturiser…") rises from below; the right column is at peak blur (`ref-02_t2.20.png`).
- **2.85 s**: the main move is done and the new hero card is sharp in the slot.
- **4.50 s**: settled and drifting slowly: the final composition (`ref-02_t4.50.png`).
