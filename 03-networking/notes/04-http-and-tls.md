# 4 · HTTP & TLS

## Anatomy of an HTTP exchange

**Request**
```http
POST /api/users HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOi...
User-Agent: curl/8.7.1

{"name": "Alice"}
```
**Response**
```http
HTTP/1.1 201 Created
Content-Type: application/json
Cache-Control: no-store

{"id": 42, "name": "Alice"}
```

## Methods

| Method | Purpose | Safe? | Idempotent? |
|---|---|---|---|
| `GET` | Read | ✅ | ✅ |
| `POST` | Create / trigger an action | ❌ | ❌ |
| `PUT` | Replace entirely | ❌ | ✅ |
| `PATCH` | Partially update | ❌ | ❌ (usually) |
| `DELETE` | Remove | ❌ | ✅ |
| `HEAD` | Like GET but headers only | ✅ | ✅ |
| `OPTIONS` | What's allowed? (CORS preflight) | ✅ | ✅ |

## Status codes

| Code | Meaning | Typical cause |
|---|---|---|
| **200** OK | Success | |
| **201** Created | Resource created | Successful POST |
| **204** No Content | Success, empty body | Successful DELETE |
| **301 / 308** | Moved permanently | HTTP → HTTPS redirect, domain change |
| **302 / 307** | Temporary redirect | Login redirects |
| **304** Not Modified | Use your cached copy | Caching |
| **400** Bad Request | Malformed request | Invalid JSON, missing field |
| **401** Unauthorized | Not authenticated | Missing/expired token |
| **403** Forbidden | Authenticated but not allowed | Wrong permissions, S3 bucket policy, WAF block |
| **404** Not Found | No such resource | Wrong URL/path, wrong Host header |
| **405** Method Not Allowed | Wrong method | POST to a GET-only endpoint |
| **429** Too Many Requests | Rate limited | Slow down / retry with backoff |
| **500** Internal Server Error | App crashed handling it | Check **application logs** |
| **502** Bad Gateway | Proxy/LB got a bad or no response from the backend | App down, crashed, wrong port, failing health checks |
| **503** Service Unavailable | No healthy backends / overloaded | All targets unhealthy, maintenance |
| **504** Gateway Timeout | Backend too slow | Slow DB query, timeout settings too low |

💡 **4xx = the client should change something. 5xx = the server side is broken.** 502/503/504 point you at the layer *behind* the proxy.

## Important headers

| Header | Purpose |
|---|---|
| `Host` | Which site (one IP can host many sites: *virtual hosting*) |
| `Content-Type` | Format of the body (`application/json`, `text/html`) |
| `Authorization` | Credentials (`Bearer <token>`, `Basic ...`) |
| `Cookie` / `Set-Cookie` | Session state |
| `Cache-Control` | Caching rules for browsers and CDNs |
| `X-Forwarded-For` | Original client IP when behind a proxy/LB |
| `Location` | Where a redirect points |
| `Strict-Transport-Security` | Force HTTPS in browsers (HSTS) |

## HTTP versions

| Version | Key feature |
|---|---|
| HTTP/1.1 | Text-based, one request at a time per connection, keep-alive |
| HTTP/2 | Binary, many requests multiplexed over one TCP connection |
| HTTP/3 | Runs over **QUIC** (UDP); faster setup, better on lossy mobile networks |

## TLS: the "S" in HTTPS

TLS gives you:
1. **Encryption:** nobody in between can read the traffic
2. **Integrity:** nobody can modify it unnoticed
3. **Authentication:** the server proves it really is `example.com` via a **certificate**

### Certificates
- Issued by a **Certificate Authority (CA)** that browsers trust (Let's Encrypt, DigiCert, Amazon).
- Contain the domain name(s), the public key, the issuer and the **expiry date**.
- **Chain of trust:** your cert ← intermediate CA ← root CA (pre-installed in your OS/browser).
- **Expired certificates** cause outages every year at big companies. Automate renewal (Let's Encrypt + certbot, or AWS Certificate Manager which renews automatically).

### TLS termination
Usually the **load balancer** handles TLS ("terminates" it) and talks plain HTTP to app servers inside the private network. Simpler certificate management, less CPU on app servers.

## 🛠️ Commands

```bash
curl -I https://example.com                     # response headers only
curl -v https://example.com -o /dev/null        # everything: DNS, TCP, TLS, request, response headers
curl -sS -o /dev/null -w "%{http_code} %{time_total}s\n" https://example.com   # status + timing
curl -X POST -H "Content-Type: application/json" -d '{"name":"Alice"}' https://httpbin.org/post
curl -H "Host: mysite.com" http://10.0.1.5/     # test a virtual host directly by IP
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates   # inspect the certificate and expiry
```

## 🧠 Check yourself
1. A user gets **403** from your S3-hosted site; another gets **404**. What's different?
2. After a deployment, the load balancer returns **502** for every request. Where do you look first?
3. Why do load balancers add `X-Forwarded-For`?

<details><summary>Answers</summary>

1. 403: they reached it but are denied (bucket policy, block public access, WAF). 404: the object/path doesn't exist. (Note: S3 can also return 403 for missing objects if the caller lacks `s3:ListBucket` permission.)
2. The targets behind the LB: are the app processes running, listening on the expected port, and passing health checks? Check app logs and the target group's health status.
3. Because the app only sees the LB's IP as the source; the header carries the real client IP for logging, rate-limiting and geo-features.
</details>
