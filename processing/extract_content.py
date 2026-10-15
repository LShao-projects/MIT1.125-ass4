#!/usr/bin/env python3
"""Own content extraction and retained text/segments for candidate JSONL on stdin.

Media bytes used for Whisper are decoded to a temporary WAV outside the repository
and removed after transcription. No video is fetched and no media is played.
"""

import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from html_text import extract_paragraphs

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "data" / "assets"
WHISPER = os.environ.get("WHISPER_CLI") or shutil.which("whisper-cli")
MODEL = os.environ.get("WHISPER_MODEL")


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def get_text(url):
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (MIT1.125 student research)"})
    with urllib.request.urlopen(request, timeout=45) as response:
        return response.read().decode("utf-8", "replace")


def clock_seconds(value):
    h, m, s = value.replace(",", ".").split(":")
    return int(h) * 3600 + int(m) * 60 + float(s)


def parse_srt(body):
    segments = []
    for block in re.split(r"\r?\n\s*\r?\n", body.strip()):
        lines = block.splitlines()
        time_index = next((i for i, line in enumerate(lines) if " --> " in line), None)
        if time_index is None:
            continue
        start, end = lines[time_index].split(" --> ", 1)
        words = " ".join(line.strip() for line in lines[time_index + 1:] if line.strip())
        words = re.sub(r"<[^>]+>", "", words)
        if words:
            segments.append({"segment_id": f"seg-{len(segments)+1:05d}",
                             "start_seconds": clock_seconds(start.strip()),
                             "end_seconds": clock_seconds(end.strip().split()[0]),
                             "text": words})
    return segments


def youtube_segments(candidate):
    result = subprocess.run(["yt-dlp", "-J", "--skip-download", "--no-warnings", candidate["url"]],
                            capture_output=True, text=True, timeout=90, check=True)
    info = json.loads(result.stdout)
    choices = []
    for group in ("subtitles", "automatic_captions"):
        for language in ("en", "en-US", "en-GB"):
            choices.extend(track for track in info.get(group, {}).get(language, []) if track.get("ext") == "json3")
        if choices:
            break
    if not choices:
        raise ValueError("no English timestamped JSON3 caption track")
    data = json.loads(get_text(choices[0]["url"]))
    segments = []
    for event in data.get("events", []):
        words = "".join(part.get("utf8", "") for part in event.get("segs", []))
        words = " ".join(words.split())
        if not words:
            continue
        start = event.get("tStartMs", 0) / 1000
        end = (event.get("tStartMs", 0) + event.get("dDurationMs", 0)) / 1000
        if end <= start:
            continue
        segments.append({"segment_id": f"seg-{len(segments)+1:05d}",
                         "start_seconds": start, "end_seconds": end, "text": words})
    if not segments:
        raise ValueError("English caption track had no usable timed text")
    return segments, "yt-dlp metadata + English caption JSON3"


def whisper_segments(candidate):
    if not WHISPER or not Path(WHISPER).is_file() or not MODEL or not Path(MODEL).is_file():
        raise RuntimeError("set WHISPER_CLI and WHISPER_MODEL for transcript fallback")
    media_url = candidate.get("media_url")
    if not media_url:
        raise ValueError("podcast has no audio enclosure URL")
    with tempfile.TemporaryDirectory(prefix="ass4-transcribe-") as temp:
        wav = Path(temp) / "episode.wav"
        output = Path(temp) / "transcript"
        subprocess.run(["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y",
                        "-i", media_url, "-ar", "16000", "-ac", "1", "-c:a", "pcm_s16le", str(wav)],
                       capture_output=True, text=True, timeout=240, check=True)
        subprocess.run([str(WHISPER), "-m", str(MODEL), "-f", str(wav), "-osrt", "-of", str(output), "-np"],
                       capture_output=True, text=True, timeout=900, check=True)
        srt = (Path(str(output) + ".srt")).read_text()
    segments = parse_srt(srt)
    if not segments:
        raise ValueError("Whisper returned no timed transcript segments")
    return segments, "ffmpeg stream to temporary WAV + local whisper.cpp"


def podcast_segments(candidate):
    transcript_url = candidate.get("transcript_url")
    if transcript_url:
        segments = parse_srt(get_text(transcript_url))
        if not segments:
            raise ValueError("publisher transcript had no SRT time ranges")
        return segments, "publisher podcast:transcript SRT"
    return whisper_segments(candidate)


def reusable_podcast_item(candidate):
    """Reuse an existing ASR result when the source enclosure identity is stable.

    A publisher could replace bytes at the same enclosure URL. This shortcut is
    documented as a coverage limit; publisher transcript SRTs are refetched.
    """
    if candidate.get("kind") != "podcast" or candidate.get("transcript_url"):
        return None
    result = subprocess.run(["bash", "data/store.sh", "get", candidate["item_id"]],
                            capture_output=True, text=True, cwd=ROOT, timeout=15)
    if result.returncode != 0:
        return None
    prior = json.loads(result.stdout)
    if any(prior.get(key) != candidate.get(key) for key in ("url", "media_url", "published_at")):
        return None
    if not prior.get("segments_path") or not prior.get("text_path"):
        return None
    if not (ROOT / prior["segments_path"]).is_file() or not (ROOT / prior["text_path"]).is_file():
        return None
    item = dict(prior)
    item.update(candidate)
    return item


def written_text(candidate):
    html = get_text(candidate["url"])
    paragraphs = extract_paragraphs(html, candidate.get("target_section"))
    text = "\n\n".join(paragraphs).strip()
    if len(text) < 500 or len(text.split()) < 80:
        raise ValueError("original page yielded too little substantive written content")
    return text


def retain(candidate, segments=None, text=None):
    material = {"title": candidate["title"], "url": candidate["url"],
                "published_at": candidate.get("published_at")}
    if segments is None:
        material["text"] = text
    else:
        material["segments"] = segments
    version = hashlib.sha256(json.dumps(material, ensure_ascii=False, sort_keys=True,
                                        separators=(",", ":")).encode()).hexdigest()[:20]
    stem = hashlib.sha256(candidate["item_id"].encode()).hexdigest()[:16] + "-" + version
    ASSETS.mkdir(parents=True, exist_ok=True)
    text_path = ASSETS / f"{stem}.txt"
    segments_path = ASSETS / f"{stem}.segments.json" if segments is not None else None
    if not text_path.exists():
        text_path.write_text((text if text is not None else "\n".join(s["text"] for s in segments)) + "\n")
    if segments_path is not None and not segments_path.exists():
        segments_path.write_text(json.dumps(segments, ensure_ascii=False, indent=2) + "\n")
    item = dict(candidate)
    item.update({"version_id": version, "text_path": str(text_path.relative_to(ROOT)),
                 "segments_path": str(segments_path.relative_to(ROOT)) if segments_path else None})
    return item


def main():
    if len(sys.argv) != 2:
        print("usage: extract_content.sh RUN_DIR", file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    run_dir.mkdir(parents=True, exist_ok=True)
    started = now()
    count = 0
    success = 0
    errors = []
    methods = set()
    for line_number, line in enumerate(sys.stdin, 1):
        if not line.strip():
            continue
        count += 1
        try:
            candidate = json.loads(line)
            kind = candidate["kind"]
            if kind == "youtube":
                segments, method = youtube_segments(candidate)
            elif kind == "podcast":
                reused = reusable_podcast_item(candidate)
                if reused is not None:
                    print(json.dumps(reused, ensure_ascii=False), flush=True)
                    success += 1
                    methods.add("reused ASR transcript via data/store.sh get")
                    print(f"reused {candidate['item_id']}: saved transcript; same enclosure URL and date", file=sys.stderr)
                    continue
                segments, method = podcast_segments(candidate)
            elif kind == "feed":
                segments, method = None, "original webpage HTML text"
            else:
                raise ValueError(f"kind {kind!r} is not implemented in this media extraction stage")
            item = retain(candidate, segments, written_text(candidate) if kind == "feed" else None)
            print(json.dumps(item, ensure_ascii=False), flush=True)
            success += 1
            methods.add(method)
            unit = f"{len(segments)} timed segments" if segments is not None else "substantive written text"
            print(f"extracted {candidate['item_id']}: {unit} via {method}", file=sys.stderr)
        except Exception as exc:
            message = f"input line {line_number}: {type(exc).__name__}: {exc}"
            errors.append(message)
            print(message, file=sys.stderr)
    log_dir = run_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "extract_content", "status": "complete" if not errors else "incomplete",
               "input_count": count, "output_count": success, "started_at": started, "finished_at": now(),
               "tools_or_models": sorted(methods), "cost_usd": 0, "cost_estimate": True,
               "errors": errors, "media_files_retained": False}
    log_path = log_dir / f"extract_content_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json"
    log_path.write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
