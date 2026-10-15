#!/usr/bin/env python3
"""Discover configured episodes and transcript links from publisher podcast RSS."""

import datetime as dt
from email.utils import parsedate_to_datetime
import json
from pathlib import Path
import sys
import urllib.request
import xml.etree.ElementTree as ET


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def candidate(source):
    request = urllib.request.Request(source["url"], headers={"User-Agent": "Mozilla/5.0 (MIT1.125 student research)"})
    with urllib.request.urlopen(request, timeout=45) as response:
        root = ET.fromstring(response.read())
    target = source["target_episode_title"].casefold()
    episode = next((it for it in root.findall(".//item") if target in it.findtext("title", "").casefold()), None)
    if episode is None:
        raise ValueError("target episode absent from current publisher RSS")
    enclosure = episode.find("enclosure")
    if enclosure is None or not enclosure.get("url"):
        raise ValueError("podcast RSS item has no audio enclosure URL")
    links = [(e.get("type"), e.get("url")) for e in episode if e.tag.endswith("}transcript")]
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
    if len(sys.argv) != 2:
        print("usage: fetch_podcasts.sh RUN_DIR", file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    source_file = run_dir / "config" / "sources.json"
    if not source_file.is_file():
        print("missing run source snapshot", file=sys.stderr)
        return 2
    sources = [s for s in json.loads(source_file.read_text()) if s.get("kind") == "podcast" and s.get("enabled", True)]
    started = now()
    count = 0
    errors = []
    for source in sources:
        try:
            print(json.dumps(candidate(source), ensure_ascii=False), flush=True)
            count += 1
        except Exception as exc:
            errors.append(f"{source['source_id']}: {type(exc).__name__}: {exc}")
    log_dir = run_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "fetch_podcasts", "status": "complete" if not errors else "incomplete",
               "input_count": len(sources), "output_count": count, "started_at": started,
               "finished_at": now(), "tools_or_models": ["Python urllib podcast RSS XML"],
               "cost_usd": 0, "cost_estimate": True, "errors": errors,
               "media_downloaded": False}
    (log_dir / f"fetch_podcasts_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
