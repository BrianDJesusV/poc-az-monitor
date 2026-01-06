# Script para desplegar Flask App a Azure App Service
# Uso: .\deploy-flask.ps1

$ErrorActionPreference = "Stop"

# Variables
$ResourceGroup = "rg-azmon-poc-mexicocentral"
$AppName = "app-azmon-demo-ltr94a"
$AppPath = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\test-app"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🚀 DESPLEGANDO FLASK APP A AZURE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Configurar Application Insights Connection String
Write-Host "📋 Paso 1: Configurando Application Insights..." -ForegroundColor Yellow
$ConnectionString = wsl az monitor app-insights component show --app appi-azmon-appservice-ltr94a --resource-group $ResourceGroup --query connectionString -o tsv

wsl az webapp config appsettings set `
    --resource-group $ResourceGroup `
    --name $AppName `
    --settings `
        "APPLICATIONINSIGHTS_CONNECTION_STRING=$ConnectionString" `
        "SCM_DO_BUILD_DURING_DEPLOYMENT=true" `
        "ENABLE_ORYX_BUILD=true" `
        "DEMO_MODE=production" `
    --output none

Write-Host "✅ Application Insights configurado" -ForegroundColor Green

# Paso 2: Desplegar aplicación
Write-Host ""
Write-Host "📦 Paso 2: Desplegando aplicación..." -ForegroundColor Yellow

# Cambiar al directorio de la aplicación
Push-Location $AppPath

# Usar az webapp up para desplegar
wsl az webapp up `
    --resource-group $ResourceGroup `
    --name $AppName `
    --runtime "PYTHON:3.11" `
    --sku F1 `
    --plan asp-azmon-poc-ltr94a `
    --os-type Linux `
    --logs

Pop-Location

Write-Host "✅ Aplicación desplegada" -ForegroundColor Green

# Paso 3: Reiniciar app
Write-Host ""
Write-Host "🔄 Paso 3: Reiniciando aplicación..." -ForegroundColor Yellow
wsl az webapp restart --resource-group $ResourceGroup --name $AppName --output none
Start-Sleep -Seconds 10

Write-Host "✅ Aplicación reiniciada" -ForegroundColor Green

# Paso 4: Verificar deployment
Write-Host ""
Write-Host "🔍 Paso 4: Verificando deployment..." -ForegroundColor Yellow
$AppUrl = "https://$AppName.azurewebsites.net"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ DEPLOYMENT COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URL de la aplicación: $AppUrl" -ForegroundColor White
Write-Host "🏥 Health Check: $AppUrl/health" -ForegroundColor White
Write-Host ""
Write-Host "Esperando 30 segundos para que la app inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Probando endpoint de health..." -ForegroundColor Yellow
try {
    $Response = Invoke-WebRequest -Uri "$AppUrl/health" -UseBasicParsing -TimeoutSec 10
    Write-Host "✅ App respondiendo correctamente (Status: $($Response.StatusCode))" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Respuesta:" -ForegroundColor Cyan
    Write-Host $Response.Content
} catch {
    Write-Host "⚠️ La app aún no está lista o hay un error" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Ver logs con:" -ForegroundColor Yellow
    Write-Host "wsl az webapp log tail --resource-group $ResourceGroup --name $AppName" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Para ver logs en tiempo real:" -ForegroundColor Yellow
Write-Host "wsl az webapp log tail --resource-group $ResourceGroup --name $AppName" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
