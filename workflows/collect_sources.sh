#!/usr/bin/env bash
set -u -o pipefail

if [[ $# -ne 1 || ! -d "$1" ]]; then
  echo "usage: bash workflows/collect_sources.sh RUN_DIR" >&2
  exit 2
fi
run_dir=$(cd "$1" && pwd)
cd "$(dirname "$0")/.."
started_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
if [[ ! -f "$run_dir/run.json" || ! -f "$run_dir/config/sources.json" ]]; then
  echo "run metadata and sources snapshot are required" >&2
  exit 2
fi

mkdir -p "$run_dir/candidates" "$run_dir/logs"
status_file="$run_dir/logs/collection_stage_status.tsv"
: > "$status_file"

record_status() {
  local stage=$1 rc=$2
  printf '%s\t%s\n' "$stage" "$rc" >> "$status_file"
  if [[ $rc -ne 0 ]]; then
    echo "$stage incomplete (exit $rc); valid partial output is retained" >&2
  fi
}

bash data/store.sh init
record_status store_init $?

bash collectors/fetch_feeds.sh "$run_dir" > "$run_dir/candidates/feeds.jsonl"
record_status fetch_feeds $?
bash collectors/fetch_youtube.sh "$run_dir" > "$run_dir/candidates/youtube.jsonl"
record_status fetch_youtube $?
bash collectors/fetch_podcasts.sh "$run_dir" > "$run_dir/candidates/podcasts.jsonl"
record_status fetch_podcasts $?
if [[ -f "$run_dir/config/supplemental_urls.json" ]]; then
  bash collectors/fetch_web.sh "$run_dir" > "$run_dir/candidates/web.jsonl"
  record_status fetch_web $?
fi

python3 - "$run_dir" <<'PY'
import json,sys
from pathlib import Path
p=Path(sys.argv[1]); seen=set(); errors=[]; count=0
sources=[p/'candidates'/name for name in ('feeds.jsonl','youtube.jsonl','podcasts.jsonl','web.jsonl')]
with (p/'candidates.jsonl').open('w') as out:
 for path in sources:
  if not path.exists():continue
  for n,line in enumerate(path.read_text().splitlines(),1):
   if not line.strip():continue
   try:
    record=json.loads(line)
    for key in ('item_id','source_id','publisher_id','kind','title','url','retrieved_at'):
     if key not in record:raise ValueError('missing '+key)
    if record['item_id'] in seen:continue
    seen.add(record['item_id']);out.write(json.dumps(record,ensure_ascii=False)+'\n');count+=1
   except Exception as e:errors.append(f'{path.name}:{n}: {type(e).__name__}: {e}')
(p/'logs'/'combine_errors.json').write_text(json.dumps(errors,ensure_ascii=False,indent=2)+'\n')
print(f'combined {count} distinct candidates; {len(errors)} malformed records',file=sys.stderr)
sys.exit(1 if errors else 0)
PY
record_status combine_candidates $?

cat "$run_dir/candidates.jsonl" | bash processing/extract_content.sh "$run_dir" > "$run_dir/items.jsonl"
record_status extract_content $?
cat "$run_dir/items.jsonl" | bash data/store.sh upsert "$run_dir" > "$run_dir/changes.jsonl"
record_status store_upsert $?
bash data/store.sh list > "$run_dir/corpus.jsonl"
record_status store_list $?
cat "$run_dir/corpus.jsonl" | bash processing/filter_items.sh "$run_dir" > "$run_dir/eligible.jsonl"
record_status filter_items $?

python3 - "$run_dir" "$started_at" <<'PY'
import datetime as dt,json,sys
from pathlib import Path
p=Path(sys.argv[1]); statuses={}
for line in (p/'logs'/'collection_stage_status.tsv').read_text().splitlines():
 name,code=line.split('\t');statuses[name]=int(code)
counts={name:sum(1 for line in (p/name).read_text().splitlines() if line.strip())
        for name in ['candidates.jsonl','items.jsonl','changes.jsonl','corpus.jsonl','eligible.jsonl','exclusions.jsonl']
        if (p/name).exists()}
now=dt.datetime.now(dt.timezone.utc).isoformat(timespec='seconds').replace('+00:00','Z')
receipt={'stage':'collect_sources','status':'complete' if all(v==0 for v in statuses.values()) else 'incomplete',
         'started_at':sys.argv[2],
         'stage_exit_codes':statuses,'counts':counts,'finished_at':now,
         'tools_or_models':['Bash coordination'],'cost_usd':None,'cost_estimate':False,
         'errors':[name for name,code in statuses.items() if code!=0]}
(p/'logs'/f'collect_sources_{dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")}.json').write_text(
 json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(receipt,ensure_ascii=False),file=sys.stderr)
sys.exit(0 if receipt['status']=='complete' else 1)
PY
