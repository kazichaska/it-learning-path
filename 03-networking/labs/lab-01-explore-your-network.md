# Lab 1 · Explore Your Own Network

**Time:** ~30 minutes · **Needs:** macOS Terminal (Linux equivalents shown)

Record your answers in a copy of this file or in your [study log](../../STUDY-LOG.md).

## Part A: Who am I on the network?

```bash
ipconfig getifaddr en0                 # macOS: private IP on Wi-Fi   | Linux: ip -4 addr
curl -s https://ifconfig.me; echo      # your public IP (as the internet sees you)
netstat -rn | grep default | head -3   # macOS: default gateway      | Linux: ip route | grep default
scutil --dns | grep nameserver | sort -u   # macOS: DNS servers      | Linux: cat /etc/resolv.conf
```

**Questions**
1. What's your private IP? Which private range (`10/8`, `172.16/12`, `192.168/16`) is it in?
2. What's your public IP? Why is it different from your private IP?
3. What's your default gateway's IP? (Hint: it's usually your router.)
4. Which DNS servers does your Mac use?

## Part B: What's listening on my machine?

```bash
lsof -nP -iTCP -sTCP:LISTEN            # Linux: sudo ss -tlnp
```

**Questions**
5. Pick three entries. Which program, which port, and is it bound to `127.0.0.1` (local only) or `*` / `0.0.0.0` (all interfaces)?
6. Why is a service listening on `*` more exposed than one on `127.0.0.1`?

## Part C: Start your own server and connect to it

```bash
# Terminal 1: start a web server on port 8000 (serves the current folder)
python3 -m http.server 8000

# Terminal 2:
curl -I http://localhost:8000          # should be 200 OK
nc -zv localhost 8000                  # "succeeded"
lsof -nP -iTCP:8000 -sTCP:LISTEN       # see your server listening
```

Now stop the server (Ctrl+C in terminal 1) and run again:
```bash
nc -zv localhost 8000
```

**Questions**
7. What error do you get now? Is it "refused" or "timed out"? Explain why using the TCP handshake.
8. Restart the server bound only to localhost: `python3 -m http.server 8000 --bind 127.0.0.1`. Could another computer on your Wi-Fi reach it? Why or why not?

## Part D: Path to the internet

```bash
traceroute -m 12 8.8.8.8               # Ctrl+C if it stalls
ping -c 5 8.8.8.8
ping -c 5 1.1.1.1
```

**Questions**
9. How many hops until you leave your ISP's network (look at the hostnames/IPs)?
10. What's the average latency to 8.8.8.8 vs 1.1.1.1?

<details><summary>Answer hints</summary>

2. NAT: your router translates your private IP to its single public IP.
6. `*` accepts connections on every network interface, so other devices on the network can connect; `127.0.0.1` only accepts connections from the same machine.
7. "Connection refused": the host is there and replies with a TCP RST because nothing is listening on that port.
8. No. It only accepts connections arriving on the loopback interface.
</details>
