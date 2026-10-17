# JavaScript & Node.js for DevOps

> JavaScript runs every web front-end, and with **Node.js** it runs on servers too. DevOps engineers meet it in web apps they deploy, serverless functions (AWS Lambda), build tools, GitHub Actions and the AWS CDK (via TypeScript).

## Setup

```bash
brew install node          # installs node + npm
node --version
npm --version
node                       # interactive REPL (Ctrl+D to exit)
```
💡 Use a version manager (`nvm`, `fnm` or `volta`) when you need different Node versions per project.

## Core syntax

```javascript
// Variables: prefer const; use let if it changes; avoid var
const service = "api";
let replicas = 3;

// Template literals
console.log(`${service} has ${replicas} replicas`);

// Arrays and objects
const servers = ["web-01", "web-02"];
const config = { env: "prod", port: 8080, tags: ["blue"] };

// Destructuring
const { env, port } = config;

// Arrow functions
const double = (n) => n * 2;

// Array methods (very common)
const ports = [80, 443, 8080];
ports.map((p) => p + 1);          // [81, 444, 8081]
ports.filter((p) => p > 1000);    // [8080]
ports.reduce((sum, p) => sum + p, 0);   // 8603

// Conditionals and comparison: always use === (strict equality)
if (port === 8080) console.log("alt http");

// JSON
const text = JSON.stringify(config);      // object → string
const parsed = JSON.parse(text);          // string → object
```

## Async/await: the key concept

Node is **single-threaded but non-blocking**: while waiting for the network or disk, it works on other things. Functions that wait return a **Promise**.

```javascript
async function getStatus(url) {
  const res = await fetch(url);            // pauses this function, not the whole program
  return res.status;
}

// Run several in parallel and wait for all of them
const results = await Promise.allSettled([
  getStatus("https://example.com"),
  getStatus("https://github.com"),
]);
```

Error handling uses `try { … } catch (err) { … }` just like Python's try/except.

## npm & package.json

```bash
npm init -y                 # create package.json
npm install express         # add a dependency
npm install -D eslint       # dev-only dependency
npm ci                      # clean, exact install from package-lock.json (use this in CI!)
npm run test                # run a script defined in package.json
```
- `package.json`: project metadata and dependency ranges
- `package-lock.json`: exact resolved versions. **Commit it.**
- `node_modules/`: installed packages. **Never commit it** (already in `.gitignore`).

## Where DevOps engineers meet JavaScript

| Place | Example |
|---|---|
| Dockerizing Node apps | `FROM node:22-alpine`, `npm ci --omit=dev` |
| AWS Lambda | `export const handler = async (event) => { … }` |
| AWS CDK (TypeScript) | Define infrastructure with code |
| GitHub Actions | Custom actions are often written in JS |
| Front-end builds | `npm run build` → static files → S3 + CloudFront |

## 🧪 Project: parallel health checker

[`health-check.js`](health-check.js) checks many URLs in parallel with timeouts and returns a non-zero exit code if any are down (useful in CI/CD after a deploy).

```bash
node health-check.js https://example.com https://github.com https://httpbin.org/status/503
echo $?      # 1 because one URL failed
```

**Challenges**
1. Read the list of URLs from a JSON file instead of arguments.
2. Add retries (try up to 3 times with a 1-second delay) before marking a URL as down.
3. Add a `--json` flag that prints results as JSON.

## 📚 Learn more
- MDN JavaScript guide: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide
- Node.js docs: https://nodejs.org/en/learn
