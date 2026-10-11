#!/usr/bin/env python3
"""reel-editor first-run setup: API keys + local Tunisian Whisper model. Asks before everything.

  python3 scripts/setup.py              # interactive: asks for each missing key / the model
  python3 scripts/setup.py --check      # status only, changes nothing (exit 0 ready, 4 something missing)
  python3 scripts/setup.py --keys       # only the API keys step
  python3 scripts/setup.py --whisper    # only the Whisper step
  python3 scripts/setup.py --whisper --yes   # Whisper step, consent already given by the user

Keys are stored in <skill>/.env (chmod 600, gitignored), never in the repo. Env vars
AUPHONIC_API_KEY / HEYGEN_API_KEY take precedence over the file.
Whisper: TuniSpeech-AI/whisper-tunisian-dialect (3.1 GB, CC-BY-NC-4.0, non-commercial) + a local
Python venv with torch/transformers (~1 GB), both under <skill>/models/ (gitignored).
Run keys steps in a real terminal: the key is typed hidden, so it never lands in a chat or a log.
"""
import argparse
import getpass
import os
import shutil
import subprocess
import sys
from pathlib import Path

SK = Path(__file__).resolve().parents[1]
ENV = SK / ".env"
MODELS = SK / "models"
WEIGHTS = MODELS / "whisper-tunisian-dialect"
VENV = MODELS / "asr-env"
BASE = "https://huggingface.co/TuniSpeech-AI/whisper-tunisian-dialect/resolve/main"
SIZE = 3086759768
SMALL = ["config.json", "generation_config.json", "processor_config.json",
         "tokenizer.json", "tokenizer_config.json", "README.md"]
PIP = ["torch", "transformers", "accelerate", "scipy", "numpy", "safetensors"]
KEYS = {
    "AUPHONIC_API_KEY": ("Auphonic", "voice enhancement (studio preset)", "https://auphonic.com/accounts/settings/#api-key"),
    "HEYGEN_API_KEY": ("HeyGen", "sound-effect search (reels only, free)", "https://app.heygen.com/settings/api"),
}


def read_env():
    out = {}
    if ENV.exists():
        for line in ENV.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                out[k.strip()] = v.strip().strip("\"'")
    return out


def write_env(data):
    ENV.write_text("".join(f"{k}={v}\n" for k, v in data.items()))
    ENV.chmod(0o600)


def have_key(name):
    return bool(os.environ.get(name) or read_env().get(name))


def whisper_ok():
    w = WEIGHTS / "model.safetensors"
    return w.exists() and w.stat().st_size >= SIZE and (VENV / "bin/python").exists()


def ask(q, default=False):
    if not sys.stdin.isatty():
        return False
    a = input(f"{q} [{'Y/n' if default else 'y/N'}] ").strip().lower()
    return default if not a else a.startswith("y")


def status():
    print("reel-editor setup status")
    for k, (name, why, _) in KEYS.items():
        print(f"  {'ok     ' if have_key(k) else 'MISSING'} {name} key ({why})")
    print(f"  {'ok     ' if whisper_ok() else 'MISSING'} Tunisian Whisper model + venv")
    for tool in ("ffmpeg", "ffprobe"):
        print(f"  {'ok     ' if shutil.which(tool) else 'MISSING'} {tool} (brew install ffmpeg)")
    return have_key("AUPHONIC_API_KEY") and have_key("HEYGEN_API_KEY") and whisper_ok()


def step_keys():
    if not sys.stdin.isatty():
        print("keys: not a terminal. Run `python3 scripts/setup.py --keys` in your own terminal.")
        return
    data = read_env()
    for k, (name, why, url) in KEYS.items():
        if have_key(k):
            print(f"{name}: already set.")
            continue
        print(f"\n{name} key is used for {why}.\n  Get it at {url}")
        if not ask(f"Enter your {name} key now?", True):
            print("  skipped (that feature stays off until you set it).")
            continue
        v = getpass.getpass(f"  {k} (hidden): ").strip()
        if v:
            data[k] = v
            write_env(data)
            print(f"  saved to {ENV} (chmod 600, gitignored).")


def step_whisper(yes):
    if whisper_ok():
        print("Whisper: model and venv already installed.")
        return 0
    free = shutil.disk_usage(SK).free / 1024**3
    print("\nWhisper (Tunisian Derja transcription, runs locally, needs ~5 GB free RAM when used)")
    print("  download : whisper-tunisian-dialect weights, 3.1 GB, license CC-BY-NC-4.0 (non-commercial)")
    print("  install  : Python venv with torch + transformers, ~1 GB")
    print(f"  location : {MODELS}   (free disk now: {free:.0f} GB)")
    if free < 6:
        print("  not enough disk space (need ~6 GB).")
        return 1
    if not (yes or ask("Download and install it now?")):
        print("  skipped. prep.py cannot transcribe until this is done (or use --skip-whisper).")
        return 1
    MODELS.mkdir(exist_ok=True)
    WEIGHTS.mkdir(exist_ok=True)
    if not (VENV / "bin/python").exists():
        print("creating venv...")
        subprocess.run([sys.executable, "-m", "venv", str(VENV)], check=True)
        subprocess.run([str(VENV / "bin/python"), "-m", "pip", "install", "-q", "-U", "pip"], check=True)
        subprocess.run([str(VENV / "bin/python"), "-m", "pip", "install", *PIP], check=True)
    for f in SMALL:
        dest = WEIGHTS / f
        if not dest.exists():
            subprocess.run(["curl", "-sSL", "--fail", "-o", str(dest), f"{BASE}/{f}"])
            if dest.exists() and dest.stat().st_size == 0:
                dest.unlink()
    big = WEIGHTS / "model.safetensors"
    print("downloading weights (resumable: rerun setup if it stops)...")
    for _ in range(60):
        if big.exists() and big.stat().st_size >= SIZE:
            break
        subprocess.run(["curl", "--http1.1", "-L", "-C", "-", "--fail", "-o", str(big), f"{BASE}/model.safetensors",
                        "--retry", "5", "--retry-delay", "2", "--connect-timeout", "20",
                        "--speed-time", "30", "--speed-limit", "50000", "-#"])
    if not whisper_ok():
        print("download incomplete: rerun `python3 scripts/setup.py --whisper --yes`.")
        return 1
    print("Whisper ready.")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--keys", action="store_true")
    ap.add_argument("--whisper", action="store_true")
    ap.add_argument("--yes", action="store_true", help="user already consented to the Whisper download")
    a = ap.parse_args()
    if a.check:
        return 0 if status() else 4
    both = not (a.keys or a.whisper)
    if both:
        status()
    if a.keys or both:
        step_keys()
    if a.whisper or both:
        step_whisper(a.yes)
    print()
    return 0 if status() else 4


if __name__ == "__main__":
    sys.exit(main())
