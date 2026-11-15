#!/bin/sh
# Pins every lib-ui dependency in this repository to one lib-ui commit:
#   scripts/pin-lib-ui.sh <40-character lib-ui commit>
# A build takes one copy of each package, so every manifest must name the same commit.
set -e
rev="$1"
case "$rev" in
  *[!0-9a-f]*|"") echo "usage: $0 <40-character lib-ui commit>" >&2; exit 1 ;;
esac
[ ${#rev} -eq 40 ] || { echo "usage: $0 <40-character lib-ui commit>" >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
find "$root/modules" -name silk.toml -exec sed -i.bak -E \
  "s#(git = \"https://github.com/silk-lang/lib-ui.git\", rev = \")[0-9a-f]{40}#\1$rev#" {} +
find "$root/modules" -name silk.toml.bak -delete
echo "lib-ui pinned to $rev"
