# Interview Prep: Cloud, DevOps & Infrastructure

> **How to use this:** cover the answer, say yours **out loud**, then compare. Interviewers care about *how you think* as much as the final answer. Talk through your reasoning, and it's fine to say "I'd check X, then Y."

## Linux

<details><summary>1. How do you find which process is using port 8080?</summary>

`sudo ss -tulpn | grep :8080` or `sudo lsof -i :8080`. Then `ps -fp <PID>` for details.
</details>

<details><summary>2. What does <code>chmod 640 file</code> mean?</summary>

Owner: read+write (6). Group: read (4). Others: nothing (0).
</details>

<details><summary>3. A server's disk is full. Walk me through what you do.</summary>

`df -h` to find the full file system → `du -sh /path/* | sort -h` to drill down → usual suspects: logs (`/var/log`, rotate/compress), Docker (`docker system df`), old backups, core dumps. Also check `df -i` (inodes) and deleted-but-open files (`lsof +L1`). Free space safely, then prevent recurrence: log rotation, monitoring/alerts on disk usage.
</details>

<details><summary>4. What's the difference between SIGTERM and SIGKILL?</summary>

SIGTERM (15) asks a process to shut down and can be caught for cleanup. SIGKILL (9) kills immediately and can't be caught or ignored. Always try SIGTERM first.
</details>

<details><summary>5. What is load average and how do you interpret it?</summary>

The average number of processes running or waiting (CPU or uninterruptible I/O) over 1, 5 and 15 minutes. Compare with the CPU count (`nproc`): a load of 8 on 4 cores means work is queueing.
</details>

<details><summary>6. How do you make a service start automatically at boot?</summary>

With systemd: write a unit file, `systemctl daemon-reload`, then `systemctl enable --now myservice`.
</details>

## Networking

<details><summary>7. What happens when you type a URL into the browser?</summary>

DNS resolution → TCP handshake to the IP on port 443 → TLS handshake (certificate verification, key exchange) → HTTP request → server/load balancer processes it (maybe app + database) → HTTP response → browser renders and fetches more resources. Mention caching (browser, DNS, CDN) for bonus points.
</details>

<details><summary>8. TCP vs UDP?</summary>

TCP: connection-oriented, reliable, ordered (HTTP, SSH, databases). UDP: connectionless, faster, no delivery guarantee (DNS, streaming, VoIP, QUIC/HTTP3).
</details>

<details><summary>9. "Connection refused" vs "connection timed out"?</summary>

Refused: the host replied with a reset, so nothing is listening on that port. Timed out: no reply at all, usually a firewall/security group dropping packets, a routing problem or the host being down.
</details>

<details><summary>10. How many usable IPs are in a /24 subnet in AWS?</summary>

256 total − 5 reserved by AWS = **251**.
</details>

<details><summary>11. What's the difference between a security group and a NACL?</summary>

Security group: stateful, attached to resources (ENIs), allow rules only. NACL: stateless (needs inbound and outbound rules), applies to a whole subnet, allow and deny rules evaluated in order.
</details>

<details><summary>12. What's the difference between an A record and a CNAME?</summary>

A maps a name to an IPv4 address. CNAME maps a name to another name. A CNAME can't be used at the zone apex; Route 53 uses Alias records for that.
</details>

## AWS / Cloud

<details><summary>13. Explain IAM users, groups, roles and policies.</summary>

Users: identities with long-term credentials. Groups: collections of users. Roles: identities assumed temporarily by services, apps or people, with no long-term keys. Policies: JSON documents defining allowed/denied actions on resources. Best practice: roles for workloads, SSO for humans, least privilege.
</details>

<details><summary>14. How would you design a highly available web application on AWS?</summary>

VPC across ≥2 AZs. ALB in public subnets. App tier (EC2 Auto Scaling Group or ECS/EKS) in private subnets across AZs. RDS Multi-AZ in private subnets. Security groups chained (ALB → app → DB). Static assets on S3 + CloudFront. Route 53 DNS. CloudWatch monitoring and alarms. Infrastructure in Terraform. Optional: ElastiCache, WAF, backups and a DR plan.
</details>

<details><summary>15. An EC2 instance in a private subnet can't download updates. Why?</summary>

Private subnets have no route to an Internet Gateway. It needs a NAT Gateway in a public subnet plus a `0.0.0.0/0 → NAT` route in the private route table (or VPC endpoints for AWS services). Also check security group egress and NACLs.
</details>

<details><summary>16. How do you keep AWS costs under control?</summary>

Budgets and alerts, tagging for cost allocation, right-sizing, auto scaling, Savings Plans/Reserved Instances for steady load, Spot for interruptible work, S3 lifecycle policies, deleting idle resources (NAT Gateways, unattached EBS volumes, old snapshots, idle load balancers), Cost Explorer reviews.
</details>

## Docker & Kubernetes

<details><summary>17. Container vs virtual machine?</summary>

A VM virtualizes hardware and runs a full guest OS (heavier, stronger isolation). A container is an isolated process sharing the host kernel (lightweight, starts in seconds). They're often combined: containers run on VMs.
</details>

<details><summary>18. How do you make a Docker image smaller and more secure?</summary>

Slim/alpine/distroless base images, multi-stage builds, `.dockerignore`, combine and clean up package installs, no build tools in the final image, run as non-root, pin versions, scan with Trivy, never bake in secrets.
</details>

<details><summary>19. A pod is in CrashLoopBackOff. How do you debug it?</summary>

`kubectl describe pod` (events, exit code, last state, e.g. OOMKilled) → `kubectl logs <pod> --previous` → check config (env vars, ConfigMaps/Secrets), probes (a liveness probe that fails too early), resource limits, the command/entrypoint, and dependencies (DB reachable?).
</details>

<details><summary>20. Deployment vs StatefulSet vs DaemonSet?</summary>

Deployment: interchangeable stateless pods. StatefulSet: stable names and per-pod storage (databases). DaemonSet: one pod per node (log/metrics agents).
</details>

<details><summary>21. What's the difference between liveness and readiness probes?</summary>

Readiness: "can this pod receive traffic?" If it fails, the pod is removed from Service endpoints. Liveness: "is this container stuck?" If it fails, the container is restarted.
</details>

## CI/CD, IaC & Git

<details><summary>22. Continuous delivery vs continuous deployment?</summary>

Both automate build/test/release. Delivery stops before production and needs manual approval; deployment goes to production automatically when all checks pass.
</details>

<details><summary>23. What is Terraform state and why does it matter?</summary>

State maps your configuration to real resources and tracks metadata. It's needed to plan changes. Store it remotely with locking (e.g. S3), encrypt it and restrict access (it can contain secrets), and never edit it by hand.
</details>

<details><summary>24. What would you check in a <code>terraform plan</code> before applying?</summary>

Resources being **destroyed or replaced** (`-/+`), especially databases and stateful resources; unexpected changes (drift); security-sensitive changes (open security groups, IAM); the count of add/change/destroy matches expectations.
</details>

<details><summary>25. How do you undo a commit that's already been pushed to main?</summary>

`git revert <sha>` creates a new commit that reverses it without rewriting shared history. Avoid `reset` + force-push on shared branches.
</details>

<details><summary>26. Blue/green vs canary deployment?</summary>

Blue/green: run the new version alongside the old one and switch all traffic at once (fast rollback by switching back). Canary: send a small percentage of traffic to the new version and increase gradually while watching metrics.
</details>

## Security & databases

<details><summary>27. How do you handle secrets in a pipeline?</summary>

Never in code or images. Use the CI's secret store or, better, OIDC to assume a cloud role (no static keys). App secrets live in Secrets Manager/Vault/SSM and are injected at runtime. Enable secret scanning and push protection; rotate secrets regularly and immediately if leaked.
</details>

<details><summary>28. What is SQL injection and how do you prevent it?</summary>

Attacker input is interpreted as SQL. Prevent it with parameterized queries/prepared statements, ORMs used correctly, input validation, least-privilege DB users and a WAF as an extra layer.
</details>

<details><summary>29. What are RTO and RPO?</summary>

RTO: the maximum acceptable time to restore service. RPO: the maximum acceptable data loss, measured in time (e.g. "we can lose at most 5 minutes of data").
</details>

## 🔥 Scenario questions (practise these out loud)

<details><summary>30. "Users report the website is slow." What do you do?</summary>

Clarify: everyone or some users? All pages or some? Since when? → Check dashboards: latency, error rate, traffic, saturation (golden signals) → What changed recently (deploys, config, traffic spike)? → Narrow down the layer: CDN/LB → app servers (CPU, memory, GC, thread pools) → database (slow queries, locks, connections) → external dependencies → Mitigate (roll back, scale out, enable caching) → Root cause and follow-up actions.
</details>

<details><summary>31. "We got a 502 from the load balancer after a deploy." Walk through it.</summary>

502 = the LB got no valid response from targets. Check target health in the target group → are the new instances/pods running? Listening on the right port and on `0.0.0.0`? Did the health check path change? App logs for startup crashes → if customers are affected, **roll back first**, then investigate.
</details>

<details><summary>32. "Someone pushed AWS keys to a public GitHub repo." What do you do?</summary>

Deactivate/delete the key immediately → check CloudTrail for activity → look for unknown resources in all regions and new IAM entities → rotate related secrets → clean Git history and enable secret scanning/push protection → move to roles/OIDC so long-lived keys aren't needed → blameless post-mortem.
</details>

## Behavioural questions: use the STAR method

**S**ituation → **T**ask → **A**ction (what *you* did) → **R**esult (with numbers if possible).

Prepare 5–6 stories you can adapt:
1. A time you troubleshot a difficult technical problem
2. A time you automated something tedious
3. A mistake you made and what you learned (show ownership and the fix)
4. A disagreement with a teammate and how you resolved it
5. Learning a new technology quickly
6. Working under pressure / during an outage

**Example (automation):** *"In my home lab I was backing up my projects by hand and kept forgetting (S). I wanted reliable, automatic backups (T). I wrote a Bash script with validation, timestamped archives, verification and rotation, scheduled it with cron and added it to a CI pipeline with ShellCheck (A). Backups now run nightly without me thinking about it, and I've practised a full restore (R)."*

## Questions to ask *them*

- What does a typical week look like for this role?
- How do you handle on-call and incidents? Do you do post-mortems?
- How are infrastructure changes made and reviewed? (IaC? PRs?)
- What would success look like in the first 90 days?
- What's the biggest technical challenge the team is facing right now?
