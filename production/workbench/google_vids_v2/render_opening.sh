#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: render_opening.sh TITLE_PNG SHOT_2_PNG SHOT_3_PNG LABEL_PNG OUTPUT_MP4" >&2
  exit 2
fi

# Silent visual-direction rough cut. Every pictured interface and document is
# illustrative; no source or generated song audio is incorporated.
ffmpeg -hide_banner -loglevel error -y \
  -framerate 30 -loop 1 -t 8 -i "$1" \
  -framerate 30 -loop 1 -t 8 -i "$2" \
  -framerate 30 -loop 1 -t 8 -i "$3" \
  -framerate 30 -loop 1 -t 23 -i "$4" \
  -filter_complex "\
    [0:v]zoompan=z='min(zoom+0.00020,1.055)':d=1:s=1280x720:fps=30,trim=duration=8,setpts=PTS-STARTPTS[a];\
    [1:v]zoompan=z='min(zoom+0.00020,1.055)':d=1:s=1280x720:fps=30,trim=duration=8,setpts=PTS-STARTPTS[b];\
    [2:v]zoompan=z='min(zoom+0.00020,1.055)':d=1:s=1280x720:fps=30,trim=duration=8,setpts=PTS-STARTPTS[c];\
    [a][b]xfade=transition=fade:duration=0.5:offset=7.5[ab];\
    [ab][c]xfade=transition=fade:duration=0.5:offset=15.0[abc];\
    [abc][3:v]overlay=0:0:format=auto,format=yuv420p[out]" \
  -map '[out]' -an -c:v libx264 -preset veryfast -crf 20 -movflags +faststart "$5"
