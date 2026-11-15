#!/bin/sh
# Pins every silkui dependency in this repository to one silkui commit:
#   scripts/pin-silkui.sh <40-character silkui commit>
# A build takes one copy of each package, so every manifest must name the same commit.
set -e
rev="$1"
case "$rev" in
  *[!0-9a-f]*|"") echo "usage: $0 <40-character silkui commit>" >&2; exit 1 ;;
esac
[ ${#rev} -eq 40 ] || { echo "usage: $0 <40-character silkui commit>" >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
find "$root/modules" -name silk.toml -exec sed -i.bak -E \
  "s#(git = \"https://github.com/silk-lang/silkui.git\", rev = \")[0-9a-f]{40}#\1$rev#" {} +
find "$root/modules" -name silk.toml.bak -delete
echo "silkui pinned to $rev"
