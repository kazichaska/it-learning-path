# Python for DevOps

> Python is the most common language for automation, cloud SDKs (boto3), Ansible modules, CLI tools and data wrangling. It reads almost like English.

## Setup

```bash
python3 --version                    # macOS: comes with Xcode tools, or `brew install python`
python3 -m venv .venv                # create an isolated environment for this project
source .venv/bin/activate            # activate it (prompt shows (.venv))
pip install requests boto3           # install packages into the venv only
pip freeze > requirements.txt        # record exact versions
pip install -r requirements.txt      # reproduce the environment elsewhere
deactivate                           # leave the venv
```
💡 **Always use a virtual environment.** Installing packages globally leads to version conflicts. `.venv/` is already in this repo's `.gitignore`.

## Core syntax in one screen

```python
# Variables and types
name = "web-01"                  # str
cpu = 73.5                       # float
port = 8080                      # int
healthy = True                   # bool
servers = ["web-01", "web-02"]   # list (ordered, changeable)
config = {"env": "prod", "replicas": 3}   # dict (key → value)

# f-strings
print(f"{name} is at {cpu}% CPU")

# Conditionals
if cpu > 90:
    print("critical")
elif cpu > 70:
    print("warning")
else:
    print("ok")

# Loops
for server in servers:
    print(server.upper())

for key, value in config.items():
    print(key, "=", value)

# Comprehensions
ports = [80, 443, 8080]
high_ports = [p for p in ports if p > 1024]       # [8080]

# Functions with type hints and defaults
def check(host: str, port: int = 443) -> bool:
    """Return True if the port is open."""
    ...

# Error handling
try:
    value = int("abc")
except ValueError as err:
    print(f"bad number: {err}")
```

## The DevOps standard library toolkit

| Module | Use | Example |
|---|---|---|
| `pathlib` | Files and paths | `Path("/var/log").glob("*.log")` |
| `json` | Parse/write JSON | `json.loads(text)`, `json.dumps(data, indent=2)` |
| `subprocess` | Run shell commands | `subprocess.run(["df", "-h"], capture_output=True, text=True, check=True)` |
| `os` / `os.environ` | Environment variables | `os.environ.get("APP_ENV", "dev")` |
| `argparse` | Command-line arguments | See [`log_analyzer.py`](log_analyzer.py) |
| `logging` | Proper logs with levels | `logging.basicConfig(level=logging.INFO)` |
| `re` | Regular expressions | `re.match(r"(\d+\.\d+\.\d+\.\d+)", line)` |
| `collections.Counter` | Count things | `Counter(ips).most_common(5)` |
| `datetime` | Dates and times | `datetime.now(timezone.utc).isoformat()` |
| `urllib.request` / `socket` | HTTP / raw network without extra packages | |

## Popular packages

| Package | Use |
|---|---|
| `requests` | HTTP calls to APIs |
| `boto3` | AWS SDK |
| `pyyaml` | Read/write YAML (Kubernetes manifests, CI configs) |
| `click` / `typer` | Nicer CLIs |
| `pytest` | Testing |
| `fabric` / `paramiko` | SSH automation |

## Real examples

### Call an API safely
```python
import requests

resp = requests.get("https://api.github.com/repos/hashicorp/terraform", timeout=5)
resp.raise_for_status()                      # raise an error for 4xx/5xx
data = resp.json()
print(data["stargazers_count"])
```

### Run a command and use its output
```python
import subprocess

result = subprocess.run(["df", "-h", "/"], capture_output=True, text=True, check=True)
print(result.stdout)
```
⚠️ Pass commands as a **list** (not `shell=True` with user input) to avoid shell injection.

### List S3 buckets with boto3
```python
import boto3

s3 = boto3.client("s3")              # uses your AWS CLI credentials/profile
for bucket in s3.list_buckets()["Buckets"]:
    print(bucket["Name"], bucket["CreationDate"])
```

## 🧪 Project: log analyzer

[`log_analyzer.py`](log_analyzer.py) parses a web server access log and reports traffic, status codes, top IPs, top paths and the error rate.

```bash
python3 log_analyzer.py sample-access.log
python3 log_analyzer.py sample-access.log --top 3
python3 log_analyzer.py sample-access.log --json
```

**Challenges**
1. Add a `--status 404` filter that only shows matching requests.
2. Add requests-per-minute: group by the timestamp's minute.
3. Exit with code 1 if the error rate is above a `--max-error-rate` threshold (great for CI or monitoring).
4. Write a `pytest` test for the `parse_line` function.

## 📚 Learn more
- Official tutorial: https://docs.python.org/3/tutorial/
- *Automate the Boring Stuff with Python* (free online): https://automatetheboringstuff.com/
