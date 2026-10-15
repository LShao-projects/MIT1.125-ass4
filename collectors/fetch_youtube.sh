#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: bash collectors/fetch_youtube.sh RUN_DIR" >&2
  exit 2
fi
cd "$(dirname "$0")/.."
exec python3 collectors/fetch_youtube.py "$1"
