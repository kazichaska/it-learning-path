#!/usr/bin/env bash
# backup.sh — create a timestamped .tar.gz backup of a directory and keep only the newest N.
#
# Usage:   ./backup.sh <source_dir> <backup_dir> [keep=7]
# Example: ./backup.sh ~/Projects/it-learning-path ~/backups 5
#
# Cron example (every night at 02:00):
#   0 2 * * * /opt/scripts/backup.sh /var/www /backups 14 >> /var/log/backup.log 2>&1
set -euo pipefail

usage() {
  echo "Usage: $0 <source_dir> <backup_dir> [keep=7]" >&2
  exit 2
}

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

[[ $# -ge 2 ]] || usage

SOURCE_DIR="$1"
BACKUP_DIR="$2"
KEEP="${3:-7}"

[[ -d "$SOURCE_DIR" ]] || { echo "Error: source '$SOURCE_DIR' is not a directory" >&2; exit 1; }
[[ "$KEEP" =~ ^[1-9][0-9]*$ ]] || { echo "Error: keep must be a positive number" >&2; exit 1; }

mkdir -p "$BACKUP_DIR"

# Resolve absolute paths so tar and the rotation logic behave predictably.
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
BACKUP_DIR="$(cd "$BACKUP_DIR" && pwd)"

case "$BACKUP_DIR/" in
  "$SOURCE_DIR"/*)
    echo "Error: backup_dir must not be inside source_dir (the backup would include itself)" >&2
    exit 1
    ;;
esac

name="$(basename "$SOURCE_DIR")"
timestamp="$(date +%Y%m%d-%H%M%S)"
archive="$BACKUP_DIR/${name}-${timestamp}.tar.gz"

log "Backing up $SOURCE_DIR -> $archive"
# -C changes into the parent dir so the archive contains "name/..." instead of the full path.
tar -czf "$archive" -C "$(dirname "$SOURCE_DIR")" "$name"
log "Created $(du -h "$archive" | cut -f1) archive"

# Verify the archive can be read before trusting it.
if ! tar -tzf "$archive" >/dev/null; then
  echo "Error: archive verification failed: $archive" >&2
  exit 1
fi
log "Archive verified"

# Rotation: timestamps sort alphabetically in date order, so the glob is oldest-first.
backups=( "$BACKUP_DIR/${name}"-*.tar.gz )
count=${#backups[@]}
if (( count > KEEP )); then
  for (( i = 0; i < count - KEEP; i++ )); do
    rm -f -- "${backups[i]}"
    log "Removed old backup ${backups[i]}"
  done
fi

log "Done. Keeping the newest $(( count < KEEP ? count : KEEP )) backup(s) of '$name'."
