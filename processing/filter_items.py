#!/usr/bin/env python3
"""Mechanical 30-calendar-day UTC eligibility filter."""

import datetime as dt
import json
from pathlib import Path
import sys


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def published_day(value):
    if value is None or value == "":
        return None, "unknown_date"
    try:
        instant = dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
        if instant.tzinfo is None:
            return None, "invalid_date"
        return instant.astimezone(dt.timezone.utc).date(), None
    except (ValueError, TypeError):
        return None, "invalid_date"


def main():
    if len(sys.argv) != 2:
        print("usage: filter_items.sh RUN_DIR", file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    try:
        run = json.loads((run_dir / "run.json").read_text())
        end = dt.date.fromisoformat(run["as_of_date"])
    except (OSError, ValueError, KeyError) as exc:
        print(f"invalid run date: {exc}", file=sys.stderr)
        return 2
    start = end - dt.timedelta(days=29)
    started = now()
    count = 0
    accepted = 0
    exclusions = []
    errors = []
    for line_number, line in enumerate(sys.stdin, 1):
        if not line.strip():
            continue
        count += 1
        try:
            item = json.loads(line)
            day, reason = published_day(item.get("published_at"))
            if reason is None:
                if day > end:
                    reason = "future_date"
                elif day < start:
                    reason = "outside_window"
            if reason:
                exclusions.append({"item_id": item["item_id"], "version_id": item["version_id"],
                                   "reason": reason, "detail": f"published_at={item.get('published_at')!r}; UTC window={start}..{end}"})
            else:
                print(json.dumps(item, ensure_ascii=False), flush=True)
                accepted += 1
        except (ValueError, KeyError, TypeError) as exc:
            errors.append(f"input line {line_number}: {type(exc).__name__}: {exc}")
    (run_dir / "exclusions.jsonl").write_text("".join(json.dumps(x, ensure_ascii=False) + "\n" for x in exclusions))
    logs = run_dir / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "filter_items", "status": "complete" if not errors else "incomplete",
               "input_count": count, "output_count": accepted, "excluded_count": len(exclusions),
               "started_at": started, "finished_at": now(),
               "tools_or_models": ["Python datetime UTC"], "cost_usd": 0,
               "cost_estimate": True, "errors": errors}
    (logs / f"filter_items_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
