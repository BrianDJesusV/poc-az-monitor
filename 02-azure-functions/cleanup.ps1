# Cleanup de recursos parciales (ambos intentos)

Write-Host "=== LIMPIEZA DE RECURSOS PARCIALES ===" -ForegroundColor Cyan
Write-Host ""

# Limpiar recursos del primer intento (7wue34) en rg viejo
$oldRG = "rg-azmon-poc-mexicocentral"
$suffix1 = "7wue34"

Write-Host "Limpiando recursos con suffix $suffix1 en $oldRG..." -ForegroundColor Yellow
az storage account delete --name "stazmon$suffix1" --resource-group $oldRG --yes 2>$null
az monitor app-insights component delete --app "appi-azmon-functions-$suffix1" --resource-group $oldRG 2>$null

# Limpiar recursos del segundo intento (7f0gvv) en nuevo RG
$newRG = "rg-azmon-functions-7f0gvv"
$suffix2 = "7f0gvv"

Write-Host "Limpiando resource group $newRG..." -ForegroundColor Yellow
$rgExists = az group exists --name $newRG
if ($rgExists -eq "true") {
    Write-Host "  Eliminando resource group completo..." -ForegroundColor Gray
    az group delete --name $newRG --yes --no-wait
    Write-Host "[OK] Resource group eliminandose en background" -ForegroundColor Green
} else {
    Write-Host "[INFO] Resource group no existe" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== LIMPIEZA DE TERRAFORM ===" -ForegroundColor Cyan
Write-Host ""

# Limpiar archivos de Terraform
$filesToRemove = @(
    "terraform.tfstate",
    "terraform.tfstate.backup",
    "tfplan",
    ".terraform.lock.hcl"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "[OK] Eliminado: $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "[OK] Limpieza completada" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE: Region cambiada a EAST US" -ForegroundColor Yellow
Write-Host "  (Mexico Central no soporta Consumption Plan)" -ForegroundColor Gray
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. terraform init" -ForegroundColor White
Write-Host "  2. .\DEPLOY_NOW.ps1" -ForegroundColor White
Write-Host ""
