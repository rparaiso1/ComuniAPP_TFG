param(
  [string]$ApiBase = "http://localhost:8000/api"
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonExe = Join-Path $root ".venv\Scripts\python.exe"
$scriptPath = Join-Path $root "check_runtime_full.py"

if (-not (Test-Path $pythonExe)) {
  Write-Host "No se encontró Python del venv en $pythonExe" -ForegroundColor Red
  exit 1
}

if (-not (Test-Path $scriptPath)) {
  Write-Host "No se encontró el script $scriptPath" -ForegroundColor Red
  exit 1
}

$env:COMUNIAPP_API_BASE = $ApiBase
& $pythonExe $scriptPath
exit $LASTEXITCODE
