# Switch de Consumption (Y1) a Basic (B1)
# Basic B1 NO requiere quota especial

Write-Host "=== CAMBIO A BASIC B1 PLAN ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Razon del cambio:" -ForegroundColor Yellow
Write-Host "  - Tu suscripcion tiene 0 quota para Consumption Plan (Dynamic VMs)" -ForegroundColor Red
Write-Host "  - Basic B1 NO requiere quota especial" -ForegroundColor Green
Write-Host "  - Funciona exactamente igual que Functions" -ForegroundColor White
Write-Host ""

Write-Host "Diferencias:" -ForegroundColor Yellow
Write-Host "  Consumption (Y1)   ->   Basic (B1)" -ForegroundColor White
Write-Host "  ----------------        ----------" -ForegroundColor Gray
Write-Host "  Serverless              Always-on" -ForegroundColor White
Write-Host "  Cold starts             No cold starts" -ForegroundColor White
Write-Host "  ~0.70/mes              ~13/mes" -ForegroundColor White
Write-Host "  Requiere quota          No requiere quota" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continuar con el cambio a Basic B1? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Modificando main.tf..." -ForegroundColor Yellow

# Leer main.tf
$mainTfPath = ".\main.tf"
$content = Get-Content $mainTfPath -Raw

# Cambiar Y1 a B1
$content = $content -replace 'sku_name\s*=\s*"Y1"', 'sku_name = "B1"'

# Guardar
$content | Set-Content $mainTfPath -NoNewline

Write-Host "[OK] main.tf modificado" -ForegroundColor Green
Write-Host "     Cambio: sku_name = `"Y1`" -> sku_name = `"B1`"" -ForegroundColor Cyan
Write-Host ""

Write-Host "=== PROXIMOS PASOS ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Limpiar recursos parciales:" -ForegroundColor Yellow
Write-Host "   .\cleanup.ps1" -ForegroundColor White
Write-Host ""

Write-Host "2. Re-inicializar Terraform:" -ForegroundColor Yellow
Write-Host "   terraform init" -ForegroundColor White
Write-Host ""

Write-Host "3. Ejecutar deployment:" -ForegroundColor Yellow
Write-Host "   .\DEPLOY_NOW.ps1" -ForegroundColor White
Write-Host ""

Write-Host "O ejecutar todo automaticamente:" -ForegroundColor Yellow
Write-Host "   .\DEPLOY_BASIC.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "[OK] Listo para deployment con Basic B1" -ForegroundColor Green
Write-Host ""
