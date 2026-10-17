# 2 · IP Addressing & Subnets

## IPv4 basics

An IPv4 address is **32 bits**, written as 4 numbers (octets) from 0–255:

```
192.168.1.10  =  11000000.10101000.00000001.00001010
```
About 4.3 billion addresses in total, which ran out long ago. Hence private ranges, NAT and IPv6.

## Special ranges

| Range | Purpose |
|---|---|
| `10.0.0.0/8` | Private (most cloud VPCs) |
| `172.16.0.0/12` (172.16.0.0–172.31.255.255) | Private (Docker's default bridge uses 172.17.0.0/16) |
| `192.168.0.0/16` | Private (home networks) |
| `127.0.0.0/8` | Loopback (`localhost` = 127.0.0.1) |
| `169.254.0.0/16` | Link-local. In AWS, `169.254.169.254` is the **instance metadata service** |
| `100.64.0.0/10` | Carrier-grade NAT (ISPs) |
| `0.0.0.0` | "Any address" (listen on all interfaces) / default route |

## CIDR notation

`10.0.0.0/16` means: **the first 16 bits are the network part, the remaining 16 bits identify hosts.**

**Number of addresses = 2^(32 − prefix)**

| CIDR | Subnet mask | Addresses | Typical use |
|---|---|---|---|
| `/32` | 255.255.255.255 | 1 | A single host ("only my IP") |
| `/30` | 255.255.255.252 | 4 | Point-to-point links |
| `/28` | 255.255.255.240 | 16 | Smallest AWS subnet |
| `/26` | 255.255.255.192 | 64 | Small subnet |
| `/24` | 255.255.255.0 | 256 | The "standard" subnet |
| `/20` | 255.255.240.0 | 4,096 | Large subnet (AWS default VPC subnets) |
| `/16` | 255.255.0.0 | 65,536 | A VPC (the AWS maximum) |
| `/8` | 255.0.0.0 | 16,777,216 | Huge private network |
| `/0` | 0.0.0.0 | everything | "The whole internet" |

💡 **Each step of 1 in the prefix halves or doubles the size.** /24 = 256, /25 = 128, /23 = 512.

### Reserved addresses
- **Traditional networks:** first address = network ID, last = broadcast → usable = total − 2.
- **AWS subnets reserve 5:** network (.0), VPC router (.1), DNS (.2), future use (.3) and the last address → usable = total − 5. A `/24` gives **251** usable IPs in AWS.

## Working out a range by hand

**Example: `10.0.1.128/25`**
1. /25 → 2^7 = 128 addresses
2. Blocks of 128 in the last octet start at 0 and 128 → this one starts at `.128`
3. Range: `10.0.1.128` → `10.0.1.255`

**Example: is `10.0.5.20` inside `10.0.0.0/22`?**
1. /22 → 2^10 = 1,024 addresses = 4 × 256 → covers third octets 0, 1, 2, 3
2. Range: `10.0.0.0` → `10.0.3.255`
3. `10.0.5.20` is **not** inside.

Check your answers with [`subnet_calculator.py`](../labs/subnet_calculator.py) or `python3 -c "import ipaddress; print(list(ipaddress.ip_network('10.0.0.0/22')))"`.

## Subnetting: splitting a network

A `/16` VPC split into `/24` subnets gives 2^(24−16) = **256 subnets** of 256 addresses each.

**Typical AWS VPC plan (2 Availability Zones):**
| Subnet | CIDR | AZ | Route to internet |
|---|---|---|---|
| public-a | 10.0.1.0/24 | us-east-1a | Internet Gateway |
| public-b | 10.0.2.0/24 | us-east-1b | Internet Gateway |
| private-a | 10.0.11.0/24 | us-east-1a | NAT Gateway (outbound only) |
| private-b | 10.0.12.0/24 | us-east-1b | NAT Gateway (outbound only) |

**Design tips:**
- Leave room to grow; you can't easily resize a VPC.
- **Don't overlap** CIDRs between VPCs/on-premises networks you may ever connect (peering, VPN, Transit Gateway).
- A subnet lives in exactly **one** Availability Zone. Use at least two AZs for high availability.

## Public vs private subnets (AWS)

A subnet is "public" only because its **route table** sends `0.0.0.0/0` to an **Internet Gateway**. There's no checkbox.

## NAT (Network Address Translation)

Rewrites private source IPs to a public IP on the way out (and back on return).
- Home router: all your devices share one public IP.
- AWS **NAT Gateway**: private instances can download updates, but nobody on the internet can start a connection to them. ⚠️ NAT Gateways cost money per hour plus per GB, which is a classic surprise bill.

## IPv6 in one minute

- 128-bit addresses like `2001:db8::1`; effectively unlimited.
- No NAT needed; every device can have a public address, so **firewalls matter even more**.
- AWS supports dual-stack VPCs. AWS now charges for public IPv4 addresses, which pushes adoption.

## 🛠️ Try it
```bash
ipconfig getifaddr en0              # macOS: your private IP
ip -4 addr show                     # Linux: your IPs
netstat -rn | head -15              # routing table (macOS) — look for "default"
ip route                            # routing table (Linux)
python3 ../labs/subnet_calculator.py 10.0.0.0/20
```

➡️ Practise: [Lab 3: Subnetting](../labs/lab-03-subnetting-practice.md)
