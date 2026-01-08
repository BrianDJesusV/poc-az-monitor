# SOLUCION ALTERNATIVA - Deployment Manual via Portal

Write-Host "=== DEPLOYMENT ALTERNATIVO - AZURE PORTAL ===" -ForegroundColor Cyan
Write-Host ""

$funcApp = "func-azmon-demo-x7p3be"
$rgName = "rg-azmon-poc-mexicocentral"

Write-Host "El ZIP deployment automatico fallo." -ForegroundColor Yellow
Write-Host "Vamos a deployar manualmente via Portal." -ForegroundColor Yellow
Write-Host ""

Write-Host "PASOS A SEGUIR:" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Crear el ZIP package:" -ForegroundColor Yellow
Write-Host ""

Push-Location functions

$zipPath = Join-Path $PSScriptRoot "functions_manual.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Write-Host "   Creando ZIP..." -ForegroundColor Gray
Compress-Archive -Path * -DestinationPath $zipPath -Force
Pop-Location

if (Test-Path "functions_manual.zip") {
    Write-Host "   [OK] ZIP creado: functions_manual.zip" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] No se pudo crear ZIP" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Abrir Azure Portal:" -ForegroundColor Yellow
Write-Host ""

$portalUrl = "https://portal.azure.com/#@/resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/$rgName/providers/Microsoft.Web/sites/$funcApp/deploymentCenter"

Write-Host "   URL: $portalUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Abriendo navegador..." -ForegroundColor Gray
Start-Process $portalUrl

Write-Host ""
Write-Host "3. En el Portal:" -ForegroundColor Yellow
Write-Host "   a. Click en 'Deployment Center'" -ForegroundColor White
Write-Host "   b. Tab: 'ZIP Deploy'" -ForegroundColor White
Write-Host "   c. Click 'Browse' y selecciona:" -ForegroundColor White
Write-Host "      $zipPath" -ForegroundColor Cyan
Write-Host "   d. Click 'Deploy'" -ForegroundColor White
Write-Host ""

Write-Host "4. Esperar deployment (1-2 minutos)" -ForegroundColor Yellow
Write-Host ""

Write-Host "5. Verificar Functions:" -ForegroundColor Yellow
Write-Host "   a. En Portal: $funcApp -> Functions" -ForegroundColor White
Write-Host "   b. Debes ver 4 functions:" -ForegroundColor White
Write-Host "      - HttpTrigger" -ForegroundColor Gray
Write-Host "      - TimerTrigger" -ForegroundColor Gray
Write-Host "      - QueueTrigger" -ForegroundColor Gray
Write-Host "      - BlobTrigger" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ZIP package listo: functions_manual.zip" -ForegroundColor Green
Write-Host "Portal abierto en navegador" -ForegroundColor Green
Write-Host ""
Write-Host "Sigue los pasos 3-5 en el Portal" -ForegroundColor Yellow
Write-Host ""

# Guardar info para testing posterior
Write-Host "Despues del deployment, ejecuta:" -ForegroundColor Cyan
Write-Host "  .\test_functions.ps1" -ForegroundColor White
Write-Host ""
