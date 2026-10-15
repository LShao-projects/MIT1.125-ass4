#!/usr/bin/env python3
"""Retain audio for accepted YouTube and podcast evidence, without playback.

Media lives outside the persistent SQLite evidence index. The per-version sidecar
and run manifest make each retrieval inspectable and idempotent.
"""

import datetime as dt
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import urllib.request


ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "data" / "media"
MAX_BYTES = 64 * 1024 * 1024


def utc_now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def records(path):
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def file_hash(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def retrieve_podcast(item, temp):
    url = item.get("media_url")
    if not url:
        raise ValueError("podcast enclosure URL is missing")
    target = temp / "audio.mp3"
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (MIT1.125 student research)"})
    with urllib.request.urlopen(request, timeout=60) as response, target.open("wb") as output:
        if "audio" not in response.headers.get("Content-Type", "").lower():
            raise ValueError("podcast enclosure did not return an audio content type")
        size = 0
        while block := response.read(1024 * 1024):
            size += len(block)
            if size > MAX_BYTES:
                raise ValueError("podcast audio exceeds 64 MiB limit")
            output.write(block)
    return target, "podcast audio enclosure"


def retrieve_youtube(item, temp):
    template = str(temp / "audio.%(ext)s")
    command = ["yt-dlp", "--no-playlist", "--no-warnings", "--no-progress",
               "--max-filesize", "64M", "--no-mtime", "-f", "bestaudio[ext=m4a]/bestaudio",
               "-o", template, item["url"]]
    result = subprocess.run(command, capture_output=True, text=True, timeout=300, check=False)
    if result.returncode:
        raise RuntimeError(f"yt-dlp audio retrieval failed (exit {result.returncode})")
    outputs = [p for p in temp.iterdir() if p.is_file() and not p.name.endswith(".part")]
    if len(outputs) != 1 or outputs[0].stat().st_size == 0:
        raise ValueError("yt-dlp did not leave exactly one complete audio file")
    if outputs[0].stat().st_size > MAX_BYTES:
        raise ValueError("YouTube audio exceeds 64 MiB limit")
    return outputs[0], "YouTube audio-only stream via yt-dlp"


def retain(item):
    key = hashlib.sha256(f"{item['item_id']}:{item['version_id']}".encode()).hexdigest()[:24]
    sidecar = MEDIA / f"{key}.json"
    if sidecar.exists():
        saved = json.loads(sidecar.read_text(encoding="utf-8"))
        local = ROOT / saved["path"]
        if (saved.get("item_id") == item["item_id"] and
                saved.get("version_id") == item["version_id"] and
                local.is_file() and local.stat().st_size == saved.get("size_bytes") and
                file_hash(local) == saved.get("sha256")):
            return {**saved, "status": "reused"}
    with tempfile.TemporaryDirectory(prefix="ass4-selected-audio-") as directory:
        temp = Path(directory)
        if item["kind"] == "youtube":
            downloaded, method = retrieve_youtube(item, temp)
        elif item["kind"] == "podcast":
            downloaded, method = retrieve_podcast(item, temp)
        else:
            raise ValueError("only YouTube and podcast items have retained media")
        MEDIA.mkdir(parents=True, exist_ok=True)
        destination = MEDIA / f"{key}{downloaded.suffix.lower()}"
        shutil.move(str(downloaded), destination)
    saved = {"item_id": item["item_id"], "version_id": item["version_id"],
             "kind": item["kind"], "source_url": item.get("media_url") or item["url"],
             "path": str(destination.relative_to(ROOT)), "size_bytes": destination.stat().st_size,
             "sha256": file_hash(destination), "retrieved_at": utc_now(), "method": method}
    sidecar.write_text(json.dumps(saved, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {**saved, "status": "downloaded"}


def main():
    if len(sys.argv) != 2:
        print("usage: retain_selected_media.py RUN_DIR", file=sys.stderr)
        return 2
    run = Path(sys.argv[1]).resolve()
    if not run.is_dir():
        print("run directory does not exist", file=sys.stderr)
        return 2
    started = utc_now()
    eligible = {item["item_id"]: item for item in records(run / "eligible.jsonl")}
    decisions = records(run / "decisions.jsonl")
    selected = []
    for decision in decisions:
        if decision["decision"] == "accept":
            item = eligible[decision["item_id"]]
            if item["kind"] in ("youtube", "podcast"):
                selected.append(item)
    output = []
    for item in selected:
        try:
            result = retain(item)
            output.append(result)
            print(f"{result['status']} {item['item_id']}: {result['size_bytes']} bytes", file=sys.stderr)
        except Exception as exc:
            output.append({"item_id": item["item_id"], "version_id": item["version_id"],
                           "kind": item["kind"], "status": "failed",
                           "error": f"{type(exc).__name__}: {exc}"})
            print(f"failed {item['item_id']}: {type(exc).__name__}: {exc}", file=sys.stderr)
    (run / "retained_media.jsonl").write_text(
        "".join(json.dumps(row, ensure_ascii=False) + "\n" for row in output), encoding="utf-8")
    logs = run / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    receipt = {"stage": "retain_selected_media", "started_at": started, "finished_at": utc_now(),
               "status": "complete" if all(x["status"] != "failed" for x in output) else "incomplete",
               "input_count": len(selected), "output_count": sum(x["status"] != "failed" for x in output),
               "tools_or_models": ["yt-dlp audio-only", "Python urllib podcast enclosure"],
               "cost_usd": 0, "cost_estimate": True,
               "errors": [x["error"] for x in output if x["status"] == "failed"]}
    (logs / f"retain_selected_media_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0 if receipt["status"] == "complete" else 1


if __name__ == "__main__":
    raise SystemExit(main())
