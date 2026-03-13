# start-flutter.ps1 - Levanta Flutter en Chrome
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Flutter Web - ComuniApp" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter no esta instalado o no esta en el PATH." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}

Set-Location $root
flutter run -d chrome --web-port 3000

Write-Host ""
Write-Host "Flutter detenido." -ForegroundColor Yellow
Read-Host "Presiona Enter para salir"
