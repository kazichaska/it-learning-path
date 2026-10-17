# Monitoring & Observability

> **You can't fix what you can't see.** Monitoring tells you *that* something is wrong; observability helps you find out *why*.

## The three pillars

| Pillar | What it is | Answers | Tools |
|---|---|---|---|
| **Metrics** | Numbers over time (CPU %, requests/sec, error rate, latency) | "Is something wrong? Since when?" | Prometheus, CloudWatch Metrics, Datadog |
| **Logs** | Timestamped event records | "What exactly happened?" | CloudWatch Logs, Loki, ELK/OpenSearch |
| **Traces** | The path of one request through many services, with timings | "Where is the time spent / which service failed?" | OpenTelemetry, Jaeger, Tempo, AWS X-Ray |

**OpenTelemetry (OTel)** is the vendor-neutral standard for producing all three.

## What to measure

### The four golden signals (Google SRE)
1. **Latency:** how long requests take (watch p95/p99, not just averages)
2. **Traffic:** requests per second
3. **Errors:** rate of failed requests (5xx)
4. **Saturation:** how "full" the system is (CPU, memory, disk, connection pools)

### Two handy methods
- **RED** (for services): **R**ate, **E**rrors, **D**uration
- **USE** (for resources like CPUs/disks): **U**tilization, **S**aturation, **E**rrors

## SLIs, SLOs and SLAs

| Term | Meaning | Example |
|---|---|---|
| **SLI** (indicator) | A measured metric | % of requests answered successfully in < 300 ms |
| **SLO** (objective) | Your internal target for an SLI | 99.9% over 30 days |
| **SLA** (agreement) | A contractual promise with penalties | 99.5%, or customers get credits |
| **Error budget** | 100% − SLO: how much failure you can "spend" | 99.9% → ~43 minutes of downtime per 30 days |

If the error budget is used up, slow down risky releases and focus on reliability.

## Alerting that doesn't burn people out

- ✅ Alert on **symptoms users feel** (error rate, latency, site down), not every high CPU blip
- ✅ Every alert must be **actionable** and link to a **runbook**
- ✅ Different severities: page someone at 3 a.m. only for real customer impact
- ❌ Noisy alerts get ignored, and then the real one is missed ("alert fatigue")

## Structured logging

Log JSON instead of free text so tools can search and aggregate:
```json
{"time": "2026-10-14T10:00:20Z", "level": "error", "service": "orders", "path": "/api/orders", "status": 500, "duration_ms": 1203, "request_id": "a1b2c3"}
```
Include a **request/trace ID** so you can follow one request across services.

## Tools landscape

| Need | Open source | AWS | SaaS |
|---|---|---|---|
| Metrics | Prometheus | CloudWatch | Datadog, New Relic, Grafana Cloud |
| Dashboards | Grafana | CloudWatch dashboards | (included) |
| Logs | Loki, OpenSearch | CloudWatch Logs | Datadog, Splunk |
| Traces | Jaeger, Tempo | X-Ray | Honeycomb, Datadog |
| Alerting | Alertmanager | CloudWatch Alarms + SNS | PagerDuty, Opsgenie |
| Uptime checks | Blackbox exporter | Route 53 health checks, CloudWatch Synthetics | UptimeRobot, Pingdom |

## 🧪 Hands-on: Prometheus + Grafana in 5 minutes

[`compose.yaml`](compose.yaml) starts Prometheus (which scrapes its own metrics plus a **node-exporter** for host metrics) and Grafana.

```bash
cd 05-cloud-devops/monitoring
docker compose up -d
```
1. Prometheus: http://localhost:9090 → **Status → Targets** (both should be UP). Try these queries:
   - `up`
   - `rate(node_cpu_seconds_total{mode!="idle"}[1m])`
   - `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100`
2. Grafana: http://localhost:3000 (login `admin` / `admin`, then set a new password). The Prometheus data source is pre-configured. Build a panel with one of the queries above, or import dashboard ID **1860** ("Node Exporter Full").
3. Clean up: `docker compose down -v`

💡 On macOS, node-exporter sees Docker's Linux VM, not your Mac itself. That's fine for learning the tools.

## 🏋️ Exercises

1. Write down 3 SLIs and SLOs for the [example app](../docker/example-app/).
2. Calculate the monthly error budget in minutes for 99.5%, 99.9% and 99.99%.
3. Write a one-page runbook for the alert "5xx error rate > 5% for 5 minutes."
4. In AWS: create a CloudWatch alarm on an EC2 instance's CPU > 80% that emails you via SNS.

<details><summary>Answer to exercise 2 (30-day month = 43,200 minutes)</summary>

- 99.5% → 216 minutes (3.6 hours)
- 99.9% → 43.2 minutes
- 99.99% → 4.3 minutes
</details>
