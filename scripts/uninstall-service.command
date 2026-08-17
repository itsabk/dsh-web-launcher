#!/bin/zsh
set -euo pipefail

PLIST="$HOME/Library/LaunchAgents/com.local.deepseek-harness-web.plist"
APP_SUPPORT="$HOME/Library/Application Support/DeepSeek Harness Web"

launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true

if [[ -f "$PLIST" ]]; then
  /usr/bin/perl -e 'unlink shift' "$PLIST"
fi

echo "DeepSeek Harness Web service has been removed from LaunchAgents."
echo "Logs and local support files are still here:"
echo "$APP_SUPPORT"
echo "Delete that folder manually if you also want to remove logs."
