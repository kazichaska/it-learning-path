"""A tiny web app used to practise Docker, Kubernetes and CI/CD.

It uses only the Python standard library, so the image needs no extra packages.

Endpoints:
    GET /        -> greeting, hostname (container ID/pod name) and version
    GET /health  -> {"status": "ok"} for load balancer and Kubernetes probes
"""
import json
import logging
import os
import signal
import socket
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("PORT", "8080"))
GREETING = os.environ.get("GREETING", "Hello from the IT learning path!")
VERSION = os.environ.get("APP_VERSION", "1.0.0")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self._send(200, {"status": "ok"})
        elif self.path == "/":
            self._send(200, {
                "message": GREETING,
                "hostname": socket.gethostname(),
                "version": VERSION,
            })
        else:
            self._send(404, {"error": "not found", "path": self.path})

    def _send(self, status: int, body: dict) -> None:
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, fmt, *args):
        # Log to stdout so `docker logs` / `kubectl logs` can see requests.
        logging.info("%s %s", self.address_string(), fmt % args)


def main() -> None:
    # Listen on 0.0.0.0 (all interfaces), not 127.0.0.1, or nothing outside
    # the container could reach the app.
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)

    def shutdown(signum, _frame):
        # Docker/Kubernetes send SIGTERM before stopping a container: exit cleanly.
        logging.info("Received signal %s, shutting down", signum)
        server.server_close()
        sys.exit(0)

    signal.signal(signal.SIGTERM, shutdown)
    logging.info("Listening on port %s (version %s)", PORT, VERSION)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()


if __name__ == "__main__":
    main()
