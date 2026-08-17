$ErrorActionPreference = "Stop"

$Url = "http://127.0.0.1:3080"
$AppData = Join-Path $env:LOCALAPPDATA "DeepSeek Harness Web"
$LogDir = Join-Path $AppData "logs"
$LogFile = Join-Path $LogDir "dsh-web.log"
$PidFile = Join-Path $AppData "dsh-web.pid"
$Runner = Join-Path $PSScriptRoot "run-dsh-web-service.ps1"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Test-DshWebReady {
  try {
    Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2 | Out-Null
    return $true
  }
  catch {
    return $false
  }
}

function Open-DshWeb {
  Start-Process $Url | Out-Null
}

if (Test-DshWebReady) {
  Open-DshWeb
  exit 0
}

$ShouldStart = $true

if (Test-Path $PidFile) {
  $ExistingPid = (Get-Content $PidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
  if ($ExistingPid) {
    $ExistingProcess = Get-Process -Id $ExistingPid -ErrorAction SilentlyContinue
    if ($ExistingProcess) {
      Write-Host "DeepSeek Harness Web is already starting. Waiting for $Url ..."
      $ShouldStart = $false
    }
  }
}

if ($ShouldStart) {
  $Process = Start-Process powershell.exe -WindowStyle Hidden -PassThru -ArgumentList @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$Runner`""
  )

  $Process.Id | Set-Content -Path $PidFile -Encoding ascii
}

for ($i = 0; $i -lt 240; $i++) {
  if (Test-DshWebReady) {
    Open-DshWeb
    exit 0
  }
  Start-Sleep -Seconds 1
}

Open-DshWeb
Write-Host "DeepSeek Harness Web is still starting or failed."
Write-Host "Log file: $LogFile"
Read-Host "Press Enter to close"
