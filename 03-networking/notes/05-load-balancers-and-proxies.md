# 5 · Load Balancers & Proxies

## Why load balancers?

1. **Scale:** spread traffic across many servers
2. **Availability:** stop sending traffic to dead servers (health checks), survive an AZ failure
3. **One stable entry point:** servers come and go (autoscaling, deploys); the LB address stays the same
4. **Offload work:** TLS termination, compression, routing rules, WAF

```
                    ┌──────────▶ app-1 (healthy)  ✅
clients ──▶ [ LB ] ─┼──────────▶ app-2 (healthy)  ✅
                    └──── ✕      app-3 (failing health check: removed) ❌
```

## Load-balancing algorithms

| Algorithm | How it picks a server | Good for |
|---|---|---|
| Round robin | Next in the list | Similar servers, similar requests |
| Least connections / least outstanding requests | Fewest active requests | Requests of very different lengths |
| Weighted | Proportional to weights | Canary releases (5% to the new version) |
| IP hash / sticky sessions | Same client → same server | Apps that store sessions in memory (better: store sessions in Redis) |

## Layer 4 vs Layer 7

| | Layer 4 | Layer 7 |
|---|---|---|
| Understands | IP + port (TCP/UDP) | HTTP: host, path, headers, cookies, methods |
| Routing examples | Port 5432 → DB nodes | `/api/*` → API service, `admin.example.com` → admin app |
| TLS | Usually passes it through (or terminates) | Terminates TLS, can inspect requests |
| Performance | Extremely fast, static IPs possible | Slightly more overhead, much smarter |
| AWS | **NLB** (Network Load Balancer) | **ALB** (Application Load Balancer) |
| Others | HAProxy (TCP mode), Kubernetes `Service` | nginx, HAProxy, Envoy, Traefik, Kubernetes `Ingress` |

## Health checks

The LB regularly requests something like `GET /health` on each target:
- **Healthy threshold:** N successes in a row → start sending traffic
- **Unhealthy threshold:** N failures → stop sending traffic
- Your app's `/health` should be **cheap and honest**: return 200 only if the app can actually serve requests.

⚠️ Classic outage: a health check path that returns 404 (wrong path) or needs login (401/302) → **every target marked unhealthy → 503 for everyone**.

## Reverse proxy vs forward proxy

| | Forward proxy | Reverse proxy |
|---|---|---|
| Sits in front of | **Clients** | **Servers** |
| Used for | Corporate web filtering, hiding client IPs | Load balancing, TLS, caching, routing |
| Examples | Squid, corporate proxies | nginx, HAProxy, Envoy, ALB, Cloudflare |

### Minimal nginx reverse proxy
```nginx
upstream app_servers {
    server 10.0.11.10:8080;
    server 10.0.12.10:8080;
}

server {
    listen 80;
    server_name app.example.com;

    location / {
        proxy_pass http://app_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## CDNs (Content Delivery Networks)

A CDN is a global network of reverse-proxy **caches** (edge locations).
- Serves static content (images, JS, CSS, videos) from near the user → lower latency
- Absorbs traffic spikes and DDoS attacks
- AWS **CloudFront**, Cloudflare, Fastly, Akamai
- Controlled by `Cache-Control` headers; "invalidate" the cache after a deploy if needed

## The AWS picture

```
Route 53 ─▶ CloudFront (optional) ─▶ ALB (public subnets, 2+ AZs)
                                        │  listener :443 (ACM certificate)
                                        │  rules: /api/* → TG-api, default → TG-web
                                        ▼
                               Target groups (private subnets)
                               EC2 / ECS tasks / EKS pods / Lambda
```

## 🧠 Check yourself
1. You deploy a new version and the ALB starts returning **503** immediately. The instances are running. What's the likely cause?
2. When would you choose an NLB over an ALB?
3. Users get logged out randomly. The app stores sessions in server memory, behind a round-robin LB. Why, and what are two fixes?

<details><summary>Answers</summary>

1. All targets are failing health checks (e.g. new version changed the health path or port, or the app is still starting). No healthy targets → 503.
2. Non-HTTP traffic (TCP/UDP, e.g. databases, game servers, MQTT), extreme performance needs, or when you need static IPs.
3. Each request may hit a different server that doesn't have their session. Fixes: sticky sessions (quick), or move sessions to a shared store like Redis/a database (the better design).
</details>
