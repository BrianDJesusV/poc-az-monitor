# DEPLOYMENT FINAL - Azure CLI con timeout extendido

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT AZURE FUNCTIONS - CLI" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rgName = "rg-azmon-poc-mexicocentral"
$funcApp = "func-azmon-demo-m5snfk"
$zipFile = "functions-deploy.zip"

Write-Host "ZipDeployUI no disponible - usando Azure CLI" -ForegroundColor Yellow
Write-Host ""

Set-Location "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions"

Write-Host "Verificando archivo ZIP..." -ForegroundColor Yellow
if (Test-Path $zipFile) {
    $zipSize = (Get-Item $zipFile).Length / 1KB
    Write-Host "[OK] $zipFile encontrado ($([math]::Round($zipSize, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "[ERROR] $zipFile no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO DEPLOYMENT" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Resource Group: $rgName" -ForegroundColor White
Write-Host "Function App:   $funcApp" -ForegroundColor White
Write-Host "Archivo:        $zipFile" -ForegroundColor White
Write-Host "Timeout:        600 segundos (10 minutos)" -ForegroundColor White
Write-Host ""

Write-Host "IMPORTANTE: Este proceso puede tomar varios minutos" -ForegroundColor Yellow
Write-Host "            NO cierres esta ventana" -ForegroundColor Yellow
Write-Host ""

Write-Host "Iniciando deployment..." -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# Deployment con timeout extendido
az functionapp deployment source config-zip `
    --resource-group $rgName `
    --name $funcApp `
    --src $zipFile `
    --timeout 600 `
    --verbose

$exitCode = $LASTEXITCODE
$duration = (Get-Date) - $startTime
$durationStr = "{0:mm}:{0:ss}" -f $duration

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($exitCode -eq 0) {
    Write-Host "  DEPLOYMENT EXITOSO" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tiempo: $durationStr" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Verificando deployment..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    $funcUrl = "https://$funcApp.azurewebsites.net/api/HttpTrigger?name=Test"
    
    try {
        $response = Invoke-WebRequest -Uri $funcUrl -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        Write-Host ""
        Write-Host "[OK] HttpTrigger responde: HTTP $($response.StatusCode)" -ForegroundColor Green
        Write-Host "[OK] FUNCTIONS DESPLEGADAS CORRECTAMENTE" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  POC COMPLETO AL 100%" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Proximos pasos:" -ForegroundColor Cyan
        Write-Host "  1. .\GENERATE_TRAFFIC.ps1  (generar trafico)" -ForegroundColor White
        Write-Host "  2. Portal -> Application Insights -> Live Metrics" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host ""
        Write-Host "[!] HttpTrigger no responde aun" -ForegroundColor Yellow
        Write-Host "    Espera 1-2 minutos y ejecuta:" -ForegroundColor White
        Write-Host "    .\CHECK_STATUS.ps1" -ForegroundColor Cyan
        Write-Host ""
    }
    
} else {
    Write-Host "  DEPLOYMENT FALLO" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tiempo transcurrido: $durationStr" -ForegroundColor White
    Write-Host "Exit code: $exitCode" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles causas:" -ForegroundColor Yellow
    Write-Host "  1. Timeout de red (aun con 600 seg)" -ForegroundColor White
    Write-Host "  2. Problema con Function App runtime" -ForegroundColor White
    Write-Host "  3. Restricciones de SKU (S1 + Linux)" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternativa:" -ForegroundColor Cyan
    Write-Host "  Contactar soporte de Azure" -ForegroundColor White
    Write-Host "  O considerar cambiar a Premium plan" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
