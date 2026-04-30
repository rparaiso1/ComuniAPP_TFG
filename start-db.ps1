# start-db.ps1 - Levanta la base de datos PostgreSQL + pgAdmin
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Base de Datos - ComuniApp" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Docker no esta instalado. Asegurate de que Docker Desktop este abierto." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}

Set-Location $root
Write-Host "Limpiando contenedores previos (si existen)..." -ForegroundColor DarkGray
$containerNames = @("tfg_postgres", "tfg_pgadmin")
$existingContainers = docker ps -a --format "{{.Names}}" 2>$null

foreach ($containerName in $containerNames) {
    if ($existingContainers -contains $containerName) {
        docker rm -f $containerName 2>$null | Out-Null
    }
}

docker compose up -d postgres pgadmin
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] No se pudo iniciar Docker. Asegurate de que Docker Desktop este abierto." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}

Write-Host ""
Write-Host "Base de datos iniciada:" -ForegroundColor Green
Write-Host "  PostgreSQL: localhost:5433"
Write-Host "  pgAdmin:    http://localhost:5050"
Write-Host ""
Write-Host "Para detener: docker compose down" -ForegroundColor Yellow
Write-Host ""
Read-Host "Presiona Enter para salir"
