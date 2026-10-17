# 6 · Packages, SSH & Remote Work

## Package managers

| Distro family | Tool | Install | Update everything | Search |
|---|---|---|---|---|
| Debian/Ubuntu | `apt` | `sudo apt install nginx` | `sudo apt update && sudo apt upgrade` | `apt search nginx` |
| RHEL/Amazon Linux/Rocky | `dnf` (`yum` on old systems) | `sudo dnf install nginx` | `sudo dnf upgrade` | `dnf search nginx` |
| Alpine | `apk` | `apk add nginx` | `apk upgrade` | `apk search nginx` |
| macOS | `brew` | `brew install htop` | `brew update && brew upgrade` | `brew search htop` |

💡 `apt update` only refreshes the **list** of available packages; `apt upgrade` actually installs newer versions.
In Dockerfiles, combine them in one layer and clean up: `apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*`

## SSH: Secure Shell

SSH gives you an encrypted terminal on a remote machine (port **22**).

### Key-based login (always prefer over passwords)
```bash
ssh-keygen -t ed25519 -C "you@example.com"     # creates ~/.ssh/id_ed25519 (private) + .pub (public)
ssh-copy-id user@server                        # installs your public key on the server
ssh user@server                                # log in
ssh -i ~/.ssh/my-aws-key.pem ec2-user@54.12.3.4   # with a specific key (AWS)
```

🔑 **The golden rule:** the **public key** (`.pub`) goes on servers; the **private key** never leaves your machine, has `600` permissions and should have a passphrase.

How it works: the server stores your public key in `~/.ssh/authorized_keys`. When you connect, it sends a challenge that only your private key can sign. No password ever crosses the network.

### `~/.ssh/config`: stop typing long commands
```
Host web-prod
    HostName 54.12.3.4
    User ec2-user
    IdentityFile ~/.ssh/my-aws-key.pem

Host bastion
    HostName bastion.example.com
    User ubuntu

Host private-db
    HostName 10.0.11.25
    User ubuntu
    ProxyJump bastion          # hop through the bastion to reach a private IP
```
Now just `ssh web-prod` or `ssh private-db`.

### Useful SSH tricks
```bash
ssh web-prod 'df -h && uptime'                  # run a command remotely
ssh -L 5432:localhost:5432 web-prod              # tunnel: localhost:5432 → server's 5432
ssh -v web-prod                                  # verbose: debug connection problems
```

### Common SSH errors
| Error | Likely cause |
|---|---|
| `Connection timed out` | Firewall/security group blocks port 22, wrong IP, or the server is down |
| `Connection refused` | Server reachable, but nothing is listening on port 22 (sshd stopped) |
| `Permission denied (publickey)` | Wrong user (`ubuntu` vs `ec2-user`), wrong key, or key not in `authorized_keys` |
| `UNPROTECTED PRIVATE KEY FILE` | `chmod 600 key.pem` |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | Server was rebuilt (same IP, new host key), or a real man-in-the-middle. Verify, then `ssh-keygen -R host` |

## Copying files

```bash
scp file.txt web-prod:/tmp/                    # copy to server
scp web-prod:/var/log/app.log .                # copy from server
rsync -avz --progress ./site/ web-prod:/var/www/site/   # sync a folder (only changed files)
rsync -avz --delete ./site/ web-prod:/var/www/site/     # also delete files removed locally
```
💡 `rsync` is faster and restartable; prefer it for anything more than a few files. Note the trailing `/` on the source: it copies the folder's *contents*.

## Environment variables & your shell

```bash
env                         # list all environment variables
echo "$PATH"                # where the shell looks for commands
export APP_ENV=staging      # set for this shell and its children
```
Persist settings in `~/.zshrc` (macOS default shell) or `~/.bashrc` (most Linux). Reload with `source ~/.zshrc`.

## 🧠 Practice
1. You can `ping` a new EC2 instance but `ssh` times out. What's the most likely cause?
2. Write an `~/.ssh/config` entry so `ssh lab` connects to `203.0.113.10` as `ubuntu` using `~/.ssh/lab.pem`.

<details><summary>Answers</summary>

1. The security group doesn't allow inbound TCP port 22 from your IP. (Ping uses ICMP, a different rule.)
2. ```
   Host lab
       HostName 203.0.113.10
       User ubuntu
       IdentityFile ~/.ssh/lab.pem
   ```
</details>
