#!/usr/bin/env python3
"""SQLite implementation owned exclusively by the data/store.sh interface."""

import datetime as dt
import json
from pathlib import Path
import sqlite3
import sys

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "data" / "evidence" / "index.sqlite3"


def now():
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def connect():
    DB.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(DB)
    db.execute("PRAGMA foreign_keys=ON")
    db.executescript("""
        CREATE TABLE IF NOT EXISTS items (
          item_id TEXT PRIMARY KEY,
          latest_version_id TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS versions (
          item_id TEXT NOT NULL,
          version_id TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          first_seen_at TEXT NOT NULL,
          PRIMARY KEY (item_id, version_id),
          FOREIGN KEY (item_id) REFERENCES items(item_id)
        );
        CREATE TABLE IF NOT EXISTS observations (
          run_id TEXT NOT NULL,
          item_id TEXT NOT NULL,
          version_id TEXT NOT NULL,
          observed_at TEXT NOT NULL,
          PRIMARY KEY (run_id, item_id, version_id),
          FOREIGN KEY (item_id, version_id) REFERENCES versions(item_id, version_id)
        );
    """)
    return db


def receipt(run_dir, started, count, outputs, errors):
    logs = run_dir / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    result = {"stage": "store_upsert", "status": "complete" if not errors else "incomplete",
              "input_count": count, "output_count": outputs, "started_at": started,
              "finished_at": now(), "tools_or_models": ["Python sqlite3"],
              "cost_usd": 0, "cost_estimate": True, "errors": errors}
    (logs / f"store_upsert_{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')}.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n")


def upsert(db, run_dir):
    started = now()
    count = 0
    outputs = 0
    errors = []
    for line_number, line in enumerate(sys.stdin, 1):
        if not line.strip():
            continue
        count += 1
        try:
            item = json.loads(line)
            for key in ("item_id", "version_id", "kind", "publisher_id", "text_path"):
                if not item.get(key):
                    raise ValueError("missing required item field " + key)
            item_id = item["item_id"]
            version_id = item["version_id"]
            latest_row = db.execute("SELECT latest_version_id FROM items WHERE item_id=?", (item_id,)).fetchone()
            version_row = db.execute("SELECT payload_json FROM versions WHERE item_id=? AND version_id=?",
                                     (item_id, version_id)).fetchone()
            if latest_row is None:
                change = "new"
                db.execute("INSERT INTO items VALUES (?, ?)", (item_id, version_id))
            elif latest_row[0] == version_id or version_row is not None:
                change = "unchanged"
            else:
                change = "changed"
                db.execute("UPDATE items SET latest_version_id=? WHERE item_id=?", (version_id, item_id))
            if version_row is None:
                db.execute("INSERT INTO versions VALUES (?, ?, ?, ?)",
                           (item_id, version_id, json.dumps(item, ensure_ascii=False, sort_keys=True), now()))
            db.execute("INSERT OR IGNORE INTO observations VALUES (?, ?, ?, ?)",
                       (run_dir.name, item_id, version_id, now()))
            db.commit()
            print(json.dumps({"item_id": item_id, "version_id": version_id, "change": change}), flush=True)
            outputs += 1
        except Exception as exc:
            db.rollback()
            errors.append(f"input line {line_number}: {type(exc).__name__}: {exc}")
    receipt(run_dir, started, count, outputs, errors)
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


def main():
    if len(sys.argv) < 2:
        print("usage: data/store.sh init|upsert RUN_DIR|list|get ITEM_ID [VERSION_ID]", file=sys.stderr)
        return 2
    command = sys.argv[1]
    if command not in {"init", "upsert", "list", "get"}:
        print("unknown store command", file=sys.stderr)
        return 2
    if command == "upsert" and (len(sys.argv) != 3 or not Path(sys.argv[2]).is_dir()):
        print("usage: data/store.sh upsert RUN_DIR", file=sys.stderr)
        return 2
    if command == "get" and len(sys.argv) not in (3, 4):
        print("usage: data/store.sh get ITEM_ID [VERSION_ID]", file=sys.stderr)
        return 2
    if command in {"init", "list"} and len(sys.argv) != 2:
        return 2
    db = connect()
    if command == "init":
        return 0
    if command == "upsert":
        return upsert(db, Path(sys.argv[2]).resolve())
    if command == "list":
        rows = db.execute("""SELECT v.payload_json FROM items i JOIN versions v
                             ON v.item_id=i.item_id AND v.version_id=i.latest_version_id
                             ORDER BY i.item_id""")
        for (payload,) in rows:
            print(payload)
        return 0
    item_id = sys.argv[2]
    version = sys.argv[3] if len(sys.argv) == 4 else None
    if version is None:
        row = db.execute("""SELECT v.payload_json FROM items i JOIN versions v
                            ON v.item_id=i.item_id AND v.version_id=i.latest_version_id
                            WHERE i.item_id=?""", (item_id,)).fetchone()
    else:
        row = db.execute("SELECT payload_json FROM versions WHERE item_id=? AND version_id=?",
                         (item_id, version)).fetchone()
    if row is None:
        print(f"item/version not found: {item_id} {version or ''}", file=sys.stderr)
        return 1
    print(row[0])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
