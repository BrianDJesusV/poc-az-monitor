# ⚡ EJECUTA ESTO - 3 COMANDOS

Write-Host ""
Write-Host "=== CAMBIO DE REGION: MEXICO CENTRAL -> EAST US ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Razon: Mexico Central NO soporta Consumption Plan" -ForegroundColor Yellow
Write-Host "Solucion: Usar East US (totalmente soportado)" -ForegroundColor Green
Write-Host ""
Write-Host "Presiona Enter para continuar..." -ForegroundColor Gray
Read-Host

# Paso 1: Cleanup
Write-Host ""
Write-Host "PASO 1: Limpiando recursos parciales..." -ForegroundColor Cyan
.\cleanup.ps1

Write-Host ""
Write-Host "Presiona Enter para continuar..." -ForegroundColor Gray
Read-Host

# Paso 2: Terraform Init
Write-Host ""
Write-Host "PASO 2: Re-inicializando Terraform..." -ForegroundColor Cyan
terraform init

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Terraform inicializado" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Presiona Enter para continuar con deployment..." -ForegroundColor Gray
Read-Host

# Paso 3: Deployment
Write-Host ""
Write-Host "PASO 3: Ejecutando deployment en East US..." -ForegroundColor Cyan
.\DEPLOY_NOW.ps1
