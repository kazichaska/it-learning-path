# 03 · Networking

> **Goal:** Understand how data moves between machines well enough to design cloud networks (VPCs, subnets, security groups) and to troubleshoot "it can't connect" problems quickly and systematically.

Most cloud outages and "it doesn't work" tickets are networking problems: wrong port, blocked firewall, bad DNS, unhealthy load balancer target.

## 📚 Lessons

| # | Lesson | Key ideas |
|---|---|---|
| 1 | [OSI & TCP/IP models](notes/01-osi-and-tcp-ip.md) | Layers, encapsulation, TCP vs UDP, the 3-way handshake |
| 2 | [IP addressing & subnets](notes/02-ip-addressing-and-subnets.md) | Public/private IPs, CIDR, subnet maths, NAT |
| 3 | [DNS](notes/03-dns.md) | Resolution flow, record types, TTL, Route 53 |
| 4 | [HTTP & TLS](notes/04-http-and-tls.md) | Methods, status codes, headers, HTTPS, certificates |
| 5 | [Load balancers & proxies](notes/05-load-balancers-and-proxies.md) | L4 vs L7, health checks, reverse proxies, CDNs |
| 6 | [Firewalls & cloud network security](notes/06-firewalls-and-security-groups.md) | Stateful vs stateless, security groups, NACLs, `ufw` |
| 7 | [Troubleshooting playbook](notes/07-troubleshooting-playbook.md) | Step-by-step method for "can't connect" problems |

## 🧪 Labs

| Lab | What you'll do |
|---|---|
| [Lab 1: Explore your network](labs/lab-01-explore-your-network.md) | Find your IPs, gateway, DNS servers, open ports |
| [Lab 2: DNS & HTTP deep dive](labs/lab-02-dns-and-http.md) | Trace a DNS lookup, dissect HTTP and TLS with `curl` |
| [Lab 3: Subnetting practice](labs/lab-03-subnetting-practice.md) | CIDR exercises plus a VPC design task (answers included) |
| [`subnet_calculator.py`](labs/subnet_calculator.py) | A Python tool to check your subnet maths |

## 🗺️ The one diagram to remember

```
             Internet
                │
        ┌───────▼────────┐   DNS (Route 53): app.example.com → load balancer
        │ Internet GW    │
┌───────┴────────────────┴────────────── VPC 10.0.0.0/16 ──────────┐
│  Public subnets  10.0.1.0/24, 10.0.2.0/24                        │
│     [ Load balancer :443 ]   [ NAT gateway ]   [ Bastion :22 ]   │
│              │ (security group allows 443 from 0.0.0.0/0)        │
│  Private subnets 10.0.11.0/24, 10.0.12.0/24                      │
│     [ App servers :8080 ]  ← only from the load balancer's SG    │
│              │                                                   │
│     [ Database :5432 ]     ← only from the app servers' SG       │
└──────────────────────────────────────────────────────────────────┘
```
This exact network is built in code in [Terraform › aws-vpc](../05-cloud-devops/terraform/aws-vpc/).

## ✅ Self-check

- [ ] Explain the difference between TCP and UDP and give two uses of each
- [ ] Calculate the number of addresses in any CIDR block (e.g. `/20`)
- [ ] Explain what happens step by step when you open `https://example.com`
- [ ] Tell the difference between "connection refused" and "connection timed out"
- [ ] Explain why databases go in private subnets
- [ ] Debug a 502 error behind a load balancer

➡️ **Next:** [04 · Programming](../04-programming/)
