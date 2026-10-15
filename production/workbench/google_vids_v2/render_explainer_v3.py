#!/usr/bin/env python3
"""Render content-specific, silent scene clips for episode 1.

Every card is an original illustration, never a Suno interface or sound test.
The clips are scene-length edit assets for Google Vids, not publishable videos.
"""

from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "episode01_explainer_v3"
CARDS = OUT / "cards"
CARDS.mkdir(parents=True, exist_ok=True)

# Each row is (visual kind, seconds, headline, contextual line, attribution).
SCENES = {
    1: [
        ("photo", 4, "Keep it, or start over?", "A four-bar demo and one promising phrase", "Evidence as of October 13, 2026"),
        ("melody", 7, "Your melody has four bars", "A fictional songwriter's starting idea", "Original illustration"),
        ("late", 8, "The new phrase enters late", "The part is worth keeping; the timing is not", "Original illustration"),
        ("choice", 8, "What would you change?", "Regenerate everything, or edit one clip?", "Original illustration"),
    ],
    2: [
        ("late", 6, "First: the entrance", "The existing phrase misses beat one", "Original illustration"),
        ("beat", 8, "Studio detects beat one more accurately", "A claim about newly created clips", "Suno release note · October 8"),
        ("ghost", 8, "A new take might land closer", "The older clip does not repair itself", "Suno release note · October 8"),
        ("compare", 8, "Which entrance fits?", "A listening check remains necessary", "Our analysis · no actual Suno test"),
    ],
    3: [
        ("short", 6, "Then the phrase ends early", "One bar still has empty space", "Original illustration"),
        ("stretch", 8, "Stretch the selected clip", "Shift + click + drag changes its length", "Suno release note · October 8"),
        ("fill", 8, "It reaches the bar line", "The diagram shows an editing option", "Original illustration"),
        ("listen", 7, "But does it sound natural?", "Control availability is not a quality result", "Our analysis · no actual Suno test"),
    ],
    4: [
        ("hard", 6, "Now the ending feels abrupt", "Timing and exit are different problems", "Original illustration"),
        ("fadeA", 7, "Try one fade curve", "Shape how the phrase leaves", "Suno release note · October 8"),
        ("fadeB", 7, "Or another curve", "Neither option is marked as better", "Suno release note · October 8"),
        ("listen", 8, "Choose with your ears", "We have not tested either exit in a real song", "Our analysis · no actual Suno test"),
    ],
    5: [
        ("windows", 5.5, "A fourth change: pop-out windows", "Move synth, typing, and plug-in views", "Suno release note · October 8"),
        ("workspace", 5.5, "More room to work", "Window layout does not fix this phrase", "Suno release note · October 8"),
    ],
    6: [
        ("fork", 6, "Why keep an editable phrase?", "Two creators describe distinct workflows", "Attributed creator accounts"),
        ("stems", 8, "One creator worked with five stems", "Separate tracks from generated material", "On a Creative Journey · October 9"),
        ("clean", 7, "Then changed the material", "Noise removal, tone, and dynamics", "On a Creative Journey · October 9"),
        ("sample", 8, "Another creator sampled it", "Generated material entered a larger practice", "Todd Edwards via MusicRadar · September 29"),
        ("converge", 8, "Two paths, one editorial point", "Creators shape material after generation", "On a Creative Journey · Todd Edwards"),
        ("limits", 7, "The important limit", "Neither account tests the October Studio controls", "Our source comparison"),
    ],
    7: [
        ("recap", 7, "Can we save this clip?", "Three specific changes to try", "Suno release note · October 8"),
        ("beat", 7, "1. Check the new entrance", "Compare it against your own beat", "Suno release note · October 8"),
        ("stretch", 7, "2. Stretch the chosen phrase", "Keep the original version beside it", "Suno release note · October 8"),
        ("fadeA", 7, "3. Shape the exit", "One change at a time, then listen", "Suno release note · October 8"),
        ("version", 8, "Keep the original", "A fair comparison needs a reference", "Our proposed listening process"),
        ("evidence", 8, "What do the sources establish?", "A control exists; a better song is unproven", "Suno · creator accounts · our analysis"),
        ("ab", 8, "Next: which version is better?", "The decision becomes an A/B listening test", "Episode 2 preview"),
    ],
}


def render_card(scene: int, index: int, row: tuple) -> Path:
    kind, _, title, subtitle, source = row
    path = CARDS / f"s{scene:02d}_{index:02d}_{kind}.png"
    subprocess.run([
        "swift", "-module-cache-path", "/private/tmp/ass4-swift-cache",
        str(ROOT / "render_explainer_card.swift"), kind, title, subtitle, source, str(path)
    ], check=True)
    return path


def render_scene(scene: int, rows: list[tuple]) -> Path:
    cards = [render_card(scene, i, row) for i, row in enumerate(rows, start=1)]
    duration = sum(row[1] for row in rows)
    output = OUT / f"scene{scene:02d}_{duration:g}s.mp4"
    cmd = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y"]
    for card, row in zip(cards, rows):
        cmd += ["-framerate", "24", "-loop", "1", "-t", str(row[1]), "-i", str(card)]
    chains = []
    for i, row in enumerate(rows):
        frames = round(row[1] * 24)
        chains.append(
            f"[{i}:v]zoompan=z='min(zoom+0.00022,1.025)':d=1:s=1280x720:fps=24,"
            f"trim=end_frame={frames},setpts=PTS-STARTPTS[v{i}]"
        )
    chains.append("".join(f"[v{i}]" for i in range(len(rows))) +
                  f"concat=n={len(rows)}:v=1:a=0,format=yuv420p[out]")
    cmd += ["-filter_complex", ";".join(chains), "-map", "[out]", "-an", "-c:v", "libx264",
            "-preset", "veryfast", "-crf", "19", "-movflags", "+faststart", str(output)]
    subprocess.run(cmd, check=True)
    return output


if __name__ == "__main__":
    for scene, rows in SCENES.items():
        output = render_scene(scene, rows)
        print(output, flush=True)
