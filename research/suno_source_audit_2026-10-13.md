# Suno source and claim preflight — 2026-10-13

This is a manual research audit, **not** a pipeline run or a substitute for saved runtime evidence. No audio or video was played or downloaded for this audit. The YouTube metadata and caption text were read without downloading media; podcast pages and RSS were read as text. Recheck publication dates, text, availability, and the UTC 30-day window on each actual run date.

## Coverage and decision

- Audience: English-speaking independent songwriters/producers considering Suno for demos or releasable work.
- Editorial questions: `01` recent changes and relevance; `02` claims versus tests; `03` implications and what to check next.
- For a 2026-10-13 UTC run, the inclusive 30-calendar-date window would be **2026-09-14 through 2026-10-13**. All 14 candidates below fall in it based on their stated publication dates. The September 16 reserve item falls out on October 16.
- Candidate inventory: **14 distinct items** — nine written, two YouTube, three podcast — from **13 publishing entities**. The two Music Business Worldwide articles share one publisher. No two candidates appear to be the same underlying recording. Publisher independence does not imply independent corroboration of a repeated company claim.
- At least two written items have a confirmed RSS discovery route: a fresh Google News RSS search directly yielded the original-article entries for Music Business Worldwide (September 22), Los Angeles Times (September 21), Dazed (October 8), and MusicRadar (September 29). Feed discovery and full original-text retrieval remain separate steps for the pipeline.
- Both selected YouTube videos have native upload date 2026-10-09 and English auto-caption tracks. The English tracks contain 635 and 571 usable timestamped segments respectively. Automatic transcription can mishear names and does not let us independently evaluate sound quality without listening. These tracks were subsequently retained in the transcript pilot described below.
- All three podcast pages expose timestamped passages relevant to the planned claims, but Podscan shows only its first 20 transcript segments publicly. **Correction after checking the publisher RSS:** AI Music Revolution's episode includes an official [SRT transcript](https://www.buzzsprout.com/2573904/19867166/transcript.srt), verified as 196 timed cues from 00:00:24 to 00:13:21. This can be retained as the complete publisher transcript in a live run without retrieving audio. Notes on Work and Thoughts on Tech & Things have audio enclosures but no `podcast:transcript` tag in their checked RSS entries; their complete timestamped transcripts still require retrieval or transcription. None of these texts has yet been saved as a live-run asset.
- Nine independent publishing entities provide the three *core* sources for the three pieces (three per piece). This meets the preliminary per-piece source mapping, subject to final claim-level review and actual-run collection.
- At least one podcast must ultimately contribute a cited passage to the published series; keeping S05/S12/S13 merely as unquoted background would fail the all-three-input-types requirement. At least two distinct podcast episodes must also be processed by the pipeline.

Statuses below mean **usable for the stated narrow claim**, **limited/optional**, or **reserve** in this preflight. They do not mean that a live pipeline has accepted the item.

## Piece 01 — What changed in the creator workflow?

**Planned analysis:** Suno's October Studio release describes concrete editing changes. Recent interviews show existing creator workflows that use AI-generated material or vocal transformation as one step. Do not assert that those interviewees tested the October update.

### S01 — Suno release notes — usable, core

- [Original page](https://blog.suno.com/release-notes); publisher Suno; written; October 8 update.
- Locator: “Improvements to Studio: Tighter timing, clip stretching and fade curves,” especially the three feature subsections.
- Supports: Suno announced improved first-beat detection, shift-drag clip stretching, and adjustable fade curves in Studio. Present improvements as company statements; the page alone does not prove saved time, better sound, or user adoption.
- Conflict/independence: Suno is the product maker and an interested party. Separate October 5 Albums and October 1 Speech entries on the same page are not necessary to this piece. The September 9 v6 launch entry is outside the October 13 window and must not be counted as recent substantive evidence.

### S02 — MusicRadar / Todd Edwards — usable, core

- [Original interview](https://www.musicradar.com/artists/i-resent-the-way-people-talk-about-this-technology-as-if-its-from-the-devil-the-hypocrisy-in-the-industry-is-insane-house-legend-todd-edwards-on-how-ai-has-transformed-his-approach-to-sampling); publisher MusicRadar; written; September 29. Its RSS entry was observed.
- Locator: interview paragraphs beginning with Edwards describing Suno Studio generated material, and his explanation of cutting generated songs into samples.
- Supports: this producer reports using Suno-generated material as material to edit and sample, rather than treating a generated track as the finished piece.
- Limit: his belief that such material is legally safe is his opinion, not legal clearance. It does not test the October 8 update.

### S03 — Dazed / artist interviews — usable, core

- [Original feature](https://www.dazeddigital.com/music/article/71134/1/suno-is-the-new-auto-tune-meet-the-artists-using-ai-to-go-viral); publisher Dazed; written; October 8. Its RSS entry was observed.
- Locator: paragraphs interviewing Zemi and Kilo Kent about singing or producing first, changing vocals with Suno, and doing further mixing; later paragraphs raise questions about transparency and the label's conduct.
- Supports: two interviewees describe using Suno for part of a larger creative process. Attribute their claims to them.
- Limit: both artists are linked to the same label, and the article is **one** publishing source. Their testimony does not establish how every artist works or verify their unshared production files.

### S04 — Produce Like a Boss YouTube test — limited/optional

- [Original video](https://www.youtube.com/watch?v=Nl-dGFi5ebw); channel Produce Like a Boss - AI; video; October 9; English auto-captions.
- Locator: 00:41–01:06 same voice memo across tools; 03:41–05:06 Suno upload and recognition of lyrics/style; 06:00–08:13 prompt and the creator's first assessment.
- Supports: the creator demonstrates placing her own rough voice memo into Suno, editing recognized lyrics, and adding style instructions.
- Limit: the captions sometimes render “Suno” incorrectly. The present audit verifies spoken *steps in the transcript*, not what the audio sounded like. Ignore the video's separate legal/registration advice without a primary source.

### S05 — Notes on Work / Caleb Porzio — limited/optional

- [Podcast transcript excerpt](https://podscan.fm/podcasts/notes-on-work-by-caleb-porzio/episodes/ai-music-is-sooo-good); originating podcast Notes on Work; October 5; audio.
- Locator: 00:01:31–00:02:23, recording a roughly 30-second guitar idea and describing putting it into Suno; 00:03:56, describing a style prompt.
- Supports: one amateur user's account of starting with a rough recording and a short prompt. Useful contrast with Todd Edwards's professional workflow.
- Limit: anecdote and personal enthusiasm, not a controlled test. Podscan publicly exposes only its first 20 transcript segments. A full 98-segment, locally generated Whisper transcript was subsequently retained in the transcript pilot described below. Inspect suspected recognition errors against the underlying audio before publishing exact quotes.

## Piece 02 — Which quality and control claims survive scrutiny?

**Planned analysis:** Compare *what each test measures*, rather than averaging judgments about whether v6 is “better.” A level measurement, prompt adherence, and an aesthetic reaction are different outcomes.

### S06 — ytyng test — usable, core

- [English-language page](https://www.ytyng.com/en/blog/suno-v6-review-variety-max-mode-spectrum); publisher ytyng; written; September 25. The site also offers a Japanese version; this is not the separate Japanese note.com candidate removed from the core set.
- Locator: Variety prompt-rewrite examples; “Spectrum measurement,” especially the 24-track setup and “The codec difference.”
- Supports: the author documents cases where Variety rewrites prompts, then measures a 24-track v6 set. That directly informs the question of controllability and demonstrates the author's method.
- Limit: the older comparison tracks use different prompts and codecs; this cannot be treated as a clean v5-versus-v6 causal comparison. The speculation that model changes were driven by copyright concerns is unsupported and should be excluded.

### S07 — WaveDisco audio test — usable, core

- [Original blog test](https://blog.wavedisco.com/blog/suno-v6-vs-v55-audio-test); publisher WaveDisco; written; September 20.
- Locator: “The setup” (three songs with the same lyrics and prompt across versions), followed by LUFS/True Peak tables and the WAV-versus-MP3 discussion.
- Supports: the author reports numerical loudness and peak results for a small, specified set of tracks; in those examples, the export formats differ less on the v6 variants than on v5.5.
- Limit: three songs and a self-published test; LUFS or peak measurements do not prove musical quality or generalize across all genres.

### S08 — On A Creative Journey YouTube demonstration — usable for method, core

- [Original video](https://www.youtube.com/watch?v=3l1FvHVuLnU); channel On A Creative Journey Making Songs Using AI; October 9; English auto-captions.
- Locator: 02:09–03:29 setup with increasing directions; 06:03–08:32 added lyric-section instructions and settings; 14:18 creator's subjective assessment; 17:23–17:53 noisy output and cleanup in Studio.
- Supports: the creator records how he changed instructions and edited an output, and reports that some takes seemed smoother while others needed cleanup.
- Limit: this is not a clean single-variable controlled trial: instructions, cover generation, and audio-influence settings enter the sequence. We cannot verify the sound-quality judgment from text alone, so attribute it to the creator.

## Piece 03 — What should a creator check before release?

**Planned analysis:** Distinguish the creator's contribution and inputs, platform or partner claims, musicians' concerns, and the status of current investigations. No feature release is said to have caused a lawsuit.

### S09 — Music Business Worldwide / user “creations” — usable, core

- [Original reporting](https://www.musicbusinessworldwide.com/suno-confirms-v6-model-was-trained-on-creations-from-users-as-it-blasts-latest-sony-and-universal-lawsuit/); publisher Music Business Worldwide; written; September 22. Its RSS entry was observed.
- Locator: opening account of Suno's September statement and comparison to prior company wording; later paragraphs explaining what Universal and Sony allege.
- Supports: Suno publicly described v6 training as including licensed content and user “creations” and preference signals; the labels made a separate allegation in a new complaint.
- Limit: company statement and complaint are competing party claims, not independent proof of training details or infringement. Do not turn theoretical damages figures into an expected outcome.

### S10 — Los Angeles Times / artist and contract reporting — usable, core

- [Original reporting](https://www.latimes.com/entertainment-arts/business/story/2026-09-21/ai-music-licensing-deals-labels-artists-who-benefits); publisher Los Angeles Times; written; September 21. Its RSS entry was observed.
- Locator: original artist/session-musician interviews and paragraphs distinguishing label-level deals from each artist's possible choice and payout.
- Supports: the reporter obtained materially different stakeholder views; details about artist choice and compensation remain undisclosed or contract-dependent in the cases discussed.
- Limit: interviewees' concerns are their concerns, and the article does not disclose individual contracts for every creator. Its summary of a company announcement does not independently corroborate the company claim in S09.

### S11 — Italian Competition Authority / AGCM — usable, core

- [Official English press release](https://en.agcm.it/en/media/press-releases/2026/10/CV278); publisher AGCM; written; October 6.
- Locator: paragraphs describing the launch of an investigation and the terms under review (changes, accounts/content, license scope).
- Supports: the Italian authority opened an investigation into Suno's Terms of Service, including possible concerns about broad discretion and user licenses.
- Limit: the opening of an investigation is **not** a finding that any term is unlawful. It is an Italian consumer-law proceeding, not a universal rule for all readers.

### S12 — Thoughts on Tech & Things / SoundExchange interview — limited/optional

- [Publisher episode page](https://www.wypr.org/podcast/thoughts-on-tech-things/2026-10-02/are-ai-music-tools-a-new-instrument) and [timestamped transcript excerpt](https://www.podscan.fm/podcasts/thoughts-on-tech-amp-things/episodes/are-ai-music-tools-a-new-instrument); originating podcast Thoughts on Tech & Things; audio; October 2.
- Locator: 00:03:43–00:06:30, guest Michael Huppe distinguishes assistive and generated uses, discusses iterative human input, and says a precise threshold is hard to state.
- Supports: a rights-collection industry leader's view that the degree and nature of human contribution matter to how he discusses AI-assisted works.
- Limit: stakeholder interview, not an official legal rule. The automatic transcript misrenders some proper names. Podscan exposes only the first 20 segments; the 41-minute full timestamped transcript remains to be obtained or generated for formal use.

### S13 — AI Music Revolution / “Is It Still Your Song?” — limited/optional

- [Publisher page with complete transcript text](https://www.buzzsprout.com/2573904/episodes/19867166-is-it-still-your-song?t=0) and [timestamped excerpt](https://podscan.fm/podcasts/ai-music-revolution/episodes/is-it-still-your-song); originating podcast AI Music Revolution/JG BeatsLab; audio; September 29.
- Locator: 00:02:12–00:04:03, host distinguishes composition, arrangement, performance, and finishing decisions; later text on the publisher page explains his suggested provenance folder.
- Supports: a producer's practical framework for documenting which parts of a song a person contributed and which were generated.
- Limit: the host sells related mastering and teaching services; his claims about what the law or Suno's September 3 terms guarantee need primary verification. Use the [publisher-linked SRT](https://www.buzzsprout.com/2573904/19867166/transcript.srt) for complete timestamps, not Podscan's first-20-segment preview. Its cues still need to be saved and checked in the live pipeline.

### S14 — MBW / Believe and TuneCore opt-in interview — reserve only

- [Original interview](https://www.musicbusinessworldwide.com/believe-and-tunecore-suno-consent/); publisher Music Business Worldwide; written; September 16.
- Locator: Believe CEO's account of a two-stage artist consent process.
- Supports only: Believe's description of its proposed/operating artist choice mechanism. It does not verify how every artist experienced consent.
- Limit: same publisher as S09, so it does not add an independent publisher to piece 03. It is a commercially interested account and leaves the 30-day window for an October 16 UTC run.

## Claims deliberately withheld

1. “Suno's October changes improved every creator's results” — only official feature statements and limited individual experiences are available.
2. “v6 is objectively better/worse than v5.5” — tests use different metrics and small or non-equivalent samples.
3. “An AI-generated arrangement is automatically copyrighted / automatically safe to release” — the consulted interviews and posts do not establish that. Any specific legal or contractual claim needs current primary material and jurisdiction-specific wording.
4. “Suno has been found in violation by the Italian authority” — the authority has opened an investigation, not announced a finding.
5. “Two MBW stories independently confirm a company claim” — one publisher and possibly the same underlying company statement.

## Remaining gates before a source can support publication

- Recheck each original publication date at **each actual live run**, capture retrieval date separately, and preserve the exact page/feed entry or media-text version used.
- The transcript pilot below has retained both YouTube caption tracks, the publisher-linked AI Music Revolution SRT, and a full local Whisper transcript for Notes on Work. These are real retained text assets, but the pilot is **not** one of the assignment's two complete live runs. The collection workflow still needs to ingest and retain them in each real run, verify current dates, and reuse unchanged assets where possible.
- Promote at least one verified podcast passage into a final brief/article/video-script claim, with its segment locator, so that podcast input actually contributes evidence.
- Make the pipeline discover at least two substantive written items through RSS, retrieve their original bodies, and resolve Google News discovery URLs to the original publication.
- Complete a human claim-level review after the AI selection stage, including the required three accepted and three rejected/deferred items. This preflight is not that later review.

## Transcript-only pilot — 2026-10-13

`runs/transcript-pilot-20261013/candidates.jsonl` and `items.jsonl` contain four real media observations. The item records point to eight retained files under `data/assets/` (one text and one timed-segment JSON file per item). The [extraction receipt](../runs/transcript-pilot-20261013/logs/) reports a successful 4/4 pass. The two YouTube tracks end at approximately 24:17 and 25:59; the Notes on Work Whisper transcript ends at 12:22; the publisher's AI Music Revolution SRT ends at 13:21. No audio or video file remains in the repository. This bounded pilot has no RSS written-article extraction, evidence-store upsert, freshness filter, editorial AI decisions, or publication drafts, and must not be reported as a full pipeline run.

The transcript-only pilot demonstrates extraction mechanics, not quote accuracy. The Caleb transcript contains rough lyrics and likely recognition errors; the publisher SRT also appears to render “Suno” as “sudo” in one passage. A student should verify important quotes before using them as evidence.

## Written-evidence and store pilot — 2026-10-13

`runs/rss-pilot-20261013/` is a **partial technical pilot**, not a complete `bash run.sh` live run. Four audited original articles were found in their configured RSS queries and retained from their publisher pages. Four more original written pages were retained through the explicitly labeled supplemental-web route; their `rss_discovered` flag is `false`, so they cannot satisfy the RSS discovery quota. The four already captured media items were then merged with these eight written items. `all_items.jsonl` has 12 distinct item IDs and 12 different originating publisher IDs: 4 RSS-written, 4 supplemental-written, 2 YouTube, and 2 podcast. The original written excerpts and both kinds of timestamped media assets are under `data/assets/` and addressed by each item's `text_path` or `segments_path`.

The SQLite index behind `data/store.sh` received 12 `new` change records in this pilot. Replaying the same `all_items.jsonl` yielded 12 `unchanged` records and still 12 logical items; see `changes.jsonl` and `replay_changes.jsonl`. Filtering the stored corpus for the actual 2026-10-13 UTC pilot date yielded 12 eligible items and zero date exclusions. These are **mechanical** checks only: independent publisher IDs do not make repeated claims independent corroboration, and every item still needs AI editorial selection and human claim review. No evidence is yet approved for publication.

The current RSS collector uses audited title-to-original-URL mappings because Google News RSS links do not resolve directly to original publisher pages in this environment. It correctly retains the RSS discovery URL and source name, but it only emits the four configured target articles. Before the two required full live runs, broaden discovery or document that limited coverage, and ensure the workflow reports newly discovered or missing items honestly. The supplemental Suno release notes extractor keeps only the October 8 Studio section; it does not count the September 9 v6 launch as fresh evidence.

## Automated collection-stage pilot — 2026-10-13

After the manual pilots, `bash workflows/collect_sources.sh runs/collection-pilot-20261013` ran all three required collectors, the optional supplemental-web collector, extraction, storage, and UTC filtering in sequence. Its [collection receipt](../runs/collection-pilot-20261013/logs/) records success for each stage: 12 combined candidates, 12 extracted items, 12 stored observations, 12 eligible items, and zero date exclusions. All 12 were `unchanged` relative to the earlier pilot store. The Caleb podcast transcript was reused through `data/store.sh get` because its episode URL, audio enclosure URL, and publication date matched; it was not retranscribed. This cache criterion may miss a publisher replacing audio bytes at the same URL, so the full repeatability demonstration should explain that limit or add a stronger content validator. No video/audio file or Whisper temporary directory remained after the run.

This is still a collection-stage pilot. The mandatory `run.sh`, series workflow, AI selection, three briefs, six drafts, content checks, approval gate, publication package, and final summary are not yet implemented. The pilot is not one of the assignment's two complete live runs. YouTube captions were retrieved without media playback or a saved video file; whether the course's “retrieve video or audio content” language requires an additional temporary media access step should be resolved before claiming full compliance.
