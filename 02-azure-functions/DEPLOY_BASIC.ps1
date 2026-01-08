# Deployment automatico con Basic B1
# Para suscripciones sin quota de Consumption Plan

Write-Host ""
Write-Host "=== DEPLOYMENT CON BASIC B1 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Este script hara:" -ForegroundColor Yellow
Write-Host "  1. Cambiar de Consumption (Y1) a Basic (B1)" -ForegroundColor White
Write-Host "  2. Limpiar recursos parciales" -ForegroundColor White
Write-Host "  3. Re-inicializar Terraform" -ForegroundColor White
Write-Host "  4. Ejecutar deployment completo" -ForegroundColor White
Write-Host ""

Write-Host "Basic B1:" -ForegroundColor Cyan
Write-Host "  - Costo: ~13/mes" -ForegroundColor White
Write-Host "  - Always-on (no cold starts)" -ForegroundColor White
Write-Host "  - NO requiere quota especial" -ForegroundColor Green
Write-Host "  - Funciona exactamente igual que Functions" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continuar? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 1: Switch to Basic
Write-Host ""
Write-Host "PASO 1: Cambiando a Basic B1..." -ForegroundColor Cyan
Write-Host ""

$mainTfPath = ".\main.tf"
$content = Get-Content $mainTfPath -Raw
$content = $content -replace 'sku_name\s*=\s*"Y1"', 'sku_name = "B1"'
$content | Set-Content $mainTfPath -NoNewline

Write-Host "[OK] Cambiado a Basic B1" -ForegroundColor Green
Write-Host ""

# PASO 2: Cleanup
Write-Host "PASO 2: Limpiando recursos parciales..." -ForegroundColor Cyan
Write-Host ""

# Limpiar RG del ultimo intento
$lastRG = "rg-azmon-functions-lvvw1w"
$rgExists = az group exists --name $lastRG
if ($rgExists -eq "true") {
    Write-Host "  Eliminando $lastRG..." -ForegroundColor Yellow
    az group delete --name $lastRG --yes --no-wait
    Write-Host "[OK] Resource group eliminandose" -ForegroundColor Green
}

# Limpiar Terraform state
$filesToRemove = @("terraform.tfstate", "terraform.tfstate.backup", "tfplan", ".terraform.lock.hcl")
foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force
    }
}

Write-Host "[OK] Cleanup completado" -ForegroundColor Green
Write-Host ""

# PASO 3: Terraform Init
Write-Host "PASO 3: Re-inicializando Terraform..." -ForegroundColor Cyan
Write-Host ""

terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Terraform inicializado" -ForegroundColor Green
Write-Host ""

# Pausa antes de deployment
Write-Host "Presiona Enter para continuar con deployment..." -ForegroundColor Gray
Read-Host

# PASO 4: Deployment
Write-Host ""
Write-Host "PASO 4: Ejecutando deployment..." -ForegroundColor Cyan
Write-Host ""

.\DEPLOY_NOW.ps1
