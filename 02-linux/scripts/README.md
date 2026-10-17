# Linux Scripts

Real, runnable Bash scripts. Each one demonstrates techniques from the [Bash scripting notes](../notes/05-bash-scripting.md). They work on Linux and macOS.

## Setup

```bash
cd 02-linux/scripts
chmod +x *.sh          # make them executable (Git usually keeps this bit)
```

## The scripts

### `system-health.sh`: quick server health snapshot
```bash
./system-health.sh          # warn if any disk is ≥ 80% full
./system-health.sh 90       # custom threshold
echo $?                     # 0 = OK, 1 = disk warning
```
**Teaches:** functions, `uname`/`df`/`ps`, `awk` for parsing columns, OS detection, returning meaningful exit codes for monitoring.

### `backup.sh`: timestamped backups with rotation
```bash
./backup.sh ~/Projects/it-learning-path ~/backups 5
ls ~/backups
```
**Teaches:** argument validation, `tar`, `date` formats, arrays, arithmetic, verifying output, rotation (keep the newest N).

### `cleanup-old-files.sh`: safe cleanup of old files
```bash
mkdir -p /tmp/cleanup-lab
touch -t 202501010000 /tmp/cleanup-lab/old.log     # fake an old file
touch /tmp/cleanup-lab/new.log
./cleanup-old-files.sh /tmp/cleanup-lab 30          # dry run: lists old.log
./cleanup-old-files.sh /tmp/cleanup-lab 30 --delete # actually deletes it
```
**Teaches:** dry-run-by-default design, guard rails against dangerous paths, `find -mtime`.

## 🏋️ Challenges

1. Add a `--json` flag to `system-health.sh` that prints the disk results as JSON.
2. Make `backup.sh` upload the archive to S3 if the `S3_BUCKET` environment variable is set (`aws s3 cp`).
3. Turn `system-health.sh` into a systemd timer or cron job that runs every 10 minutes and logs to `/var/log/health.log`.
4. Run `shellcheck *.sh` and make sure your changes stay warning-free.
