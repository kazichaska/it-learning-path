# 2 · Users & Permissions

## Users and groups

```bash
whoami                 # your username
id                     # your UID, GID and groups
groups                 # groups you belong to
cat /etc/passwd        # all users (name:x:UID:GID:comment:home:shell)
cat /etc/group         # all groups
```

- **root** (UID 0) can do anything. Normal users have UIDs ≥ 1000 on most distros.
- **System users** (e.g. `www-data`, `nginx`, `postgres`) run services and usually can't log in.
- `sudo` runs one command as root and logs it. Prefer `sudo command` over logging in as root.

### Managing users (Linux)
```bash
sudo useradd -m -s /bin/bash alice     # create user with home dir and bash
sudo passwd alice                      # set password
sudo usermod -aG sudo alice            # add to sudo group (Ubuntu); 'wheel' on RHEL
sudo usermod -aG docker alice          # let alice run docker without sudo
sudo userdel -r alice                  # delete user and home dir
```
⚠️ `usermod -G` **without `-a`** *replaces* all groups. Always use `-aG`.

## Permissions: read, write, execute

Every file has permissions for three classes: **u**ser (owner), **g**roup, **o**thers.

```
-rwxr-xr--
 └┬┘└┬┘└┬┘
  u  g  o
```

| Symbol | On a file | On a directory | Value |
|---|---|---|---|
| `r` | Read contents | List contents (`ls`) | 4 |
| `w` | Modify contents | Create/delete/rename files inside | 2 |
| `x` | Execute as a program | Enter it (`cd`) | 1 |

Add the values for each class: `rwx` = 4+2+1 = **7**, `r-x` = 4+0+1 = **5**, `r--` = **4**, `rw-` = **6**.

### The numbers you'll use 95% of the time

| Mode | Symbolic | Use for |
|---|---|---|
| `755` | `rwxr-xr-x` | Scripts, programs, directories |
| `644` | `rw-r--r--` | Normal files (configs, web pages) |
| `600` | `rw-------` | **Private keys**, secrets, `.env` files |
| `700` | `rwx------` | `~/.ssh` directory, private folders |
| `777` | `rwxrwxrwx` | ⚠️ Almost never. Anyone can modify. A red flag in reviews |

```bash
chmod 755 deploy.sh          # numeric
chmod +x deploy.sh           # symbolic: add execute for everyone
chmod u+x,go-w file          # owner +execute; group/others −write
chmod -R 750 /opt/app        # recursive
```

💡 SSH refuses to use a private key that others can read:
`WARNING: UNPROTECTED PRIVATE KEY FILE!` → fix with `chmod 600 ~/.ssh/id_ed25519`. (The same error happens with AWS `.pem` keys.)

## Ownership

```bash
sudo chown alice file.txt              # change owner
sudo chown alice:developers file.txt   # owner and group
sudo chown -R www-data:www-data /var/www/html
```

## Special permissions (know they exist)

| Bit | Effect | Example |
|---|---|---|
| **setuid** (`4xxx`, `s` in user x) | Program runs as its *owner* | `/usr/bin/passwd` runs as root |
| **setgid** (`2xxx`) on a dir | New files inherit the dir's group | Shared team folders |
| **sticky** (`1xxx`, `t`) on a dir | Only a file's owner can delete it | `/tmp` is `drwxrwxrwt` |

🔐 Attackers hunt for unusual setuid binaries: `find / -perm -4000 -type f 2>/dev/null`.

## umask: default permissions

`umask 022` (common default) means new files get `644` and new dirs get `755`. The umask *removes* bits from 666 (files) / 777 (dirs).

## Troubleshooting "Permission denied"

1. **Who am I?** `id`
2. **What are the file's permissions and owner?** `ls -l file`
3. **Can I enter every parent directory?** `namei -l /path/to/file` (Linux) shows permissions along the whole path
4. **Is it executable?** Scripts need `x`. Or run with `bash script.sh`
5. **Is something else blocking?** SELinux/AppArmor, read-only mount, or a container running as a different user

## 🧠 Practice
1. What does `chmod 640 secrets.conf` allow?
2. A teammate ran `chmod -R 777 /var/www`. Why is that bad, and what would you set instead?
3. Your script fails with `Permission denied` even though you own it. Why?

<details><summary>Answers</summary>

1. Owner: read+write. Group: read. Others: nothing.
2. Any user or compromised process can modify or replace the website's files. Use `755` for dirs and `644` for files, owned by the deploy user, with the web server user only needing read access.
3. It doesn't have the execute bit. Run `chmod +x script.sh`.
</details>
