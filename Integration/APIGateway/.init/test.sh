#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/crm-application-1224-4007/Integration/APIGateway"
cd "$WS"
mkdir -p __tests__
cat > __tests__/smoke.test.js <<'JS'
test('smoke',()=>{expect(1+1).toBe(2)});
JS
# Prefer project npm test script to preserve CRA transforms
if npm run | sed -n '1,200p' | grep -q "test"; then
  npm test --silent -- --watchAll=false || { echo "npm test failed" >&2; exit 4; }
else
  JEST_BIN=./node_modules/.bin/jest
  if [ -x "$JEST_BIN" ]; then
    "$JEST_BIN" --runInBand --silent || { echo "jest tests failed" >&2; exit 5; }
  else
    echo "no test runner available" >&2; exit 6
  fi
fi
echo "tests: PASS"
exit 0
