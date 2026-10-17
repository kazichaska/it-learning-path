# 02 · Linux & Command Line

> **Goal:** Be comfortable on any Linux server: navigate, manage files and permissions, investigate processes and logs, and automate tasks with Bash.

Almost every cloud server, container and CI runner runs Linux. This is the single most important skill in Cloud & DevOps.

## 📚 Lessons

| # | Lesson | Key commands |
|---|---|---|
| 1 | [File system & navigation](notes/01-filesystem-and-navigation.md) | `ls`, `cd`, `cp`, `mv`, `rm`, `find`, `ln`, `df`, `du` |
| 2 | [Users & permissions](notes/02-users-and-permissions.md) | `chmod`, `chown`, `sudo`, `id`, `useradd` |
| 3 | [Processes & services](notes/03-processes-and-services.md) | `ps`, `top`, `kill`, `systemctl`, `journalctl`, `cron` |
| 4 | [Text processing & pipes](notes/04-text-processing-and-pipes.md) | `grep`, `awk`, `sed`, `sort`, `uniq`, `xargs` |
| 5 | [Bash scripting](notes/05-bash-scripting.md) | variables, `if`, loops, functions, `set -euo pipefail` |
| 6 | [Packages, SSH & remote work](notes/06-packages-ssh-and-remote.md) | `apt`, `dnf`, `ssh`, `scp`, `rsync` |

📄 **Quick reference:** [Linux cheat sheet](cheatsheet.md)

## 🧰 Scripts (real, runnable)

| Script | What it teaches |
|---|---|
| [`system-health.sh`](scripts/system-health.sh) | Gathering system info, functions, `awk`, exit codes for monitoring |
| [`backup.sh`](scripts/backup.sh) | Arguments, validation, `tar`, timestamps, backup rotation |
| [`cleanup-old-files.sh`](scripts/cleanup-old-files.sh) | Safe deletion with `find`, dry-run by default, safety guards |

See [scripts/README.md](scripts/README.md) for how to run them.

## 🖥️ Where to practise

| Option | How | Best for |
|---|---|---|
| macOS Terminal | Already on your Mac | Most commands (macOS is Unix, but not Linux) |
| Docker container | `docker run -it --rm ubuntu:24.04 bash` | A real Linux shell in seconds; throw it away after |
| Multipass VM | `brew install multipass` then `multipass launch --name lab` | A full Ubuntu VM with systemd |
| AWS EC2 | Free-tier eligible `t3.micro`/`t4g.micro` (check current free-tier terms) | Real cloud experience |
| OverTheWire Bandit | https://overthewire.org/wargames/bandit/ | Fun, game-style Linux practice |

⚠️ **macOS vs Linux differences:** macOS ships BSD versions of tools (`sed -i ''` vs `sed -i`, no `free`, no `systemctl`, `ss` missing). When something behaves oddly, practise in a Linux container.

## ✅ Self-check

- [ ] Explain `chmod 755` and `chmod 600` and when you'd use each
- [ ] Find which process is using port 8080
- [ ] Follow a log file live and filter it for errors
- [ ] Start, stop and check the status of a systemd service, and read its logs
- [ ] Write a Bash script with arguments, an `if`, a loop and a function, which passes `shellcheck`
- [ ] SSH into a server with a key and copy files with `scp` or `rsync`

➡️ **Next:** [03 · Networking](../03-networking/)
