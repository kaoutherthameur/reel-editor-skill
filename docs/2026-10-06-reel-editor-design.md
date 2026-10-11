# reel-editor — design spec

Date: 2026-10-06 · Updated 2026-10-07 (v3 demo approved: palette, grade pop, acrylic + liquid glass, motion library, SFX kit) · Agent entry point: `SKILL.md`

## 1. Purpose

One skill that edits every reel for the founder's **personal channel** (AI / growth content, Tunisian Derja) in one consistent style. Not for Wtide: Wtide brand rules (cream, cobalt, orange point, Archivo/Readex) do not apply here.

Input: a base video the founder already cleaned (cuts done, vertical, e.g. `editing now/cuts.mov`, 2160×3840, 30 fps).
Output: an edited 1080×1920 reel mixing talking head, glass UI, captions and explainer scenes, rendered with HyperFrames.

## 2. Approach

**A — pipeline scripts + reusable visual kit.** Scripts do the deterministic prep (audio, enhancement, transcription). The kit holds every reusable visual piece (background, glass, conveyor transition, captions, components, 3D helper) and is copied into each episode. Per video, the agent writes an edit plan and composes scenes from the kit; only EXPLAIN scenes are designed per topic.

Rejected: B (instructions only — style drifts), C (JSON-to-video generator — too rigid for custom explainer UI).

## 3. Folder layout

```
Content-Creator/.claude/skills/reel-editor/
  SKILL.md                      workflow + checkpoints (the agent's entry point)
  docs/                         this spec
  scripts/
    prep.py                     steps 1–4 + 6 of the pipeline (below)
    grade.swift                 step 6b: subject-aware colour grade + matte
    pin_fetch.sh                download Pinterest pins as style references
  kit/
    theme.css                   tokens: colours, font, sizes, safe zones
    glass.css                   glass card material + variants
    conveyor.js                 the transition system
    captions.js                 caption engine (groups, reveal, bordo marker)
    liquid.js                   WebGL liquid glass (metaball split/merge)
    fonts/                      Plex Arabic 500/700, Anton, Alexandria (local, no network at render)
    (planned: three-glass.js, components/*.html, library effects as functions)
  template/                     reference-demo-v3.html (approved worked example) + hyperframes.json
  assets/sfx/kit/               house SFX kit (18 HeyGen clips + kit.json: event -> ID -> volume -> hit)
  references/                   Pinterest refs, contact sheets, font comparison

Content-Creator/videos/<slug>/  one folder per episode
  source.mov  graded.mov  matte.mov  audio/  assets/  renders/
  transcript.raw.json  transcript.fixed.json  transcript.md  transcript.changes.md
  edit-plan.md  assets-needed.md  sfx-plan.md
  index.html  (+ kit copy)
```

## 4. Pipeline

### Step 1–4: prep (`scripts/prep.py <video> [--slug name]`)
1. Create `videos/<slug>/`, copy or link the source video.
2. Extract audio to `audio/raw.wav` (ffmpeg, mono, 48 kHz).
3. RAM gate: measure free memory. If under 5 GB, stop and print a request to close Chrome, Blender, Docker and other heavy apps; the agent relays it to the user and waits. `--force` overrides.
4. In parallel:
   - **Auphonic**: `tools/auphonic/enhance.py audio/raw.wav --preset studio --out audio/`; prep.py renames the result to `audio/voice_studio.wav`. Cloud job, light on RAM. Extraction keeps full bit depth (no gain added) since enhance.py normalises itself.
   - **Whisper Tunisian**: `models/asr-env/bin/python models/transcribe-tunisian.py audio/raw.wav --out transcript.raw.json` (word timestamps). Uses raw audio, so it does not wait for Auphonic.
   Either failing does not cancel the other; the script reports both results.

### Step 5: transcript fix (agent, manual — no script)
- The agent reads the whole `transcript.raw.json` and uses sentence context to restore French/English words written in Arabic letters to Latin (e.g. شات جي بي تي → ChatGPT, البرومبت → le prompt).
- Word timings are kept: only `text` changes. If ASR split one foreign word into several chunks, merge them (first start, last end).
- Derja stays verbatim. Clear mistranscriptions are fixed; uncertain words are flagged, never guessed.
- Outputs: `transcript.fixed.json` (feeds captions), `transcript.md` (readable), `transcript.changes.md` (every change with timestamp + flagged words) for the founder's later pass.
- `models/fix-french-terms.py` is not used.

### Step 6: audio swap
Final audio for the composition is `audio/voice_studio.wav`. If Auphonic failed, fall back to `audio/raw.wav` and say so.

### Step 6b: colour grade (`scripts/grade.swift <source> <out_dir>`)
Problem it fixes (measured on `editing now/cuts.mov`): wall brighter than the face (luma 169–180 vs 133), dull beige-grey wall with busy posters, flat contrast (p99 208/255), flat slightly yellow face light; the wall's off-white also blends into the kit's grid background.

Method: subject-aware grade using Apple Vision person segmentation (`VNGeneratePersonSegmentationRequest`, accurate, sequence-smoothed; runs on the Neural Engine, no RAM gate needed). Builds on `tools/relight.swift`.
- **v3 rule (approved look "pop"):** ONE global grade for the whole image (same white balance, same S curve, light vibrance, vignette 0.32) plus a small, wide-feathered exposure gap: subject +0.12 EV, room −0.5 EV, room saturation 0.90, room blur 5 px. Never split white balance between person and room, never lift shadows or sharpen only the person (v1/v2 did and looked "very very artificial"). Look "natural" is the softer alternative. Values live in `grade.swift`.
- **Global:** gentle S tone curve, identical on every video (parameters live in one place so all reels match).
- **Fade on non-face frames:** like relight.swift, the effect scales with person coverage so screen recordings are left untouched.
- Outputs: `graded.mov` (H.264, Rec.709) and `matte.mov` (subject mask) so the composition can place elements behind the subject when useful.
- Prototype and comparison: `references/grade/` (options 0–3; 3 "grid world" and 2 "darker room" were rejected for now).

Verify: snapshot 4–6 frames incl. fast hand moves; check no halo, no edge flicker, skin natural, face brighter than the wall.

**Checkpoint 1** — short summary to the user (durations, word count, number of fixes/flags). Detailed transcript check can come later.

### Step 7: edit plan (`edit-plan.md`)
Transcript split into beats (one idea each). One table row per beat: time range · words · scene type · on-screen elements · transition · SFX cue · assets needed.

Scene types:
- **TALK** — face FULL, captions.
- **TALK+UI** — face (FULL or CARD) + 1–3 small glass elements tied to what is said.
- **SPLIT** — face kept while animated elements play (ref: `references/layouts/split-ref-instagram.webp`). Room in a card on the bottom ~38% of the frame, the subject cut out and breaking out above the card's top edge (pop-out). The top ~55% is the stage on the grid: logos, icons, glass components, and the caption becomes big kinetic text there (no caption strip over the face). The default when a beat names tools, numbers or steps but the face should stay.
- **EXPLAIN** — no face; scene built on the grid from glass UI, screenshots in glass device frames, lists, comparisons, 3D only when it explains.

Pacing rules:
- Hook in first 2 s: big title over the face.
- Review attention around every ~3 s; meaningful speech, expression, gestures, captions or existing UI may carry the beat without another effect. Longer still holds are valid. Optional talking-head reframing follows `../references/camera-reframing.md`; never force a punch-in, UI entry or EXPLAIN just to meet a timer.
- An EXPLAIN scene roughly every 8–12 s.

### Step 8: asset requests (`assets-needed.md`)
Checklist, three kinds:
- **SCREENSHOT** — agent captures in the user's Chrome (URL, state, crop). Ask before opening pages logged into the user's accounts.
- **GENERATE** — ready-to-paste prompt for the user's image generator, with size, aspect, transparent or not, and target filename.
- **FROM YOU** — logos, photos, screen recordings.
Previews may use placeholders; final render waits for every asset.

### Step 9: SFX plan (`sfx-plan.md`)
- One row per cue: time · event · `tools/heygen/sfx.py` query · top 3 candidates (name, duration, `peak_offset`).
- **House kit (approved 2026-10-07): `assets/sfx/kit/kit.json`.** HeyGen only, no synthetic sounds. Map each on-screen event to its kit role and reuse the file; search HeyGen only for event types the kit lacks, then propose them before adding.
- Kit roles: video-start S1 (.07, riser from 0) · hook-text-in A1 (.14) · hook-word-lands H2 (.16) · pill-tag-pop P2 (.22) · full-to-popout A4 (.20) · card-appears P5 (.20) · ui-tap T1 (.18) · in-scene-swap A1 (.16) · folder-opens G6 (.08) · items-rise D6 (.16) · conveyor A2 (.20) · carousel-reveal SQ8 (.22) · typing T4 (.10–.12) · carousel-step A3 (.16) + T1 on landing · glass-appear SQ1 (.24) · glass-split SQ3 (.22) · glass-label T2 (.14) · glass-merge SQ9 (.20) · glass-pop-away P4 (.22).
- `data-start = event_time − hit`. Clips are loudnorm I=−20; mixed low under the voice; no inserted silence. No sound on captions.

**Checkpoint 2** — user approves / edits edit plan, asset list, SFX list, and delivers assets.

### Step 10: build
- Copy `kit/` and `template/hyperframes.json`, follow the structure of `template/reference-demo-v3.html`, wire `graded.mov` (never the raw source), audio, transcript, assets.
- Compose with HyperFrames (`/hyperframes-core` contract, `/hyperframes-cli` for check/snapshot/preview/render). Three.js through the HyperFrames adapter when needed.
- Verify: `npx hyperframes check` 0 errors; snapshot each beat midpoint and inspect legibility, safe zones, caption correctness, direction rule.

**Checkpoint 3** — preview for the user → approval → render `renders/<slug>.mp4` → ffprobe check (duration, 1080×1920, audio stream).

## 5. Visual kit

### Canvas
1080×1920, 30 fps. Safe zone x 60–960 (right 120 px = platform buttons), y 220–1500. Caption band y ≈ 1180–1460.

### Background
Paper `#F7EDE2`, 44 px grid `rgba(15,61,58,.07)`, soft vignette. Slow constant drift. Parallax: on each conveyor transition the grid shifts ~120 px left.

### Palette (approved 2026-10-07, replaces mint)
- **Bordo `#6C151E`** — accent only (~10% of screen): keyword marker (cream text on bordo), hook pill, acrylic corner accents.
- **Green `#0F3D3A`** — ink on light scenes, and the deep background of EXPLAIN scenes (~20%).
- **Cream `#F5DABF`** — text on bordo/green, caption fills. **Paper `#F7EDE2`** — large light backgrounds (~70%).
- Keep bordo rare so red + green never reads as Christmas. Note: base is close to Wtide cream; Wtide stays distinct through cobalt/orange.

### Typography weights
Regular/medium by default; bold only for one accent word per line. Heavy bold everywhere reads as AI slop. Hook may use a display face (Anton / Alexandria) different from captions.

### Liquid glass (kit/liquid.js)
WebGL shader: rounded-box SDF shapes joined by smooth union (metaball "Zac" merge/split), lens refraction at the rim, light chromatic fringe, light frost, white rim, specular from top-left, soft light shadow. **Light/white only — no dark edge shading.** Use only over imagery (face, screenshots, green scene); on the empty grid use acrylic. Background comes from a pre-extracted frame sequence (headless render cannot read video into WebGL).

### Motion library
`references/motion/ref-0N.md` — frame-by-frame analyses of approved Pinterest references (card swipes, envelope items, screenshots on glass cards in 3D, 3D card stacks behind the speaker). Reuse when the beat fits; each entry lists assets needed.

### Talking-head states
- **FULL** — fills the canvas.
- **CARD** — scale 0.86, radius 48, bright 1.5 px edge, soft long shadow; grid visible around it.
- **SPLIT ("pop-out")** — as built in the demo: rig scaled ~0.8, room clipped to a bottom card (`clip-path: inset(995px 0 0 0 round 56px)`), soft shadow on its top edge. The card shows the graded room only; the subject (from `matte.mov`) is layered **above** the card so the head and shoulders break out over its top edge onto the grid (ref `split-ref-instagram.webp`, second frame). Stage elements sit above, never overlapping the head. Entering SPLIT from FULL: the face scales and crops down into the bottom card (anchored bottom, no vertical slide) while the stage items enter from the right; leaving SPLIT follows the normal conveyor.
- **PIP** (optional) — small glass-framed circle or rounded square during EXPLAIN.

### Conveyor transition (signature, ~1.0 s, power2.inOut — see kit/conveyor.js; the steps below are the original sketch)
1. FULL → CARD (0.25 s, power2.inOut).
2. Outgoing scene x 0 → −1150, incoming x +1150 → 0, same ease (power3.inOut), overlapped, ~0.45 s. Horizontal motion blur peaks mid-move. Grid parallax −120 px.
3. Incoming elements stagger ~60 ms, all from the right.
4. Return to face: CARD enters from the right, then expands to FULL.

**Direction rule (global):** everything enters from the right and exits to the left — scenes, elements inside scenes, caption groups. No fade-only entrances. Exception: in-scene moves of a motion-library effect follow the reference (e.g. a vertical card scroll).

### Glass material
- (v1 white frosted fill was replaced; see next line.)
- Material is now **acrylic** (v2): warm cream body, bright refracted rim, light streak, bordo corner accents, real shadow. `.glass.deep` variant for the green scene.
- Over footage the blur shows the face behind: strongest glass look, use it.

### Components (`kit/components/`)
chip (icon + label) · stat card (count-up) · notification (app icon + title + line) · checklist (bordo ticks) · glass device frame (phone / browser) around screenshots · quote card · progress bar · cursor + click ripple. Icons and brand logos resolved through `/media-use`.

### Captions
- Font: IBM Plex Sans Arabic 500 (Latin terms in the same family), 700 only for the accent word, 66–72 px, green ink on a cream acrylic strip in the caption band.
- Derja in Arabic letters, French/English terms in Latin, from `transcript.fixed.json` timings.
- Groups of 2–4 words. At most one bordo-marked keyword per group.
- Enter: words right → left, 40 ms stagger, small rise + blur 6 → 0. Marker swipes in behind the keyword after it lands. Exit: group slides left + fades.
- Hook title: display type shown directly, no box: Anton (Latin) / Alexandria 900 (Arabic), max 2 lines; may sit behind the head.
- In SPLIT scenes captions switch to kinetic mode: 1–3 words at a time, ~100–120 px, centred on the top stage, ink on the grid with the same bordo marker; words still enter from the right.

### 3D
Three.js only for hero objects (glass icon, logo, explanatory shape), max 1–2 per video. Physical glass material (transmission) with warm cream rim light. Driven by the composition timeline (seek-safe, deterministic).

## 6. References
`references/pinterest/` — glass, bg, captions pins (images + MP4s, `index.tsv` per folder, contact sheets `_sheet-*.jpg`). Chosen: bg #2/#5/#9 (soft light grid); glass #0, #8, #14, #20; caption ref pin 631770654021238932 (faseiela). Font comparison: `references/_font-compare.png`.

## 7. Error handling
- RAM gate refuses Whisper under 5 GB free (unless `--force`).
- Auphonic failure → fall back to raw audio, reported.
- Whisper failure → stop at checkpoint 1 with the error; no editing without a transcript.
- Missing assets → placeholders in preview, final render blocked.
- `hyperframes check` errors block render.

## 8. Testing
- `prep.py --dry-run` prints planned commands without running them.
- First real run: `editing now/cuts.mov` (44.5 s) end to end.
- Kit test: a short test composition (TALK → conveyor → EXPLAIN with 2 components → back to TALK, captions on) rendered and inspected frame by frame before the first full episode.

## 9. Out of scope (later steps the user will add)
Extra pre-editing steps for audio and caption extraction beyond the above; 4:5 / 16:9 variants; music bed.
