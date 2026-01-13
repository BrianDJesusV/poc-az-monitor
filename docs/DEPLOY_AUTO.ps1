# DEPLOYMENT AUTOMATIZADO - Sin confirmaciones
# Autorizado explicitamente

$ErrorActionPreference = "Stop"
$baseDir = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor"

Write-Host "=== DEPLOYMENT AUTOMATIZADO ===" -ForegroundColor Cyan
Write-Host ""

# ESCENARIO 0
Set-Location "$baseDir\00-shared-infrastructure"
Write-Host "Escenario 0: Terraform init..." -ForegroundColor Yellow
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

$lawName = terraform output -raw law_name
$rgName = terraform output -raw resource_group_name
$env:POC_LAW_NAME = $lawName
$env:POC_RG_NAME = $rgName
Remove-Item tfplan -Force -ErrorAction SilentlyContinue

Write-Host "[OK] Escenario 0: $rgName" -ForegroundColor Green
Start-Sleep -Seconds 30

# ESCENARIO 1
Set-Location "$baseDir\01-app-service"
Write-Host "Escenario 1: Terraform init..." -ForegroundColor Yellow
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

$appName = terraform output -raw app_service_name
$appUrl = terraform output -raw app_service_url
Remove-Item tfplan -Force -ErrorAction SilentlyContinue

Write-Host "Desplegando codigo..." -ForegroundColor Yellow
Push-Location app
Compress-Archive -Path * -DestinationPath ..\app.zip -Force
Pop-Location
az webapp deployment source config-zip --resource-group $env:POC_RG_NAME --name $appName --src app.zip --timeout 300
Remove-Item app.zip -Force -ErrorAction SilentlyContinue

Write-Host "[OK] Escenario 1: $appUrl" -ForegroundColor Green
Start-Sleep -Seconds 30

# ESCENARIO 2
Set-Location "$baseDir\02-azure-functions"
Write-Host "Escenario 2: Terraform init..." -ForegroundColor Yellow
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

$funcApp = terraform output -raw function_app_name
$funcUrl = terraform output -raw function_app_url
Remove-Item tfplan -Force -ErrorAction SilentlyContinue

Write-Host "Creando ZIP..." -ForegroundColor Yellow
Push-Location functions
Compress-Archive -Path * -DestinationPath ..\functions_deploy.zip -Force
Pop-Location

Write-Host "[OK] Escenario 2 infra: $funcUrl" -ForegroundColor Green
Write-Host ""
Write-Host "DEPLOYMENT MANUAL:" -ForegroundColor Yellow
Write-Host "Portal -> $funcApp -> Deployment Center -> ZIP Deploy" -ForegroundColor White
Write-Host "Upload: functions_deploy.zip" -ForegroundColor White

$portalUrl = "https://portal.azure.com/#resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/$env:POC_RG_NAME/providers/Microsoft.Web/sites/$funcApp/vstscd"
Start-Process $portalUrl

Write-Host ""
Write-Host "=== DEPLOYMENT COMPLETO ===" -ForegroundColor Green
Write-Host "RG: $rgName" -ForegroundColor White
Write-Host "App: $appUrl" -ForegroundColor White
Write-Host "Functions: $funcUrl (manual pendiente)" -ForegroundColor White
