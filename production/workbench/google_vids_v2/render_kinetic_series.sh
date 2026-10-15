#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
binary="$(mktemp -u /private/tmp/ass4-series.XXXXXX)"
trap 'rm -f "$binary"' EXIT
mkdir -p /private/tmp/ass4-swift-cache
swiftc -O -module-cache-path /private/tmp/ass4-swift-cache "$script_dir/render_kinetic_series.swift" -o "$binary"
for episode in 2 3; do
  output_dir="$(printf '%s/episode%02d_kinetic' "$script_dir" "$episode")"
  mkdir -p "$output_dir"
  if [ "$episode" = 2 ]; then durations=(35 39 35 35 40 44); else durations=(34 44 44 43 38 41); fi
  for scene in 1 2 3 4 5 6; do
    seconds="${durations[$((scene-1))]}"
    outfile="$(printf '%s/scene%02d_%ss.mp4' "$output_dir" "$scene" "$seconds")"
    "$binary" "$episode" "$scene" 24 | \
      ffmpeg -hide_banner -loglevel error -y -f rawvideo -pix_fmt rgba -s 1280x720 -r 24 -i - \
        -an -c:v libx264 -preset veryfast -crf 21 -pix_fmt yuv420p -movflags +faststart "$outfile"
    printf '%s\n' "$outfile"
  done
done
