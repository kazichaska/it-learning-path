# 1 · File System & Navigation

## The Linux directory tree

Everything starts at `/` (the **root** directory). There are no drive letters like `C:\`.

| Path | Contains | You'll go there to… |
|---|---|---|
| `/etc` | System configuration files | Edit `nginx.conf`, `/etc/hosts`, `/etc/ssh/sshd_config` |
| `/var` | Variable data: logs, caches, databases | Read logs in `/var/log/` |
| `/home` | Users' home folders (`/home/ubuntu`) | Keep your own files |
| `/root` | The root user's home | (rarely) |
| `/usr` | Installed programs and libraries | Find binaries in `/usr/bin` |
| `/opt` | Optional/third-party software | Install vendor apps |
| `/tmp` | Temporary files, often wiped at reboot | Scratch work |
| `/proc` | Virtual files describing processes and the kernel | `cat /proc/cpuinfo` |
| `/dev` | Devices (disks, terminals) | `/dev/nvme0n1`, `/dev/null` |
| `/mnt`, `/media` | Mount points for extra disks | Mount an EBS volume |
| `/boot` | Kernel and bootloader | (be careful) |

## Paths

- **Absolute** paths start with `/`: `/var/log/syslog`
- **Relative** paths start from where you are: `logs/app.log`
- `.` = current dir, `..` = parent dir, `~` = your home dir, `-` = previous dir (`cd -`)

## Navigation

```bash
pwd                  # print working directory: where am I?
ls -lah              # list: long format, all (incl. hidden), human sizes
cd /var/log          # go to an absolute path
cd ..                # up one level
cd ~  # or just: cd  # go home
cd -                 # jump back to the previous directory
tree -L 2            # tree view, 2 levels deep (may need installing)
```

### Reading `ls -l` output
```
-rw-r--r--  1 ubuntu ubuntu  4096 Oct 14 10:00 notes.txt
│└──┬────┘    └─┬──┘ └─┬──┘  └┬─┘ └────┬─────┘ └───┬───┘
│   perms     owner  group   size   modified     name
└ type: - file, d directory, l symlink
```

## Working with files and directories

```bash
mkdir -p projects/app/logs     # create nested dirs (no error if they exist)
touch file.txt                 # create empty file / update timestamp
cp file.txt backup.txt         # copy
cp -r dir1 dir2                # copy a directory recursively
mv old.txt new.txt             # rename or move
rm file.txt                    # delete a file (no recycle bin!)
rm -r dir                      # delete a directory and everything in it
rmdir emptydir                 # delete an empty directory only
```

⚠️ **`rm -rf` has no undo.** Always double-check the path, especially with variables: `rm -rf "$DIR/"*` when `$DIR` is empty becomes `rm -rf /*`. Use `set -u` in scripts (see [Bash scripting](05-bash-scripting.md)).

## Viewing files

```bash
cat file.txt           # print whole file
less /var/log/syslog   # scroll (q quit, / search, G end, g start)
head -n 20 file        # first 20 lines
tail -n 50 file        # last 50 lines
tail -f app.log        # follow live: essential for watching logs
wc -l file             # count lines
```

## Finding things

```bash
find /var/log -name "*.log"                 # by name
find . -type f -size +100M                  # files bigger than 100 MB
find /tmp -type f -mtime +7                 # modified more than 7 days ago
find . -name "*.tmp" -exec rm {} \;         # run a command on each result
which python3                               # where is this command?
type ll                                     # is it an alias, function or binary?
```

## Links

```bash
ln -s /opt/app/releases/v2 /opt/app/current   # symbolic (soft) link
```
- **Symlink:** a pointer to a path (like a shortcut). Breaks if the target is deleted. Used for "current release" deploy patterns.
- **Hard link:** another name for the same data on disk. Rarely used directly.

## Disk space

```bash
df -h                     # free space per file system
du -sh *                  # size of each item in the current dir
du -sh /var/* 2>/dev/null | sort -h | tail   # biggest folders in /var
```

💡 **"Disk full" incident recipe:** `df -h` → find the full mount → `du -sh /that/mount/* | sort -h` → drill down. Usual suspects: logs in `/var/log`, Docker images (`docker system df`), old backups.

## 🧠 Practice
1. Create `~/lab/a/b/c` in one command.
2. Find all `.conf` files under `/etc` (on Linux) and count them.
3. Which 5 folders in your home directory use the most space?

<details><summary>Answers</summary>

```bash
mkdir -p ~/lab/a/b/c
find /etc -name "*.conf" 2>/dev/null | wc -l
du -sh ~/* 2>/dev/null | sort -h | tail -5
```
</details>
