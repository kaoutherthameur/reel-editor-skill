#!/usr/bin/env python3
"""
Podcast-grade voice enhancement for DJI Mic recordings via the Auphonic API.

Pipeline
  1. Local prep (ffmpeg): pull audio out of video if needed, mono mixdown,
     clean peak-normalise to -1 dBFS (linear gain, never clips), 24-bit FLAC.
     -> Do NOT pre-boost +20 dB yourself: on 16/24-bit exports that clips the
        peaks, and no enhancer can undo clipping. Feed raw DJI files (32-bit
        float is ideal) and let this handle gain.
  2. Auphonic: denoise + de-reverb, Voice AutoEQ + bandwidth extension,
     speech leveler + compressor, loudness normalise (-14 LUFS, -1 dBTP).
  3. Download 24-bit WAV next to the input, print before/after loudness.
  4. Video input (e.g. CapCut export): put the enhanced voice back into the
     video -> clip_studio.mov. Picture is stream-copied, cuts stay in sync.
     Export from CapCut with music/SFX muted and CapCut voice effects off.

Usage
  python3 enhance.py clip.mov                    # CapCut export in -> clip_studio.mov out
  python3 enhance.py clip.WAV                    # default "studio" preset (Studio Voice, chosen 2026-10-06)
  python3 enhance.py clip.WAV --preset podcast   # classic Auphonic chain, more natural
  python3 enhance.py clip.WAV --preset both      # render both for A/B (2x credits)
  python3 enhance.py clip.mov --wav              # also keep the enhanced WAV
  python3 enhance.py clip.mov --no-mux           # video in, WAV out only
  python3 enhance.py clip.mov --target -16       # quieter podcast target
  python3 enhance.py clip.WAV --dry-run          # show settings, upload nothing

Key: AUPHONIC_API_KEY env var, or <skill>/.env (python3 scripts/setup.py --keys)
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

import requests

API = "https://auphonic.com/api"
HERE = Path(__file__).resolve().parent

# Base chain shared by every preset.
BASE = {
    # cleanup
    "denoise": True,
    "denoisemethod": "dynamic",   # keep voice, remove room/AC/traffic noise
    "denoiseamount": 12,          # medium: clean without "underwater" artifacts
    "deverbamount": 12,           # tame room echo (home recordings' main flaw)
    "debreathamount": 6,          # soften breaths, keep it human
    "dehum": 0,
    "dehumamount": 0,
    # tone
    "filtering": True,
    "filtermethod": "bwe",        # Voice AutoEQ + bandwidth extension
    # dynamics
    "leveler": True,
    "levelerstrength": 100,
    "compressor": "medium",
    "msclassifier": "speech",     # pure voice: don't let music detection skip leveling
    # loudness
    "normloudness": True,
    "loudnesstarget": -14,        # Instagram/TikTok/YouTube level
    "maxpeak": -1.0,
    "loudnessmethod": "program",
}

PRESETS = {
    # Classic Auphonic chain, very natural, punchy.
    "podcast": {},
    # Studio Voice (beta): resynthesises the voice -> closest to Adobe Podcast,
    # biggest "studio mic" jump. Can sound processed on some voices; A/B it.
    "studio": {"filtermethod": "studiovoice", "denoiseamount": 0, "deverbamount": 0},
    # Gentle: for already-clean rooms, minimal processing artifacts.
    "gentle": {"denoisemethod": "static", "denoiseamount": 6, "deverbamount": -1,
               "debreathamount": -1, "filtermethod": "autoeq", "compressor": "soft"},
}

VIDEO_EXT = {".mov", ".mp4", ".m4v", ".mkv", ".avi", ".mts"}


# ---------- helpers ----------

def load_key():
    key = os.environ.get("AUPHONIC_API_KEY")
    env = HERE.parents[1] / ".env"
    if not key and env.exists():
        for line in env.read_text().splitlines():
            if line.startswith("AUPHONIC_API_KEY="):
                key = line.split("=", 1)[1].strip()
    if not key:
        sys.exit("No API key: set AUPHONIC_API_KEY or run scripts/setup.py")
    return key


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, check=True)


def measure(path):
    """Integrated loudness (LUFS), true peak (dBTP), loudness range (LU)."""
    err = subprocess.run(
        ["ffmpeg", "-hide_banner", "-nostats", "-i", str(path),
         "-vn", "-af", "ebur128=peak=true", "-f", "null", "-"],
        capture_output=True, text=True).stderr
    summary = err[err.rfind("Summary:"):]

    def grab(label):
        m = re.search(label + r":\s+(-?[\d.]+|-inf)", summary)
        return float(m.group(1)) if m else float("nan")
    return {"lufs": grab("I"), "peak": grab("Peak"), "lra": grab("LRA")}


def sample_peak_db(path):
    err = subprocess.run(
        ["ffmpeg", "-hide_banner", "-nostats", "-i", str(path),
         "-vn", "-af", "astats=measure_perchannel=none:measure_overall=Peak_level",
         "-f", "null", "-"], capture_output=True, text=True).stderr
    m = re.search(r"Peak level dB:\s+(-?[\d.]+|-inf)", err)
    return float(m.group(1)) if m else 0.0


def duration(path):
    out = run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
               "-of", "csv=p=0", str(path)]).stdout
    return float(out.strip())


def strip_jingle(path, expected_dur):
    """Free Auphonic plan prepends a ~6 s jingle. Cut whatever exceeds the input length off the front."""
    extra = duration(path) - expected_dur
    if extra < 0.2:
        return
    tmp = path.with_suffix(".trim.wav")
    run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", str(path),
         "-af", f"atrim=start={extra:.4f},asetpts=PTS-STARTPTS",
         "-c:a", "pcm_s24le", str(tmp)])
    tmp.replace(path)
    print(f"  removed {extra:.2f}s free-plan jingle from start")


def stream_start(path, sel):
    out = run(["ffprobe", "-v", "error", "-select_streams", sel,
               "-show_entries", "stream=start_time", "-of", "csv=p=0", str(path)]).stdout.strip()
    try:
        return float(out.splitlines()[0])
    except (ValueError, IndexError):
        return 0.0


def mux(video, audio, dest):
    """Swap the video's audio for the enhanced track. Video stream is copied untouched (no re-encode)."""
    offset = stream_start(video, "a:0") - stream_start(video, "v:0")
    ext = dest.suffix.lower()
    cmd = ["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", str(video)]
    if abs(offset) > 0.001:
        cmd += ["-itsoffset", f"{offset:.4f}"]
    cmd += ["-i", str(audio), "-map", "0:v:0", "-map", "1:a:0", "-map_metadata", "0",
            "-c:v", "copy", "-c:a", "aac", "-b:a", "320k", "-ar", "48000"]
    if ext in (".mp4", ".mov", ".m4v"):
        cmd += ["-movflags", "+faststart"]
        if run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
                "stream=codec_name", "-of", "csv=p=0", str(video)]).stdout.strip() == "hevc":
            cmd += ["-tag:v", "hvc1"]  # keeps HEVC playable in QuickTime / iPhone
    run(cmd + [str(dest)])


def is_float_pcm(path):
    out = run(["ffprobe", "-v", "error", "-select_streams", "a:0",
               "-show_entries", "stream=codec_name", "-of", "csv=p=0", str(path)]).stdout
    return out.strip().startswith("pcm_f")


def prep(src, workdir, keep_stereo):
    """Mono (or stereo) 48 kHz 24-bit FLAC, peak at -1 dBFS."""
    peak = sample_peak_db(src)
    if not is_float_pcm(src) and peak > -0.1:
        print(f"  ! input peaks at {peak:+.1f} dBFS in fixed-point -> probably clipped.\n"
              "    Use the raw DJI file (no +20 dB boost) for best results.")
    gain = -1.0 - peak
    out = Path(workdir) / (src.stem + "_prep.flac")
    cmd = ["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", str(src),
           "-map", "0:a:0", "-vn", "-af", f"volume={gain:.2f}dB", "-ar", "48000"]
    if not keep_stereo:
        cmd += ["-ac", "1"]
    cmd += ["-c:a", "flac", "-sample_fmt", "s32", "-bits_per_raw_sample", "24", str(out)]
    run(cmd)
    print(f"  prep: peak {peak:+.1f} dBFS -> gain {gain:+.1f} dB -> {out.name}")
    return out


# ---------- Auphonic ----------

class Auphonic:
    def __init__(self, key):
        self.s = requests.Session()
        self.s.headers["Authorization"] = f"bearer {key}"

    def _ok(self, r):
        try:
            j = r.json()
        except ValueError:
            r.raise_for_status()
            raise
        if r.status_code != 200 or j.get("error_message"):
            sys.exit(f"Auphonic error {r.status_code}: {j.get('error_message')} {j.get('form_errors') or ''}")
        return j["data"]

    def credits(self):
        return self._ok(self.s.get(f"{API}/user.json"))["credits"]

    def create(self, title, algorithms):
        body = {
            "metadata": {"title": title},
            "algorithms": algorithms,
            "output_files": [{"format": "wav-24bit", "mono_mixdown": False}],
        }
        return self._ok(self.s.post(f"{API}/productions.json", json=body))["uuid"]

    def upload(self, uuid, path):
        with open(path, "rb") as f:
            self._ok(self.s.post(f"{API}/production/{uuid}/upload.json",
                                 files={"input_file": (path.name, f)}))

    def start(self, uuid):
        self._ok(self.s.post(f"{API}/production/{uuid}/start.json"))

    def wait(self, uuid):
        last = None
        while True:
            d = self._ok(self.s.get(f"{API}/production/{uuid}.json"))
            if d["status_string"] != last:
                last = d["status_string"]
                print(f"  auphonic: {last}")
            if d["status"] == 3:
                return d
            if d["status"] in (2, 9, 11):
                sys.exit(f"Production failed: {d.get('error_message') or last}\n"
                         f"See https://auphonic.com/engine/status/{uuid}")
            time.sleep(4)

    def download(self, url, dest):
        with self.s.get(url, stream=True) as r:
            r.raise_for_status()
            with open(dest, "wb") as f:
                for chunk in r.iter_content(1 << 16):
                    f.write(chunk)


# ---------- main ----------

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", type=Path)
    ap.add_argument("--preset", choices=[*PRESETS, "both"], default="studio")
    ap.add_argument("--target", type=int, default=-14,
                    choices=[-13, -14, -15, -16, -18, -19, -20, -23],
                    help="loudness target LUFS (-14 social, -16 podcast)")
    ap.add_argument("--keep-stereo", action="store_true",
                    help="keep stereo (default: mono mixdown, right for one DJI mic)")
    ap.add_argument("--no-breath", action="store_true", help="disable breath reduction")
    ap.add_argument("--out", type=Path, help="output dir (default: next to input)")
    ap.add_argument("--no-mux", action="store_true",
                    help="video input: only output the enhanced WAV, don't rebuild the video")
    ap.add_argument("--wav", action="store_true",
                    help="video input: also keep the enhanced WAV next to the new video")
    ap.add_argument("--dry-run", action="store_true", help="print settings, upload nothing")
    a = ap.parse_args()

    src = a.input.expanduser().resolve()
    if not src.exists():
        sys.exit(f"Not found: {src}")
    is_video = src.suffix.lower() in VIDEO_EXT
    outdir = (a.out or src.parent).resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    presets = list(PRESETS)[:2] if a.preset == "both" else [a.preset]
    jobs = []
    for p in presets:
        algo = {**BASE, **PRESETS[p], "loudnesstarget": a.target}
        if a.no_breath:
            algo["debreathamount"] = -1
        jobs.append((p, algo))

    if a.dry_run:
        for p, algo in jobs:
            print(f"[{p}]\n{json.dumps(algo, indent=2)}")
        return

    key = load_key()
    au = Auphonic(key)
    print(f"Input: {src.name}")
    before = measure(src)
    print(f"  before: {before['lufs']:.1f} LUFS, peak {before['peak']:+.1f} dBTP, LRA {before['lra']:.1f} LU")
    print(f"  credits left: {au.credits():.2f} h")

    with tempfile.TemporaryDirectory() as tmp:
        prepped = prep(src, tmp, a.keep_stereo)
        for p, algo in jobs:
            print(f"[{p}]")
            uuid = au.create(f"{src.stem} [{p}]", algo)
            au.upload(uuid, prepped)
            au.start(uuid)
            d = au.wait(uuid)
            url = d["output_files"][0]["download_url"]
            dest = outdir / f"{src.stem}_{p}.wav"
            au.download(url, dest)
            strip_jingle(dest, duration(prepped))
            after = measure(dest)
            print(f"  after:  {after['lufs']:.1f} LUFS, peak {after['peak']:+.1f} dBTP, LRA {after['lra']:.1f} LU")
            if is_video and not a.no_mux:
                vdest = outdir / f"{src.stem}_{p}{src.suffix}"
                mux(src, dest, vdest)
                if not a.wav:
                    dest.unlink()
                print(f"  -> {vdest}")
            else:
                print(f"  -> {dest}")


if __name__ == "__main__":
    main()
