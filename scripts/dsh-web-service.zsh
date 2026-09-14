#!/bin/zsh
set -euo pipefail

APP_SUPPORT="$HOME/Library/Application Support/DeepSeek Harness Web"
LOG_DIR="$APP_SUPPORT/logs"
LOG_FILE="$LOG_DIR/dsh-web.log"
STATE_FILE="$APP_SUPPORT/service-state"

umask 077
mkdir -p "$LOG_DIR"
touch "$LOG_FILE" "$STATE_FILE"
chmod 600 "$LOG_FILE" "$STATE_FILE"
cd "$HOME"

# launchd starts with a minimal PATH. Include common user and Homebrew locations
# so the globally installed dsh binary is found without relying on a login shell.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "---- $(date '+%Y-%m-%d %H:%M:%S') starting DeepSeek Harness Web ----" >>"$LOG_FILE"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  source "$HOME/.nvm/nvm.sh"
  nvm use --silent default >/dev/null 2>&1 || true
fi

if ! command -v dsh >/dev/null 2>&1 && ! command -v npx >/dev/null 2>&1; then
  for node_bin in "$HOME"/.nvm/versions/node/*/bin(N); do
    export PATH="$node_bin:$PATH"
  done
fi

{
  echo "PATH=$PATH"
  if command -v dsh >/dev/null 2>&1; then
    echo "Using dsh: $(command -v dsh)"
    echo "running" >"$STATE_FILE"
    exec dsh web --no-open
  fi

  if command -v npx >/dev/null 2>&1; then
    echo "Using npx: $(command -v npx)"
    echo "running" >"$STATE_FILE"
    exec npx --yes @deepseek-ai/dsh@latest web --no-open
  fi

  echo "ERROR: neither dsh nor npx was found. Install Node.js or make npx available through nvm."
  echo "failed" >"$STATE_FILE"
  exit 127
} >>"$LOG_FILE" 2>&1
