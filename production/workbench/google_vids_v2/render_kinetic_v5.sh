#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
output_dir="$script_dir/episode01_kinetic_v5"
binary="$(mktemp -u /private/tmp/ass4-kinetic-v5.XXXXXX)"
trap 'rm -f "$binary"' EXIT
mkdir -p "$output_dir" /private/tmp/ass4-swift-cache
swiftc -O -module-cache-path /private/tmp/ass4-swift-cache \
  "$script_dir/render_kinetic_scene_v5.swift" -o "$binary"

# The Google Vids scene lengths remain 24.7, 24.5, 26.8, 24.2, 35.7, and 48.5 s.
# These source clips include the small overlap that Vids uses for its dissolves.
scenes=(1 2 3 4 6 7)
seconds=(24.9 25.0 27.3 24.7 36.2 48.7)
frames=(598 600 656 593 869 1169)
for i in "${!scenes[@]}"; do
  scene="${scenes[$i]}"
  suffix=clean
  if [[ "$scene" == 2 || "$scene" == 3 || "$scene" == 4 || "$scene" == 6 ]]; then suffix=clean_sync; fi
  outfile="$(printf '%s/scene%02d_%s.mp4' "$output_dir" "$scene" "$suffix")"
  "$binary" "$scene" 24 "$script_dir/episode01_studio_plate.png" "${frames[$i]}" |
    ffmpeg -hide_banner -loglevel error -y -f rawvideo -pix_fmt rgba \
      -s 1280x720 -r 24 -i - -t "${seconds[$i]}" -an -c:v libx264 \
      -preset veryfast -crf 21 -pix_fmt yuv420p -movflags +faststart "$outfile"
  printf '%s\n' "$outfile"
done
