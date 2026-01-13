# DEPLOYMENT AUTOMATICO - POC Completo

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT POC AZURE MONITOR" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor"

# ===================================
# ESCENARIO 0: SHARED INFRASTRUCTURE
# ===================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ESCENARIO 0: SHARED INFRASTRUCTURE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scenario0Dir = Join-Path $baseDir "00-shared-infrastructure"
Set-Location $scenario0Dir

Write-Host "Terraform init..." -ForegroundColor Yellow
terraform init -upgrade
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Init fallo" -ForegroundColor Red; exit 1 }
Write-Host "[OK] Init completo" -ForegroundColor Green
Write-Host ""

Write-Host "Terraform apply..." -ForegroundColor Yellow
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Apply fallo" -ForegroundColor Red; exit 1 }

$lawName = terraform output -raw law_name 2>$null
$rgName = terraform output -raw resource_group_name 2>$null
$env:POC_LAW_NAME = $lawName
$env:POC_RG_NAME = $rgName

Write-Host ""
Write-Host "[OK] Escenario 0 desplegado" -ForegroundColor Green
Write-Host "  Resource Group: $rgName" -ForegroundColor White
Write-Host "  LAW Name:       $lawName" -ForegroundColor White
Write-Host ""

# ===================================
# ESCENARIO 1: APP SERVICE
# ===================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ESCENARIO 1: APP SERVICE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scenario1Dir = Join-Path $baseDir "01-app-service"
Set-Location $scenario1Dir

Write-Host "Terraform init..." -ForegroundColor Yellow
terraform init -upgrade
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Init fallo" -ForegroundColor Red; exit 1 }
Write-Host "[OK] Init completo" -ForegroundColor Green
Write-Host ""

Write-Host "Terraform apply..." -ForegroundColor Yellow
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Apply fallo" -ForegroundColor Red; exit 1 }

$appName = terraform output -raw app_service_name 2>$null
$appUrl = terraform output -raw app_service_url 2>$null

Write-Host ""
Write-Host "[OK] Escenario 1 desplegado" -ForegroundColor Green
Write-Host "  App Service: $appName" -ForegroundColor White
Write-Host "  URL:         $appUrl" -ForegroundColor White
Write-Host ""

Write-Host "Desplegando codigo..." -ForegroundColor Yellow
Push-Location app
Compress-Archive -Path * -DestinationPath ..\app-deploy.zip -Force
Pop-Location

az webapp deployment source config-zip `
    --resource-group $rgName `
    --name $appName `
    --src app-deploy.zip `
    --timeout 300

Remove-Item app-deploy.zip -Force -ErrorAction SilentlyContinue
Write-Host "[OK] Codigo desplegado" -ForegroundColor Green
Write-Host ""

# ===================================
# ESCENARIO 2: AZURE FUNCTIONS
# ===================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ESCENARIO 2: AZURE FUNCTIONS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scenario2Dir = Join-Path $baseDir "02-azure-functions"
Set-Location $scenario2Dir

Write-Host "Terraform init..." -ForegroundColor Yellow
terraform init -upgrade
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Init fallo" -ForegroundColor Red; exit 1 }
Write-Host "[OK] Init completo" -ForegroundColor Green
Write-Host ""

Write-Host "Terraform apply..." -ForegroundColor Yellow
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) { Write-Host "[ERROR] Apply fallo" -ForegroundColor Red; exit 1 }

$funcApp = terraform output -raw function_app_name 2>$null
$funcUrl = terraform output -raw function_app_url 2>$null
$storage = terraform output -raw storage_account_name 2>$null

Write-Host ""
Write-Host "[OK] Escenario 2 infraestructura desplegada" -ForegroundColor Green
Write-Host "  Function App: $funcApp" -ForegroundColor White
Write-Host "  URL:          $funcUrl" -ForegroundColor White
Write-Host "  Storage:      $storage" -ForegroundColor White
Write-Host ""

Write-Host "Desplegando Functions..." -ForegroundColor Yellow
Push-Location functions
Compress-Archive -Path * -DestinationPath ..\functions-deploy.zip -Force
Pop-Location

Write-Host "Intentando deployment via CLI..." -ForegroundColor Gray
az functionapp deployment source config-zip `
    --resource-group $rgName `
    --name $funcApp `
    --src functions-deploy.zip `
    --timeout 300 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Functions desplegadas via CLI" -ForegroundColor Green
    Remove-Item functions-deploy.zip -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "[!] CLI deployment fallo - usar Portal" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "DEPLOYMENT MANUAL:" -ForegroundColor Cyan
    Write-Host "  1. Portal: https://portal.azure.com" -ForegroundColor White
    Write-Host "  2. Buscar: $funcApp" -ForegroundColor White
    Write-Host "  3. Deployment Center -> ZIP Deploy" -ForegroundColor White
    Write-Host "  4. Upload: functions-deploy.zip" -ForegroundColor White
    Write-Host ""
    Write-Host "ZIP listo en: $scenario2Dir\functions-deploy.zip" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""

# ===================================
# RESUMEN FINAL
# ===================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT COMPLETO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Escenarios desplegados:" -ForegroundColor Yellow
Write-Host "  [OK] Escenario 0: Shared Infrastructure" -ForegroundColor Green
Write-Host "  [OK] Escenario 1: App Service + Monitoring" -ForegroundColor Green
Write-Host "  [OK] Escenario 2: Azure Functions + Monitoring" -ForegroundColor Green
Write-Host ""

Write-Host "Recursos creados:" -ForegroundColor Cyan
Write-Host "  Resource Group:   $rgName" -ForegroundColor White
Write-Host "  LAW:              $lawName" -ForegroundColor White
Write-Host "  App Service:      $appName" -ForegroundColor White
Write-Host "  Function App:     $funcApp" -ForegroundColor White
Write-Host "  Storage Account:  $storage" -ForegroundColor White
Write-Host ""

Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  App Service:  $appUrl" -ForegroundColor White
Write-Host "  Function App: $funcUrl" -ForegroundColor White
Write-Host ""

Write-Host "Costo estimado:" -ForegroundColor Cyan
Write-Host "  Escenario 0: $0/mes" -ForegroundColor White
Write-Host "  Escenario 1: ~$13/mes" -ForegroundColor White
Write-Host "  Escenario 2: ~$70/mes" -ForegroundColor White
Write-Host "  ────────────────────" -ForegroundColor Gray
Write-Host "  TOTAL:       ~$83/mes" -ForegroundColor Yellow
Write-Host ""

Write-Host "Proximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Portal -> Live Metrics" -ForegroundColor White
Write-Host "  2. Application Insights -> Logs (KQL queries)" -ForegroundColor White
Write-Host "  3. Generar trafico de prueba" -ForegroundColor White
Write-Host ""

Set-Location $baseDir
Write-Host "[OK] POC completo!" -ForegroundColor Green
Write-Host ""
