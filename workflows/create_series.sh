#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: bash workflows/create_series.sh RUN_DIR" >&2
  exit 2
fi
run_dir=$(cd "$1" && pwd)
cd "$(dirname "$0")/.."
mkdir -p "$run_dir/logs"

if [[ ! -f "$run_dir/eligible.jsonl" ]]; then
  echo "eligible.jsonl is missing; collect sources first" >&2
  exit 2
fi

python3 - "$run_dir" <<'PY'
import collections,json,sys
from pathlib import Path
r=Path(sys.argv[1]); items=[json.loads(x) for x in (r/'eligible.jsonl').read_text().splitlines() if x.strip()]
kinds=collections.Counter(x['kind'] for x in items)
publishers={x['publisher_id'] for x in items}
rss_written=sum(x['kind']=='feed' and x.get('rss_discovered',False) for x in items)
if len(items)<12 or len(publishers)<6 or rss_written<2 or kinds['youtube']<2 or kinds['podcast']<2:
 print(f'Insufficient eligible evidence: items={len(items)}, publishers={len(publishers)}, RSS written={rss_written}, YouTube={kinds["youtube"]}, podcasts={kinds["podcast"]}',file=sys.stderr)
 sys.exit(1)
PY

cat "$run_dir/eligible.jsonl" | bash editorial/select_items.sh "$run_dir" > "$run_dir/decisions.jsonl"
if ! bash processing/extract_content.sh "$run_dir" --retain-accepted-media; then
  echo "Accepted-media retrieval incomplete; see retained_media.jsonl and the stage receipt" >&2
fi
cat "$run_dir/decisions.jsonl" | bash editorial/create_briefs.sh "$run_dir" > "$run_dir/briefs.jsonl"
cat "$run_dir/briefs.jsonl" | bash content/write_articles.sh "$run_dir" > "$run_dir/articles.jsonl"
cat "$run_dir/briefs.jsonl" | bash content/write_video_scripts.sh "$run_dir" > "$run_dir/video_scripts.jsonl"
bash review/check_content.sh "$run_dir" > "$run_dir/review.json"

python3 - "$run_dir" <<'PY'
import json,sys
from pathlib import Path
r=Path(sys.argv[1]); review=json.loads((r/'review.json').read_text())
if not review.get('passed'):
 print('Content review found blocking errors; inspect review.json',file=sys.stderr)
 sys.exit(1)
PY
