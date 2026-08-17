$ErrorActionPreference = "Stop"

$AppData = Join-Path $env:LOCALAPPDATA "DeepSeek Harness Web"
$PidFile = Join-Path $AppData "dsh-web.pid"

if (!(Test-Path $PidFile)) {
  Write-Host "No DeepSeek Harness Web PID file found."
  Read-Host "Press Enter to close"
  exit 0
}

$PidValue = (Get-Content $PidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
if (!$PidValue) {
  Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
  Write-Host "PID file was empty and has been removed."
  Read-Host "Press Enter to close"
  exit 0
}

$Process = Get-Process -Id $PidValue -ErrorAction SilentlyContinue
if ($Process) {
  & taskkill.exe /PID $PidValue /T /F | Out-Host
  Write-Host "Stopped DeepSeek Harness Web process tree: $PidValue"
}
else {
  Write-Host "DeepSeek Harness Web process $PidValue is not running."
}

Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
Read-Host "Press Enter to close"

