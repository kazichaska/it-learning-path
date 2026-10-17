#!/usr/bin/env bash
# system-health.sh — print a quick health snapshot of a Linux or macOS machine.
#
# Usage:   ./system-health.sh [disk_warn_percent]
# Example: ./system-health.sh 90
#
# Exit codes: 0 = healthy, 1 = at least one disk is above the threshold.
# That makes it usable from cron or a monitoring tool:
#   ./system-health.sh > /dev/null || echo "Disk warning on $(hostname)"
set -euo pipefail

DISK_WARN="${1:-80}"
OS="$(uname -s)"

if ! [[ "$DISK_WARN" =~ ^[0-9]+$ ]] || (( DISK_WARN > 100 )); then
  echo "Error: disk_warn_percent must be a number from 0 to 100" >&2
  exit 2
fi

section() {
  printf '\n=== %s ===\n' "$1"
}

show_system() {
  section "System"
  echo "Host:     $(hostname)"
  echo "OS:       ${OS} $(uname -r) ($(uname -m))"
  echo "Uptime:   $(uptime | sed -E 's/.*up +([^,]+),.*/\1/')"
  echo "Load avg: $(uptime | sed -E 's/.*load averages?: //')"
}

show_memory() {
  section "Memory"
  if [[ "$OS" == "Linux" ]]; then
    free -h
  else
    local total_gib
    total_gib=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    echo "Total RAM: ${total_gib} GiB"
    memory_pressure 2>/dev/null | tail -n 1 || true
  fi
}

# Prints the disk table and marks file systems at or above the threshold.
# Returns 1 if any disk is over the threshold.
check_disks() {
  section "Disk usage (warning at ${DISK_WARN}%)"
  local report status
  if report=$(df -Ph | awk -v warn="$DISK_WARN" '
    NR == 1 { print; next }
    $1 ~ /^(devfs|map|tmpfs|devtmpfs|overlay|efivarfs|\/dev\/loop)/ { next }   # skip virtual and snap loop mounts
    {
      use = $5; sub(/%/, "", use)
      if (use + 0 >= warn) { print $0 "   <-- WARNING"; bad = 1 } else { print }
    }
    END { exit bad }
  '); then
    status=0
  else
    status=$?
  fi
  echo "$report"
  return "$status"
}

show_top_processes() {
  section "Top 5 processes by CPU"
  local list
  list=$(ps -eo pid,pcpu,pmem,ucomm)
  echo "$list" | head -n 1
  echo "$list" | tail -n +2 | sort -k2 -nr | head -n 5
}

show_listening_ports() {
  section "Listening TCP ports"
  if command -v ss >/dev/null 2>&1; then
    ss -tln
  elif command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR == 1 || !seen[$1 $9]++' || true
  else
    echo "(neither ss nor lsof is available)"
  fi
}

show_failed_services() {
  if command -v systemctl >/dev/null 2>&1; then
    section "Failed systemd services"
    systemctl --failed --no-legend || true
  fi
}

main() {
  show_system
  show_memory
  local disk_status=0
  check_disks || disk_status=1
  show_top_processes
  show_listening_ports
  show_failed_services

  echo
  if (( disk_status == 0 )); then
    echo "RESULT: OK"
  else
    echo "RESULT: WARNING (disk usage at or above ${DISK_WARN}%)"
  fi
  return "$disk_status"
}

main "$@"
