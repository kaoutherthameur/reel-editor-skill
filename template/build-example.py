#!/usr/bin/env python3
"""Assemble index.html from index.src.html: words, card wall, wheel, SFX tags (kit timing)."""
import json, re
from pathlib import Path
H = Path(__file__).parent
src = (H / "index.tpl").read_text()
kit = json.loads((H / "../../.claude/skills/reel-editor/assets/sfx/kit/kit.json").read_text())
END = 44.5

words = json.loads((H / "transcript.fixed.json").read_text())["words"]
W = json.dumps([[round(w["start"], 2), w["text"]] for w in words], ensure_ascii=False)

# ---- card wall (ref-02): 3 brick columns, pitch 660, real images + videos
PITCH = 660
cols = {
  "L": ["img02", "h20", "img04", "v05", "h21", "img06"],
  "C": ["img01", "mask", "v06", "v01", "h23", "img08"],
  "R": ["h07", "img03", "cat", "h19", "img09", "man"],
}
base = {"L": -690, "C": -360, "R": -30}
vid = {"v01": "vid/v01.mp4", "v05": "vid/v05.mp4", "v06": "vid/v06.mp4"}
img = lambda n: f"assets/pg/hat/{n}.jpg" if n.startswith("h") else f"assets/pg/{n}.jpg"
play = '<div class="play"><svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z" fill="#F5DABF"/></svg></div>'
wall, track = [], 90
for c, items in cols.items():
    cards = []
    for k, n in enumerate(items):
        top = base[c] + k * PITCH
        if n in vid:
            cards.append(f'<div class="wc" style="top:{top}px"><video id="w{n}" src="assets/pg/{vid[n]}" muted playsinline data-start="17" data-duration="3.9" data-track-index="{track}"></video>{play}</div>')
            track += 1
        else:
            cards.append(f'<div class="wc" style="top:{top}px"><img src="{img(n)}" alt="" /></div>')
    wall.append(f'<div class="col" id="col{c}">' + "".join(cards) + "</div>")

# ---- card wheel (ref-03): 12 search results, OLD MONEY (h01) at index 6 lands on top after the 2nd spin
wheel_items = ["h03", "h04", "h17", "h21", "h23", "h18", "h01", "h02", "h20", "h05", "h29", "h34"]
wheel = []
for i, n in enumerate(wheel_items):
    th = (i - 5) * 17.5
    wheel.append(f'<div class="wh" data-th="{th}" style="z-index:{i + 1}"><img src="assets/pg/hat/{n}.jpg" alt="" /></div>')

# ---- SFX: approved demo cues (0-14 s) kept verbatim, then kit-timed cues
tpl = (H / "../../.claude/skills/reel-editor/template/reference-demo-v3.html").read_text()
demo = re.findall(r'(    <audio id="sfx-\d+-\w+" [^\n]*)', tpl)
events = [  # (event time, role, note)
  (14.75, "pill-tag-pop", "link in bio"),
  (15.75, "card-appears", "home page in"),
  (15.9, "conveyor", "to EXPLAIN 2"),
  (16.3, "ui-tap", "tap Prompt Gallery"),
  (17.3, "in-scene-swap", "home -> card wall"),
  (17.75, "items-rise", "wall in place"),
  (18.85, "carousel-step", "wall flick"),
  (21.2, "conveyor", "back to face (pop-out)"),
  (21.6, "card-appears", "search field"),
  (23.7, "conveyor", "to EXPLAIN 3"),
  (24.26, "typing", "ad for hat"),
  (25.4, "in-scene-swap", "wheel -> real results page"),
  (27.4, "pill-tag-pop", "pick OLD MONEY"),
  (28.4, "conveyor", "back to face"),
  (28.45, "card-appears", "detail card"),
  (29.0, "ui-tap", "tap the image"),
  (30.35, "typing", "prompt lines"),
  (31.5, "conveyor", "to EXPLAIN 4"),
  (33.75, "typing", "delete the hat"),
  (34.35, "typing", "type the chechia"),
  (35.45, "pill-tag-pop", "product chip"),
  (36.9, "ui-tap", "Generate"),
  (37.6, "items-rise", "result appears"),
  (38.5, "conveyor", "back to face"),
  (38.42, "glass-appear", "dock appears"),
  (38.75, "glass-label", "save"),
  (39.25, "glass-label", "share"),
  (40.95, "glass-pop-away", "dock pops away"),
  (41.6, "pill-tag-pop", "link in bio"),
  (43.5, "card-appears", "photogenerator.ai"),
]
tags, n0 = list(demo), len(demo)
for j, (t, role, note) in enumerate(sorted(events)):
    e = kit["events"][role]; sid = e["sfx"]; s = kit["sounds"][sid]
    start = max(0.0, round(t - s["hit"], 3)); dur = round(min(s["duration"], END - start), 3)
    vol = 0.11 if role == "typing" else e["volume"]
    k = n0 + j
    tags.append(f'    <audio id="sfx-{k:02d}-{sid.lower()}" src="assets/sfx/{sid}.wav" data-start="{start}" data-duration="{dur}" data-track-index="{3 + k}" data-volume="{vol}"></audio>  <!-- {note} (event {t}s) -->')

SFX_GAIN = 1.8   # creator 2026-10-07: SFX too low against the Auphonic voice (1.5, then "a little bit louder")
tags = [re.sub(r'data-volume="([\d.]+)"', lambda m: f'data-volume="{round(float(m.group(1)) * SFX_GAIN, 3)}"', t) for t in tags]
out = (src.replace("/*WORDS*/", W).replace("/*WALL*/", "".join(wall)).replace("/*WHEEL*/", "".join(wheel))
          .replace("<!--SFX-->", "\n".join(tags)))
# wheel angles: set once at build via tl.set in the page (cards carry data-th)
out = out.replace("    // ---- typing (seek-safe", '    document.querySelectorAll(".wh").forEach((el) => tl.set(el, { rotation: +el.dataset.th }, 0));\n\n    // ---- typing (seek-safe')
(H / "index.html").write_text(out)
print("cues:", len(tags), "wall videos:", track - 90)
