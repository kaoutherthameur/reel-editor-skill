#!/usr/bin/env python3
"""reel-editor prep: episode folder, audio extract, Auphonic + Tunisian Whisper in parallel.

  python3 prep.py <cleaned_video> [--slug name] [--force] [--skip-auphonic] [--skip-whisper] [--dry-run]

Steps
  1. videos/<slug>/ with source.<ext> (symlink to the cleaned base video).
  2. audio/raw.wav: mono 48 kHz 32-bit float, no gain (enhance.py normalises itself).
  3. RAM gate for Whisper (needs ~5 GB free+inactive). Under it: exit code 3 and a message
     asking the creator to close Chrome / Blender / Docker. The agent relays it and waits.
     --force skips the gate.
  4. In parallel:
       Auphonic studio preset  -> audio/voice_studio.wav   (cloud, light on RAM)
       Whisper Tunisian (raw)  -> transcript.raw.json      (local, Apple GPU)
     One failing does not cancel the other. Logs: audio/auphonic.log, whisper.log.

Exit codes: 0 both ok · 1 Whisper failed (no editing without a transcript) ·
            2 only Auphonic failed (fall back to raw.wav) · 3 RAM gate ·
            4 setup missing (Auphonic key / Whisper model): ask the creator, run scripts/setup.py.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import threading
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]          # Content-Creator/
SK = Path(__file__).resolve().parents[1]           # the skill itself
ENHANCE = SK / "scripts/auphonic/enhance.py"
WHISPER = SK / "scripts/asr/transcribe-tunisian.py"
ASR_PY = SK / "models/asr-env/bin/python"
SETUP = SK / "scripts/setup.py"
NEED_GB = 5.0


def free_gb():
    out = subprocess.run(["vm_stat"], capture_output=True, text=True).stdout
    ps = int(out.split("page size of ")[1].split(" ")[0])
    get = lambda k: int(next(l for l in out.splitlines() if l.startswith(k)).split(":")[1].strip(" .\n"))
    return (get("Pages free") + get("Pages inactive") + get("Pages speculative")) * ps / 1024**3


def slugify(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-") or "episode"


def run_logged(name, cmd, log, results, cwd):
    with open(log, "w") as f:
        p = subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, cwd=cwd)
    results[name] = p.returncode
    print(f"  [{name}] {'ok' if p.returncode == 0 else f'FAILED (exit {p.returncode}), see {log}'}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("video", type=Path)
    ap.add_argument("--slug")
    ap.add_argument("--force", action="store_true", help="skip the RAM gate")
    ap.add_argument("--skip-auphonic", action="store_true")
    ap.add_argument("--skip-whisper", action="store_true")
    ap.add_argument("--dry-run", action="store_true", help="print the plan, run nothing")
    a = ap.parse_args()

    src = a.video.expanduser().resolve()
    if not src.exists():
        sys.exit(f"not found: {src}")
    slug = a.slug or slugify(src.stem)
    ep = ROOT / "videos" / slug
    raw = ep / "audio/raw.wav"
    extract = ["ffmpeg", "-v", "error", "-y", "-i", str(src), "-vn", "-ac", "1", "-ar", "48000",
               "-c:a", "pcm_f32le", str(raw)]
    auph = [sys.executable, str(ENHANCE), str(raw), "--preset", "studio", "--out", str(ep / "audio")]
    whis = [str(ASR_PY), str(WHISPER), str(raw), "--out", str(ep / "transcript.raw.json"), "--force"]

    print(f"episode: {ep}")
    if a.dry_run:
        print(f"  link   {ep / ('source' + src.suffix.lower())} -> {src}")
        print("  " + " ".join(extract))
        print(f"  RAM gate: {free_gb():.1f} GB free+inactive (need {NEED_GB})")
        if not a.skip_auphonic:
            print("  " + " ".join(auph) + "   -> audio/voice_studio.wav")
        if not a.skip_whisper:
            print("  " + " ".join(whis))
        return 0

    # 0. setup check: never start a job that cannot work; the creator must consent to keys/download
    miss = []
    env_txt = (SK / ".env").read_text() if (SK / ".env").exists() else ""
    if not a.skip_auphonic and not (os.environ.get("AUPHONIC_API_KEY") or "AUPHONIC_API_KEY=" in env_txt):
        miss.append("Auphonic API key (python3 scripts/setup.py --keys, in your own terminal)")
    if not a.skip_whisper and not ((SK / "models/whisper-tunisian-dialect/model.safetensors").exists() and ASR_PY.exists()):
        miss.append("Tunisian Whisper model, 3.1 GB download (python3 scripts/setup.py --whisper)")
    if miss:
        print("SETUP MISSING: ask the creator before installing anything:")
        for m in miss:
            print("  - " + m)
        print(f"  or skip a part with --skip-auphonic / --skip-whisper. Status: python3 {SETUP} --check")
        return 4

    # 1. folder + source link
    (ep / "audio").mkdir(parents=True, exist_ok=True)
    for d in ("assets", "renders", "snapshots"):
        (ep / d).mkdir(exist_ok=True)
    link = ep / ("source" + src.suffix.lower())
    if not link.exists():
        link.symlink_to(src)

    # 2. audio
    if not raw.exists():
        subprocess.run(extract, check=True)
    dur = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
                          str(raw)], capture_output=True, text=True).stdout.strip()
    print(f"  audio/raw.wav  {float(dur):.1f} s")

    # 3. RAM gate (only matters when Whisper runs)
    if not a.skip_whisper and not a.force:
        g = free_gb()
        print(f"  memory free+inactive: {g:.1f} GB (need {NEED_GB})")
        if g < NEED_GB:
            print("RAM GATE: ask the creator to close Chrome, Blender, Docker and other heavy apps, "
                  "then rerun (or --force).")
            return 3

    # 4. parallel jobs
    results, threads = {}, []
    if not a.skip_auphonic:
        threads.append(threading.Thread(target=run_logged,
                                        args=("auphonic", auph, ep / "audio/auphonic.log", results, ROOT)))
    if not a.skip_whisper:
        threads.append(threading.Thread(target=run_logged,
                                        args=("whisper", whis, ep / "whisper.log", results, ROOT)))
    print(f"  running: {', '.join(t._args[0] for t in threads) or 'nothing'}")
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    if results.get("auphonic") == 0:
        out = ep / "audio/raw_studio.wav"
        if out.exists():
            shutil.move(out, ep / "audio/voice_studio.wav")
            print("  -> audio/voice_studio.wav")
    if results.get("whisper") == 0:
        print("  -> transcript.raw.json")

    if results.get("whisper", 0) != 0:
        return 1
    if results.get("auphonic", 0) != 0:
        print("  Auphonic failed: build with audio/raw.wav and tell the creator.")
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
