#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: bash reporting/summarize_run.sh RUN_DIR" >&2
  exit 2
fi
run_dir=$(cd "$1" && pwd)
cd "$(dirname "$0")/.."
export PYTHONDONTWRITEBYTECODE=1
started_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
record_receipt() {
  local rc=$?
  trap - EXIT
  python3 reporting/write_stage_receipt.py "$run_dir" summarize_run "$started_at" "$rc" run.json stdout local || true
}
trap record_receipt EXIT
python3 reporting/summarize_run.py "$run_dir"
