# Linux Server Hardening Checklist

> Apply this to every new server (or, better, bake it into your image/automation with Ansible, cloud-init or Packer). Commands are for Ubuntu; RHEL equivalents use `dnf` and `firewalld`.

## 1. Keep it updated
- [ ] Install updates now: `sudo apt update && sudo apt upgrade -y`
- [ ] Enable automatic security updates:
  ```bash
  sudo apt install -y unattended-upgrades
  sudo dpkg-reconfigure --priority=low unattended-upgrades
  ```
- [ ] Reboot when the kernel is updated (`/var/run/reboot-required` exists)

## 2. Users and access
- [ ] Create a personal admin user; don't work as `root`
  ```bash
  sudo adduser alice && sudo usermod -aG sudo alice
  ```
- [ ] Remove or lock unused accounts: `sudo passwd -l olduser`
- [ ] Check who has sudo: `getent group sudo`
- [ ] Check for accounts with UID 0 other than root: `awk -F: '$3 == 0' /etc/passwd`

## 3. SSH hardening
Edit `/etc/ssh/sshd_config` (or add a file in `/etc/ssh/sshd_config.d/`):
```
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
AllowUsers alice deploy
X11Forwarding no
```
```bash
sudo sshd -t                     # test the config BEFORE restarting!
sudo systemctl restart ssh       # 'sshd' on RHEL-family systems
```
⚠️ Keep your current session open and test login in a **second** terminal before closing it.

- [ ] Keys only, no passwords
- [ ] In the cloud: restrict port 22 in the security group to your IP, or remove SSH entirely and use **AWS SSM Session Manager**

## 4. Firewall
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```
- [ ] Only the ports you need are open: verify with `sudo ss -tulpn`

## 5. Brute-force protection
```bash
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd
```

## 6. Minimize the attack surface
- [ ] Remove unneeded packages and services: `systemctl list-unit-files --state=enabled`
- [ ] Services bind to `127.0.0.1` unless they must be reachable from outside
- [ ] Apps run as **dedicated non-root users**

## 7. File permissions
- [ ] Secrets and keys are `600`, owned by the service user
- [ ] No world-writable files in sensitive places: `sudo find / -xdev -type f -perm -0002 2>/dev/null`
- [ ] Review setuid binaries: `sudo find / -xdev -perm -4000 -type f 2>/dev/null`

## 8. Logging and monitoring
- [ ] `journald` logs persist (`/var/log/journal` exists)
- [ ] Logs are shipped off the box (CloudWatch agent, Fluent Bit…) so attackers can't erase them
- [ ] Audit important actions: `sudo apt install auditd`
- [ ] Time is synced (`timedatectl`): accurate timestamps matter for investigations and TLS

## 9. Kernel and network settings (sysctl)
`/etc/sysctl.d/99-hardening.conf`:
```
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
kernel.kptr_restrict = 2
```
Apply with `sudo sysctl --system`.

## 10. Backups and recovery
- [ ] Automated backups (see [`backup.sh`](../../02-linux/scripts/backup.sh)) stored **off the server** (e.g. S3 with versioning/Object Lock)
- [ ] **Test restores regularly.** An untested backup is not a backup.

## 11. Audit the result
```bash
sudo apt install -y lynis
sudo lynis audit system          # gives a hardening score and suggestions
```

## Going further
- **CIS Benchmarks:** industry-standard hardening guides for each OS (https://www.cisecurity.org/cis-benchmarks)
- Mandatory access control: **AppArmor** (Ubuntu) / **SELinux** (RHEL). Keep them enabled
- **Immutable infrastructure:** instead of patching servers by hand, rebuild images and replace servers
