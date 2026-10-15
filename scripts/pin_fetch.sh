#!/usr/bin/env bash
# Download Pinterest pins (image + video if any) for style references.
# Usage: pin_fetch.sh <out_dir> <pin_id> [pin_id ...]
# Writes <out_dir>/<pin_id>.jpg|png, <pin_id>.mp4 (720w) and appends to <out_dir>/index.tsv
set -u
out="$1"; shift; mkdir -p "$out"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/128 Safari/537.36"
for id in "$@"; do
  html=$(curl -sL -A "$UA" "https://www.pinterest.com/pin/$id/")
  img=$(printf '%s' "$html" | grep -oE '<meta[^>]+og:image"[^>]*content="[^"]+"|content="[^"]+"[^>]+og:image"' | grep -oE 'https://i\.pinimg\.com/[^"]+' | head -1)
  vid=$(printf '%s' "$html" | grep -oE 'https://v1\.pinimg\.com/videos/[^"\\]+_720w\.mp4' | head -1)
  title=$(printf '%s' "$html" | grep -oE '<title[^>]*>[^<]*' | sed 's/<title[^>]*>//' | head -1)
  [ -n "$img" ] && curl -sfL "$img" -o "$out/$id.${img##*.}"
  [ -n "$vid" ] && curl -sL "$vid" -o "$out/$id.mp4"
  printf '%s\t%s\t%s\t%s\n' "$id" "${img:-}" "${vid:-}" "$title" >> "$out/index.tsv"
  echo "$id img:${img:+y} vid:${vid:+y}"
done
