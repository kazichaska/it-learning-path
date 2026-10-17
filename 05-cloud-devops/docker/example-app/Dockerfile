# Small, official, version-pinned base image.
FROM python:3.12-slim

# Don't write .pyc files; send output straight to the logs (no buffering).
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

# This app only uses the standard library. For a real app you would add, BEFORE copying the code:
#   COPY requirements.txt .
#   RUN pip install --no-cache-dir -r requirements.txt
# so the dependency layer stays cached when only your code changes.

COPY app.py .

# Run as an unprivileged user, never as root.
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8080

# The slim image has no curl, so use Python itself for the health check.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health', timeout=2)" || exit 1

# Exec form (JSON array) so the app is PID 1 and receives SIGTERM directly.
CMD ["python", "app.py"]
