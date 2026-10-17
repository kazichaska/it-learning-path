# 04 · Programming

> **Goal:** Write scripts and small tools that automate real infrastructure work, version everything with Git, and debug problems methodically.

You don't need to be a software engineer to do DevOps, but you **must** be able to read and write code. Bash takes you far; **Python** takes you the rest of the way.

## 📚 Topics

| Folder | Focus | Hands-on |
|---|---|---|
| [`python/`](python/) | Python for automation: files, JSON, HTTP, subprocess, AWS (boto3) | [`log_analyzer.py`](python/log_analyzer.py): analyse a web server log |
| [`javascript/`](javascript/) | JavaScript & Node.js essentials, async, JSON, npm | [`health-check.js`](javascript/health-check.js): check URLs in parallel |
| [`git/`](git/) | Git from basics to branching, PRs and undoing mistakes | Practice exercises |
| [`debugging/`](debugging/) | A systematic debugging method and common error reference | Error-message decoder table |

## 🧭 Which language for what?

| Task | Best tool |
|---|---|
| Glue commands together, quick server tasks | **Bash** |
| Anything with logic, data parsing, APIs, AWS automation | **Python** |
| Web front-ends, serverless functions, AWS CDK | **JavaScript/TypeScript** |
| Kubernetes operators, high-performance CLIs (Docker, Terraform, kubectl are written in it) | **Go** (learn later) |

## ✅ Self-check

- [ ] Write a Python script that reads a file, parses data and prints a summary
- [ ] Call a REST API from Python and handle errors and timeouts
- [ ] Create a Python virtual environment and install packages
- [ ] Explain `async`/`await` in JavaScript at a high level
- [ ] Create a branch, commit, push and open a pull request
- [ ] Undo a bad commit safely (`revert` vs `reset`)
- [ ] Describe your debugging process step by step

➡️ **Next:** [05 · Cloud & DevOps](../05-cloud-devops/)
