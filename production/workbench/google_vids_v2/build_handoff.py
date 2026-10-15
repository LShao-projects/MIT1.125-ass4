#!/usr/bin/env python3
"""Extract exact approved narration and timing for the video editor handoff."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
APPROVED = ROOT / "runs/live-20261013T181427Z/package/video_scripts"
OUT = Path(__file__).resolve().parent / "handoff"


def parse_script(path: Path) -> list[dict[str, str]]:
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("| ") or "–" not in line.split("|", 2)[1]:
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) != 7:
            raise ValueError(f"Unexpected table width in {path}: {len(cells)}")
        rows.append(dict(zip(
            ("time", "narration", "visual_action", "on_screen_text", "audio_cue", "asset_notes", "claim_ids"),
            cells,
        )))
    if not rows:
        raise ValueError(f"No timed narration found in {path}")
    return rows


def main() -> None:
    OUT.mkdir(exist_ok=True)
    for number in ("01", "02", "03"):
        rows = parse_script(APPROVED / f"{number}.md")
        (OUT / f"episode{number}_segments.json").write_text(
            json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        (OUT / f"episode{number}_narration.txt").write_text(
            "\n\n".join(f"[{row['time']}]\n{row['narration']}" for row in rows) + "\n",
            encoding="utf-8",
        )


if __name__ == "__main__":
    main()
