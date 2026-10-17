# 1 · OSI & TCP/IP Models

> Layer models are a **map for troubleshooting**: "Is this a cable problem (L1), an IP problem (L3), a port problem (L4) or an app problem (L7)?"

## The two models side by side

| OSI layer | Name | TCP/IP layer | Unit | Examples | Devices / cloud |
|---|---|---|---|---|---|
| 7 | Application | Application | Data | HTTP, DNS, SSH, SMTP, TLS* | ALB, API gateway, WAF |
| 6 | Presentation | ↑ | | Encoding, encryption | |
| 5 | Session | ↑ | | Sessions | |
| 4 | Transport | Transport | Segment | **TCP, UDP**, ports | NLB, security groups |
| 3 | Network | Internet | Packet | **IP**, ICMP | Routers, route tables |
| 2 | Data link | Link | Frame | Ethernet, Wi-Fi, MAC addresses | Switches |
| 1 | Physical | ↑ | Bits | Cables, radio | Cables, NICs |

\*TLS sits awkwardly between L4 and L7; in practice people call it "L6" or just part of the app layer.

**Mnemonic (7→1):** *All People Seem To Need Data Processing.*

In real life, engineers mostly say **"L4"** (ports, TCP) and **"L7"** (HTTP). Learn those two well.

## Encapsulation

Each layer wraps the data from the layer above with its own header:

```
[ HTTP request                         ]  L7 data
[ TCP hdr: ports 51234→443 ][  data    ]  L4 segment
[ IP hdr: 10.0.1.5→93.184.215.14 ][ ...]  L3 packet
[ Ethernet hdr: MACs ][ ... ][ trailer ]  L2 frame
 0101100101110…                           L1 bits
```
The receiver unwraps in reverse order.

## TCP vs UDP

| | TCP | UDP |
|---|---|---|
| Connection | Yes (handshake first) | No; just send |
| Reliability | Guaranteed, ordered, retransmits lost data | Best effort; may lose or reorder |
| Speed / overhead | Slower, more overhead | Faster, lightweight |
| Uses | HTTP(S), SSH, databases, email | DNS, video calls, streaming, gaming, VPNs (WireGuard), HTTP/3 (QUIC) |
| Analogy | Phone call | Shouting announcements |

### The TCP three-way handshake

```
Client                    Server
  │ ── SYN ─────────────▶ │   "Can we talk?"
  │ ◀──────────── SYN-ACK │   "Yes, can you hear me?"
  │ ── ACK ─────────────▶ │   "Yes. Let's go."
  │ ===== data flows ===== │
```

**Why this matters for troubleshooting:**
| What you see | What happened at the TCP level |
|---|---|
| **Connection refused** (instant) | SYN reached the host, which replied **RST**: nothing is listening on that port |
| **Connection timed out** (slow) | SYN got **no reply**: a firewall dropped it, the host is down, or routing is wrong |

## Ports

| Range | Name | Examples |
|---|---|---|
| 0–1023 | Well-known (need root to listen) | 22 SSH, 53 DNS, 80 HTTP, 443 HTTPS |
| 1024–49151 | Registered | 3306 MySQL, 5432 PostgreSQL, 6379 Redis, 8080 alt-HTTP, 27017 MongoDB |
| 49152–65535 | Ephemeral (temporary client-side ports) | Your browser's side of a connection |

A connection is identified by the **5-tuple**: protocol, source IP, source port, destination IP, destination port.

## ICMP

The "control messages" protocol (Layer 3). Used by `ping` (echo request/reply) and `traceroute`. Many cloud firewalls block it by default, so **a failed ping doesn't prove a host is down.**

## 🧠 Check yourself
1. `curl` to `10.0.11.5:5432` immediately says "connection refused". Is the firewall blocking you?
2. Why does DNS mostly use UDP?
3. At which layer does an AWS Application Load Balancer operate, and what can it see that an NLB can't?

<details><summary>Answers</summary>

1. Probably not. The host replied with a reset, so packets got through. Nothing is listening on 5432 (database down or bound to a different interface/port).
2. Queries are tiny and need to be fast; a lost query is simply retried. (DNS falls back to TCP for large responses and zone transfers.)
3. Layer 7. It can see HTTP details: paths, host headers, cookies, methods, so it can route `/api` differently from `/images`.
</details>
