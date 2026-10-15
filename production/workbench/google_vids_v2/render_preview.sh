#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
CLANG_MODULE_CACHE_PATH=/private/tmp/ass4-clang-cache \
  swift -module-cache-path /private/tmp/ass4-swift-cache render_label.swift preview_label.png

# Visual rough cut only. Its shots are illustrative; no Suno screen capture or
# source audio is used. The submitted video still must be assembled in Vids.
ffmpeg -hide_banner -loglevel error -y \
  -framerate 30 -loop 1 -t 8 -i episode01_style_frame.png \
  -framerate 30 -loop 1 -t 8 -i episode01_notebook_closeup.png \
  -framerate 30 -loop 1 -t 8 -i episode01_timeline_closeup.png \
  -framerate 30 -loop 1 -t 23 -i preview_label.png \
  -filter_complex "\
    [0:v]zoompan=z='min(zoom+0.00020,1.055)':d=1:s=1280x720:fps=30,trim=duration=8,setpts=PTS-STARTPTS[a];\
    [1:v]zoompan=z='min(zoom+0.00020,1.055)':d=1:s=1280x720:fps=30,trim=duration=8,setpts=PTS-STARTPTS[b];\
    [2:v]zoompan=z='min(zoom+0.00020,1.055)':d=1:s=1280x720:fps=30,trim=duration=8,setpts=PTS-STARTPTS[c];\
    [a][b]xfade=transition=fade:duration=0.5:offset=7.5[ab];\
    [ab][c]xfade=transition=fade:duration=0.5:offset=15.0[abc];\
    [abc][3:v]overlay=0:0:format=auto,format=yuv420p[out]" \
  -map '[out]' -an -c:v libx264 -preset veryfast -crf 20 -movflags +faststart \
  episode01_23s_multishot_preview.mp4
