# Lab 2 · DNS & HTTP Deep Dive

**Time:** ~45 minutes · **Needs:** `dig`, `curl`, `openssl` (all preinstalled on macOS)

## Part A: DNS

```bash
dig +short google.com
dig google.com
dig google.com AAAA +short
dig github.com MX +short
dig github.com NS +short
dig +trace example.com
dig @1.1.1.1 example.com +short
dig @8.8.8.8 example.com +short
```

**Questions**
1. In the full `dig google.com` output, find the **TTL**. Run it again a few seconds later. What happened to the TTL, and why?
2. Does google.com return more than one IP? Why might a big site do that?
3. In `dig +trace`, list the three levels of servers that were asked (root → TLD → authoritative).
4. Who hosts GitHub's DNS (look at the NS records)?

## Part B: HTTP with curl

```bash
curl -I https://example.com
curl -I http://github.com
curl -sS -o /dev/null -w "status=%{http_code}  dns=%{time_namelookup}s  connect=%{time_connect}s  tls=%{time_appconnect}s  total=%{time_total}s\n" https://example.com
curl -v https://example.com -o /dev/null 2>&1 | grep -E '^\*|^>|^<' | head -40
```

**Questions**
5. What status code does `http://github.com` return, and what's in the `Location` header? Why?
6. From the timing line: how long did DNS, TCP connect and the TLS handshake each take?
7. In the `-v` output, lines starting with `>` are what you **sent** and `<` what you **received**. Find the `Host` header you sent.

## Part C: Status codes in the wild

```bash
for path in /get /status/201 /status/404 /status/500 /redirect/1; do
  printf '%-14s → ' "$path"
  curl -s -o /dev/null -w "%{http_code}\n" "https://httpbin.org$path"
done
```

**Question**
8. For each code you saw, say whether it's a client-side or server-side problem (or success/redirect).

## Part D: TLS certificates

```bash
echo | openssl s_client -connect github.com:443 -servername github.com 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

**Questions**
9. Who issued GitHub's certificate? When does it expire?
10. Why do certificate expiries cause outages, and how do AWS Certificate Manager or Let's Encrypt help?

<details><summary>Answer hints</summary>

1. The TTL counts down: you're seeing a cached answer from your resolver, which will re-query when it reaches 0.
2. Load distribution and redundancy (DNS round robin), often combined with geo-based answers.
5. `301` redirect to `https://github.com/`. Sites force HTTPS.
10. Certs are often renewed by hand and forgotten. ACM renews automatically for certificates it manages; Let's Encrypt is automated via certbot or similar clients.
</details>
