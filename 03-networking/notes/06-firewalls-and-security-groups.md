# 6 · Firewalls & Cloud Network Security

## What a firewall does

A firewall allows or blocks traffic based on rules like:
**"Allow TCP port 443 from anywhere"** or **"Allow TCP port 5432 only from the app servers."**

## Stateful vs stateless

| | Stateful | Stateless |
|---|---|---|
| Remembers connections? | Yes: return traffic for an allowed connection is automatically allowed | No: every packet is checked on its own |
| You must write rules for | Inbound (or outbound) only | **Both directions**, including ephemeral return ports (1024–65535) |
| Examples | AWS **Security Groups**, `ufw`, `firewalld`, most host firewalls | AWS **Network ACLs** |

## AWS Security Groups vs Network ACLs

| | Security Group | Network ACL |
|---|---|---|
| Attached to | Network interfaces (instances, LBs, RDS…) | Subnets |
| State | Stateful | Stateless |
| Rules | **Allow only** | Allow **and** deny |
| Evaluation | All rules together | In number order; first match wins |
| Default | Inbound: deny all · Outbound: allow all | Default NACL allows everything |
| Typical use | Your main tool, 95% of the time | Extra subnet-wide guard, blocking specific IP ranges |

### The killer feature: referencing other security groups

Instead of IP addresses, a rule can say "allow traffic **from anything in security group X**":

| Security group | Inbound rule | Source |
|---|---|---|
| `sg-alb` | TCP 443 | `0.0.0.0/0` (the internet) |
| `sg-app` | TCP 8080 | `sg-alb` (only the load balancer) |
| `sg-db` | TCP 5432 | `sg-app` (only the app servers) |

This scales automatically as instances are added or replaced, and nothing except the LB is exposed to the internet.

## Principle of least privilege (networking edition)

- ❌ `0.0.0.0/0` on port **22** (SSH) or **3389** (RDP): bots scan the whole internet constantly
- ✅ SSH only from your IP (`x.x.x.x/32`), a bastion's SG, or better: **no SSH at all**, using **AWS Systems Manager Session Manager**
- ❌ Databases with public IPs
- ✅ Databases in private subnets, reachable only from the app's security group

## Host firewalls on Linux

### ufw (Ubuntu, simple)
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp                       # do this BEFORE enabling, or you'll lock yourself out
sudo ufw allow from 10.0.0.0/16 to any port 5432 proto tcp
sudo ufw enable
sudo ufw status numbered
```

### firewalld (RHEL family)
```bash
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

Under the hood both use the kernel's **netfilter** (`iptables`/`nftables`). Docker and Kubernetes also write netfilter rules, which can surprise you.

## Other layers of network defence

| Tool | Layer | Protects against |
|---|---|---|
| **WAF** (AWS WAF, Cloudflare) | L7 | SQL injection, XSS, bad bots, rate limiting |
| **DDoS protection** (AWS Shield) | L3/L4/L7 | Floods of traffic |
| **VPN** (WireGuard, OpenVPN, AWS Client VPN) | L3 | Secure access to private networks |
| **Private endpoints** (VPC endpoints / PrivateLink) | L3 | Reaching AWS services (S3, DynamoDB…) without going over the internet |

## Debugging "is the firewall blocking me?"

1. **Timeout** (not "refused") → strongly suggests a firewall drop or routing problem
2. Check **every layer** in the path: local firewall → security group (inbound on target) → NACLs (both directions!) → route tables → target's host firewall
3. **AWS tools:** VPC Reachability Analyzer, VPC Flow Logs (look for `REJECT`)
4. Test from inside the network to rule out the outer layers: `nc -zv 10.0.11.5 5432`

## 🧠 Check yourself
1. Your security group allows inbound 443, and return traffic works without an outbound rule for ephemeral ports. Why?
2. You added a NACL rule allowing inbound 443, but connections still hang. What did you probably forget?
3. Rewrite this rule safely: *"Inbound TCP 22 from 0.0.0.0/0."*

<details><summary>Answers</summary>

1. Security groups are stateful; replies to allowed connections are automatically permitted.
2. NACLs are stateless; you also need an **outbound** rule allowing the return traffic to ephemeral ports 1024–65535.
3. Allow TCP 22 only from your own IP (`203.0.113.7/32`) or from a bastion's security group. Better still: remove SSH and use SSM Session Manager.
</details>
