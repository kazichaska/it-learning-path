# Lab 3 · Subnetting Practice

**Rule:** try each question on paper first, then check with the calculator:
```bash
python3 subnet_calculator.py 10.0.0.0/20
python3 subnet_calculator.py 10.0.0.0/16 --split 24
python3 subnet_calculator.py 10.0.0.0/22 --contains 10.0.5.20
```

**Formula:** addresses = 2^(32 − prefix). AWS usable = addresses − 5.

## Questions

1. How many addresses are in `192.168.10.0/24`? How many are usable in a traditional network? In AWS?
2. What is the range (first and last address) of `10.0.0.0/20`?
3. How many `/24` subnets fit into `10.0.0.0/16`?
4. Is `10.0.5.20` inside `10.0.0.0/22`?
5. What's the last address of the private range `172.16.0.0/12`?
6. What's the smallest subnet that can hold 50 servers in AWS?
7. What is the range of `10.0.1.128/25`, and how many addresses does it contain?
8. Would `10.0.0.0/16` and `10.0.128.0/17` overlap? Could you peer two VPCs with these CIDRs?
9. What does `0.0.0.0/0` mean in a route table? In a security group?
10. **Design task:** Plan a VPC with CIDR `10.20.0.0/16` across **3** Availability Zones, with one public and one private subnet per AZ, each with at least 200 usable IPs. Leave space for a future "database" tier.

## Answers

<details><summary>Click to reveal</summary>

1. 256 addresses. Traditional usable: 254. AWS usable: 251.
2. `10.0.0.0` – `10.0.15.255` (4,096 addresses).
3. 2^(24−16) = **256** subnets.
4. **No.** /22 = 1,024 addresses = third octet 0–3, so the range is 10.0.0.0–10.0.3.255.
5. `172.31.255.255`.
6. Need 50 + 5 reserved = 55 → `/26` (64 addresses, 59 usable). A `/27` (32) is too small.
7. `10.0.1.128` – `10.0.1.255`, 128 addresses.
8. **Yes, they overlap**: `10.0.128.0/17` is entirely inside `10.0.0.0/16`. VPC peering requires non-overlapping CIDRs, so no.
9. Route table: the **default route** (any destination not matched more specifically). Security group: **any source IP** (the whole internet).
10. One possible plan (each `/24` = 251 usable IPs in AWS):

| Tier | AZ a | AZ b | AZ c |
|---|---|---|---|
| Public | 10.20.1.0/24 | 10.20.2.0/24 | 10.20.3.0/24 |
| Private (app) | 10.20.11.0/24 | 10.20.12.0/24 | 10.20.13.0/24 |
| Database (future) | 10.20.21.0/24 | 10.20.22.0/24 | 10.20.23.0/24 |

The numbering pattern (third octet 1–3 = public, 11–13 = app, 21–23 = database) makes subnets easy to recognize, and over 200 other `/24` blocks remain free for growth.
</details>
