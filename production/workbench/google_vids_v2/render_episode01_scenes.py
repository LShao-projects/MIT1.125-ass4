#!/usr/bin/env python3
"""Render silent scene-length motion plates for Google Vids episode 1."""

import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "episode01_scene_clips"
OUT.mkdir(exist_ok=True)

# Durations follow the approved narration rows. These are edit plates and
# carry no Suno audio, real UI, or claim of having tested the controls.
SCENES = [
    (2, 30, "Does it land on beat one?", "Suno release note · October 8",
     ["episode01_timeline_closeup.png", "episode01_notebook_closeup.png", "episode01_stretch_closeup.png", "episode01_studio_plate.png"]),
    (3, 29, "Can it fill the bar?", "Suno release note · October 8",
     ["episode01_notebook_closeup.png", "episode01_stretch_closeup.png", "episode01_timeline_closeup.png", "episode01_stretch_closeup.png"]),
    (4, 28, "Which exit fits the song?", "Suno release note · October 8",
     ["episode01_fade_choice.png", "episode01_notebook_closeup.png", "episode01_timeline_closeup.png", "episode01_fade_choice.png"]),
    (5, 10, "Pop-out windows", "Suno release note · October 8",
     ["episode01_studio_plate.png", "episode01_stems_closeup.png"]),
    (6, 44, "Keep the idea. Shape the result.", "On a Creative Journey · Todd Edwards",
     ["episode01_stems_closeup.png", "episode01_timeline_closeup.png", "episode01_notebook_closeup.png", "episode01_studio_plate.png", "episode01_stems_closeup.png"]),
    (7, 52, "Test before you regenerate.", "Evidence as of October 13, 2026",
     ["episode01_notebook_closeup.png", "episode01_stretch_closeup.png", "episode01_fade_choice.png", "episode01_stems_closeup.png", "episode02_ab_choice.png", "episode01_studio_plate.png"]),
]


def run_scene(number: int, seconds: int, caption: str, source: str, shots: list[str]) -> None:
    overlay = OUT / f"scene{number:02d}_overlay.png"
    subprocess.run([
        "swift", "-module-cache-path", "/private/tmp/ass4-swift-cache",
        str(HERE / "render_scene_overlay.swift"), caption, source, str(overlay),
    ], check=True)
    cmd = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y"]
    shot_seconds = seconds / len(shots)
    for shot in shots:
        cmd += ["-framerate", "30", "-loop", "1", "-t", str(shot_seconds), "-i", str(HERE / shot)]
    cmd += ["-framerate", "30", "-loop", "1", "-t", str(seconds), "-i", str(overlay)]
    chains = []
    for i in range(len(shots)):
        chains.append(
            f"[{i}:v]zoompan=z='min(zoom+0.00016,1.05)':d=1:s=1280x720:fps=30,"
            f"trim=duration={shot_seconds},setpts=PTS-STARTPTS[v{i}]"
        )
    video_inputs = "".join(f"[v{i}]" for i in range(len(shots)))
    chains.append(f"{video_inputs}concat=n={len(shots)}:v=1:a=0[sequence]")
    chains.append(f"[sequence][{len(shots)}:v]overlay=0:0:format=auto,format=yuv420p[out]")
    cmd += ["-filter_complex", ";".join(chains), "-map", "[out]", "-an", "-c:v", "libx264",
            "-preset", "veryfast", "-crf", "20", "-movflags", "+faststart",
            str(OUT / f"scene{number:02d}_{seconds}s.mp4")]
    subprocess.run(cmd, check=True)
    overlay.unlink()


if __name__ == "__main__":
    for args in SCENES:
        run_scene(*args)
        print(f"Rendered scene {args[0]}", flush=True)
