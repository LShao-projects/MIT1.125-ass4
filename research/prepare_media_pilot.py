#!/usr/bin/env python3
"""Make four real media candidate records for a transcript-only pilot.

This is a bounded preflight, not one of the assignment's two complete live runs.
It reads metadata and RSS XML only; it never fetches audio/video bytes.
"""

import datetime as dt
from email.utils import parsedate_to_datetime
import json
from pathlib import Path
import subprocess
import sys
import urllib.request
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SOURCES = json.loads((ROOT / "config/sources.json").read_text())


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def youtube_candidate(source):
    result = subprocess.run(["yt-dlp", "-J", "--skip-download", "--no-warnings", source["url"]],
                            capture_output=True, text=True, check=True, timeout=90)
    info = json.loads(result.stdout)
    timestamp = info.get("release_timestamp") or info.get("timestamp")
    if timestamp:
        published_at = dt.datetime.fromtimestamp(timestamp, dt.timezone.utc).isoformat().replace("+00:00", "Z")
        precision = "second"
    else:
        date = dt.datetime.strptime(info["upload_date"], "%Y%m%d").date()
        published_at = date.isoformat() + "T00:00:00Z"
        precision = "day; time is a UTC placeholder"
    return {"item_id": "youtube:" + info["id"], "source_id": source["source_id"],
            "publisher_id": source["publisher_id"], "kind": "youtube",
            "title": info["title"], "url": "https://www.youtube.com/watch?v=" + info["id"],
            "published_at": published_at, "published_at_precision": precision,
            "retrieved_at": now(), "media_url": None}


def podcast_candidate(source):
    request = urllib.request.Request(source["url"], headers={"User-Agent": "Mozilla/5.0 (MIT1.125 student research)"})
    with urllib.request.urlopen(request, timeout=45) as response:
        root = ET.fromstring(response.read())
    target = source["target_episode_title"].casefold()
    episode = next((it for it in root.findall(".//item") if target in it.findtext("title", "").casefold()), None)
    if episode is None:
        raise ValueError("target episode absent from publisher RSS: " + source["source_id"])
    enclosure = episode.find("enclosure")
    if enclosure is None or not enclosure.get("url"):
        raise ValueError("podcast RSS item has no audio enclosure")
    links = [(e.get("type"), e.get("url")) for e in episode
             if e.tag.endswith("}transcript")]
    srt = next((url for kind, url in links if kind == "application/x-subrip"), None)
    published = parsedate_to_datetime(episode.findtext("pubDate")).astimezone(dt.timezone.utc)
    guid = episode.findtext("guid") or episode.findtext("link") or episode.findtext("title")
    return {"item_id": "podcast:" + source["publisher_id"] + ":" + guid,
            "source_id": source["source_id"], "publisher_id": source["publisher_id"],
            "kind": "podcast", "title": episode.findtext("title"),
            "url": episode.findtext("link") or source["url"],
            "published_at": published.isoformat().replace("+00:00", "Z"),
            "retrieved_at": now(), "media_url": enclosure.get("url"),
            "transcript_url": srt}


def main():
    selected_podcasts = {"podcast-notes-on-work", "podcast-ai-music-revolution"}
    for source in SOURCES:
        if source["kind"] == "youtube":
            print(json.dumps(youtube_candidate(source), ensure_ascii=False), flush=True)
        elif source["source_id"] in selected_podcasts:
            print(json.dumps(podcast_candidate(source), ensure_ascii=False), flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"media pilot metadata failed: {type(exc).__name__}: {exc}", file=sys.stderr)
        raise SystemExit(1)
