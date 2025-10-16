#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/crm-application-1224-4007/Integration/APIGateway"
cd "$WS"
command -v npm >/dev/null 2>&1 || { echo "npm required" >&2; exit 2; }
# Run build non-interactively; fail with code 4 on build failure
npm run build --silent || { echo "build failed" >&2; exit 4; }
echo "BUILD_OK"
