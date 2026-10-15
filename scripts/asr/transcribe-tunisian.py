#!/usr/bin/env python3
"""Transcribe Tunisian Derja with TuniSpeech-AI/whisper-tunisian-dialect (local, Apple GPU).

  models/asr-env/bin/python scripts/asr/transcribe-tunisian.py audio.wav [--out words.json] [--force]

- Output: Arabic letters, with word timestamps when the model supports them (JSON + printed table).
- License of the weights: CC-BY-NC-4.0 (non-commercial). Check before using it in paid work.
- Memory guard: the model needs about 4-5 GB. It refuses to start if less than 5 GB is free or
  inactive, so a busy Mac does not get pushed into heavy swap. --force overrides.
"""
import argparse, json, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
MODEL = os.path.join(HERE, "..", "..", "models", "whisper-tunisian-dialect")
NEED_GB = 5.0


def free_gb():
    out = subprocess.run(["vm_stat"], capture_output=True, text=True).stdout
    ps = int(out.split("page size of ")[1].split(" ")[0])
    get = lambda k: int(next(l for l in out.splitlines() if l.startswith(k)).split(":")[1].strip(" .\n"))
    return (get("Pages free") + get("Pages inactive") + get("Pages speculative")) * ps / 1024**3


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("audio")
    ap.add_argument("--out")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--no-words", action="store_true", help="segment timestamps only")
    a = ap.parse_args()

    size = os.path.getsize(os.path.join(MODEL, "model.safetensors"))
    if size < 3086759768:
        sys.exit(f"weights incomplete ({size/1e9:.2f} of 3.09 GB): run scripts/setup.py")
    g = free_gb()
    print(f"free+inactive memory: {g:.1f} GB (need {NEED_GB})")
    if g < NEED_GB and not a.force:
        sys.exit("not enough free memory: close Chrome / Blender / Docker and retry (or --force)")

    import numpy as np, torch
    from scipy.io import wavfile
    from transformers import pipeline

    wav = tempfile.mktemp(suffix=".wav")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", a.audio, "-ar", "16000", "-ac", "1", wav], check=True)
    sr, x = wavfile.read(wav)
    os.remove(wav)
    x = x.astype(np.float32) / 32768.0

    dev = "mps" if torch.backends.mps.is_available() else "cpu"
    dtype = torch.float16 if dev == "mps" else torch.float32
    pipe = pipeline("automatic-speech-recognition", model=MODEL, torch_dtype=dtype, device=dev,
                    model_kwargs={"low_cpu_mem_usage": True})
    gen = {"language": "ar", "task": "transcribe"}
    kw = dict(chunk_length_s=30, stride_length_s=5, generate_kwargs=gen)
    res = None
    if not a.no_words:
        try:
            res = pipe({"raw": x, "sampling_rate": sr}, return_timestamps="word", **kw)
        except Exception as e:  # model without alignment heads
            print("word timestamps unavailable:", repr(e)[:200], "-> segment timestamps")
    if res is None:
        res = pipe({"raw": x, "sampling_rate": sr}, return_timestamps=True, **kw)
    print(res["text"])
    for c in res.get("chunks", []):
        print("%6.2f-%6.2f  %s" % (c["timestamp"][0] or 0, c["timestamp"][1] or 0, c["text"]))
    if a.out:
        json.dump(res, open(a.out, "w"), ensure_ascii=False, indent=2)
        print("wrote", a.out)


if __name__ == "__main__":
    main()
