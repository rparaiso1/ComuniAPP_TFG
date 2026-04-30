# start-backend.ps1 - Levanta el backend FastAPI
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Backend FastAPI - ComuniApp" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Activar entorno virtual si existe
if (Test-Path "$root\.venv\Scripts\Activate.ps1") {
    Write-Host "Activando entorno virtual..." -ForegroundColor Yellow
    & "$root\.venv\Scripts\Activate.ps1"
} elseif (Test-Path "$root\backend\.venv\Scripts\Activate.ps1") {
    Write-Host "Activando entorno virtual del backend..." -ForegroundColor Yellow
    & "$root\backend\.venv\Scripts\Activate.ps1"
}

Set-Location "$root\backend"
$env:PYTHONIOENCODING = 'utf-8'
python start_server.py

Write-Host ""
Write-Host "Backend detenido." -ForegroundColor Yellow
Read-Host "Presiona Enter para salir"
