#!/usr/bin/env python3
"""Supplement written evidence with audited original pages outside RSS discovery."""

import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import sys
import urllib.request


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def visible_date(html, date):
    variants = {date.isoformat(), date.strftime("%B %-d, %Y"), date.strftime("%b %-d, %Y"),
                date.strftime("%-d %B %Y")}
    return any(value.casefold() in html.casefold() for value in variants)


def main():
    if len(sys.argv) != 2:
        print("usage: fetch_web.sh RUN_DIR", file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    snapshot = run_dir / "config" / "supplemental_urls.json"
    if not snapshot.is_file():
        print(f"missing supplemental snapshot: {snapshot}", file=sys.stderr)
        return 2
    sources = json.loads(snapshot.read_text())
    started = now()
    errors = []
    count = 0
    for source in sources:
        try:
            request = urllib.request.Request(source["url"], headers={"User-Agent": "Mozilla/5.0 (MIT1.125 student research)"})
            with urllib.request.urlopen(request, timeout=45) as response:
                html = response.read().decode("utf-8", "replace")
                if response.url.split("#")[0].rstrip("/") != source["url"].split("#")[0].rstrip("/"):
                    raise ValueError("page redirected; recheck canonical source")
            day = dt.date.fromisoformat(source["publication_date"])
            if not visible_date(html, day):
                raise ValueError("audited publication date absent from current original page")
            title_match = re.search(r"<title[^>]*>(.*?)</title>", html, re.I | re.S)
            title = re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", title_match.group(1))).strip() if title_match else source["source_id"]
            candidate = {"item_id": "feed:" + hashlib.sha256(source["url"].encode()).hexdigest()[:24],
                         "source_id": source["source_id"], "publisher_id": source["publisher_id"],
                         "kind": "feed", "title": title, "url": source["url"],
                         "published_at": day.isoformat() + "T00:00:00Z",
                         "published_at_precision": "day; time is a UTC placeholder",
                         "retrieved_at": now(), "media_url": None,
                         "discovery_method": "supplemental original webpage", "rss_discovered": False}
            if source.get("target_section"):
                candidate["target_section"] = source["target_section"]
            print(json.dumps(candidate, ensure_ascii=False), flush=True)
            count += 1
        except Exception as exc:
            errors.append(f"{source.get('source_id', '?')}: {type(exc).__name__}: {exc}")
    logs = run_dir / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "fetch_web", "status": "complete" if not errors else "incomplete",
               "input_count": len(sources), "output_count": count,
               "started_at": started, "finished_at": now(),
               "tools_or_models": ["Python urllib original HTML"], "cost_usd": 0,
               "cost_estimate": True, "errors": errors}
    (logs / f"fetch_web_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
