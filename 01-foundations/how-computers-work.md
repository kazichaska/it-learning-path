# How Computers Work

> **Key idea:** A computer is a machine that **stores data** and **follows instructions** very, very fast. Everything else is detail.

## 1. The main components

| Component | What it does | Analogy | Cloud equivalent |
|---|---|---|---|
| **CPU** (processor) | Executes instructions | The chef | vCPUs on an EC2 instance |
| **RAM** (memory) | Fast, temporary working space; wiped on power-off | The kitchen counter | Instance memory (GiB) |
| **Storage** (SSD/HDD) | Slow(er), permanent storage | The pantry | EBS volumes, S3 |
| **Motherboard** | Connects everything | The kitchen layout | (hidden from you) |
| **NIC** (network card) | Sends and receives network data | The delivery door | ENI (Elastic Network Interface), network bandwidth |
| **GPU** | Massively parallel maths (graphics, AI) | 1,000 junior chefs doing one simple task | GPU instances (p/g families) |

**The flow:** a program lives on **storage** → it's loaded into **RAM** → the **CPU** executes it, reading and writing data in RAM → results get saved back to storage or sent over the **network**.

## 2. The CPU

- **Cores:** independent processing units. 8 cores ≈ 8 things truly at the same time.
- **Clock speed (GHz):** how many cycles per second (3 GHz = 3 billion cycles/second).
- **Cache (L1/L2/L3):** tiny, ultra-fast memory inside the CPU, holding recently used data.
- **Threads / hyper-threading:** one physical core pretending to be two. In AWS, **1 vCPU is usually 1 hyper-thread**, i.e. half a physical core on Intel/AMD instances.

### The fetch → decode → execute cycle
1. **Fetch** the next instruction from memory
2. **Decode** it (what operation? which data?)
3. **Execute** it (add, compare, move data, jump…)
4. Repeat billions of times per second

## 3. Binary and units

Computers store everything as **bits** (0 or 1). 8 bits = 1 **byte** (enough for one character like `A`).

| Unit | Decimal (SI, used by disk makers) | Binary (IEC, used by OSes and cloud) |
|---|---|---|
| Kilo | 1 KB = 1,000 bytes | 1 KiB = 1,024 bytes |
| Mega | 1 MB = 1,000² | 1 MiB = 1,024² |
| Giga | 1 GB = 1,000³ | 1 GiB = 1,024³ |

💡 That's why a "1 TB" disk shows up as ~931 GiB. Also: **network speeds are in bits** (Mbps), **file sizes are in bytes** (MB). 100 Mbps ≈ 12.5 MB/s.

## 4. The memory hierarchy (memorize the shape, not exact numbers)

| Where data lives | Approx. access time | Relative "human" scale (if L1 = 1 second) |
|---|---|---|
| CPU L1 cache | ~1 ns | 1 second |
| RAM | ~100 ns | ~2 minutes |
| NVMe SSD read | ~20–100 µs | ~6–28 hours |
| Network round trip, same data centre | ~0.5 ms | ~6 days |
| HDD seek | ~5–10 ms | ~2–4 months |
| Network round trip, across continents | ~150 ms | ~5 years |

**Why a DevOps engineer cares:** this table explains caching (Redis, CDNs), why databases want lots of RAM, why "put the app server in the same region as the database" matters, and why disk-heavy workloads need fast EBS volumes.

## 5. CPU architectures: `x86_64` vs `arm64`

| | x86_64 (amd64) | arm64 (aarch64) |
|---|---|---|
| Made by | Intel, AMD | Apple Silicon, AWS Graviton, Ampere |
| Strength | Huge compatibility | Power efficiency, often cheaper in the cloud |
| You'll see it in | Most traditional servers | Your M-series Mac, Graviton EC2 (`t4g`, `m7g`…) |

⚠️ A program compiled for one architecture **won't run** on the other. With Docker you'll see `exec format error` if you get this wrong. Fix: `docker build --platform linux/amd64 …` (see [Docker notes](../05-cloud-devops/docker/)).

## 6. Virtualization: the foundation of the cloud

A **hypervisor** lets one physical server run many isolated **virtual machines (VMs)**, each with its own OS.

| Type | Runs on | Examples |
|---|---|---|
| Type 1 (bare metal) | Directly on hardware | AWS Nitro, VMware ESXi, Hyper-V, KVM |
| Type 2 (hosted) | On top of a normal OS | VirtualBox, UTM, Parallels |

```
 Virtual machines                      Containers
┌──────┐┌──────┐┌──────┐              ┌──────┐┌──────┐┌──────┐
│ App  ││ App  ││ App  │              │ App  ││ App  ││ App  │
│ Libs ││ Libs ││ Libs │              │ Libs ││ Libs ││ Libs │
│Guest ││Guest ││Guest │              └──────┘└──────┘└──────┘
│  OS  ││  OS  ││  OS  │              ┌──────────────────────┐
└──────┘└──────┘└──────┘              │   Container runtime  │
┌──────────────────────┐              ├──────────────────────┤
│      Hypervisor      │              │ Host OS (one kernel) │
├──────────────────────┤              ├──────────────────────┤
│       Hardware       │              │       Hardware       │
└──────────────────────┘              └──────────────────────┘
```

**VMs** virtualize hardware: strong isolation, heavier (GBs, boot in minutes).
**Containers** share the host kernel: lightweight (MBs, start in seconds). More in [Docker](../05-cloud-devops/docker/).

## 🛠️ Try it

```bash
# macOS
sysctl -n machdep.cpu.brand_string      # CPU model
sysctl -n hw.ncpu                       # number of cores
echo "$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 )) GiB RAM"
uname -m                                # architecture (arm64 on Apple Silicon)
df -h /                                 # disk size and usage

# Linux
lscpu          # CPU details
free -h        # RAM
lsblk          # disks and partitions
uname -m       # architecture
```

## 🧠 Check yourself
1. A server has plenty of free CPU but is very slow and its disk light is always busy. What's the likely bottleneck?
2. Why does a 1 Gbps network connection download a 1 GB file in ~8 seconds, not 1?
3. What error might you see if you run an `arm64` Docker image on an `x86_64` server?

<details><summary>Answers</summary>

1. Disk I/O (and possibly not enough RAM, causing swapping to disk).
2. 1 Gbps is gigabits; 1 GB is gigabytes. 8 bits per byte → 8 Gb to transfer ≈ 8 seconds (plus overhead).
3. `exec format error`.
</details>
