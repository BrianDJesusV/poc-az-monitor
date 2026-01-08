# RETRY con Standard S1 - Última esperanza de quota

Write-Host ""
Write-Host "=== RETRY CON STANDARD S1 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tu suscripcion NO tiene quota para:" -ForegroundColor Red
Write-Host "  X Consumption (Dynamic VMs): 0" -ForegroundColor Red
Write-Host "  X Basic (Basic VMs): 0" -ForegroundColor Red
Write-Host ""
Write-Host "Intentando con Standard S1..." -ForegroundColor Yellow
Write-Host "  - Costo: ~70/mes" -ForegroundColor White
Write-Host "  - Puede tener quota disponible" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continuar con Standard S1? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 1: Limpiar
Write-Host ""
Write-Host "PASO 1: Limpiando deployment fallido..." -ForegroundColor Cyan
Write-Host ""

$failedRG = "rg-azmon-functions-x2ytm6"

$rgExists = az group exists --name $failedRG
if ($rgExists -eq "true") {
    Write-Host "Eliminando $failedRG..." -ForegroundColor Yellow
    az group delete --name $failedRG --yes --no-wait
    Write-Host "[OK] Resource group eliminandose" -ForegroundColor Green
}

$filesToRemove = @("terraform.tfstate", "terraform.tfstate.backup", "tfplan")
foreach ($file in $filesToRemove) {
    if (Test-Path $file) { Remove-Item $file -Force }
}

Write-Host "[OK] Limpieza completada" -ForegroundColor Green
Write-Host ""

# PASO 2: Verificar cambio
Write-Host "PASO 2: Verificando S1..." -ForegroundColor Cyan
$mainTf = Get-Content "main.tf" -Raw
if ($mainTf -match 'sku_name\s*=\s*"S1"') {
    Write-Host "[OK] main.tf tiene sku_name = `"S1`"" -ForegroundColor Green
} else {
    Write-Host "[ERROR] main.tf no tiene S1" -ForegroundColor Red
    exit 1
}
Write-Host ""

# PASO 3: Plan
Write-Host "PASO 3: Terraform Plan..." -ForegroundColor Cyan
Write-Host ""

terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Plan fallo" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Plan generado" -ForegroundColor Green
Write-Host ""

$apply = Read-Host "Aplicar con Standard S1? (S/N)"
if ($apply -ne "S" -and $apply -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 4: Apply
Write-Host ""
Write-Host "PASO 4: Terraform Apply..." -ForegroundColor Cyan
Write-Host ""

terraform apply tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Apply fallo - tampoco hay quota para Standard" -ForegroundColor Red
    Write-Host ""
    Write-Host "Opciones restantes:" -ForegroundColor Yellow
    Write-Host "  1. Intentar con Windows: .\try_windows_s1.ps1" -ForegroundColor White
    Write-Host "  2. Usar App Service existente: .\use_existing_appservice.ps1" -ForegroundColor White
    Write-Host "  3. Solicitar quota en Azure Portal" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "[OK] Standard S1 funciono!" -ForegroundColor Green
Write-Host ""

# Continuar con deployment normal...
terraform output -json > outputs.json

$funcApp = terraform output -raw function_app_name
$funcUrl = terraform output -raw function_app_url
$storage = terraform output -raw storage_account_name
$rgName = terraform output -raw resource_group_name

Write-Host "Resource Group: $rgName" -ForegroundColor White
Write-Host "Function App:   $funcApp" -ForegroundColor White
Write-Host "URL:            $funcUrl" -ForegroundColor White
Write-Host ""

# Deploy functions...
Write-Host "Deploying functions..." -ForegroundColor Yellow
Push-Location functions
Compress-Archive -Path * -DestinationPath ..\functions.zip -Force
Pop-Location

az functionapp deployment source config-zip --resource-group $rgName --name $funcApp --src functions.zip

Remove-Item functions.zip -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DEPLOYMENT EXITOSO CON S1" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Function App: $funcApp" -ForegroundColor White
Write-Host "URL:          $funcUrl" -ForegroundColor White
Write-Host "Costo:        ~70/mes (Standard S1)" -ForegroundColor Yellow
Write-Host ""
