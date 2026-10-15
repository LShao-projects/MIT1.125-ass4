#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: bash editorial/create_briefs.sh RUN_DIR" >&2
  exit 2
fi

run_dir=$(cd "$1" && pwd)
cd "$(dirname "$0")/.."
export PYTHONDONTWRITEBYTECODE=1
exec python3 editorial/create_briefs.py "$run_dir"
