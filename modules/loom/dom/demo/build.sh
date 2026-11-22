#!/bin/sh
# Builds the page into dist/ and, with `serve`, serves it on http://localhost:8021.
# `node check.mjs` (after a build) drives it in Chromium with Playwright.
set -e
here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../../../.." && pwd)"

cd "$root"
silk build --manifest-path "$here/silk.toml" \
  --target wasm32-unknown-unknown --optimization size --debug false

rm -rf "$here/dist"
mkdir -p "$here/dist"
cp "$root/build/wasm32-unknown-unknown/size/loom-dom-demo.wasm" "$here/dist/demo.wasm"
cp "$root/modules/loom/dom/js/silk-ui-dom.js" "$here/dist/silk-ui-dom.js"
cp "$here/web/index.html" "$here/dist/index.html"
echo "Built $here/dist"

if [ "$1" = "serve" ]; then
  cd "$here/dist"
  exec python3 -m http.server 8021
fi
