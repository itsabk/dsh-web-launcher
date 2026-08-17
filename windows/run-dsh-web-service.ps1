$ErrorActionPreference = "Stop"

$AppData = Join-Path $env:LOCALAPPDATA "DeepSeek Harness Web"
$LogDir = Join-Path $AppData "logs"
$LogFile = Join-Path $LogDir "dsh-web.log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Set-Location $env:USERPROFILE

function Write-Log {
  param([string]$Message)
  Add-Content -Path $LogFile -Value $Message -Encoding utf8
}

Write-Log "---- $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') starting DeepSeek Harness Web ----"
Write-Log "PATH=$env:PATH"

$Dsh = Get-Command dsh -ErrorAction SilentlyContinue
if ($Dsh) {
  Write-Log "Using dsh: $($Dsh.Source)"
  & $Dsh.Source web *>> $LogFile
  exit $LASTEXITCODE
}

$Npx = Get-Command npx -ErrorAction SilentlyContinue
if ($Npx) {
  Write-Log "Using npx: $($Npx.Source)"
  & $Npx.Source --yes "@deepseek-ai/dsh" web *>> $LogFile
  exit $LASTEXITCODE
}

Write-Log "ERROR: neither dsh nor npx was found. Install Node.js, then try again."
exit 127

