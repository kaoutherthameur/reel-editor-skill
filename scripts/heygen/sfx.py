#!/usr/bin/env python3
"""
Search and download sound effects from the HeyGen audio library (free, $0 wallet ok).

Usage
  python3 sfx.py "whoosh for a scene change"            # list top 5, no download
  python3 sfx.py "cash register" -n 3 --download        # save top 3 mp3s
  python3 sfx.py "pop click" -d --out ~/sfx --min-score 0.6

Key: HEYGEN_API_KEY env var, or <skill>/.env (python3 scripts/setup.py --keys)
Downloads land in <skill>/library/<query-slug>_<name>.mp3 and a
library/index.json keeps name, duration and peak_offset (sec to the hit,
use it to line the hit up with a cut). Audio URLs are pre-signed and expire
after 7 days, so downloads happen immediately.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.parse
from pathlib import Path

API = "https://api.heygen.com/v3/audio/sounds"
HERE = Path(__file__).resolve().parent


def load_key():
    key = os.environ.get("HEYGEN_API_KEY")
    env = HERE.parents[1] / ".env"
    if not key and env.exists():
        for line in env.read_text().splitlines():
            if line.startswith("HEYGEN_API_KEY="):
                key = line.split("=", 1)[1].strip().strip("\"'")
    if not key:
        sys.exit("No key. Set HEYGEN_API_KEY or run scripts/setup.py")
    return key


def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")[:40]


def get(url, key):
    # curl, not urllib: python.org builds on macOS ship without CA certs
    r = subprocess.run(
        ["curl", "-sS", "--fail", "-H", f"x-api-key: {key}", url], capture_output=True
    )
    if r.returncode:
        sys.exit(f"request failed: {r.stderr.decode().strip()}")
    return r.stdout


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("query")
    ap.add_argument("-n", "--limit", type=int, default=5)
    ap.add_argument("--min-score", type=float, default=0.0)
    ap.add_argument("-d", "--download", action="store_true")
    ap.add_argument("--out", type=Path, default=HERE.parents[1] / "library")
    a = ap.parse_args()

    key = load_key()
    qs = urllib.parse.urlencode(
        {"type": "sound_effects", "query": a.query, "limit": a.limit, "min_score": a.min_score}
    )
    items = json.loads(get(f"{API}?{qs}", key)).get("data", [])
    if not items:
        sys.exit("No results. Lower --min-score or rephrase.")

    index_path = a.out / "index.json"
    index = json.loads(index_path.read_text()) if index_path.exists() else {}

    for i, it in enumerate(items, 1):
        print(f"{i}. {it['name']}  {it['duration']:.2f}s  hit@{it['peak_offset']:.2f}s  score {it['score']:.2f}")
        print(f"   {it['description']}")
        if a.download:
            a.out.mkdir(parents=True, exist_ok=True)
            path = a.out / f"{slug(a.query)}_{slug(it['name'])}_{it['id'][:6]}.mp3"
            path.write_bytes(get(it["audio_url"], key))
            index[path.name] = {k: it[k] for k in ("id", "name", "description", "duration", "peak_offset", "placement")}
            index[path.name]["query"] = a.query
            print(f"   saved {path}")
    if a.download:
        index_path.write_text(json.dumps(index, indent=2))


if __name__ == "__main__":
    main()
