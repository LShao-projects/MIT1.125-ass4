# Three-episode video QA — updated 2026-10-15

**Final status:** This report records the assistant's mechanical and visual checks. The student subsequently reviewed the final exports before uploading them; the published links are in [`SUBMISSION.md`](../../../../SUBMISSION.md). References below to a remaining prepublication listen reflect the earlier checkpoint.

## Review copies

| Episode | Review export | Duration |
| --- | --- | ---: |
| 1 | `../../../final_videos/episode_01_final.mp4` | 3:14.49 |
| 2 | `../../../final_videos/episode_02_final.mp4` | 3:29.60 |
| 3 | `../../../final_videos/episode_03_final.mp4` | 3:42.82 |

## Requested checks

1. **Static picture with no speech.** FFmpeg silence detection (`-35 dB`, minimum 1.2 s) found no such interval in Episodes 1 or 2. It flagged three quiet spans in Episode 3: 1.29 s near 1:20, 1.51 s near 2:31, and 1.51 s near 3:04. These include low-level speech tails; the actual subtitle-cue gaps at the latter two scene boundaries are 0.66 s and 0.86 s. The image holds briefly on the illustration at these points, but the earlier multi-second dead hold has been removed.
2. **Voiceover handoffs.** The Tova audio tracks were retained. Episode 3's first two dissolves caused adjacent narration to overlap; the remaining three dissolves also superimposed captions at scene boundaries. All five were removed. Episode 2's long pause around 1:37 was removed by shortening scene 3 and taking out its following dissolve. The exported transcript cue boundaries and Google Vids audio clip positions now show sequential speech at the scene joins. This is a timing check, not a substitute for listening.
3. **Blank or black transitions.** No black segment of at least 0.15 s was detected in any final export. A 10-frame-per-second luminance scan found no white-screen frames in any final export. Intermediate versions did reveal white frames in Episodes 2 and 3; those were removed by extending the affected visual clips and replacing them in Google Vids. Sampled frames at the corrected joins show direct cuts between complete illustrations.
4. **Visual consistency.** All three use a dark navy 16:9 canvas, white sans-serif scene headings, aqua/orange/coral accents, rounded panels, and an illustration label. Episode 3's top label says `CREATOR / RELEASE DESK`, reflecting its release focus; Episodes 1 and 2 say `STUDIO / EDIT SESSION`. The former subtitle mismatch was fixed: all three final exports now use Martian Mono, size 17, normal weight, white text on black, and line-by-line captions. Episode 2 and 3 custom presets were edited for all scenes and re-exported. New contact-sheet samples from their opening, middle, and ending scenes show the style applied throughout.
5. **Odd or cropped visuals.** Contact sheets sampled throughout the three exports and full-resolution stills from each later scene showed the central diagrams, headings, and cards inside the frame. No sample showed the former moving yellow scan line or the previously clipped cards. This is a sampled visual check, not a claim that every frame has been manually inspected.

## Caption corrections

The final Episode 3 Google Vids export was regenerated after correcting two automatic transcript errors: `JJ Beats Lab` to `JG Beats Lab`, and `investigation in Dusuno's terms` to `investigation into Suno's terms`. The final embedded subtitle track contains the corrected wording. The narration audio was not regenerated; all three episodes retain the selected Tova voice.

## Method and limits

The checks use the exported MP4s, embedded transcript timing, Google Vids scene/audio timing, FFmpeg silence/black/luminance scans, and inspected still frames at scene boundaries and throughout the episodes. The review does not claim a human listening test: the assistant could inspect audio timing and detect silence, but could not hear the spoken performance through its analysis tools. A final listen by the student remains useful before publication.

After the subtitle style change, Episodes 2 and 3 were re-exported. Their embedded subtitle text and cue timings are unchanged from the prior exports; durations and silence/black-frame scan results are unchanged.
