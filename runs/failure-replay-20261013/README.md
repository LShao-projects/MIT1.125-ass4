# Deliberate RSS failure replay — 2026-10-13

This is a **simulated failure replay**, not a live complete run. The source snapshot adds `intentional-broken-feed-replay` at `http://127.0.0.1:9/ass4-intentional-failure`. The normal `config/sources.json` was not changed.

I ran `bash workflows/collect_sources.sh runs/failure-replay-20261013`. The RSS collector reported `Connection refused` and exit code 1. The workflow retained the valid sources from the other endpoints and continued through extraction, store upsert, corpus listing, and date filtering. It produced 20 candidates and 20 extracted items, with 21 eligible corpus items including one previously stored source. Its final receipt reports `status: incomplete`, `stage_exit_codes.fetch_feeds: 1`, and `errors: ["fetch_feeds"]`; the command returned exit code 1. The error was not silently converted to an empty successful feed.

Inspect `logs/collection_stage_status.tsv`, the `fetch_feeds_*.json` receipt, `logs/collect_sources_*.json`, and the retained `candidates/`, `items.jsonl`, and `eligible.jsonl` outputs. No audio or video was played or retained for this replay.
