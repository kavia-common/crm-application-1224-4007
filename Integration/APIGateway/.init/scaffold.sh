#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/crm-application-1224-4007/Integration/APIGateway"
mkdir -p "$WS" && cd "$WS"
# Only change ownership when files are root-owned and workspace appears isolated
if [ -e "$WS" ]; then
  ROOT_OWNED=$(find "$WS" -maxdepth 1 -mindepth 1 -user root -print -quit || true)
  if [ -n "$ROOT_OWNED" ]; then
    ME_UID=$(id -u) || ME_UID=1000; ME_GID=$(id -g) || ME_GID=1000
    sudo chown -R "$ME_UID":"$ME_GID" "$WS"
  fi
fi
[ -f package.json ] && exit 0
# Detect TypeScript files recursively
if find "$WS" -type f \( -name "*.ts" -o -name "*.tsx" \) -print -quit >/dev/null 2>&1; then USE_TS=1; else USE_TS=0; fi
# Create minimal package.json (keep dependencies minimal; devDependencies added in dependencies step)
if [ "$USE_TS" -eq 1 ]; then
  cat > package.json <<JSON
{
  "name": "integration-apigateway",
  "private": true,
  "engines": {"node":">=16"},
  "scripts": {"start":"react-scripts start","build":"react-scripts build","test":"npm run test:ci","serve":"serve -s build -l 5000","test:ci":"jest --runInBand --silent"},
  "dependencies": {"react":"^18.0.0","react-dom":"^18.0.0","react-scripts":"^5.0.0"}
}
JSON
  cat > tsconfig.json <<'JSON'
{ "compilerOptions": { "target": "ES6", "jsx": "react-jsx", "module": "ESNext", "moduleResolution": "Node" }, "include": ["src"] }
JSON
else
  cat > package.json <<JSON
{
  "name": "integration-apigateway",
  "private": true,
  "engines": {"node":">=16"},
  "scripts": {"start":"react-scripts start","build":"react-scripts build","test":"npm run test:ci","serve":"serve -s build -l 5000","test:ci":"jest --runInBand --silent"},
  "dependencies": {"react":"^18.0.0","react-dom":"^18.0.0","react-scripts":"^5.0.0"}
}
JSON
fi
mkdir -p src public
cat > public/index.html <<HTML
<!doctype html><html><head><meta charset="utf-8"><title>APIGateway</title></head><body><div id="root"></div></body></html>
HTML
if [ "$USE_TS" -eq 1 ]; then
  cat > src/index.tsx <<TS
import React from 'react';import {createRoot} from 'react-dom/client';const App=()=>React.createElement('div',null,'APIGateway');createRoot(document.getElementById('root')!).render(React.createElement(App));
TS
else
  cat > src/index.js <<JS
import React from 'react';import {createRoot} from 'react-dom/client';const App=()=>React.createElement('div',null,'APIGateway');createRoot(document.getElementById('root')).render(React.createElement(App));
JS
fi
cat > .gitignore <<GIT
node_modules/
build/
.env
GIT
cat > README.md <<MD
APIGateway minimal scaffold for headless development (workspace: $WS)
MD
[ -f package.json ] && [ -f public/index.html ] || { echo "scaffold failed" >&2; exit 6; }
exit 0
