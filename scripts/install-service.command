#!/bin/zsh
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_SUPPORT="$HOME/Library/Application Support/DeepSeek Harness Web"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="$LAUNCH_AGENTS/com.local.deepseek-harness-web.plist"
SERVICE_SCRIPT="$APP_SUPPORT/dsh-web-service.zsh"
LOG_DIR="$APP_SUPPORT/logs"

mkdir -p "$APP_SUPPORT" "$LAUNCH_AGENTS" "$LOG_DIR"
cp "$BASE_DIR/scripts/dsh-web-service.zsh" "$SERVICE_SCRIPT"
chmod +x "$SERVICE_SCRIPT"

cat >"$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.local.deepseek-harness-web</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>$SERVICE_SCRIPT</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/launchd.err.log</string>
  <key>WorkingDirectory</key>
  <string>$HOME</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HOME</key>
    <string>$HOME</string>
  </dict>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl kickstart -k "gui/$(id -u)/com.local.deepseek-harness-web"

echo "DeepSeek Harness Web service installed and started."
echo "Open http://127.0.0.1:3080 after the first download/startup finishes."
echo "Logs: $LOG_DIR/dsh-web.log"
