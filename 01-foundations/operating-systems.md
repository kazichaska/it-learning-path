# Operating Systems

> **Key idea:** The operating system (OS) is the **manager** between your programs and the hardware. Programs never touch the hardware directly; they ask the OS.

## 1. Kernel vs user space

```
┌───────────────────────────────────────────┐
│  User space: your apps, shells, nginx,    │
│  python, docker CLI…                      │
├──────────────── system calls ─────────────┤  ← open(), read(), write(), fork(), connect()…
│  Kernel: process scheduler, memory        │
│  manager, file systems, network stack,    │
│  device drivers                           │
├───────────────────────────────────────────┤
│  Hardware: CPU, RAM, disk, NIC            │
└───────────────────────────────────────────┘
```

- The **kernel** has full control of the hardware. Linux, XNU (macOS) and the Windows NT kernel are examples.
- **User space** programs are restricted. To read a file or open a network connection, they make a **system call** and the kernel does it for them.
- This separation keeps one buggy program from crashing the whole machine.

💡 **Containers** are just processes in user space that the kernel isolates (using *namespaces*) and limits (using *cgroups*). That's why all containers on a host share **one kernel**.

## 2. Processes and threads

| Term | Meaning |
|---|---|
| **Program** | An executable file on disk (e.g. `/usr/bin/python3`) |
| **Process** | A running instance of a program, with its own memory and a **PID** (process ID) |
| **Thread** | A unit of execution *inside* a process; threads share the process's memory |
| **Parent/child** | Processes are created by other processes (`fork`). PID 1 (`systemd`/`init`) is the ancestor of all |
| **Daemon / service** | A background process with no terminal (e.g. `sshd`, `nginx`) |

The **scheduler** rapidly switches the CPU between processes (thousands of times per second), so everything appears to run at once.

## 3. Memory management

- Every process gets its own **virtual memory** address space and thinks it has the machine to itself.
- The kernel maps virtual addresses to physical RAM in chunks called **pages** (usually 4 KiB on x86_64; 16 KiB on Apple Silicon).
- When RAM runs out, the kernel can move rarely used pages to disk (**swap**). This keeps things running but **very slowly** (remember the memory hierarchy).
- If memory is truly exhausted, Linux's **OOM killer** (Out-Of-Memory) kills a process to save the system. In Kubernetes you'll see this as `OOMKilled`.

## 4. File systems

A file system organizes bytes on a disk into files and folders.

| File system | Where you'll see it |
|---|---|
| ext4, XFS | Most Linux servers (Amazon Linux uses XFS by default) |
| APFS | macOS |
| NTFS | Windows |
| overlayfs | Docker image layers |
| NFS / EFS | Network file shares |

**In Linux, "everything is a file":** disks (`/dev/nvme0n1`), processes (`/proc/1234/`), even kernel settings (`/proc/sys/...`). See [Linux file system notes](../02-linux/notes/01-filesystem-and-navigation.md).

## 5. The boot process (Linux)

1. **Firmware** (BIOS or UEFI) tests the hardware and finds a boot device
2. **Bootloader** (GRUB) loads the kernel into memory
3. **Kernel** starts, detects hardware, mounts the root file system
4. **Init system** (PID 1, usually `systemd`) starts
5. **systemd** starts services (network, SSH, your apps) in dependency order
6. **Login** prompt / SSH becomes available

💡 When an EC2 instance "won't boot," the problem is somewhere in this chain. AWS's **EC2 serial console** and **system log** let you see where it stopped.

## 6. Users and permissions (preview)

- Every process runs as a **user**. The all-powerful user is **root** (UID 0).
- Files have an **owner**, a **group** and **permissions** (read/write/execute).
- Best practice: **never run apps as root**. If the app is hacked, the attacker gets only that user's power.

Deep dive: [Users & permissions](../02-linux/notes/02-users-and-permissions.md).

## 7. Common server operating systems

| OS | Family | Package manager | Notes |
|---|---|---|---|
| Ubuntu Server | Debian | `apt` | Most popular in the cloud, beginner-friendly |
| Debian | Debian | `apt` | Very stable; base of many Docker images |
| Amazon Linux 2023 | Fedora/RHEL-like | `dnf` | AWS-optimized, default on EC2 |
| RHEL / Rocky / AlmaLinux | Red Hat | `dnf` | Enterprises, banks, government |
| Alpine | Independent | `apk` | Tiny (~5 MB); popular for containers |
| Windows Server | Windows | — | Active Directory, .NET, SQL Server shops |

## 🛠️ Try it

```bash
ps -ef | head -5           # PID 1 at the top (launchd on macOS, systemd on Linux)
echo $$                    # PID of your current shell
ps -o pid,ppid,command -p $$   # your shell and its parent PID
cat /etc/os-release        # (Linux) which distribution am I on?
sw_vers                    # (macOS) macOS version
```

## 🧠 Check yourself
1. What's the difference between a program and a process?
2. Why do containers start faster than virtual machines?
3. A container keeps getting restarted with reason `OOMKilled`. What happened?

<details><summary>Answers</summary>

1. A program is a file on disk; a process is a running instance of it, with its own PID and memory.
2. Containers don't boot an OS. They're just isolated processes sharing the host's already-running kernel.
3. It used more memory than its limit, so the kernel's OOM killer terminated it.
</details>
