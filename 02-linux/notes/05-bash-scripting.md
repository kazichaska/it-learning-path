# 5 · Bash Scripting

> **Why:** If you do something twice, script it. If you do it three times, put it in a pipeline. Bash is the glue of DevOps: CI steps, server setup, cron jobs, Docker entrypoints.

## The template to start every script with

```bash
#!/usr/bin/env bash
# deploy.sh — one line saying what this script does.
# Usage: ./deploy.sh <environment>
set -euo pipefail

main() {
  echo "Hello from $0"
}

main "$@"
```

| Line | Why |
|---|---|
| `#!/usr/bin/env bash` | **Shebang**: run this file with bash, wherever it's installed |
| `set -e` | Exit immediately if a command fails |
| `set -u` | Error on undefined variables (prevents `rm -rf "$UNSET/"*` disasters) |
| `set -o pipefail` | A pipeline fails if *any* command in it fails, not just the last |
| `main "$@"` | Keeps code organized; `"$@"` passes all arguments through safely |

Make it executable and run: `chmod +x deploy.sh && ./deploy.sh staging`

## Variables and quoting

```bash
name="world"                 # NO spaces around =
echo "Hello, $name"          # double quotes: variables expand
echo 'Hello, $name'          # single quotes: literal text
today=$(date +%F)            # command substitution → 2026-10-14
count=$((3 + 4))             # arithmetic → 7
readonly MAX_RETRIES=3       # constant
```

⚠️ **Always quote variables:** `"$file"` not `$file`. Unquoted variables break on spaces and wildcards.

### Defaults and string tricks (parameter expansion)
```bash
env="${1:-dev}"              # first argument, or "dev" if missing
: "${API_KEY:?API_KEY must be set}"   # exit with a message if unset

file="backup.tar.gz"
echo "${file%.gz}"           # backup.tar   (remove shortest suffix match)
echo "${file%%.*}"           # backup       (remove longest suffix match)
echo "${file#*.}"            # tar.gz       (remove shortest prefix match)
echo "${#file}"              # 13           (length)
path="/var/log/nginx/access.log"
echo "${path##*/}"           # access.log   (like basename)
```

## Arguments

| Variable | Meaning |
|---|---|
| `$0` | Script name |
| `$1`, `$2`… | Positional arguments |
| `$#` | Number of arguments |
| `"$@"` | All arguments, each safely quoted |
| `$?` | Exit code of the last command |
| `$$` | PID of this script |

```bash
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <environment>" >&2     # errors go to stderr
  exit 2
fi
```

## Conditionals

```bash
if [[ -f "$file" ]]; then
  echo "file exists"
elif [[ -d "$file" ]]; then
  echo "it's a directory"
else
  echo "not found"
fi
```

| Test | True if… |
|---|---|
| `-f path` / `-d path` / `-e path` | File / directory / anything exists |
| `-r` / `-w` / `-x path` | Readable / writable / executable |
| `-z "$s"` / `-n "$s"` | String is empty / not empty |
| `"$a" == "$b"` / `!=` | Strings equal / not equal |
| `$a -eq $b` (`-ne -lt -le -gt -ge`) | Numeric comparisons |
| `"$s" =~ ^[0-9]+$` | Regex match |

Short forms:
```bash
[[ -d "$dir" ]] || mkdir -p "$dir"       # create only if missing
command -v docker >/dev/null || { echo "docker not installed" >&2; exit 1; }
```

### case
```bash
case "$env" in
  dev|staging) echo "safe to deploy" ;;
  prod)        echo "are you sure?" ;;
  *)           echo "unknown env: $env" >&2; exit 1 ;;
esac
```

## Loops

```bash
for server in web1 web2 web3; do
  echo "Checking $server"
done

for file in /var/log/*.log; do
  echo "$file: $(wc -l < "$file") lines"
done

for i in {1..5}; do echo "attempt $i"; done

while read -r line; do
  echo "→ $line"
done < servers.txt

# Retry until success (max 5 times)
for attempt in {1..5}; do
  if curl -fsS http://localhost:8080/health >/dev/null; then
    echo "healthy"; break
  fi
  echo "not ready (attempt $attempt), retrying…"; sleep 2
done
```

## Functions

```bash
log() {
  local level="$1"; shift              # 'local' keeps variables inside the function
  printf '%s [%s] %s\n' "$(date +%T)" "$level" "$*"
}

log INFO "Deploy started"
log ERROR "Something broke" >&2
```
Functions return an **exit code** (`return 0` success, `return 1` failure). To return data, `echo` it and capture with `$(...)`.

## Exit codes

- `0` = success; anything else = failure. Check with `echo $?`.
- `cmd1 && cmd2`: run cmd2 only if cmd1 **succeeded**
- `cmd1 || cmd2`: run cmd2 only if cmd1 **failed**
- CI/CD pipelines, cron and health checks all rely on exit codes.

## Cleanup with trap

```bash
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT     # runs when the script exits, even on error
```

## Heredocs: multi-line text

```bash
cat > config.ini <<EOF
env=$env
date=$(date +%F)
EOF
```
Use `<<'EOF'` (quoted) to stop variable expansion.

## Idempotency: a core DevOps principle

An **idempotent** script gives the same result whether you run it once or ten times.

| ❌ Not idempotent | ✅ Idempotent |
|---|---|
| `mkdir logs` (fails the 2nd time) | `mkdir -p logs` |
| `echo "x" >> config` (duplicates lines) | `grep -qx "x" config \|\| echo "x" >> config` |
| `useradd app` (errors if exists) | `id app &>/dev/null \|\| useradd app` |

Tools like Ansible and Terraform are built around this idea.

## ShellCheck: your Bash linter

```bash
brew install shellcheck        # macOS
shellcheck myscript.sh
```
It catches unquoted variables, typos and subtle bugs. This repo's CI runs it on every push (see [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)).

## 🧠 Practice
Write `check-sites.sh` that takes URLs as arguments, prints `UP` or `DOWN` for each, and exits with code 1 if any are down.

<details><summary>One solution</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

[[ $# -ge 1 ]] || { echo "Usage: $0 <url>..." >&2; exit 2; }

failed=0
for url in "$@"; do
  if curl -fsS --max-time 5 -o /dev/null "$url"; then
    echo "UP    $url"
  else
    echo "DOWN  $url"
    failed=1
  fi
done
exit "$failed"
```
</details>

See full real examples in [`../scripts/`](../scripts/).
