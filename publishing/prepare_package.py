#!/usr/bin/env python3
"""Prepare production handoff only after matching student approval."""

import datetime as dt
import json
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent


def records(path):
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def main():
    if len(sys.argv) != 2:
        print("usage: bash publishing/prepare_package.sh RUN_DIR", file=sys.stderr)
        return 2
    run = Path(sys.argv[1]).resolve()
    try:
        saved_review = json.loads((run / "review.json").read_text(encoding="utf-8"))
        approval = json.loads((run / "approval.json").read_text(encoding="utf-8"))
        result = subprocess.run(["bash", str(ROOT / "review/check_content.sh"), str(run)],
                                cwd=ROOT, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            raise ValueError("content check could not reassess current files")
        current_review = json.loads(result.stdout)
        if not current_review.get("passed"):
            raise ValueError("current content review has blocking errors")
        if current_review.get("review_id") != saved_review.get("review_id"):
            raise ValueError("review.json is stale; rerun check_content and obtain student review again")
        if approval.get("decision") != "approve" or approval.get("review_id") != current_review["review_id"]:
            raise ValueError("matching student approval is missing")
        if not all(isinstance(approval.get(k), str) and approval[k].strip()
                   for k in ("reviewer", "reviewed_at", "notes")):
            raise ValueError("approval lacks reviewer, reviewed_at, or notes")
        briefs = records(run / "briefs.jsonl")
        eligible = {x["item_id"]: x for x in records(run / "eligible.jsonl")}
        package = run / "package"
        package.mkdir(parents=True, exist_ok=True)
        assets = []
        for piece in ("01", "02", "03"):
            for folder in ("articles", "video_scripts"):
                source = run / folder / f"{piece}.md"
                target = package / folder / f"{piece}.md"
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, target)
                assets.append({"piece_id": piece, "kind": folder,
                               "path": str(target.relative_to(ROOT))})
            brief = next(b for b in briefs if b["piece_id"] == piece)
            seen = set()
            notes = [f"# Source notes — piece {piece}", "",
                     f"Review ID: `{current_review['review_id']}`", ""]
            for claim in brief["claims"]:
                notes.append(f"## {claim['claim_id']}: {claim['statement']}")
                notes.append("")
                for ref in claim["evidence"]:
                    item = eligible[ref["item_id"]]
                    loc = ref["locator"]
                    key = (ref["item_id"], ref["version_id"], json.dumps(loc, sort_keys=True))
                    if key in seen:
                        continue
                    seen.add(key)
                    where = loc.get("quote") if loc["type"] == "text" else loc.get("segment_id")
                    notes.append(f"- [{item['title']}]({item['url']}) — {item['publisher_id']}; "
                                 f"item `{item['item_id']}` version `{item['version_id']}`; "
                                 f"{loc['type']}: {where}")
                notes.append("")
            note_path = package / "source_notes" / f"{piece}.md"
            note_path.parent.mkdir(parents=True, exist_ok=True)
            note_path.write_text("\n".join(notes) + "\n", encoding="utf-8")
            assets.append({"piece_id": piece, "kind": "source_notes",
                           "path": str(note_path.relative_to(ROOT))})
        links_path = package / "publication_links.json"
        if not links_path.exists():
            links_path.write_text(json.dumps([
                {"piece_id": piece, "substack_url": None, "youtube_url": None}
                for piece in ("01", "02", "03")], indent=2) + "\n", encoding="utf-8")
        instructions = package / "manual_steps.md"
        instructions.write_text(
            "# Remaining manual steps\n\n"
            "1. The student reviews the approved article and video-script files again during production.\n"
            "2. Make each 3–5 minute video in Google Vids or HeyGen from its paired script; verify visuals, narration, attribution, and any AI-generated presentation.\n"
            "3. Upload the three videos to YouTube and publish the three free Substack articles. Link each article to its video, and each video description to the article and source notes.\n"
            "4. Replace null values in `publication_links.json` with real URLs and test all six links without a paywall.\n"
            "5. Record production changes and publish dates; if a substantive evidence claim changes, rerun review and seek a new approval.\n",
            encoding="utf-8")
        manifest = {"review_id": current_review["review_id"],
                    "prepared_at": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
                    "assets": assets, "publication_links": str(links_path.relative_to(ROOT)),
                    "manual_steps": str(instructions.relative_to(ROOT))}
        (package / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                                                encoding="utf-8")
        print(json.dumps(manifest, ensure_ascii=False))
        return 0
    except (OSError, ValueError, KeyError, StopIteration, json.JSONDecodeError) as exc:
        print(f"prepare_package: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
