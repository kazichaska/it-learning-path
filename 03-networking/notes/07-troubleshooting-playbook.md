# 7 · Network Troubleshooting Playbook

> **Method beats guessing.** Work from the bottom of the stack up, and change one thing at a time.

## The 6-step method for "X can't connect to Y"

| Step | Question | Command(s) | If it fails… |
|---|---|---|---|
| 1 | **Is the name resolving?** | `dig +short api.example.com` | DNS problem: record missing, wrong zone, private zone not attached |
| 2 | **Is the host reachable?** | `ping -c 3 <ip>` (may be blocked), `traceroute <ip>` | Routing, host down, or ICMP blocked; keep going |
| 3 | **Is the port open?** | `nc -zv <host> <port>` | **refused** → nothing listening; **timeout** → firewall/SG/NACL/route |
| 4 | **Is the service listening (on the server)?** | `sudo ss -tulpn \| grep <port>` | Service down, wrong port, or bound to `127.0.0.1` only |
| 5 | **Does the protocol work?** | `curl -v http://host:port/health` | TLS errors, wrong Host header, app errors (4xx/5xx) |
| 6 | **What do the logs say?** | `journalctl -u svc`, app logs, LB logs, VPC Flow Logs | Read the actual error message! |

## Key symptom → cause table

| Symptom | Most likely cause |
|---|---|
| `Could not resolve host` | DNS |
| `Connection refused` | Host reachable; nothing listening on that port |
| `Connection timed out` | Firewall/security group/NACL drops packets, wrong route, or host down |
| `No route to host` | Routing problem or host firewall actively rejecting |
| Works with `localhost`, not from other machines | App bound to `127.0.0.1` instead of `0.0.0.0`, or a host firewall |
| Works by IP, not by name | DNS |
| Works from server A, not B | Security group source rules, NACLs, route tables differ |
| `SSL certificate problem` | Expired cert, wrong hostname, missing intermediate cert, or clock skew |
| Intermittent failures | One unhealthy backend behind an LB, DNS round-robin to a dead IP, resource exhaustion |
| `502` from LB | Backend down/crashing or wrong target port |
| `504` from LB | Backend too slow (DB queries, timeouts) |

## The "bound to localhost" trap

```bash
$ sudo ss -tlnp | grep 8080
LISTEN 0 128  127.0.0.1:8080  0.0.0.0:*  users:(("python3",pid=812))
```
`127.0.0.1:8080` means **only local connections** are accepted. The app must listen on `0.0.0.0:8080` (all interfaces). This is *the* most common Docker beginner bug: inside a container, an app bound to `127.0.0.1` is unreachable from outside the container.

## Scenario walk-throughs

### "The website is down!"
1. `curl -sv https://site.com -o /dev/null`: what exactly fails? DNS? TLS? Status code?
2. DNS OK? → Check the load balancer: are targets healthy?
3. Targets unhealthy? → SSH/SSM into one: is the service running (`systemctl status`)? Listening (`ss -tlnp`)? Logs?
4. Service running? → Does `curl localhost:8080/health` work *on the box*? If yes → security group between LB and instance.
5. Recently deployed? → **Roll back first, investigate second.**

### "The app can't reach the database"
1. From the app server: `nc -zv db.internal 5432`
2. **Timeout** → DB security group must allow 5432 from the **app's security group**; check NACLs and route tables
3. **Refused** → DB isn't listening on that interface/port (`listen_addresses` in `postgresql.conf`), or it's down
4. **Connects but auth fails** → credentials, `pg_hba.conf`, IAM auth, SSL requirements

## Toolbox summary

| Tool | Use |
|---|---|
| `dig`, `nslookup` | DNS |
| `ping`, `traceroute` / `mtr` | Reachability and path |
| `nc -zv` (netcat) | Is a TCP port open? |
| `curl -v`, `openssl s_client` | HTTP and TLS details |
| `ss -tulpn`, `lsof -i` | What's listening locally |
| `ip a`, `ip route` | Interfaces and routes (Linux) |
| `tcpdump -i any port 443` | Capture packets (advanced) |
| VPC Flow Logs, Reachability Analyzer | AWS-side visibility |

💡 **In containers/Kubernetes:** run a throwaway debug pod with network tools: `kubectl run tmp --rm -it --image=nicolaka/netshoot -- bash`.
