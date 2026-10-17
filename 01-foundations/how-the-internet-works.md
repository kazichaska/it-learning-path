# How the Internet Works

> **Key idea:** The internet is a **network of networks**. Data is chopped into small **packets**, each labelled with a destination **IP address**, and routers pass them hop by hop until they arrive.

## 1. The building blocks

| Piece | Role | Analogy |
|---|---|---|
| **Packet** | A small chunk of data (typically ≤1,500 bytes) with a header saying where it's from and going | A postcard |
| **IP address** | The address of a device on a network | A street address |
| **Port** | Which program on that device should receive the data | An apartment number |
| **Router** | Forwards packets between networks, choosing the next hop | A post office sorting centre |
| **Switch** | Connects devices *within* one local network | The mailroom in one building |
| **ISP** | Your Internet Service Provider; connects you to the rest of the internet | The national postal service |
| **DNS** | Translates names (`google.com`) into IP addresses | The phone book |
| **Protocol** | Agreed rules for communicating (IP, TCP, HTTP…) | A shared language |

## 2. Your home network

```
 Laptop 192.168.1.23 ─┐
 Phone  192.168.1.45 ─┼─ Wi-Fi router ── ISP ── the internet
 TV     192.168.1.60 ─┘  (public IP: 203.0.113.7)
```

- Devices at home get **private IPs** (`192.168.x.x`). They can't be reached directly from the internet.
- The router uses **NAT** (Network Address Translation) so all of them share one **public IP**.
- **DHCP** on the router hands out IP addresses automatically.

☁️ An AWS **VPC** works exactly like this: private IPs inside, an **Internet Gateway** for public access and a **NAT Gateway** so private servers can reach out without being reachable.

## 3. The journey of a web request: `https://example.com`

1. **DNS lookup:** your computer asks a DNS resolver, "What's the IP of `example.com`?" and gets back an address.
2. **TCP connection:** your computer opens a connection to that IP on **port 443** with the *three-way handshake*: `SYN → SYN-ACK → ACK`.
3. **TLS handshake:** the server proves its identity with a **certificate** and both sides agree on encryption keys. Now the connection is HTTPS.
4. **HTTP request:** the browser sends `GET / HTTP/1.1` with headers.
5. **Routing:** every packet hops through many routers (try `traceroute`).
6. **Server side:** a load balancer or web server receives the request, the app builds a response (maybe querying a database).
7. **HTTP response:** `200 OK` plus HTML comes back, in packets.
8. **Rendering:** the browser parses the HTML and makes *more* requests for CSS, JavaScript and images.

Each step is a place where things can break. That's the core of [network troubleshooting](../03-networking/notes/07-troubleshooting-playbook.md).

## 4. The layer model (simplified TCP/IP)

| Layer | Job | Protocols | Example problem |
|---|---|---|---|
| **Application** | What the data means | HTTP, DNS, SSH, SMTP | 500 Internal Server Error |
| **Transport** | Reliable delivery to the right program (ports) | TCP, UDP | Connection refused on port 5432 |
| **Internet** | Addressing and routing between networks | IP, ICMP | No route to host |
| **Link** | Delivery on the local network | Ethernet, Wi-Fi | Cable unplugged |

Full detail (including the 7-layer OSI model): [OSI & TCP/IP](../03-networking/notes/01-osi-and-tcp-ip.md).

## 5. Latency vs bandwidth

- **Bandwidth:** how much data per second (the *width* of the pipe). Measured in Mbps/Gbps.
- **Latency:** how long one trip takes (the *length* of the pipe). Measured in ms.
- A satellite link can have high bandwidth but terrible latency. Video calls care about latency; big downloads care about bandwidth.

**Why CDNs exist:** the speed of light is a hard limit. A user in Sydney talking to a server in Virginia will always wait ~200 ms per round trip. A **CDN** (CloudFront, Cloudflare) caches content in a data centre near the user.

## 🛠️ Try it

```bash
dig +short example.com             # step 1: DNS
nc -zv example.com 443             # step 2: can I open a TCP connection?
curl -sI https://example.com       # steps 3–7: TLS + HTTP; shows response headers
traceroute -m 15 example.com       # step 5: the routers in between (Ctrl+C to stop)
ping -c 4 example.com              # latency (some servers block ping)
```

## 🧠 Check yourself
1. Why can't someone on the internet connect directly to your laptop at `192.168.1.23`?
2. In the request journey, what happens *before* the TCP connection, and why?
3. Your website is fast for US users but slow in Asia. What's one fix?

<details><summary>Answers</summary>

1. It's a private IP behind NAT; it isn't routable on the public internet.
2. DNS lookup. The computer needs the IP address before it can connect.
3. Use a CDN (or deploy in an Asian region) to reduce latency.
</details>
