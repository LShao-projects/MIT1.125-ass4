#!/usr/bin/env bash
set -u -o pipefail

cd "$(dirname "$0")"

if [[ $# -eq 2 && "$1" == "--package" ]]; then
  if [[ ! -d "$2" ]]; then
    echo "run directory not found: $2" >&2
    exit 2
  fi
  run_dir=$(cd "$2" && pwd)
  started_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  record_receipt() {
    local rc=$?
    trap - EXIT
    python3 reporting/write_stage_receipt.py "$run_dir" package_run "$started_at" "$rc" approval.json summary.json local || true
  }
  trap record_receipt EXIT
  review_rc=0
  bash review/check_content.sh "$run_dir" > "$run_dir/review.json" || review_rc=$?
  package_rc=0
  if [[ $review_rc -eq 0 ]]; then
    bash publishing/prepare_package.sh "$run_dir" > "$run_dir/package_result.json" || package_rc=$?
  else
    package_rc=$review_rc
  fi
  bash reporting/summarize_run.sh "$run_dir" > "$run_dir/summary.json"
  cat "$run_dir/summary.json"
  [[ $package_rc -eq 0 ]]
  exit $?
fi

if [[ $# -ne 0 ]]; then
  echo "usage: bash run.sh [--package runs/RUN_ID]" >&2
  exit 2
fi

python3 - <<'PY'
import json,sys
from pathlib import Path
root=Path.cwd()
project=json.loads((root/'config/project.json').read_text())
for key in ('publication_name','topic','audience','central_question'):
 if not isinstance(project.get(key),str) or not project[key].strip():
  sys.exit(f'config/project.json missing {key}')
sources=json.loads((root/'config/sources.json').read_text())
if not isinstance(sources,list) or not sources:
 sys.exit('config/sources.json needs sources')
for source in sources:
 for key in ('source_id','publisher_id','kind','url'):
  if not isinstance(source.get(key),str) or not source[key]:
   sys.exit(f'source missing {key}')
 if source['kind'] not in ('feed','youtube','podcast'):
  sys.exit('invalid source kind')
for name in ('editorial_policy.md',):
 if not (root/'config'/name).is_file():sys.exit(f'missing config/{name}')
for name in ('select_items.md','create_briefs.md','write_articles.md','write_video_scripts.md'):
 if not (root/'prompts'/name).is_file():sys.exit(f'missing prompts/{name}')
PY
if [[ $? -ne 0 ]]; then
  exit 2
fi

run_id="live-$(date -u '+%Y%m%dT%H%M%SZ')"
run_dir="runs/$run_id"
if [[ -e "$run_dir" ]]; then
  echo "run directory already exists: $run_dir" >&2
  exit 1
fi
mkdir -p "$run_dir/config" "$run_dir/prompts" "$run_dir/logs"
started_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
record_receipt() {
  local rc=$?
  trap - EXIT
  python3 reporting/write_stage_receipt.py "$run_dir" run "$started_at" "$rc" config/project.json summary.json local || true
}
trap record_receipt EXIT
cp config/project.json config/sources.json config/editorial_policy.md "$run_dir/config/"
if [[ -f config/supplemental_urls.json ]]; then
  cp config/supplemental_urls.json "$run_dir/config/"
fi
cp prompts/select_items.md prompts/create_briefs.md prompts/write_articles.md prompts/write_video_scripts.md "$run_dir/prompts/"

python3 - "$run_dir" "$run_id" <<'PY'
import datetime as dt,json,sys
from pathlib import Path
p=Path(sys.argv[1]); now=dt.datetime.now(dt.timezone.utc)
previous=sorted(Path('runs').glob('live-*/run.json'))
prior=[x.parent.name for x in previous if x.parent.name != sys.argv[2]]
record={'run_id':sys.argv[2], 'started_at':now.isoformat(timespec='seconds').replace('+00:00','Z'),
        'as_of_date':now.date().isoformat(),'mode':'live',
        'previous_run_id':prior[-1] if prior else None}
(p/'run.json').write_text(json.dumps(record,indent=2)+'\n')
PY

collection_rc=0
bash workflows/collect_sources.sh "$run_dir" || collection_rc=$?
series_rc=0
if [[ -s "$run_dir/eligible.jsonl" ]]; then
  bash workflows/create_series.sh "$run_dir" || series_rc=$?
else
  echo "No eligible evidence was produced; series workflow cannot start" >&2
  series_rc=1
fi
python3 - "$run_dir" <<'PY'
import datetime as dt,json,sys
from pathlib import Path
p=Path(sys.argv[1])/'run.json'
record=json.loads(p.read_text())
record['finished_at']=dt.datetime.now(dt.timezone.utc).isoformat(timespec='milliseconds').replace('+00:00','Z')
p.write_text(json.dumps(record,indent=2)+'\n')
PY
bash reporting/summarize_run.sh "$run_dir" > "$run_dir/summary.json"
cat "$run_dir/summary.json"
if [[ $collection_rc -ne 0 || $series_rc -ne 0 ]]; then
  exit 1
fi
