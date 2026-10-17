#!/usr/bin/env python3
"""Analyse a web server access log (nginx/Apache "combined" format).

Examples:
    python3 log_analyzer.py sample-access.log
    python3 log_analyzer.py sample-access.log --top 3
    python3 log_analyzer.py sample-access.log --json
"""
import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

# 203.0.113.9 - - [14/Oct/2026:10:00:01 +0000] "GET /index.html HTTP/1.1" 200 5120 "-" "curl/8.7.1"
LINE_PATTERN = re.compile(
    r'(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\] '
    r'"(?P<method>[A-Z]+) (?P<path>\S+) [^"]*" '
    r'(?P<status>\d{3}) (?P<size>\d+|-)'
)


def parse_line(line: str) -> dict | None:
    """Return the fields of one log line, or None if it doesn't match the format."""
    match = LINE_PATTERN.match(line)
    if not match:
        return None
    entry = match.groupdict()
    entry["status"] = int(entry["status"])
    entry["size"] = 0 if entry["size"] == "-" else int(entry["size"])
    return entry


def analyse(lines, top: int) -> dict:
    entries, skipped = [], 0
    for line in lines:
        entry = parse_line(line)
        if entry:
            entries.append(entry)
        elif line.strip():
            skipped += 1

    total = len(entries)
    errors = sum(1 for e in entries if e["status"] >= 500)
    return {
        "total_requests": total,
        "skipped_lines": skipped,
        "total_bytes": sum(e["size"] for e in entries),
        "status_codes": dict(sorted(Counter(e["status"] for e in entries).items())),
        "status_classes": dict(sorted(Counter(f"{e['status'] // 100}xx" for e in entries).items())),
        "top_ips": Counter(e["ip"] for e in entries).most_common(top),
        "top_paths": Counter(e["path"] for e in entries).most_common(top),
        "server_error_rate_pct": round(100 * errors / total, 2) if total else 0.0,
    }


def print_report(report: dict) -> None:
    print(f"Total requests:     {report['total_requests']}")
    print(f"Total data sent:    {report['total_bytes'] / 1024:.1f} KiB")
    print(f"5xx error rate:     {report['server_error_rate_pct']}%")
    if report["skipped_lines"]:
        print(f"Unparsed lines:     {report['skipped_lines']}")

    print("\nStatus codes:")
    for code, count in report["status_codes"].items():
        print(f"  {code}  {count:>5}  {'#' * count}")

    print("\nTop client IPs:")
    for ip, count in report["top_ips"]:
        print(f"  {ip:<16} {count:>5}")

    print("\nTop paths:")
    for path, count in report["top_paths"]:
        print(f"  {path:<24} {count:>5}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Analyse a web server access log.")
    parser.add_argument("logfile", type=Path, help="path to the access log")
    parser.add_argument("--top", type=int, default=5, help="how many top IPs/paths to show")
    parser.add_argument("--json", action="store_true", help="print the report as JSON")
    args = parser.parse_args()

    if not args.logfile.is_file():
        sys.exit(f"Error: {args.logfile} not found")

    with args.logfile.open(encoding="utf-8", errors="replace") as handle:
        report = analyse(handle, args.top)

    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print_report(report)


if __name__ == "__main__":
    main()
