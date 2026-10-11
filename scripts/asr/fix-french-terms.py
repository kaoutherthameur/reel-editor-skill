#!/usr/bin/env python3
"""Put French/English terms back in Latin letters in an Arabic-script Derja transcript.

  models/asr-env/bin/python scripts/asr/fix-french-terms.py words.json [--out fixed.json] [--glossary g.json]

Input: the JSON written by transcribe-tunisian.py. Each word is matched against french-glossary.json
(normalised, with a similarity threshold). Prints every replacement so you can check them; words not
in the glossary stay in Arabic letters. Only as good as the glossary: add terms as they come up.
"""
import argparse, difflib, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))


def norm(w):
    w = re.sub(r"[ً-ٟـ]", "", w)  # diacritics, tatweel
    w = re.sub("[إأآا]", "ا", w).replace("ى", "ي").replace("ة", "ه")
    return re.sub(r"[^؀-ۿ]", "", w)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("words")
    ap.add_argument("--out")
    ap.add_argument("--glossary", default=os.path.join(HERE, "french-glossary.json"))
    ap.add_argument("--threshold", type=float, default=0.84)
    a = ap.parse_args()
    gl = {norm(k): v for k, v in json.load(open(a.glossary)).items() if not k.startswith("_")}
    d = json.load(open(a.words))
    changes = []
    for c in d["chunks"]:
        w = norm(c["text"])
        if len(w) < 4:
            continue
        best = max(gl, key=lambda k: difflib.SequenceMatcher(None, w, k).ratio())
        r = difflib.SequenceMatcher(None, w, best).ratio()
        if r >= a.threshold:
            changes.append((c["timestamp"][0], c["text"].strip(), gl[best], round(r, 2)))
            c["text"] = " " + gl[best]
    d["text"] = " ".join(c["text"].strip() for c in d["chunks"])
    for t, old, new, r in changes:
        print("%6.2f  %-14s -> %-16s (%.2f)" % (t or 0, old, new, r))
    print(len(changes), "replacements")
    if a.out:
        json.dump(d, open(a.out, "w"), ensure_ascii=False, indent=2)
        print("wrote", a.out)


if __name__ == "__main__":
    main()
