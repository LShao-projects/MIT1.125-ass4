#!/usr/bin/env python3
"""Discover audited original written stories through their RSS entries."""

import datetime as dt
from email.utils import parsedate_to_datetime
import hashlib
import json
from pathlib import Path
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def domain_allowed(url, allowed):
    host = (urllib.parse.urlparse(url).hostname or "").lower()
    return any(host == d or host.endswith("." + d) for d in allowed)


def main():
    if len(sys.argv) != 2:
        print("usage: fetch_feeds.sh RUN_DIR", file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    snapshot = run_dir / "config" / "sources.json"
    if not snapshot.is_file():
        print(f"missing run source snapshot: {snapshot}", file=sys.stderr)
        return 2
    sources = json.loads(snapshot.read_text())
    started = now()
    seen = set()
    output = 0
    errors = []
    for source in sources:
        if source.get("kind") != "feed":
            continue
        try:
            request = urllib.request.Request(source["url"], headers={"User-Agent": "Mozilla/5.0 (MIT1.125 student research)"})
            with urllib.request.urlopen(request, timeout=45) as response:
                root = ET.fromstring(response.read())
            entries = root.findall(".//item")
            if not entries:
                raise ValueError("RSS feed returned no items")
            found = set()
            automatic_count = 0
            for entry in entries:
                title = entry.findtext("title", "").strip()
                if source.get("auto_discover"):
                    if automatic_count >= source.get("max_items", 10):
                        break
                    url = entry.findtext("link", "").strip()
                    if not title or not domain_allowed(url, source.get("allowed_domains", [])):
                        continue
                    published = parsedate_to_datetime(entry.findtext("pubDate")).astimezone(dt.timezone.utc)
                    item_id = "feed:" + hashlib.sha256(url.encode()).hexdigest()[:24]
                    if item_id in seen:
                        continue
                    seen.add(item_id)
                    record = {"item_id": item_id, "source_id": source["source_id"],
                              "publisher_id": source["publisher_id"], "kind": "feed",
                              "title": title, "url": url,
                              "published_at": published.isoformat().replace("+00:00", "Z"),
                              "retrieved_at": now(), "media_url": None,
                              "discovery_url": source["url"],
                              "discovery_method": "publisher RSS feed",
                              "rss_discovered": True}
                    print(json.dumps(record, ensure_ascii=False), flush=True)
                    output += 1
                    automatic_count += 1
                    continue
                publisher = entry.find("source")
                origin = publisher.get("url", "") if publisher is not None else ""
                if source.get("allowed_domains") and not domain_allowed(origin, source["allowed_domains"]):
                    continue
                for target in source.get("targets", []):
                    if target["title_contains"].casefold() not in title.casefold():
                        continue
                    url = target["url"]
                    if not domain_allowed(url, source.get("allowed_domains", [])):
                        raise ValueError("curated original URL is outside publisher domain")
                    published = parsedate_to_datetime(entry.findtext("pubDate")).astimezone(dt.timezone.utc)
                    item_id = "feed:" + hashlib.sha256(url.encode()).hexdigest()[:24]
                    if item_id in seen:
                        continue
                    seen.add(item_id)
                    found.add(target["url"])
                    record = {"item_id": item_id, "source_id": source["source_id"],
                              "publisher_id": source["publisher_id"], "kind": "feed",
                              "title": title.rsplit(" - ", 1)[0], "url": url,
                              "published_at": published.isoformat().replace("+00:00", "Z"),
                              "retrieved_at": now(), "media_url": None,
                              "discovery_url": entry.findtext("link"),
                              "discovery_method": "RSS entry plus verified original URL map",
                              "rss_discovered": True}
                    print(json.dumps(record, ensure_ascii=False), flush=True)
                    output += 1
            missing = {t["url"] for t in source.get("targets", [])} - found
            for url in sorted(missing):
                errors.append(f"{source['source_id']}: audited target absent from current RSS: {url}")
        except Exception as exc:
            errors.append(f"{source.get('source_id', '?')}: {type(exc).__name__}: {exc}")
    logs = run_dir / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "fetch_feeds", "status": "complete" if not errors else "incomplete",
               "input_count": sum(s.get("kind") == "feed" for s in sources),
               "output_count": output, "started_at": started, "finished_at": now(),
               "tools_or_models": ["Python urllib RSS XML"], "cost_usd": 0,
               "cost_estimate": True, "errors": errors}
    (logs / f"fetch_feeds_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
