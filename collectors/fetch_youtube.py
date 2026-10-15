#!/usr/bin/env python3
"""Read native YouTube metadata without fetching or playing video/audio."""

import datetime as dt
import json
from pathlib import Path
import subprocess
import sys


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def candidate(source):
    result = subprocess.run(["yt-dlp", "-J", "--skip-download", "--no-warnings", source["url"]],
                            capture_output=True, text=True, check=True, timeout=90)
    info = json.loads(result.stdout)
    timestamp = info.get("release_timestamp") or info.get("timestamp")
    if timestamp:
        published_at = dt.datetime.fromtimestamp(timestamp, dt.timezone.utc).isoformat().replace("+00:00", "Z")
        precision = "second"
    else:
        date = dt.datetime.strptime(info["upload_date"], "%Y%m%d").date()
        published_at = date.isoformat() + "T00:00:00Z"
        precision = "day; time is a UTC placeholder"
    return {"item_id": "youtube:" + info["id"], "source_id": source["source_id"],
            "publisher_id": source["publisher_id"], "kind": "youtube",
            "title": info["title"], "url": "https://www.youtube.com/watch?v=" + info["id"],
            "published_at": published_at, "published_at_precision": precision,
            "retrieved_at": now(), "media_url": None}


def main():
    if len(sys.argv) != 2:
        print("usage: fetch_youtube.sh RUN_DIR", file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    source_file = run_dir / "config" / "sources.json"
    if not source_file.is_file():
        print("missing run source snapshot", file=sys.stderr)
        return 2
    sources = [s for s in json.loads(source_file.read_text()) if s.get("kind") == "youtube" and s.get("enabled", True)]
    started = now()
    count = 0
    errors = []
    for source in sources:
        try:
            print(json.dumps(candidate(source), ensure_ascii=False), flush=True)
            count += 1
        except Exception as exc:
            errors.append(f"{source['source_id']}: {type(exc).__name__}: {exc}")
    log_dir = run_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "fetch_youtube", "status": "complete" if not errors else "incomplete",
               "input_count": len(sources), "output_count": count, "started_at": started,
               "finished_at": now(), "tools_or_models": ["yt-dlp metadata only"],
               "cost_usd": 0, "cost_estimate": True, "errors": errors,
               "media_downloaded": False}
    (log_dir / f"fetch_youtube_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
