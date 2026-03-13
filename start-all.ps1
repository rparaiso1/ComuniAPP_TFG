# start-all.ps1 - ComuniApp: levanta DB, backend y Flutter
param(
    [switch]$Verify
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  ComuniApp - Inicio Completo" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# ---- Verificar requisitos ----
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Docker no esta instalado." -ForegroundColor Red; Read-Host; exit 1
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Python no esta instalado." -ForegroundColor Red; Read-Host; exit 1
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter no esta instalado." -ForegroundColor Red; Read-Host; exit 1
}

# ---- [1/5] DB ----
Write-Host "[1/5] Iniciando PostgreSQL + pgAdmin..." -ForegroundColor Cyan
Set-Location $root
Write-Host "       Limpiando contenedores previos (si existen)..." -ForegroundColor DarkGray
$containerNames = @("tfg_postgres", "tfg_pgadmin")
$existingContainers = docker ps -a --format "{{.Names}}" 2>$null

foreach ($containerName in $containerNames) {
    if ($existingContainers -contains $containerName) {
        docker rm -f $containerName 2>$null | Out-Null
    }
}

docker compose up -d postgres pgadmin
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Docker fallo. Asegurate de que Docker Desktop este abierto." -ForegroundColor Red
    Read-Host; exit 1
}

# ---- [2/5] Esperar PostgreSQL ----
Write-Host "[2/5] Esperando a que PostgreSQL este listo..." -ForegroundColor Cyan
$maxWait = 60
$waited = 0
do {
    Start-Sleep -Seconds 2
    $waited += 2
    $ready = docker exec tfg_postgres pg_isready -U tfg_user -d tfg_db 2>$null
    if ($waited -ge $maxWait) {
        Write-Host "[ERROR] PostgreSQL no respondio en $maxWait segundos." -ForegroundColor Red
        Read-Host; exit 1
    }
} while ($LASTEXITCODE -ne 0)
Write-Host "       PostgreSQL listo." -ForegroundColor Green

# ---- [3/5] Esquema SQL ----
Write-Host "[3/5] Aplicando esquema de base de datos..." -ForegroundColor Cyan
Get-Content "$root\backend\schema.sql" | docker exec -i tfg_postgres psql -U tfg_user -d tfg_db 2>&1 | Where-Object { $_ -notmatch '^NOTICE' }
Write-Host "       Esquema aplicado." -ForegroundColor Green

# ---- [4/5] Backend ----
Write-Host "[4/5] Iniciando Backend FastAPI..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$root\start-backend.ps1"

Start-Sleep -Seconds 3

# ---- [5/5] Flutter ----
Write-Host "[5/5] Iniciando Flutter en Chrome..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$root\start-flutter.ps1"

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Todos los servicios iniciados" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  PostgreSQL:  localhost:5433"
Write-Host "  pgAdmin:     http://localhost:5050"
Write-Host "  Backend:     http://localhost:8000"
Write-Host "  API Docs:    http://localhost:8000/docs"
Write-Host "  Flutter:     http://localhost:3000"
Write-Host ""
Write-Host "  Login: admin1@tfg.com / Test1234"
Write-Host ""
Write-Host "  Para detener: docker compose down" -ForegroundColor Yellow
Write-Host ""

if ($Verify) {
    Write-Host "[VERIFY] Ejecutando verificacion runtime..." -ForegroundColor Cyan
    $checkScript = Join-Path $root "check-runtime.ps1"
    if (Test-Path $checkScript) {
        powershell.exe -ExecutionPolicy Bypass -File $checkScript
    } else {
        Write-Host "[WARN] No se encontro check-runtime.ps1 en la raiz del proyecto." -ForegroundColor Yellow
    }
    Write-Host ""
}

Read-Host "Presiona Enter para salir"
