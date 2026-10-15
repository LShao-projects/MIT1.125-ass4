#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: bash publishing/prepare_package.sh RUN_DIR" >&2
  exit 2
fi
run_dir=$(cd "$1" && pwd)
cd "$(dirname "$0")/.."
export PYTHONDONTWRITEBYTECODE=1
exec python3 publishing/prepare_package.py "$run_dir"
