# Simulated 30-day date-boundary replay

This is a labeled component demonstration, not a live collection run and not evidence for the Suno articles. The two input records are synthetic. For an October 15, 2026 UTC run, the 30 eligible calendar dates are September 16 through October 15 inclusive. The first synthetic record is dated September 15; the second is dated September 16.

Run with:

```bash
bash processing/filter_items.sh runs/date-window-replay-20261015 < runs/date-window-replay-20261015/input.jsonl > runs/date-window-replay-20261015/eligible.jsonl
```

The expected result is one `outside_window` record in `exclusions.jsonl` with the explicit date interval, and one record in `eligible.jsonl`. The stage receipt in `logs/` reports two inputs, one eligible output, and one exclusion. This replay shows the boundary behavior of the required filter without claiming that a real old source was newly collected.
