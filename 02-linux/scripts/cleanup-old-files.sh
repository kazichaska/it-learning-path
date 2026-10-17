#!/usr/bin/env bash
# cleanup-old-files.sh — find (and optionally delete) files older than N days.
#
# Safe by default: without --delete it only shows what WOULD be removed (a "dry run").
#
# Usage:   ./cleanup-old-files.sh <directory> [days=7] [--delete]
# Example: ./cleanup-old-files.sh /var/log/myapp 14            # dry run
#          ./cleanup-old-files.sh /var/log/myapp 14 --delete   # really delete
set -euo pipefail

usage() {
  echo "Usage: $0 <directory> [days=7] [--delete]" >&2
  exit 2
}

[[ $# -ge 1 && $# -le 3 ]] || usage

TARGET="$1"
DAYS="${2:-7}"
MODE="${3:-}"

[[ -d "$TARGET" ]] || { echo "Error: '$TARGET' is not a directory" >&2; exit 1; }
[[ "$DAYS" =~ ^[0-9]+$ ]] || { echo "Error: days must be a whole number" >&2; exit 1; }
[[ -z "$MODE" || "$MODE" == "--delete" ]] || usage

# Normalize the path (removes trailing slashes, resolves ..) before the safety check.
TARGET="$(cd "$TARGET" && pwd)"

# Guard rails: refuse to clean important system locations or your whole home directory.
case "$TARGET" in
  /|/bin|/boot|/dev|/etc|/home|/lib|/proc|/root|/sbin|/sys|/usr|/var|/Users|/System|/Applications|"$HOME")
    echo "Refusing to clean '$TARGET': too dangerous. Point me at a specific subfolder." >&2
    exit 1
    ;;
esac

# Collect matches once so the count and the list always agree.
matches=$(find "$TARGET" -type f -mtime +"$DAYS")
if [[ -z "$matches" ]]; then
  echo "No files older than $DAYS day(s) in $TARGET."
  exit 0
fi
count=$(printf '%s\n' "$matches" | wc -l | tr -d ' ')

printf '%s\n' "$matches"
if [[ "$MODE" == "--delete" ]]; then
  find "$TARGET" -type f -mtime +"$DAYS" -delete
  echo "Deleted $count file(s) older than $DAYS day(s) from $TARGET."
else
  echo "DRY RUN: $count file(s) would be deleted. Re-run with --delete to remove them."
fi
