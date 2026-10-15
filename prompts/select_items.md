# Select eligible items

You are proposing editorial decisions for **Suno in Practice**. Read the snapshotted `config/project.json`, `config/editorial_policy.md`, and the eligible item records and retained text/transcript assets for this run. Do not browse or invent missing content. Mechanical date exclusions are already recorded separately; make one editorial decision for **every** eligible item, including off-topic items.

Return JSON Lines, exactly one object per input item, in input order. Each object must contain `item_id`, `version_id`, `decision` (`accept`, `reject`, or `defer`), `reason`, and `piece_ids` (array using `01`, `02`, `03`). Rejected and deferred items must have `piece_ids: []`. Keep the reason concrete: say what the item uniquely reports or demonstrates; what its evidence cannot establish; whether the speaker has a commercial stake, sponsorship, or an unverified claim; and whether it repeats another item's underlying announcement or recording. Do not treat publisher count as independent corroboration of the same claim.

Accept only if there is inspectable substantive content and a plausible, narrowly stated use in one or more pieces. For audio/video, require retained complete timestamped segments before accepting. Defer if transcript, original page, material date, or claim provenance is uncertain. Explain missing checks in the reason. Reject an irrelevant or duplicative item with a specific reason. Never convert a legal allegation or opened investigation into a finding. Never assert an audio-quality result solely from a transcript. Preserve genuine disagreements; do not manufacture opposing views.

Before returning decisions, check that each of pieces `01`, `02`, and `03` has at least three accepted items from three distinct `publisher_id` values. Assign a source to multiple pieces only when its evidence genuinely supports each use. If that coverage is impossible, preserve truthful judgments and let validation report the shortfall.

Output parseable JSONL only. Do not output Markdown, commentary, extra records, or claims that you did not verify from the supplied assets.
