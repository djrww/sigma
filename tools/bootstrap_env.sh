#!/usr/bin/env bash
set -euo pipefail

if [ ! -x "$HOME/.moon/bin/moon" ]; then
  curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
fi

if ! command -v why3 >/dev/null 2>&1; then
  sudo apt-get update -qq && sudo apt-get install -y -qq why3 libgmp-dev
fi

ln -sf "$(which why3)" "$HOME/.moon/bin/why3"
WHY3SERVER_BIN="$(find /usr -name why3server 2>/dev/null | head -n 1)"
if [ -n "$WHY3SERVER_BIN" ]; then
  ln -sf "$WHY3SERVER_BIN" "$HOME/.moon/bin/why3server"
fi

if [ ! -x "/usr/local/bin/z3" ]; then
  pip install --break-system-packages -q z3-solver
fi

if [ ! -x "/usr/local/bin/cvc5" ]; then
  curl -fsSL https://github.com/cvc5/cvc5/releases/latest/download/cvc5-Linux-x86_64-static.zip -o /tmp/cvc5_latest.zip
  rm -rf /tmp/cvc5_ext && unzip -q -o /tmp/cvc5_latest.zip -d /tmp/cvc5_ext
  sudo cp "$(find /tmp/cvc5_ext -name cvc5 -type f)" /usr/local/bin/cvc5
  sudo chmod +x /usr/local/bin/cvc5
fi

echo "Toolchain ready: $( "$HOME/.moon/bin/moon" version )"
