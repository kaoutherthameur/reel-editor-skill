---
name: reel-editor
description: Use when editing a reel, short or TikTok for the creator's personal channel (AI / growth content, Tunisian Derja talking head) from a cleaned base video, e.g. a file in "editing now/". Covers audio enhancement, Derja transcription, colour grade, glass UI, captions, SFX and the HyperFrames build. Not for Wtide videos (Wtide brand rules never apply here).
disable-model-invocation: true
---

# Reel editor (personal channel)

Talking head that alternates with face-less explainer frames, premium light acrylic / liquid glass UI, beautiful Derja captions, one light background, every move right → left. HyperFrames build (Three.js only for 3D heroes).

**Full spec:** `docs/2026-10-06-reel-editor-design.md`. Where this file and the spec disagree, this file wins (the spec still carries some pre-v3 values).
**Worked examples:** `template/reference-demo-v3.html` (14 s, approved) and `template/reference-prompt-library.tpl` + `template/build-example.py` (first full reel, 44.5 s, approved 2026-10-07: wall, wheel, real results page, prompt swap, liquid dock). Read them before building.

Load `/hyperframes` → `/hyperframes-core` (composition contract) and `/hyperframes-cli` before writing HTML. This skill says WHAT to build; those skills own HOW.

All commands run from `Content-Creator/`. Below, `$SK` stands for `.claude/skills/reel-editor` and `$EP` for `videos/<slug>`; write the real paths (each shell call starts fresh), or prefix the call with `SK=.claude/skills/reel-editor EP=videos/<slug>;`.

## Setup (first run on a new machine)

Run `python3 $SK/scripts/setup.py --check`. Anything MISSING → **ask the creator before doing it**, never install or download on your own:
- **API keys** (Auphonic = voice enhancement, HeyGen = SFX search, both optional-per-feature): tell the creator to run `python3 $SK/scripts/setup.py --keys` in their own terminal (key typed hidden, saved to `$SK/.env`, gitignored). Never ask for the key in chat, never write it in a file you commit, never echo it.
- **Whisper Tunisian model** (3.1 GB download, CC-BY-NC non-commercial, + ~1 GB venv, needs ~5 GB free RAM to run): state size and license, wait for a clear yes, then `python3 $SK/scripts/setup.py --whisper --yes`.
- Declined → run prep with `--skip-auphonic` / `--skip-whisper` and say what is lost (no transcript = no editing). prep.py exits 4 if setup is missing.
- Also needs `ffmpeg`, Node, and the HyperFrames skills.

## Workflow and checkpoints

| # | Step | Tool / output |
|---|---|---|
| 0 | First run only: `python3 $SK/scripts/setup.py --check` (see Setup) | keys + Whisper model |
| 1 | Prep: folder, audio, Auphonic ∥ Whisper | `python3 $SK/scripts/prep.py "<video>" --slug <slug>` |
| 2 | Fix transcript by hand | `transcript.fixed.json`, `transcript.md`, `transcript.changes.md` |
| 3 | Colour grade + matte + pop-out layer | one look file from `looks/` (default `pop`), then the alphamerge command below |
| ✔ | **Checkpoint 1**: durations, word count, fixes/flags count | short message |
| 4 | Edit plan | `edit-plan.md` (one row per beat) |
| 5 | Asset requests | `assets-needed.md` |
| 6 | SFX plan from the house kit | `sfx-plan.md` |
| ✔ | **Checkpoint 2**: creator approves plan, assets, SFX and delivers assets | wait |
| 7 | Build, check, snapshot | `$EP/index.html` + copies of `kit/` and `template/hyperframes.json` |
| ✔ | **Checkpoint 3**: preview → approval → render → ffprobe | `renders/<slug>.mp4` |

### 1. Prep
- **Before running, tell the creator:** "Close Chrome, Blender, Docker and other heavy apps; Whisper needs ~5 GB free." prep.py checks it too: exit 3 = RAM gate (relay and wait), 1 = Whisper failed (stop, no editing without a transcript), 2 = Auphonic failed (build with `audio/raw.wav`, say so). `--dry-run` shows the plan.
- Composition audio = `audio/voice_studio.wav` (or `audio/raw.wav` if Auphonic failed).

### 2. Transcript fix (manual, never `scripts/asr/fix-french-terms.py`)
Read the whole `transcript.raw.json`. Restore French/English words that Whisper wrote in Arabic letters to Latin script from sentence context (شات جي بي تي → ChatGPT, البرومبت → le prompt). Keep every word's timing, change only `text`; merge chunks of one split foreign word (first start, last end). Derja stays verbatim. Unsure → flag in `transcript.changes.md`, never guess. The creator does the final pass later.

### 3. Grade: pick ONE look and read only its file
| Look | File | When |
|---|---|---|
| **pop** (default) | `looks/pop.md` | nothing else asked; bright, clean, airy |
| **warm-falloff** ("M") | `looks/warm-falloff.md` | the creator asks for warmer / moodier / more cinematic, or filmed with a side light |

Each look writes `graded.mov` + `matte.mov` in `$EP`. Then the pop-out layer, run inside `$EP`:
```bash
ffmpeg -i graded.mov -i matte.mov -filter_complex "[1]format=gray,scale=1080:1920[m];[0][m]alphamerge,format=yuva420p" -c:v libvpx-vp9 -b:v 6M -auto-alt-ref 0 -row-mt 1 -deadline realtime -cpu-used 8 subject.webm
```

### 4. Edit plan
`edit-plan.md` = one table, one row per beat: time range · words (Derja) · scene type · on-screen elements (with real asset ids) · transition in · camera (hold / push / pull / punch / reset, with purpose and times) · library effect (if any) · SFX roles. Camera defaults to **hold**. `sfx-plan.md` = one row per cue: event time · on screen · kit role · ID · volume · data-start.

Scene types:
- **TALK**: face full frame, caption strip.
- **TALK+UI**: face + 1–3 small acrylic elements tied to the words.
- **SPLIT (pop-out)**: room in a bottom card (rig scale ~0.8, `clip-path: inset(... round 56px)`), `subject.webm` layered above so the head breaks out over the card; stage above for UI; captions switch to kinetic mode. Default when a beat names tools, numbers or steps but the face stays.
- **EXPLAIN**: no face, deep green scene (`.bg-deep`), real screenshots / images in glass, library effects.
- Hook in the first 2 s: display type (Anton for Latin, Alexandria 900 for Arabic) shown directly, no glass box; can sit behind the head. No captions during the hook.
- Review attention around every ~3 s, without forcing a change: speech, expression, gestures, captions, UI or footage may already carry the beat. A useful still hold can last longer. An EXPLAIN starts about every 8–12 s (start to start).
- **Selective camera reframing:** on suitable TALK beats, use a gentle push/pull and an occasional instant framing reset or punch-in at a meaningful word / sentence boundary. Read [references/camera-reframing.md](references/camera-reframing.md) when planning or building these moves. Keep quiet holds between them; avoid an automatic zoom loop. In TALK+UI, use only when the UI leaves attention and space for it.
- Leaving SPLIT or EXPLAIN always goes through `Reel.conveyor`: the old scene exits left, the face comes back FULL from the right. Never un-shrink the pop-out in place.
  - SPLIT → EXPLAIN → TALK (demo): reset the rig to FULL with `tl.set` while it is off-screen during EXPLAIN.
  - SPLIT → TALK directly: add a second FULL face layer `#faceB` (`graded.mov`, same `data-start`, own track, hidden in CSS). `Reel.conveyor(tl, [rigMove, "#split"], ["#faceB"], at)`; at the end of the move `tl.set` the rig back to FULL at x 0 and hide `#faceB` in the same frame (identical picture, invisible swap). Not yet used in a real reel: snapshot the frames around the swap.

### 5. Assets: real content only
Ask, never invent UI. Three kinds: **SCREENSHOT** (websites only), **GENERATE** (the creator uses **ChatGPT**: give a ChatGPT-ready prompt + aspect + filename, and the path of a reference image to upload when the result must match an existing one), **FROM YOU** (logos, desktop apps, terminal / Claude Code, Finder, phone screens, screen recordings). Something that only exists after this build (e.g. "the video you're watching") → use a frame of the source video or ask for an older example. Download clean source images; never crop from screenshots with the cursor or account UI.
- **Page screenshots:** `node $SK/scripts/capture_page.mjs "<url>" <out.png> --dismiss "<popup button text>" --rect "<selector>"` (headless, logged out, 2x, prints element boxes for aligning taps / rings / lenses). The browser pane is low-res; the creator's Chrome shows their account.
- **Platform demo recordings (Claude records):** drive the creator's Chrome with the extension and record the screen with `ffmpeg -f avfoundation -framerate 30 -capture_cursor 0 -i "<screen idx>:none"` (stop with SIGINT; `screencapture -v` loses the file when interrupted). Needs the creator's Screen Recording permission. Confirm credit-spending actions (Generate) are wanted; crop the debugging banner, blur avatar / credits. New voice lines: `template/splice_voice-example.py` (stumbles cut, pace matched with `atempo`).
- **Images and videos from a site:** read the `img`/`video` `src` in the creator's Chrome (logged in is fine for reading) and download the full-size CDN file. Video URLs often appear only in the item's detail view.

### 6. SFX: house kit `assets/sfx/kit/kit.json`
Map each on-screen event to a kit role and copy the wav into `$EP/assets/sfx/`. kit.json defines, per role, what the event moment is, the volume, and per sound the `hit` and duration: `data-volume` = kit volume × `voice_studio_gain` (1.8) with the Auphonic voice. `data-start = event_time − hit` (negative → 0); trim `data-duration` so no cue runs past the end. A kit role missing for an event (e.g. an end-card CTA) → HeyGen search + creator approval. One `<audio id="sfx-NN-<id>">` per cue; tracks 0–1 video, 2 voice, 3+ SFX. The demo's inline `<!-- hit -->` comments are approximate; kit.json is the source. No sound on captions. Event the kit lacks → search HeyGen (`python3 $SK/scripts/heygen/sfx.py "<query>" -d`), loudnorm I=−20, propose before using. HeyGen only, no synthetic sounds.

### 7. Build
Copy `kit/` and `template/hyperframes.json` into `$EP`. Wire `graded.mov` (never the raw source), `subject.webm`, voice, transcript, assets. Start from the structure of `template/reference-demo-v3.html` (layers: bg → rig with room card + hook + subject → split stage → explain → glass canvas → captions → audio).

Build only the camera moves recorded in the edit plan; follow `references/camera-reframing.md` for separate footage transforms, room/subject alignment, and reset boundaries. Camera motion does not require an SFX cue.

Captions: strip mode (groups of 2–4 words, one line; split a group that wraps) in TALK, TALK+UI and EXPLAIN; kin mode (1–3 words, ~100–120 px, default `top` 160) in SPLIT; none in the hook. Bordo-mark the word that carries the beat (tool name, number, result), at most one per group. A Latin phrase of several words inside an Arabic line ("ad for hat") must be ONE caption word, or the bidi order reverses it.

| Kit piece | Use |
|---|---|
| `theme.css` | palette tokens, fonts, `.bg` `.bg-grid` `.bg-vignette` `.bg-deep`, `.mk` marker |
| `glass.css` | `.glass` acrylic (`.plain` no corner accents, `.deep` on green), chip, notif, stat, caption strip |
| `conveyor.js` | `Reel.conveyor(tl, outs, ins, at, {grid})` scene change; `Reel.enter` / `Reel.exit` / `Reel.drift` |
| `captions.js` | `Reel.captions(tl, host, groups, {mode:"strip"\|"kin", top})` from `transcript.fixed.json` word times |
| `liquid.js` | `Reel.liquid({canvas, size, frames, shapes, t0, t1})` metaball liquid glass over footage. Needs the footage behind the canvas as frames, one folder per glass window: `ffmpeg -ss <t0> -t <t1−t0> -i graded.mov -vf "scale=1080:1920,crop=<w>:<h>:<x>:<y>" frames-<name>/f%04d.jpg` (canvas at the same x,y,w,h; frame 1 = t0). Register `glass.ready` in `window.__hf.buildReady` |

**Motion library** (`references/motion/README.md`): ref-01 glass dock, ref-02 card wall, ref-03 word chain / card wheel, ref-04 3D glass folder, ref-05 cover-flow carousel. Use one only when the spoken beat fits, at most one per scene, implement its **full** motion (steps, reveals, holds) with real content, re-skinned in our palette.

Verify: `npx hyperframes check` (0 errors; text behind `#subj` in the hook and contrast sampled mid-fade are known false positives), snapshot every beat midpoint and read it (legibility, safe zone x 60–960 / y 220–1500, caption text, direction rule). Then a preview render for the creator (listen to SFX vs voice balance here), approval, `npx hyperframes render -o renders/<slug>.mp4`, ffprobe (1080×1920, 30 fps, audio stream).

If using camera reframing, also inspect the frame before/at/after each instant cut and each handoff to SPLIT or a conveyor. Watch the moves at normal speed: check stable eye position, matched room/subject layers, readable overlays, and enough quiet holds.

## Style rules (approved)
- **Palette:** paper `#F7EDE2` / cream `#F5DABF` ~70%, green `#0F3D3A` ink + deep scenes ~20%, bordo `#6C151E` accent only ~10% (marker, pill, corner accents). Never copy a reference's colours.
- **Type:** IBM Plex Sans Arabic 500; 700 only for one accent word per line. Heavy bold everywhere = AI slop.
- **Glass:** light/white only, no dark edge shading. Liquid glass only over imagery (face, screenshots, green scene); acrylic on the empty grid.
- **Motion:** scene transitions stay smooth ~1 s `power2.inOut`, never fast or linear. Scenes and elements enter from the right, leave to the left. In-scene moves may follow a library reference. Planned footage reframing may use a gentle continuous push/pull or an instant framing cut; this exception does not replace the conveyor or animate captions/UI with the camera.
- **Captions:** Derja in Arabic script, FR/EN terms in Latin, at most one bordo-marked word per group.

## Content rules (creator feedback)
- When the creator names visual things (ads, posters, images, videos), show real examples of them, not just the words.
- When the creator says "كيما تراو" (as you see) about a site, the real page is on screen at that word.
- Show the payoff (the real generated result) on screen; a prompt → swap word → Generate → result sequence works well.

## Common mistakes
| Mistake | Fix |
|---|---|
| Library effect frozen (e.g. carousel never steps) | Implement every step; fetch the extra real data it needs |
| Invented custom UI instead of real screenshots | Ask for assets or capture them |
| Abstract effect where the speaker says "as you see" (كيما تراو) about a site | Show the real page screenshot at that word; library effects can lead into it |
| `<video>` sampled into WebGL in headless render | Pre-extract a frame sequence (`ffmpeg -ss … -vf crop=… frames/f%04d.jpg`) |
| Element hidden with `tl.set(…, 0)` flashes on seek | Hide in CSS, reveal in the timeline; `immediateRender:false` on repeated `fromTo` |
| CSS `transform` and GSAP on the same property | Position with layout/inset; let GSAP own transforms |
| Grade lifts or sharpens only the face, or splits white balance | One global grade, small exposure gap only |
| SFX started at the event time | Start = event − `hit`, or the hit lands late |
| A second `.html` with `data-composition-id` in the episode folder (e.g. a source template) | Name templates `.tpl`; `check` fails with `multiple_root_compositions` |
| Relative tween (`x: "-=15"`) while another tween writes the same property | Absolute values (`gsap_relative_value_second_writer`) |
| Screen recording cut on its raw timestamps | `avfoundation` recordings are VFR: convert to CFR 30 fps first, cut frame-exact, 0.2 s crossfades between steps (`template/cut_rec-example.py`) |
| Camera hard-cuts on a screen recording | Camera = smooth GSAP moves (~0.5 s) centred on each step boundary; a camera cut a few frames off the content cut reads as a jump |
| Talking-head zoom repeats every ~3 s, or competes with a UI reveal | Default to hold; place reframing only on a meaningful beat. Screen-recording camera rules still apply |
| Zoom fights rig scale, shifts captions, or separates the matte from the room | Use dedicated footage transforms; move room and subject identically; return to neutral before SPLIT / scene handoffs |
| SFX loudness judged by the mix's mean volume | The voice dominates the mean; compare SFX moments or the difference between two renders |
