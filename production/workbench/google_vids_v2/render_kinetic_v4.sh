#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
output_dir="$script_dir/episode01_kinetic_v4"
binary="$(mktemp -u /private/tmp/ass4-kinetic.XXXXXX)"
trap 'rm -f "$binary"' EXIT
mkdir -p "$output_dir" /private/tmp/ass4-swift-cache
swiftc -O -module-cache-path /private/tmp/ass4-swift-cache "$script_dir/render_kinetic_scene.swift" -o "$binary"

durations=(27 30 29 28 11 44 52)
for scene in 1 2 3 4 5 6 7; do
  seconds="${durations[$((scene - 1))]}"
  outfile="$(printf '%s/scene%02d_%ss.mp4' "$output_dir" "$scene" "$seconds")"
  "$binary" "$scene" 24 "$script_dir/episode01_studio_plate.png" |
    ffmpeg -hide_banner -loglevel error -y -f rawvideo -pix_fmt rgba -s 1280x720 -r 24 -i - \
      -an -c:v libx264 -preset veryfast -crf 21 -pix_fmt yuv420p -movflags +faststart "$outfile"
  printf '%s\n' "$outfile"
done
