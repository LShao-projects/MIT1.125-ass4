#!/usr/bin/env python3
"""Check the three drafts against their exact, retained evidence references."""

import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parent.parent


def lines(path):
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def asset(relative):
    path = (ROOT / relative).resolve()
    if not path.is_relative_to((ROOT / "data/assets").resolve()):
        raise ValueError("evidence asset path escapes data/assets")
    return path


def word_count(content):
    body = re.split(r"(?im)^## (?:sources|references|source notes)\s*$", content)[0]
    return len(re.findall(r"\b[\w’'-]+\b", body))


def spoken_word_count(content):
    """Count narration, excluding storyboard metadata and source notes."""
    scene_lines = [line for line in content.splitlines() if re.match(r"^\| [0-9]:[0-9]{2}–", line)]
    if scene_lines:
        narration = " ".join(line.split("|")[2].strip() for line in scene_lines)
    else:
        blocks = re.findall(
            r"(?s)\*\*Narration:\*\*(.*?)(?=\n\*\*Visual:\*\*|\n## Sources|\Z)",
            content)
        narration = " ".join(blocks)
    narration = re.sub(r"\[[0-9]{2}-c[0-9]+\]", "", narration)
    return len(re.findall(r"\b[\w’'-]+\b", narration))


def main():
    if len(sys.argv) != 2:
        print("usage: bash review/check_content.sh RUN_DIR", file=sys.stderr)
        return 2
    run = Path(sys.argv[1]).resolve()
    issues = []
    fingerprint = hashlib.sha256()
    fingerprint.update(b"MIT1.125-ass4-review-v1\0")

    def issue(piece, artifact, severity, explanation):
        issues.append({"piece_id": piece, "artifact": artifact,
                       "severity": severity, "explanation": explanation})

    def read_file(path, required=True):
        if not path.is_file():
            if required:
                issue(None, str(path.relative_to(run)), "error", "Required file is missing")
            return None
        contents = path.read_bytes()
        fingerprint.update(str(path.relative_to(run)).encode() + b"\0" + contents + b"\0")
        return contents

    try:
        raw_run = read_file(run / "run.json")
        run_data = json.loads(raw_run) if raw_run else {}
        as_of = run_data.get("as_of_date")
        try:
            as_of_day = dt.date.fromisoformat(as_of)
        except (TypeError, ValueError):
            as_of_day = None
            issue(None, "run.json", "error", "Missing or invalid UTC as_of_date")

        raws = {name: read_file(run / f"{name}.jsonl") for name in
                ("eligible", "decisions", "briefs", "articles", "video_scripts")}
        parsed = {name: [json.loads(line) for line in data.decode().splitlines() if line.strip()]
                  if data is not None else [] for name, data in raws.items()}
        eligible = {x["item_id"]: x for x in parsed["eligible"]}
        decisions = {x["item_id"]: x for x in parsed["decisions"]}
        briefs = {x.get("piece_id"): x for x in parsed["briefs"]}
        article_manifests = {x.get("piece_id"): x for x in parsed["articles"]}
        script_manifests = {x.get("piece_id"): x for x in parsed["video_scripts"]}
        for name, group in (("briefs", briefs), ("articles", article_manifests),
                            ("video_scripts", script_manifests)):
            if set(group) != {"01", "02", "03"} or len(parsed[name]) != 3:
                issue(None, f"{name}.jsonl", "error", "Need exactly three distinct pieces 01, 02, 03")

        cited_kinds = set()
        for piece in ("01", "02", "03"):
            brief = briefs.get(piece)
            if brief is None:
                continue
            if not all(brief.get(key) for key in ("title", "question", "argument", "synthesis", "limitations")):
                issue(piece, "briefs.jsonl", "error", "Brief lacks required editorial content")
            claims = brief.get("claims", [])
            claim_ids = set()
            publishers = set()
            for claim in claims:
                cid = claim.get("claim_id")
                if not isinstance(cid, str) or not cid.startswith(piece + "-c") or cid in claim_ids:
                    issue(piece, "briefs.jsonl", "error", "Invalid or duplicate claim ID")
                claim_ids.add(cid)
                if claim.get("type") not in ("reported_fact", "source_claim", "inference"):
                    issue(piece, "briefs.jsonl", "error", f"{cid}: invalid claim type")
                refs = claim.get("evidence") or []
                if not refs:
                    issue(piece, "briefs.jsonl", "error", f"{cid}: claim has no evidence")
                ref_publishers = set()
                for ref in refs:
                    item = eligible.get(ref.get("item_id"))
                    if not item or item.get("version_id") != ref.get("version_id"):
                        issue(piece, "briefs.jsonl", "error", f"{cid}: cited version is absent")
                        continue
                    decision = decisions.get(item["item_id"], {})
                    if decision.get("decision") != "accept" or piece not in decision.get("piece_ids", []):
                        issue(piece, "briefs.jsonl", "error", f"{cid}: cited item not accepted for this piece")
                    publishers.add(item["publisher_id"])
                    ref_publishers.add(item["publisher_id"])
                    cited_kinds.add(item["kind"])
                    date_text = item.get("published_at")
                    try:
                        published = dt.date.fromisoformat(date_text[:10])
                        if as_of_day and not (as_of_day - dt.timedelta(days=29) <= published <= as_of_day):
                            issue(piece, "briefs.jsonl", "error", f"{cid}: source outside 30-day window")
                    except (TypeError, ValueError):
                        issue(piece, "briefs.jsonl", "error", f"{cid}: missing publication date")
                    locator = ref.get("locator", {})
                    if locator.get("type") == "text" and item["kind"] not in ("youtube", "podcast"):
                        text_path = asset(item["text_path"])
                        data = text_path.read_bytes()
                        fingerprint.update(data)
                        if locator.get("quote") not in data.decode("utf-8"):
                            issue(piece, "briefs.jsonl", "error", f"{cid}: text locator not found")
                    elif locator.get("type") == "segment" and item["kind"] in ("youtube", "podcast"):
                        seg_path = asset(item["segments_path"])
                        data = seg_path.read_bytes()
                        fingerprint.update(data)
                        segments = json.loads(data)
                        if locator.get("segment_id") not in {s["segment_id"] for s in segments}:
                            issue(piece, "briefs.jsonl", "error", f"{cid}: segment locator not found")
                    else:
                        issue(piece, "briefs.jsonl", "error", f"{cid}: locator/source mismatch")
                if claim.get("type") == "inference" and len(ref_publishers) < 2:
                    issue(piece, "briefs.jsonl", "error", f"{cid}: inference needs two independent publishers")
            if len(publishers) < 3:
                issue(piece, "briefs.jsonl", "error", "Piece cites fewer than three independent publishers")
            for label, manifests, folder in (("article", article_manifests, "articles"),
                                             ("video script", script_manifests, "video_scripts")):
                manifest = manifests.get(piece)
                if not manifest:
                    issue(piece, f"{folder}.jsonl", "error", f"Missing {label} manifest")
                    continue
                expected = f"runs/{run.name}/{folder}/{piece}.md"
                if manifest.get("path") != expected:
                    issue(piece, f"{folder}.jsonl", "error", f"{label} path does not match run artifact")
                data = read_file(run / folder / f"{piece}.md")
                if data is None:
                    continue
                content = data.decode("utf-8")
                if as_of and f"Evidence as of {as_of} UTC" not in content:
                    issue(piece, f"{folder}/{piece}.md", "error", f"{label} does not state the run's as-of date")
                markers = set(re.findall(r"\[([0-9]{2}-c[0-9]+)\]", content))
                if not markers or not markers.issubset(claim_ids):
                    issue(piece, f"{folder}/{piece}.md", "error", f"{label} has missing or unknown claim markers")
                if set(manifest.get("claim_ids", [])) != markers:
                    issue(piece, f"{folder}.jsonl", "error", f"{label} manifest markers differ from draft")
                if "http" not in content:
                    issue(piece, f"{folder}/{piece}.md", "error", f"{label} lacks reader-facing source links")
                words = word_count(content)
                if folder == "articles" and not (600 <= words <= 900):
                    issue(piece, f"{folder}/{piece}.md", "warning", f"Article body is about {words} words; target is 600–900")
                if folder == "video_scripts":
                    spoken_words = spoken_word_count(content)
                    if not (350 <= spoken_words <= 750):
                        issue(piece, f"{folder}/{piece}.md", "warning",
                              f"Narration is about {spoken_words} words; verify 3–5 minute delivery")
            am = article_manifests.get(piece, {})
            vm = script_manifests.get(piece, {})
            if am and vm and set(am.get("claim_ids", [])) != set(vm.get("claim_ids", [])):
                issue(piece, "articles/video_scripts", "warning", "Paired drafts cite different claim sets; inspect substantive consistency")
            issue(piece, "human_review", "warning", "Student must review factual scope, synthesis, source attribution, and article/script consistency")
        if not {"feed", "youtube", "podcast"}.issubset(cited_kinds):
            issue(None, "briefs.jsonl", "error", "Series does not cite all three required input types")
        review = {"review_id": fingerprint.hexdigest(),
                  "passed": not any(x["severity"] == "error" for x in issues),
                  "issues": issues}
        print(json.dumps(review, ensure_ascii=False, indent=2))
        return 0
    except (OSError, ValueError, TypeError, KeyError, json.JSONDecodeError) as exc:
        print(f"check_content could not assess run: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
