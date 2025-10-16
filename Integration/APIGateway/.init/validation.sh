#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/crm-application-1224-4007/Integration/APIGateway"
cd "$WS"
PORT=5000
LOG_FILE=${LOG_FILE:-/tmp/serve_integration.log}
PID_FILE=/tmp/serve_integration.pid
PGID_FILE=/tmp/serve_integration.pgid
# Ensure curl available
command -v curl >/dev/null 2>&1 || { echo "curl required" >&2; exit 2; }
# Ensure server process info exists
[ -f "$PID_FILE" ] || { echo "PID file not found: $PID_FILE" >&2; exit 8; }
PID=$(cat "$PID_FILE")
[ -n "$PID" ] || { echo "invalid PID" >&2; exit 8; }
# Wait up to 120s for HTTP 200 with 1s intervals (longer timeout)
OK=1
STATUS=000
for i in $(seq 1 120); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:${PORT}/ || echo 000)
  if [ "$STATUS" = "200" ]; then OK=0; break; fi
  sleep 1
done
if [ $OK -ne 0 ]; then echo "server failed to respond, last status=$STATUS" >&2; tail -n 500 "$LOG_FILE" >&2 || true; exit 7; fi
echo "HTTP_STATUS=$STATUS"
# Provide build dir evidence if present
[ -d "$WS/build" ] && echo "BUILD_DIR=$WS/build"
exit 0
