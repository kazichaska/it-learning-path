# 3 · DNS (Domain Name System)

> DNS turns names into IP addresses. When it breaks, *everything* looks broken, which is why "it's always DNS" is a running joke among engineers.

## How a lookup works

```
Your laptop                Recursive resolver            The DNS hierarchy
(stub resolver)            (ISP, 1.1.1.1, 8.8.8.8,
                            or AWS VPC .2 resolver)
     │ "api.example.com?"        │
     │ ────────────────────────▶ │ ── "who handles .com?" ────────▶ Root servers (.)
     │                           │ ◀─ "ask the .com servers" ─────
     │                           │ ── "who handles example.com?" ─▶ .com TLD servers
     │                           │ ◀─ "ask ns1.example.com" ──────
     │                           │ ── "api.example.com?" ─────────▶ Authoritative server
     │                           │ ◀─ "203.0.113.50, TTL 300" ────   (e.g. Route 53)
     │ ◀──── 203.0.113.50 ────── │
```

Answers are **cached** at every step (browser, OS, resolver) for the **TTL** (time to live, in seconds).

## Record types

| Type | Maps | Example |
|---|---|---|
| **A** | Name → IPv4 | `api.example.com → 203.0.113.50` |
| **AAAA** | Name → IPv6 | `api.example.com → 2001:db8::50` |
| **CNAME** | Name → another name (alias) | `www.example.com → example.com` |
| **MX** | Domain → mail servers (with priority) | `example.com → 10 mail.example.com` |
| **TXT** | Free text | SPF/DKIM email security, domain verification |
| **NS** | Domain → its authoritative name servers | `example.com → ns-123.awsdns-15.com` |
| **SOA** | Zone metadata (primary NS, serial, timers) | |
| **PTR** | IP → name (reverse DNS) | `50.113.0.203.in-addr.arpa → api.example.com` |
| **CAA** | Which CAs may issue certificates | `0 issue "letsencrypt.org"` |

⚠️ **A CNAME can't be used at the zone apex** (`example.com` itself). AWS Route 53 solves this with **Alias records**, which can point the apex at a load balancer or CloudFront.

## TTL in practice

- High TTL (e.g. 86400 = 1 day): fewer lookups, but **changes take a long time to spread**.
- Low TTL (60–300): changes take effect fast.
- **Migration tip:** lower the TTL a day *before* you change an IP; raise it again afterwards.

## Where names are resolved locally

1. `/etc/hosts`: checked first; handy for testing (`127.0.0.1 myapp.local`)
2. The resolver configured in `/etc/resolv.conf` (Linux) or System Settings (macOS)
3. In Kubernetes, CoreDNS gives every Service a name like `my-svc.my-namespace.svc.cluster.local`

## Route 53 (AWS DNS) essentials

- **Hosted zones:** public (internet) or private (inside your VPCs)
- **Routing policies:** simple, weighted (canary releases), latency-based, failover (with health checks), geolocation
- **Alias records:** free lookups to AWS resources, and they work at the zone apex

## 🛠️ Commands

```bash
dig example.com                    # full answer: records, TTL, which server replied
dig +short example.com             # just the IP(s)
dig example.com MX +short          # mail servers
dig example.com NS +short          # authoritative name servers
dig @8.8.8.8 example.com           # ask a specific resolver (compare answers!)
dig +trace example.com             # follow the whole chain from the root
dig -x 8.8.8.8 +short              # reverse lookup
nslookup example.com               # older, available everywhere (incl. Windows)
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder   # macOS: flush DNS cache
```

## Troubleshooting DNS

| Symptom | Check |
|---|---|
| Works by IP, fails by name | It's DNS. `dig name`. Does it resolve at all? |
| Works for you, not for a colleague | Caching / different resolvers. Compare `dig @1.1.1.1` vs `dig @8.8.8.8` |
| Changed a record but nothing happened | TTL hasn't expired yet. Check the TTL in `dig` output |
| `NXDOMAIN` | The name doesn't exist (typo? wrong zone? private zone not attached to VPC?) |
| `SERVFAIL` | The resolver couldn't get an answer (broken delegation, DNSSEC issues) |

## 🧠 Check yourself
1. You moved your site to a new server and updated the A record, but some users still hit the old server 2 hours later. Why?
2. Why can't you put a CNAME on `example.com`, and what does Route 53 offer instead?

<details><summary>Answers</summary>

1. Their resolvers cached the old answer and the TTL hasn't expired (the old TTL might have been several hours or a day).
2. The apex must hold SOA and NS records, and a CNAME can't coexist with other records. Route 53 offers Alias records.
</details>
