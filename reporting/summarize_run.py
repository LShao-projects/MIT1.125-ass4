#!/usr/bin/env python3
"""Summarize a complete or interrupted assignment run without inventing counts."""

import collections
import datetime as dt
import json
from pathlib import Path
import sys


def read_json(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def read_lines(path):
    try:
        return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    except (OSError, json.JSONDecodeError):
        return None


def count(records):
    return len(records) if records is not None else None


def main():
    if len(sys.argv) != 2:
        print("usage: bash reporting/summarize_run.sh RUN_DIR", file=sys.stderr)
        return 2
    run = Path(sys.argv[1]).resolve()
    metadata = read_json(run / "run.json") or {}
    candidates = read_lines(run / "candidates.jsonl")
    items = read_lines(run / "items.jsonl")
    changes = read_lines(run / "changes.jsonl")
    eligible = read_lines(run / "eligible.jsonl")
    exclusions = read_lines(run / "exclusions.jsonl")
    decisions = read_lines(run / "decisions.jsonl")
    articles = read_lines(run / "articles.jsonl")
    videos = read_lines(run / "video_scripts.jsonl")
    review = read_json(run / "review.json")
    approval = read_json(run / "approval.json")
    package = read_json(run / "package/manifest.json")

    counts = {
        "discovered": count(candidates), "extracted": count(items),
        "new": None, "changed": None, "unchanged": None,
        "eligible": count(eligible), "excluded": count(exclusions),
        "accepted": None, "rejected": None, "deferred": None,
        "articles": count(articles), "video_scripts": count(videos),
    }
    if changes is not None:
        kinds = collections.Counter(x.get("change") for x in changes)
        for key in ("new", "changed", "unchanged"):
            counts[key] = kinds[key]
    if decisions is not None:
        kinds = collections.Counter(x.get("decision") for x in decisions)
        for field, key in (("accepted", "accept"), ("rejected", "reject"), ("deferred", "defer")):
            counts[field] = kinds[key]

    coverage = {"eligible_by_kind": None, "eligible_publishers": None,
                "accepted_by_kind": None, "accepted_publishers": None,
                "rss_written_eligible": None, "raw_observations": None,
                "duplicate_observations": None}
    if eligible is not None:
        coverage["eligible_by_kind"] = dict(collections.Counter(x.get("kind") for x in eligible))
        coverage["eligible_publishers"] = len({x.get("publisher_id") for x in eligible})
        coverage["rss_written_eligible"] = sum(x.get("kind") == "feed" and x.get("rss_discovered", False)
                                                for x in eligible)
    if decisions is not None and eligible is not None:
        by_id = {x["item_id"]: x for x in eligible}
        accepted = [by_id[x["item_id"]] for x in decisions
                    if x.get("decision") == "accept" and x.get("item_id") in by_id]
        coverage["accepted_by_kind"] = dict(collections.Counter(x.get("kind") for x in accepted))
        coverage["accepted_publishers"] = len({x.get("publisher_id") for x in accepted})
    if candidates is not None:
        coverage["raw_observations"] = len(candidates)
        coverage["duplicate_observations"] = len(candidates) - len({x.get("item_id") for x in candidates})

    receipts = []
    for path in (run / "logs").glob("*.json") if (run / "logs").is_dir() else []:
        entry = read_json(path)
        if isinstance(entry, dict) and "stage" in entry and "status" in entry:
            receipts.append(entry)
    latest = {}
    for entry in receipts:
        stage = entry["stage"]
        if stage not in latest or entry.get("finished_at", "") > latest[stage].get("finished_at", ""):
            latest[stage] = entry
    failed = sorted(stage for stage, entry in latest.items() if entry.get("status") != "complete")
    tools_models = sorted({tool for x in receipts for tool in x.get("tools_or_models", [])})
    known_costs = [x["cost_usd"] for x in receipts if isinstance(x.get("cost_usd"), (int, float))]
    unknown_cost_stages = sorted({x["stage"] for x in receipts if x.get("cost_usd") is None})
    started = metadata.get("started_at")
    finished = metadata.get("finished_at")
    elapsed = None
    if isinstance(started, str):
        try:
            begin = dt.datetime.fromisoformat(started.replace("Z", "+00:00"))
            end = (dt.datetime.fromisoformat(finished.replace("Z", "+00:00"))
                   if isinstance(finished, str) else dt.datetime.now(dt.timezone.utc))
            elapsed = round((end - begin).total_seconds(), 1)
        except ValueError:
            pass
    if failed:
        status = "failed"
    elif review and review.get("passed") and approval and approval.get("decision") == "approve" \
            and approval.get("review_id") == review.get("review_id") and package:
        status = "ready_for_production"
    elif review and review.get("passed"):
        status = "awaiting_review"
    else:
        status = "failed"
    remaining = []
    if status == "failed":
        remaining.append("Repair incomplete or failing pipeline stages and rerun content checks")
    elif status == "awaiting_review":
        remaining.extend(["Student review of the three articles and three video scripts",
                          "Student approval or revision recorded against the current review_id"])
    else:
        remaining.extend(["Produce three Google Vids or HeyGen videos from reviewed scripts",
                          "Publish three Substack articles and three YouTube videos",
                          "Fill real publication links and verify access"])
    summary = {"run_id": metadata.get("run_id", run.name), "mode": metadata.get("mode"),
               "as_of_date": metadata.get("as_of_date"), "status": status,
               "counts": counts, "coverage": coverage,
               "failed_or_incomplete_stages": failed,
               "elapsed_seconds": elapsed, "tools_or_models": tools_models,
               "known_cost_usd": sum(known_costs) if known_costs else None,
               "unknown_cost_stages": unknown_cost_stages,
               "review_id": review.get("review_id") if review else None,
               "remaining_manual_actions": remaining}
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
