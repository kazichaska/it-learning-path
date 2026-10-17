# 01 · Foundations

> **Goal:** Understand what actually happens inside a computer, an operating system and the internet, so that everything later (Linux, cloud, containers) feels logical instead of magical.

## 📚 Lessons

| # | Lesson | You'll learn |
|---|---|---|
| 1 | [How computers work](how-computers-work.md) | CPU, memory, storage, binary, CPU architectures, virtualization |
| 2 | [Operating systems](operating-systems.md) | Kernel vs user space, processes, memory, file systems, boot process |
| 3 | [How the internet works](how-the-internet-works.md) | Packets, routers, IP, DNS, TCP, HTTP: the whole journey of a web request |

## 🔗 How this connects to Cloud & DevOps

| Foundation concept | Where you'll meet it again |
|---|---|
| CPU cores, RAM, disk speed | Choosing an EC2 instance type, setting Kubernetes resource limits |
| `x86_64` vs `arm64` | Building Docker images that run on the right servers |
| Virtualization | Every cloud VM; containers are a lighter version of the same idea |
| Processes & memory | Debugging slow servers, `OOMKilled` containers |
| Packets, IP, DNS | VPCs, security groups, load balancers, Route 53 |

## ✅ Self-check: you're ready to move on when you can…

- [ ] Explain the difference between RAM and storage, and why both matter for a server
- [ ] Explain what a kernel does in one sentence
- [ ] Describe the difference between a virtual machine and a container
- [ ] Walk through what happens when you type a URL into a browser
- [ ] Say why `arm64` vs `x86_64` matters when deploying software

➡️ **Next:** [02 · Linux & command line](../02-linux/)
