#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 || ! -d "$1" ]]; then
  echo "usage: bash processing/extract_content.sh RUN_DIR [--retain-accepted-media]" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
export PYTHONDONTWRITEBYTECODE=1
if [[ $# -eq 2 ]]; then
  if [[ "$2" != "--retain-accepted-media" ]]; then
    echo "unknown extract_content option: $2" >&2
    exit 2
  fi
  exec python3 processing/retain_selected_media.py "$1"
fi
exec python3 processing/extract_content.py "$1"
