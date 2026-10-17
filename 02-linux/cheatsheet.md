# 🐧 Linux Cheat Sheet

## Navigation & files
| Command | Does |
|---|---|
| `pwd` · `ls -lah` · `cd -` | Where am I · list everything · previous dir |
| `mkdir -p a/b/c` | Create nested dirs |
| `cp -r src dst` · `mv a b` · `rm -r dir` | Copy · move/rename · delete |
| `ln -s target link` | Symbolic link |
| `find . -name "*.log" -mtime +7` | Find .log files older than 7 days |
| `cat` · `less` · `head -n 20` · `tail -f` | View · scroll · first lines · follow |

## Permissions & users
| Command | Does |
|---|---|
| `chmod 755 file` · `chmod +x file` | Set permissions · make executable |
| `chmod 600 key.pem` | Private key permissions |
| `chown user:group file` | Change owner |
| `id` · `whoami` · `sudo -i` | My identity · username · root shell |
| `sudo usermod -aG docker $USER` | Add yourself to a group (log out/in after) |

## Processes & services
| Command | Does |
|---|---|
| `ps aux` · `pgrep -a name` | List processes · find by name |
| `top` / `htop` | Live resource view |
| `kill PID` · `kill -9 PID` | Graceful stop · force kill |
| `sudo ss -tulpn` · `sudo lsof -i :80` | Listening ports · who uses port 80 |
| `systemctl status\|start\|stop\|restart\|enable svc` | Manage services |
| `journalctl -u svc -f` | Follow a service's logs |
| `crontab -e` | Schedule jobs |

## System info
| Command | Does |
|---|---|
| `uname -a` · `cat /etc/os-release` | Kernel/arch · distribution |
| `uptime` · `nproc` | Load average · CPU count |
| `free -h` · `df -h` · `du -sh *` | Memory · disk per FS · size per item |
| `lsblk` · `mount` | Disks · mounted file systems |
| `dmesg -T \| tail` | Kernel messages (hardware, OOM kills) |

## Text processing
| Command | Does |
|---|---|
| `grep -rin "text" dir/` | Recursive, case-insensitive search with line numbers |
| `awk '{print $1}'` | Print first column |
| `sed 's/old/new/g'` | Replace text |
| `sort \| uniq -c \| sort -rn` | Count and rank duplicates |
| `cut -d: -f1` · `wc -l` · `tr a-z A-Z` | Fields · count lines · translate |

## Networking
| Command | Does |
|---|---|
| `ip a` · `ip r` | IP addresses · routing table (Linux) |
| `ping -c 4 host` · `traceroute host` | Reachability · path |
| `dig +short name` · `nslookup name` | DNS lookup |
| `curl -I url` · `curl -v url` | Headers only · verbose request |
| `nc -zv host 443` | Is a TCP port open? |

## Archives & transfer
| Command | Does |
|---|---|
| `tar -czf out.tar.gz dir/` | Create compressed archive |
| `tar -xzf out.tar.gz -C /dest` | Extract |
| `scp file host:/path` · `rsync -avz src/ host:/dst/` | Copy · sync |

## Shell shortcuts
| Keys | Does |
|---|---|
| `Ctrl+C` · `Ctrl+Z` · `Ctrl+D` | Stop · suspend · end input/log out |
| `Ctrl+R` | Search command history |
| `Ctrl+A` · `Ctrl+E` | Start · end of line |
| `!!` · `sudo !!` | Repeat last command · repeat it with sudo |
| `Tab` (twice) | Autocomplete / show options |
