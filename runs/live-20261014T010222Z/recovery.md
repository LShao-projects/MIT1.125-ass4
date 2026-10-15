# Second live run: failed selection and recovery

The 2026-10-14 UTC live run collected 20 candidates and produced 22 eligible records, including still-current prior evidence. Its first AI selection accepted 13 items but assigned only Suno (one publisher) to piece 01. `create_briefs` correctly stopped because each piece requires at least three independent publishers. The original selection and failed summary remain in `decisions.initial.jsonl` and `summary.initial.json`; the failed stage receipt remains under `logs/`.

The selection component was updated to check independent publisher coverage for all three pieces before emitting decisions. It now makes one evidence-constrained retry if coverage is short, and fails clearly if the second answer is still insufficient. The top-level selection prompt was also updated for future runs. This run's snapshotted prompt was deliberately left intact.

The same saved eligible evidence was reselected without recollection. The recovered decisions accepted 13 items and assigned 4, 7, and 5 distinct publishers to pieces 01, 02, and 03 respectively. The four previously retained accepted media files passed SHA-256 checks and were reused. Briefs, three article drafts, three video scripts, and the content review then completed. The current `summary.json` reports `awaiting_review` with no incomplete stages. The student has approved the prior run's drafts, not these newly generated drafts.

The new candidate concerned AI bots and ticket scalping, not Suno's music-creation question, and was rejected. The item marked `changed` had changed related-story links in its extracted page text; the substantive Suno article passage did not change. Neither observation was treated as independent evidence for a new editorial claim.
