# Docker & Containers

> **The problem Docker solves:** "It works on my machine." A container packages an app **with everything it needs** (runtime, libraries, config) so it runs the same on your laptop, in CI and in production.

## Key concepts

| Term | Meaning | Analogy |
|---|---|---|
| **Image** | A read-only template: app + dependencies + filesystem, built in **layers** | A recipe / class |
| **Container** | A running instance of an image (an isolated process) | A dish made from the recipe / object |
| **Dockerfile** | Instructions to build an image | The written recipe |
| **Registry** | Stores and shares images (Docker Hub, GHCR, ECR) | A recipe library |
| **Tag** | A version label: `python:3.12-slim`, `myapp:1.4.2` | Edition number |
| **Volume** | Persistent storage that outlives containers | An external hard drive |

Containers vs VMs: see [How computers work › virtualization](../../01-foundations/how-computers-work.md#6-virtualization-the-foundation-of-the-cloud).

## Installing on macOS

Docker needs a Linux VM on macOS. Options: **Docker Desktop**, **Colima** (free, CLI: `brew install colima docker && colima start`), **OrbStack** or Rancher Desktop.

```bash
docker version          # both Client and Server sections should appear
docker run --rm hello-world
```
`Cannot connect to the Docker daemon` → the VM isn't running (`colima start` or open Docker Desktop).

## Essential commands

```bash
# Images
docker pull nginx:1.27
docker images                         # list local images
docker build -t myapp:1.0 .           # build from the Dockerfile in this folder
docker rmi myapp:1.0                  # remove an image

# Containers
docker run -d --name web -p 8080:80 nginx:1.27   # detached, host port 8080 → container port 80
docker ps                             # running containers (add -a for stopped ones too)
docker logs -f web                    # follow logs
docker exec -it web sh                # open a shell inside the running container
docker stop web && docker rm web      # stop and remove
docker run --rm -it ubuntu:24.04 bash # throwaway Linux shell

# Inspect & clean up
docker inspect web                    # all details (IP, mounts, env…)
docker stats                          # live CPU/memory per container
docker system df                      # disk used by Docker
docker system prune                   # remove stopped containers, unused networks, dangling images
```

### `-p HOST:CONTAINER`
`-p 8080:80` means "traffic to **my Mac's** port 8080 goes to the **container's** port 80." The app inside must listen on `0.0.0.0`, not `127.0.0.1`.

## Writing good Dockerfiles

See the working example: [`example-app/Dockerfile`](example-app/Dockerfile).

```dockerfile
# 1. Small, official, pinned base image
FROM python:3.12-slim
WORKDIR /app

# 2. Copy the dependency list first, so this layer is cached between builds
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Then the code (it changes most often)
COPY . .

# 4. Don't run as root
RUN useradd --create-home appuser
USER appuser

EXPOSE 8080
# 5. Exec form (JSON array) so signals reach the app
CMD ["python", "app.py"]
```
💡 Dockerfile comments must be on their own line. `#` after an instruction is *not* a comment.

### Best practices checklist
- ✅ **Pin versions** (`python:3.12-slim`, not `python:latest`)
- ✅ **Small base images** (`-slim`, `-alpine`, distroless) → faster pulls, fewer vulnerabilities
- ✅ **Order layers** from least to most frequently changing (dependencies before code) for build caching
- ✅ **Non-root user**
- ✅ **`.dockerignore`** to keep `.git`, `.venv`, secrets and junk out of the build context
- ✅ **One process per container**
- ✅ **Multi-stage builds** for compiled apps: build in a big image, copy only the binary into a tiny one
- ✅ Config via **environment variables**, not baked into the image
- ❌ Never put **secrets** in a Dockerfile or image layers (they're visible with `docker history`)

## Volumes and networks

```bash
docker volume create pgdata
docker run -d --name db -e POSTGRES_PASSWORD=devpass -v pgdata:/var/lib/postgresql/data postgres:17
docker run -v "$PWD":/app ...            # bind mount: share a host folder (great for development)

docker network create appnet
docker run -d --network appnet --name db postgres:17 ...
docker run -d --network appnet --name api myapp:1.0   # can reach the DB at hostname "db"
```
Containers on the same user-defined network find each other **by name** (built-in DNS).

## Docker Compose: multi-container apps

Compose describes several containers in one YAML file. See [`example-app/compose.yaml`](example-app/compose.yaml).
```bash
docker compose up -d --build     # build and start everything
docker compose ps
docker compose logs -f
docker compose down              # stop and remove (add -v to delete volumes too)
```

## CPU architecture gotcha (Apple Silicon)

Your Mac builds **arm64** images. Most servers are **amd64** (x86_64), unless you use AWS Graviton.
```bash
docker build --platform linux/amd64 -t myapp:1.0 .                 # build for x86 servers
docker buildx build --platform linux/amd64,linux/arm64 -t user/myapp:1.0 --push .   # multi-arch
```
Symptom of a mismatch: `exec format error`.

## 🧪 Hands-on: the example app

```bash
cd example-app
docker build -t example-app:1.0 .
docker run -d --name example -p 8080:8080 example-app:1.0
curl localhost:8080
curl localhost:8080/health
docker logs example
docker stop example && docker rm example
```
Then try `docker compose up -d --build` in the same folder.

**Challenges**
1. Change the `GREETING` environment variable at run time with `-e GREETING="Hi!"`.
2. Check the image size with `docker images`. Try `python:3.12-alpine` as the base: how much smaller is it? (Hint: Alpine has no `useradd`; use `adduser -D -u 10001 appuser`.)
3. Run two containers from the same image on ports 8081 and 8082. Notice the different `hostname` in each response.
4. Push the image to GitHub Container Registry (see [CI/CD](../cicd/)).

## Troubleshooting

| Problem | Check |
|---|---|
| Container exits immediately | `docker logs <name>`; `docker ps -a` shows the exit code |
| Can't reach the app on `localhost:PORT` | Did you publish with `-p`? Is the app listening on `0.0.0.0`? |
| `port is already allocated` | Something else uses the host port: `lsof -i :8080` |
| Build is slow every time | Layer order: copy dependency files before source code |
| `exec format error` | Wrong architecture; use `--platform` |
| Disk filling up | `docker system df`, `docker system prune -a` (careful) |
