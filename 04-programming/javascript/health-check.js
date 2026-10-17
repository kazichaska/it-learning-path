#!/usr/bin/env node
// health-check.js — check several URLs in parallel and report UP/DOWN with response times.
//
// Usage:   node health-check.js <url> [url...]
// Example: node health-check.js https://example.com https://github.com
//
// Exit code 0 if every URL returned a 2xx/3xx status, 1 otherwise. That makes it
// usable as a smoke test in a CI/CD pipeline right after a deployment.
// Requires Node.js 18+ (built-in fetch).

const TIMEOUT_MS = 5000;

async function check(url) {
  const started = performance.now();
  try {
    const res = await fetch(url, {
      method: "GET",
      redirect: "manual",
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
    const ms = Math.round(performance.now() - started);
    const up = res.status >= 200 && res.status < 400;
    return { url, up, status: res.status, ms };
  } catch (err) {
    const ms = Math.round(performance.now() - started);
    const reason = err.name === "TimeoutError" ? `timeout after ${TIMEOUT_MS} ms` : err.cause?.code ?? err.message;
    return { url, up: false, status: reason, ms };
  }
}

async function main() {
  const urls = process.argv.slice(2);
  if (urls.length === 0) {
    console.error("Usage: node health-check.js <url> [url...]");
    process.exit(2);
  }

  // Run all checks at the same time instead of one after another.
  const results = await Promise.all(urls.map(check));

  for (const r of results) {
    const label = r.up ? "UP  " : "DOWN";
    console.log(`${label}  ${String(r.status).padEnd(24)} ${String(r.ms).padStart(5)} ms  ${r.url}`);
  }

  const down = results.filter((r) => !r.up).length;
  console.log(`\n${results.length - down}/${results.length} healthy`);
  process.exitCode = down > 0 ? 1 : 0;
}

main();
