#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_SUPPORT="$HOME/Library/Application Support/DeepSeek Harness Web"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
PLIST="$LAUNCH_AGENTS/com.local.deepseek-harness-web.plist"
SERVICE_SCRIPT="$APP_SUPPORT/dsh-web-service.zsh"
INSTALLER_COPY="$APP_SUPPORT/install-service.command"
LOG_DIR="$APP_SUPPORT/logs"
APP_SOURCE="$BASE_DIR/DeepSeek Harness.app"

if [[ -d "/Applications" && -w "/Applications" ]]; then
  APP_DIR="/Applications"
else
  APP_DIR="$HOME/Applications"
fi
APP_DEST="$APP_DIR/DeepSeek Harness.app"

umask 077
mkdir -p "$APP_SUPPORT" "$APP_DIR" "$LAUNCH_AGENTS" "$LOG_DIR"
chmod 700 "$APP_SUPPORT" "$LOG_DIR"
if [[ "$SCRIPT_DIR/dsh-web-service.zsh" != "$SERVICE_SCRIPT" ]]; then
  cp "$SCRIPT_DIR/dsh-web-service.zsh" "$SERVICE_SCRIPT"
fi
if [[ "$0" != "$INSTALLER_COPY" ]]; then
  cp "$0" "$INSTALLER_COPY"
fi
chmod +x "$SERVICE_SCRIPT" "$INSTALLER_COPY"

if [[ -d "$APP_SOURCE" ]]; then
  /usr/bin/ditto "$APP_SOURCE" "$APP_DEST"
  chmod +x "$APP_DEST/Contents/MacOS/DeepSeekHarnessWeb"
  /usr/bin/codesign --force --deep --sign - "$APP_DEST" >/dev/null 2>&1 || true
fi

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
echo "Launcher: $APP_DEST"
echo "Logs: $LOG_DIR/dsh-web.log"
