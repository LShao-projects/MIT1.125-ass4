"""Repair the displayed caption tails in the Episode 1 Google Vids export.

Google Vids retains the words in its transcript and WebVTT track, but its
styled on-screen captions stop early at several scene boundaries. This script
adds only those missing on-screen phrases to the exported MP4. It copies the
original Tova audio unchanged and leaves every other frame untouched apart
from a standard video re-encode.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


HERE = Path(__file__).resolve().parent
QA = HERE / "episode01_caption_qc"
SOURCE = QA / "episode01_caption_check.mp4"
OUTPUT = HERE.parents[1] / "final_videos" / "episode_01_final.mp4"
FONT = Path("/System/Library/Fonts/Menlo.ttc")

# Times are global seconds in the exported video. Each starts immediately
# after the preceding Google Vids caption disappears.
MISSING = [
    (22.56, 24.68, "see what each actually changes."),
    (46.60, 49.18, "That still needs a real listening check."),
    (72.90, 75.98, "It does not answer that listening question."),
    (97.90, 100.18, "exit sounds better in a real song."),
    (108.10, 110.28, "your workspace, not this clip."),
    (143.60, 145.98, "only if it helps with that decision."),
    (192.40, 194.45, "is actually better for your music?"),
]


def make_overlay(path: Path, words: str) -> None:
    image = Image.new("RGBA", (1920, 1080), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    font = ImageFont.truetype(str(FONT), 51)
    left, top, right, bottom = draw.textbbox((0, 0), words, font=font)
    text_width = right - left
    box_width = min(1800, text_width + 48)
    x0 = (1920 - box_width) // 2
    y0 = 826
    draw.rectangle((x0, y0, x0 + box_width, 984), fill=(0, 0, 0, 255))
    draw.text(((1920 - text_width) / 2, 874 - top), words, font=font, fill="white")
    image.save(path)


def main() -> None:
    QA.mkdir(parents=True, exist_ok=True)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    images = []
    for number, (_, _, words) in enumerate(MISSING, start=1):
        path = QA / f"missing_caption_{number:02d}.png"
        make_overlay(path, words)
        images.append(path)

    command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(SOURCE)]
    for path in images:
        command.extend(["-loop", "1", "-framerate", "24", "-i", str(path)])

    parts = []
    previous = "[0:v]"
    for number, (start, end, _) in enumerate(MISSING, start=1):
        output = f"[v{number}]"
        parts.append(
            f"{previous}[{number}:v]overlay=0:0:format=auto:"
            f"enable='between(t,{start},{end})':eof_action=pass{output}"
        )
        previous = output
    command.extend(
        [
            "-filter_complex", ";".join(parts),
            "-map", previous,
            "-map", "0:a?",
            "-c:v", "libx264",
            "-preset", "medium",
            "-crf", "18",
            "-pix_fmt", "yuv420p",
            "-c:a", "copy",
            "-movflags", "+faststart",
            str(OUTPUT),
        ]
    )
    subprocess.run(command, check=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
