#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/crm-application-1224-4007/Integration/APIGateway"
cd "$WS"
[ -f package.json ] || { echo "package.json missing" >&2; exit 2; }
# Safely mutate package.json with visible errors
node -e '
const fs=require("fs");const P="package.json";let p;try{p=JSON.parse(fs.readFileSync(P));}catch(e){console.error("package.json parse error:",e.message);process.exit(3);}p.devDependencies=p.devDependencies||{};let changed=false;function add(k,v){if(!(p.devDependencies&&p.devDependencies[k]) && !((p.dependencies||{})[k])){p.devDependencies[k]=v;changed=true}};add("serve","^14.0.0");add("jest","^29.0.0");if(fs.existsSync("tsconfig.json"))add("typescript","^5.0.0");if(changed)fs.writeFileSync(P,JSON.stringify(p,null,2));' || { echo "failed to update package.json" >&2; exit 4; }
# Create package-lock deterministically if absent
if [ ! -f package-lock.json ]; then npm i --package-lock-only --no-audit --no-fund --silent; fi
# Deterministic install
npm ci --no-audit --no-fund --silent
# Validate react-scripts presence; be tolerant if --version unsupported
if [ -x node_modules/.bin/react-scripts ]; then
  if ! ./node_modules/.bin/react-scripts --version >/dev/null 2>&1; then
    if [ -f node_modules/react-scripts/package.json ]; then
      # ensure jq may not be present; use node to validate version field quietly
      node -e 'try{const v=require("./node_modules/react-scripts/package.json").version; if(!v)process.exit(1);}catch(e){process.exit(1)}' || { echo "react-scripts installed but version check failed" >&2; exit 5; }
    else
      echo "react-scripts installed but version check failed" >&2; exit 5
    fi
  fi
else
  echo "react-scripts not installed" >&2; exit 6
fi
exit 0
