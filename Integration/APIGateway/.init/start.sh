#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/crm-application-1224-4007/Integration/APIGateway"
cd "$WS"
PORT=5000
LOG=/tmp/serve_integration.log
# Check for curl (used by validation later) and for serve binary
command -v curl >/dev/null 2>&1 || { echo "curl required" >&2; exit 2; }
SERVE_BIN="$WS/node_modules/.bin/serve"
[ -x "$SERVE_BIN" ] || { echo "serve binary not found at $SERVE_BIN" >&2; exit 5; }
# Portable port-in-use check: ss then netstat
if command -v ss >/dev/null 2>&1; then
  if ss -ltn | awk '{print $4}' | grep -E -q ":${PORT}$|:${PORT}\\b"; then echo "port $PORT already in use" >&2; exit 3; fi
elif command -v netstat >/dev/null 2>&1; then
  if netstat -ltn | awk '{print $4}' | grep -E -q ":${PORT}$|:${PORT}\\b"; then echo "port $PORT already in use" >&2; exit 3; fi
fi
# Start serve in new session so we can kill group; capture PID and PGID
setsid "$SERVE_BIN" -s build -l "$PORT" >"$LOG" 2>&1 &
PID=$!
sleep 1
if ! kill -0 "$PID" >/dev/null 2>&1; then echo "serve process not running, logs:" >&2; tail -n 500 "$LOG" >&2 || true; exit 6; fi
PGID=$(ps -o pgid= "$PID" | tr -d ' ')
[ -z "$PGID" ] && PGID=$PID
# Save PGID/PID to files for stop script
echo "$PID" > /tmp/serve_integration.pid
echo "$PGID" > /tmp/serve_integration.pgid
echo "$LOG" > /tmp/serve_integration.logpath
# Install trap for interactive runs; start script exits but leaves files for stop
trap 'kill -TERM -"$PGID" >/dev/null 2>&1 || kill -TERM "$PID" >/dev/null 2>&1 || true' EXIT
# Print start info
echo "SERVE_STARTED PID=$PID PGID=$PGID LOG=$LOG"
