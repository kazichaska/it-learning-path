# Debugging

> Debugging is the core skill of operations work. Great engineers aren't the ones who never see errors; they're the ones with a **method** for finding the cause quickly.

## The method (scientific debugging)

1. **Reproduce it.** Can you make it happen on demand? What exactly happens: error text, status code, timestamp?
2. **Read the actual error message.** All of it, especially the first and last lines of a stack trace.
3. **Check what changed.** Most incidents follow a change: a deploy, a config edit, a certificate expiry, a dependency update, traffic growth.
4. **Form a hypothesis.** "I think the app can't reach the DB because the security group changed."
5. **Test it with one change or one command.** Don't change five things at once.
6. **Narrow down (divide and conquer).** Which layer? Which component? Which commit (`git bisect`)?
7. **Fix, verify, and write it down.** Add a test, alert or runbook entry so it doesn't happen again.

> 💡 During an outage: **mitigate first** (roll back, fail over, scale up), **diagnose second**.

## Where to look

| Source | Command / place |
|---|---|
| Application logs | `journalctl -u app`, `/var/log/app/*.log`, `docker logs <c>`, `kubectl logs <pod>` |
| System logs | `journalctl -p err -b`, `dmesg -T` (OOM kills, disk errors) |
| Resource usage | `top`, `free -h`, `df -h`, `iostat`, `kubectl top pods` |
| Network | See the [network troubleshooting playbook](../../03-networking/notes/07-troubleshooting-playbook.md) |
| Recent changes | `git log`, deploy history, CloudTrail (AWS API changes) |
| Metrics & dashboards | CloudWatch, Grafana, Datadog |

## Reading a stack trace (Python example)

```
Traceback (most recent call last):
  File "/app/main.py", line 42, in <module>
    orders = load_orders(conn)
  File "/app/db.py", line 17, in load_orders
    cur.execute("SELECT * FROM order")
psycopg.errors.SyntaxError: syntax error at or near "order"
```
- **Read from the bottom up:** the last line is the error type and message.
- The frames above show *how* the program got there. Find the first frame in **your** code (`db.py`, line 17).
- Here: `order` is a reserved SQL word. The table should be `orders` (or quoted).

## Tools

| Tool | Use |
|---|---|
| `print()` / `echo` / log statements | Quick and always available |
| `bash -x script.sh` or `set -x` | Print every command a Bash script runs |
| Python `breakpoint()` | Drop into the `pdb` debugger at that line |
| VS Code debugger | Set breakpoints by clicking left of a line number, press **F5** |
| `curl -v` | See the full HTTP conversation |
| `strace -f -p <pid>` (Linux) | Watch a process's system calls (what file is it failing to open?) |
| `git bisect` | Binary-search history for the commit that broke something |
| Rubber duck 🦆 | Explain the problem out loud, line by line. Surprisingly effective |

### git bisect in 30 seconds
```bash
git bisect start
git bisect bad                 # current commit is broken
git bisect good v1.4.0         # this older version worked
# Git checks out a commit in the middle → test it → tell Git:
git bisect good                # or: git bisect bad
# ...repeat until Git prints the first bad commit...
git bisect reset
```

## 🔎 Error message decoder

| Error | Usually means | First thing to try |
|---|---|---|
| `command not found` | Not installed, or not in `$PATH` | `which cmd`, check `echo $PATH`, install it |
| `Permission denied` | Missing file permissions or wrong user | `ls -l`, `id`, `chmod +x`, `sudo` (if appropriate) |
| `No such file or directory` | Wrong path, or relative path from the wrong dir | `pwd`, use absolute paths |
| `No space left on device` | Disk full (or out of inodes) | `df -h`, `df -i`, `du -sh /var/*` |
| `Address already in use` | Another process is on that port | `lsof -i :PORT` / `ss -tlnp` |
| `Connection refused` | Nothing listening at that host:port | Is the service running? Correct port? Bound to `0.0.0.0`? |
| `Connection timed out` | Firewall/security group or routing | Check SGs, NACLs, routes |
| `Could not resolve host` | DNS | `dig name` |
| `SSL certificate problem` | Expired/self-signed cert, wrong name, clock skew | `openssl s_client`, check dates |
| `Killed` / exit code **137** | Out of memory (OOM killer, SIGKILL) | `dmesg -T \| grep -i oom`, raise memory limits, fix leaks |
| `Segmentation fault` / exit code **139** | Program crashed accessing bad memory | Check versions/architecture, core dump |
| `exec format error` | Wrong CPU architecture (arm64 vs amd64) or missing shebang | `docker build --platform linux/amd64`, add `#!/usr/bin/env bash` |
| `CrashLoopBackOff` (Kubernetes) | Container starts and keeps crashing | `kubectl logs <pod> --previous` |
| `ImagePullBackOff` (Kubernetes) | Image name/tag wrong or no registry access | `kubectl describe pod <pod>` |
| `AccessDenied` (AWS) | IAM policy doesn't allow the action | Read the action + resource in the message; check the policy |
| HTTP `502`/`503`/`504` | Backend down / no healthy targets / too slow | Check targets behind the load balancer |

## Exit codes cheat sheet

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General error |
| 2 | Misuse of command / bad arguments |
| 126 | Found but not executable |
| 127 | Command not found |
| 128 + N | Killed by signal N (130 = Ctrl+C, 137 = SIGKILL/OOM, 143 = SIGTERM) |

## 🏋️ Exercises

1. Run `bash -x ../../02-linux/scripts/backup.sh` with no arguments. Follow the trace: which line decided to exit?
2. Put `breakpoint()` inside `parse_line` in [`log_analyzer.py`](../python/log_analyzer.py), run it and inspect `match` with `p match`. Type `c` to continue and `q` to quit.
3. Break the sample log on purpose (delete a quote on one line) and see how the analyzer reports unparsed lines.
