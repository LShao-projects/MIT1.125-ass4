# Editorial-policy revision and selection rerun — pilot, 2026-10-13

This comparison uses the **same 20 eligible source versions** as `../editorial-pilot-20261013/eligible.jsonl`. It is an editorial-stage pilot, not a second complete live pipeline run or a different-date run.

## Student inspection

The student reviewed three AI accepts (A1 Suno release notes, A2 Deezer search filter, A3 JG Beats Lab podcast) and three AI rejects (R1 UK cinema tariff, R2 producer-career interview, R3 Madverse distribution interview). They agreed with all six decisions. Their reasons and the assistant's separate evidence-boundary notes are in `../editorial-pilot-20261013/review_queue.md`. No AI decision was overturned by the student.

## Targeted policy change

After the student's R3 judgment, `config/editorial_policy.md` gained a specific relevance rule for piece 03. A music-industry article that merely mentions AI is insufficient. A platform or practitioner item needs a concrete, inspectable step or rule relevant to a Suno creator's release decision. A distributor's generic, commercially interested description of AI-powered back-office checks does not qualify without a stated rule, observable result, or documented Suno-assisted case. A planned listener-facing filter may be used only as a conditional discoverability example, with its scope and rollout status explicit.

The original policy is preserved at `../editorial-pilot-20261013/config/editorial_policy.md`; the revised policy used for this rerun is at `config/editorial_policy.md`. The original and rerun decisions are separately retained in each directory's `decisions.jsonl`.

## Result

| Measure | Before | After |
| --- | ---: | ---: |
| Eligible source versions | 20 | 20 |
| Accepted | 13 | 13 |
| Rejected | 7 | 7 |
| Deferred | 0 | 0 |
| Decision or piece assignment changes | — | 0 |

The revised rule **did not change the 20 selection decisions or their piece assignments**. It made the model's rationale more specific: A2 remains accepted for piece 03 as a *planned, conditional* discoverability example; A3 remains accepted for piece 03 as an attributed creator documentation practice; R3 remains rejected because the article does not provide a rule, observed result, or Suno-assisted case. A stable decision count here is the recorded outcome, not proof that the policy revision had no effect on reasoning.

After the rerun, accepted material comprises 9 RSS written items, 2 YouTube videos, and 2 podcasts. Pieces 01, 02, and 03 have 3, 7, and 6 distinct originating publishers respectively. These counts concern pilot candidates and selections; publication still requires claim-level checks, full content generation and review, and the assignment's two complete runs on different dates.

The selection receipt is in `logs/select_items_20261013T172643699673Z.json` and reports `complete`, 20 inputs, 20 outputs, and no stage errors. Model cost is not estimated in that receipt.
