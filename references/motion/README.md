# Motion library

Reusable motion ideas studied frame by frame from references the creator picked on Pinterest. Each `ref-0N.md` holds the exact timeline (eases, durations, staggers), materials, camera, rebuild plan and reuse recipe; stills sit next to it.

## Rules
- **Copy the movement and the UI structure, never the colours.** Every effect is re-skinned in our palette: bordo `#6C151E` (accent only), green `#0F3D3A` (ink / deep scene), cream `#F5DABF`, paper `#F7EDE2`. Reference palettes (violet, coral, magenta, indigo, blue) are ignored.
- Use an effect only when the spoken beat fits it. Never as decoration. One library effect per scene at most.
- Content inside cards/folders/wheels is real: screenshots, screen recordings, AI images, logos. Ask the creator for assets or capture them in Chrome; no invented UI.
- Text inside these elements: medium/regular weight, sentence case; bold only for one accent word.
- Glass: light/white only, no dark edge shading; frosted panels only over imagery or the deep green scene.
- Implement the effect's full motion as analysed (steps, reveals, holds). Never freeze it to save work; if a step needs more content (e.g. each card's own prompt), capture it.
- Assets: download clean source images; never crop from screenshots that contain the mouse cursor or the creator's account UI.
- Direction rule: scene-to-scene transitions stay right → left. In-scene moves may follow the reference (e.g. a vertical scroll) when the effect needs it.

## Index

| Ref | Effect | Core motion | Fits when the speaker… | Assets needed |
|---|---|---|---|---|
| [ref-01](ref-01.md) | Liquid glass dock + profile card collapse | Glass capsule springs open in width (~1.0 s, ~7% overshoot); icons pop in (back.out, 0.07 s stagger); pointer dot glides and magnifies each icon ~1.16×; card "Follow → Following" squish, then card collapses into an avatar tile with a slight 3D yaw/roll | lists apps/tools, mentions following/subscribing, introduces a person or account | app icons/logos, profile screenshot or avatar |
| [ref-02](ref-02.md) | Staggered glass card-wall scroll | 3 brick-offset columns; each dips 4–20 px then flicks up one card pitch in 1.15 s (left → centre → right, 0.21 s apart), motion blur at ~1200 px/s, slow decaying drift; static backdrop glow re-tints cards as they pass | shows many prompts / chat answers / examples, "there are hundreds of…" | text of prompts/answers, optional avatars |
| [ref-03](ref-03.md) | Word chain + hand-drawn marks, arrow wipe, card wheel, magnifier | Words build one by one with hand-drawn circles/underlines; giant arrow wipe reveals a word letter by letter; ~12 portrait cards on a huge wheel (centre ~90% down) spin ~41° then ~14° with settle; search bar types over it; magnifier lens fills to reveal a word | searches for something, browses a collection, reveals "the one" result | screenshots / AI images for the wheel cards |
| [ref-04](ref-04.md) | 3D glass folder reveal | Frosted folder swings toward camera (~1.46× scale, yaw −5°→+18°, roll +6°, front pocket tips ~22°, inOut, no bounce); 3 cards fan out (right, centre, left, ~0.1 s apart), sharpen as they clear the glass; 0.9 s hold; exact reverse | opens a collection, "inside this pack/folder/site you find…" | 3 screenshots (cards), folder label |
| [ref-05](ref-05.md) | 3D cover-flow card carousel | Side cards slide out from behind the centre card (expo.out ~0.6 s); then every ~2.3 s a step: side card swings to centre and grows 0.78→1, z-swap mid-move, power3.inOut ~0.55 s + small settle; long still holds | names items one by one ("3 tools…", prompt → result) | 3–5 portrait screenshots/images |

## Re-skin notes (our palette)
- Deep scenes (ref-02 gradient, ref-04 dark indigo) → our deep green radial (`.bg-deep`) with faint cream grid; glass tinted cream, not lavender/violet.
- Flat 2D brand pieces (ref-03 violet/coral) → paper background, green ink, bordo for the hand-drawn marks and the magnifier fill.
- Rim lights and glows → warm cream/white, never coloured neon.
