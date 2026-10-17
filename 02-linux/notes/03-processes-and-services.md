# 3 · Processes & Services

## Looking at processes

```bash
ps aux                         # every process (BSD style)
ps -ef                         # every process (System V style, shows PPID)
ps aux | grep nginx            # find a specific process
pgrep -a nginx                 # cleaner: PIDs + command lines
top                            # live view (q to quit; P sort CPU, M sort memory)
htop                           # nicer top (install it)
```

### Key `ps aux` columns
| Column | Meaning |
|---|---|
| `USER` | Who runs it |
| `PID` | Process ID |
| `%CPU`, `%MEM` | Resource usage |
| `VSZ`, `RSS` | Virtual / actual (resident) memory in KiB |
| `STAT` | State: `R` running, `S` sleeping, `D` waiting on disk (uninterruptible), `Z` zombie |
| `COMMAND` | What's running |

```bash
ps aux --sort=-%cpu | head -6       # top CPU users (Linux)
ps aux --sort=-%mem | head -6       # top memory users (Linux)
ps aux | sort -nrk 3 | head -5      # portable version (works on macOS too)
```

## Load average

`uptime` shows `load average: 0.52, 0.78, 1.10`: the 1, 5 and 15-minute averages of processes running or waiting.
**Rule of thumb:** compare to the number of CPU cores (`nproc`). On 4 cores, a load of 4 = fully busy; 8 = things are queueing.

## Signals: talking to processes

| Signal | Number | Meaning |
|---|---|---|
| `SIGTERM` | 15 | "Please shut down cleanly" (default for `kill`) |
| `SIGKILL` | 9 | "Die now." Can't be caught; no cleanup. **Last resort** |
| `SIGINT` | 2 | What Ctrl+C sends |
| `SIGHUP` | 1 | Often means "reload your config" (nginx, sshd) |

```bash
kill 1234              # SIGTERM
kill -9 1234           # SIGKILL (only if SIGTERM didn't work)
pkill -f "python app.py"
kill -HUP $(pgrep -o nginx)   # ask nginx's master process to reload config
```

💡 Docker and Kubernetes send **SIGTERM**, wait (10s / 30s by default), then **SIGKILL**. Apps should handle SIGTERM to shut down gracefully.

## Foreground, background & jobs

```bash
long_task &            # run in background
jobs                   # list background jobs
fg %1                  # bring job 1 to the foreground
# Ctrl+Z suspends the foreground job; then `bg` resumes it in the background
nohup ./script.sh > out.log 2>&1 &   # keep running after you log out
```
For anything long-running over SSH, use **`tmux`** or **`screen`**, or better, make it a service.

## Which process uses a port?

```bash
sudo ss -tulpn | grep :8080         # Linux (modern)
sudo lsof -i :8080                  # Linux and macOS
```
`Address already in use` error? Something is already listening on that port. Find it with the commands above.

## systemd: managing services

Most modern distros use **systemd** as PID 1. Services are described by **unit files**.

```bash
systemctl status nginx          # is it running? recent log lines
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx    # stop + start
sudo systemctl reload nginx     # reload config without dropping connections
sudo systemctl enable nginx     # start automatically at boot
sudo systemctl enable --now nginx   # enable + start in one go
systemctl --failed              # which services have failed?
systemctl list-units --type=service --state=running
```

### Reading logs with journalctl
```bash
journalctl -u nginx              # all logs for a service
journalctl -u nginx -f           # follow live
journalctl -u nginx --since "1 hour ago"
journalctl -p err -b             # errors since the last boot
```

### Writing your own service

`/etc/systemd/system/myapp.service`:
```ini
[Unit]
Description=My Python web app
After=network.target

[Service]
User=myapp
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=on-failure
RestartSec=5
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload        # after creating/editing unit files
sudo systemctl enable --now myapp
```

## Scheduling with cron

```bash
crontab -e     # edit your scheduled jobs
crontab -l     # list them
```
```
# ┌ minute (0-59)
# │ ┌ hour (0-23)
# │ │ ┌ day of month (1-31)
# │ │ │ ┌ month (1-12)
# │ │ │ │ ┌ day of week (0-6, Sun=0)
# │ │ │ │ │
  0 2 * * * /opt/scripts/backup.sh /var/www /backups >> /var/log/backup.log 2>&1
*/5 * * * * /opt/scripts/system-health.sh > /dev/null || echo "health check failed" | logger
```
💡 Use https://crontab.guru to check expressions. Cron has a minimal `PATH`, so use **absolute paths** in cron jobs. systemd **timers** are the modern alternative.

## 🧠 Practice
1. A server's load average is `12.0` and it has 4 cores. What does that tell you?
2. `kill 4321` didn't stop a process. What do you try next, and why not first?
3. You edited a unit file but `systemctl restart` still uses the old settings. What did you forget?

<details><summary>Answers</summary>

1. It's heavily overloaded. About 3× more work is queued than the CPUs can handle (or processes are stuck waiting on disk, state `D`).
2. `kill -9 4321`. Not first, because SIGKILL gives the process no chance to save data or close connections cleanly.
3. `sudo systemctl daemon-reload`.
</details>
