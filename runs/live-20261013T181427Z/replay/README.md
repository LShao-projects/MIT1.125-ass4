# Same-input store replay — 2026-10-13

This is a **labeled replay**, not a second live pipeline run. I ran `bash data/store.sh upsert runs/live-20261013T181427Z < runs/live-20261013T181427Z/items.jsonl` again on the exact 20 saved item records. The replay emitted 20 `unchanged` changes, zero `new`, and zero `changed` in `changes.jsonl`. The store interface returned 21 latest item records before and after the replay. No source media was fetched or played for this store-only check.

The live run's original `changes.jsonl` remains separate; it reported 1 new and 19 unchanged items. The replay receipt is under the parent run's `logs/` directory.
