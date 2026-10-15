# Editorial policy — Suno in Practice

## Reader and purpose

Write for English-speaking independent songwriters and producers deciding whether Suno helps them turn their own musical ideas into work they would feel ready to release. The three pieces ask, in order: (01) what changed recently and matters to their workflow; (02) which quality and control claims withstand scrutiny, and why tests differ; (03) what creators should verify before using or releasing Suno-assisted work, and what to watch next. Keep one coherent series but give each piece its own argument.

## Eligibility and selection

1. Apply the mechanical UTC date filter first. An item may support a run dated D only if its substantive material was first published on one of the 30 calendar dates D−29 through D. Record publication and retrieval dates separately. A refreshed page date or reupload of old material does not make old claims newly published. Unknown, invalid, or future dates cannot support publication.
2. Accept an eligible item when it contributes specific, inspectable information relevant to an independent creator: a feature description, original reporting or interview, a documented test, a primary regulator statement, or an identifiable practitioner account. Explain *which* piece and claim it could inform.
3. Reject off-topic items, ads without substantive evidence, bare headlines, duplicate uploads of the same recording, and summaries that add no original information. Defer when original text or a required transcript is inaccessible, a claim's source is unclear, dates conflict, or a material commercial relationship needs checking.
   For piece 03, a general music-industry item mentioning AI is insufficient. Accept a platform or practitioner item only when it supplies a concrete, inspectable step or rule that a creator using Suno could reasonably need to evaluate before or after release. A distributor's self-description of AI-powered back-office checks, without a stated rule, observable result, or documented Suno-assisted case, does not meet that threshold. A planned listener-facing filter for fully AI-generated tracks may be used as a **conditional** discoverability example; do not infer that it is live, that all AI-assisted songs fall under it, or that a specific Suno-assisted release would lose listeners. Record the relevant passage and the gap between that passage and any proposed creator implication.
4. Count distinct underlying items and originating publishers separately. An RSS aggregator is a discovery route, not a publisher. Resolve an RSS entry to the original written article and confirm its publisher. Articles from the same publisher share one publisher ID. Several outlets repeating a Suno press statement remain one underlying company claim, regardless of publisher count.
5. Gather at least 12 distinct substantive items from at least six independent publishers, including at least two substantive written items discovered through RSS, two YouTube videos, and two podcast episodes. Every included audio/video item needs a complete retained transcript with segment timestamps. At least one podcast passage must be cited in the published series. A candidate inventory or excerpt alone does not satisfy this requirement.

## Claim-level credibility

- Judge each claim by its underlying evidence and method. A famous outlet, a popular channel, and the AI model's confidence are not proof. Name the speaker or organization and their incentives: Suno product marketing; label or licensing partner; rights organization; independent artist; reviewer with sponsorship, affiliate links, or a commercial course.
- A product release note can establish what Suno announced, not that users saved time or that sound improved. A creator demonstration establishes what that creator did and reported, not an average effect. Compare tests only after checking their prompts, model settings, sample size, export format, and measured outcome. Measurements such as LUFS are not aesthetic judgments.
- For a regulatory announcement, distinguish an opened investigation from an adverse finding. For a lawsuit, distinguish allegations, responses, and court decisions. Do not give individualized legal advice. Verify any current rights or terms statement against the applicable primary text and describe jurisdiction and version.
- Mark reported facts, attributed source claims, our inference, and open uncertainty separately. An inference should connect at least two independent pieces of evidence and explain the reasoning. Every substantive claim must have a source-version ID and a passage locator (exact text quote or transcript segment ID). Do not make a claim from a title or description alone.

## Perspective and original analysis

Seek genuinely different evidence: company release notes, independent practitioner methods, original reporting, tests with visible methods, creators' concerns, and regulator or rights-group statements. Record whose perspective is still missing. Do not stage an artificial yes/no debate; each piece must instead discuss a meaningful limitation or genuine counterargument. Reusing a source in another piece is allowed when it supports a different inference.

The provisional source audit in `research/suno_source_audit_2026-10-13.md` is a lead list only. A live run must verify all dates, original pages, transcript completeness, duplicate relationships, and claim locators again. The September 9 v6 launch may be background only when outside the live window. The October Studio feature update must not be presented as causing the separate licensing or legal disputes.

`config/sources.json` holds the required RSS, YouTube, and podcast collection endpoints. `config/supplemental_urls.json` holds four audited primary/original web pages for direct retrieval. These extra pages can strengthen the pieces, but none may be counted toward the minimum of two RSS-discovered written items. A run must snapshot and ingest both configuration files, then keep the discovery route and originating publisher distinct in its records.

## Human checkpoints

AI decisions are proposals. The student checks at least three accepted and three rejected/deferred decisions, corrects factual claims against their passages, records what changed and why, revises this policy at least once, and reruns the affected stage while retaining both outputs. Before publication, the student reviews article and video-script consistency, source attribution, uncertainty, and any AI-generated presentation. Only the student may supply the formal `approval.json` decision.
