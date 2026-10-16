# Historical receipt coverage audit

This audit was prepared after publication. It does not create or backdate receipts for the October 13–14 runs. The requirement in `ARCHITECTURE.md` is one uniquely named receipt for each stage invocation; the archived live runs do not fully meet that requirement.

| Stage | Historical receipt | Surviving outcome evidence |
| --- | --- | --- |
| `run.sh` | Missing | Each live run's `run.json`, stage outputs, and `summary.json` |
| `workflows/collect_sources.sh` | Present | `logs/collect_sources_*.json` and the separate collection streams |
| `workflows/create_series.sh` | Missing | `decisions.jsonl`, `briefs.jsonl`, article and script manifests, `review.json` |
| `review/check_content.sh` | Missing | `review.json`; this is an assessment output, not a stage receipt |
| `publishing/prepare_package.sh` | Missing for the approved first run | `package/manifest.json` and `package_result.json`; the later runs were not approved or packaged |
| `reporting/summarize_run.sh` | Missing | `summary.json`; this is a report output, not a stage receipt |

The collection, extraction, storage, filtering, AI selection, briefing, and generation stages have their original receipts under each run's `logs/` directory. Current entry point and workflow scripts call `reporting/write_stage_receipt.py` for future valid invocations. The first run's 13 accepted versus 12 cited items are also now surfaced by `review/check_content.py` and `reporting/summarize_run.py`; the historical `review.json` and `summary.json` are preserved as originally submitted.
