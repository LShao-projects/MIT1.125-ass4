#!/usr/bin/env python3
"""Write a receipt for a Bash coordination or assessment entry point."""

import datetime as dt
import json
from pathlib import Path
import sys


def count(path):
    if path == "-":
        return 0
    source = Path(path)
    if not source.is_file():
        return 0
    if source.suffix == ".jsonl":
        return sum(bool(line.strip()) for line in source.read_text(encoding="utf-8").splitlines())
    return 1


def main():
    if len(sys.argv) != 8:
        print("usage: write_stage_receipt.py RUN_DIR STAGE STARTED_AT EXIT_CODE INPUT OUTPUT COST_KIND", file=sys.stderr)
        return 2
    _, run_name, stage, started_at, exit_text, input_name, output_name, cost_kind = sys.argv
    run = Path(run_name)
    exit_code = int(exit_text)
    finished = dt.datetime.now(dt.timezone.utc)
    if exit_code != 0:
        output_count = 0
    elif output_name == "stdout":
        output_count = 1
    else:
        output_count = count(run / output_name)
    receipt = {
        "stage": stage,
        "status": "complete" if exit_code == 0 else "incomplete",
        "input_count": count(run / input_name) if input_name != "-" else 0,
        "output_count": output_count,
        "started_at": started_at,
        "finished_at": finished.isoformat(timespec="seconds").replace("+00:00", "Z"),
        "tools_or_models": ["Bash coordination" if stage in ("run", "package_run", "create_series")
                            else "Python " + stage],
        "cost_usd": 0 if cost_kind == "local" else None,
        "cost_estimate": cost_kind == "local",
        "errors": [] if exit_code == 0 else [f"exit code {exit_code}; inspect stage output"],
    }
    logs = run / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    stamp = finished.strftime("%Y%m%dT%H%M%S%fZ")
    (logs / f"{stage}_{stamp}.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
