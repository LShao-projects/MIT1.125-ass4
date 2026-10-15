#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
output_dir="$script_dir/episode03_revision"
binary="$(mktemp -u /private/tmp/ass4-episode03.XXXXXX)"
trap 'rm -f "$binary"' EXIT

mkdir -p "$output_dir/upload" /private/tmp/ass4-swift-cache
swiftc -O -module-cache-path /private/tmp/ass4-swift-cache \
  "$script_dir/render_kinetic_series.swift" -o "$binary"

durations=(31.4 38.7 39.8 43.0 32.5 38.0)
for scene in 1 2 3 4 5 6; do
  seconds="${durations[$((scene-1))]}"
  image_path="$(printf '%s/scene%02d.png' "$output_dir" "$scene")"
  suffix=sync
  if [[ "$scene" == 4 || "$scene" == 5 ]]; then suffix=final; fi
  video_path="$(printf '%s/upload/scene%02d_%s.mp4' "$output_dir" "$scene" "$suffix")"
  "$binary" 5 "$scene" 24 288 | ffmpeg -hide_banner -loglevel error -y \
    -f rawvideo -pix_fmt rgba -s 1280x720 -i - -frames:v 1 "$image_path"
  ffmpeg -hide_banner -loglevel error -y -loop 1 -framerate 30 \
    -i "$image_path" -t "$seconds" -an -c:v libx264 -preset medium -r 30 \
    -crf 19 -pix_fmt yuv420p -movflags +faststart "$video_path"
  printf '%s\n' "$video_path"
done
