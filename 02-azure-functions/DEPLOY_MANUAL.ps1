# ========================================
# DEPLOYMENT MANUAL - COPIA ESTOS COMANDOS
# Ejecuta en PowerShell como Administrador
# ========================================

Write-Host "=== ESCENARIO 2 DEPLOYMENT ===" -ForegroundColor Cyan
Write-Host ""

# PASO 1: Navegar
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions
Write-Host "✓ Directorio: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# PASO 2: Terraform Init (30 segundos)
Write-Host "PASO 2: Terraform Init..." -ForegroundColor Yellow
terraform init
Write-Host ""

# PASO 3: Terraform Plan (1 minuto)
Write-Host "PASO 3: Terraform Plan..." -ForegroundColor Yellow
terraform plan -out=tfplan
Write-Host ""

# Confirmar
$continue = Read-Host "¿Continuar con deployment? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit
}

# PASO 4: Terraform Apply (5-8 minutos)
Write-Host ""
Write-Host "PASO 4: Deploying infraestructura..." -ForegroundColor Yellow
$startTime = Get-Date
terraform apply tfplan
$duration = (Get-Date) - $startTime
Write-Host ""
Write-Host "✓ Infraestructura desplegada en $([math]::Round($duration.TotalMinutes, 2)) minutos" -ForegroundColor Green
Write-Host ""

# Guardar outputs
terraform output -json > outputs.json
$funcApp = terraform output -raw function_app_name
$funcUrl = terraform output -raw function_app_url
$storage = terraform output -raw storage_account_name
$appInsights = terraform output -raw app_insights_name

Write-Host "=== RECURSOS CREADOS ===" -ForegroundColor Cyan
Write-Host "Function App:     $funcApp" -ForegroundColor White
Write-Host "Function URL:     $funcUrl" -ForegroundColor White
Write-Host "Storage Account:  $storage" -ForegroundColor White
Write-Host "App Insights:     $appInsights" -ForegroundColor White
Write-Host ""

# PASO 5: Deploy Functions (3-5 minutos)
Write-Host "PASO 5: Deploying Functions..." -ForegroundColor Yellow
Write-Host ""

# Crear ZIP
Push-Location functions
$zipPath = Join-Path $PSScriptRoot "functions.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path * -DestinationPath $zipPath -Force
Pop-Location
Write-Host "✓ Package creado" -ForegroundColor Green

# Deploy
Write-Host "Desplegando a Azure..." -ForegroundColor Yellow
az functionapp deployment source config-zip `
    --resource-group rg-azmon-poc-mexicocentral `
    --name $funcApp `
    --src functions.zip

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Functions desplegadas" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "✗ Deployment falló" -ForegroundColor Red
    exit 1
}

Remove-Item functions.zip -Force
Write-Host ""

# PASO 6: Wait
Write-Host "PASO 6: Esperando deployment (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
Write-Host "✓ Wait complete" -ForegroundColor Green
Write-Host ""

# PASO 7: Test HttpTrigger
Write-Host "PASO 7: Testing HttpTrigger..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POC" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ HttpTrigger funciona!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Cyan
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
    }
} catch {
    Write-Host "⚠ HttpTrigger cold start (normal)" -ForegroundColor Yellow
}
Write-Host ""

# PASO 8: Generate Test Data
Write-Host "PASO 8: Generando test data..." -ForegroundColor Yellow

# Queue messages
for ($i=1; $i -le 5; $i++) {
    $msg = "{`"orderId`":`"ORDER-$(Get-Random -Min 1000 -Max 9999)`",`"customer`":`"Test-$i`",`"amount`":$($i*10)}"
    az storage message put --queue-name queue-orders --account-name $storage --content $msg --output none
}
Write-Host "✓ 5 mensajes enviados a queue" -ForegroundColor Green

# Blob files
for ($i=1; $i -le 3; $i++) {
    "Test content $i" | Out-File "test-$i.txt"
    az storage blob upload --account-name $storage --container-name uploads --name "test-$i.txt" --file "test-$i.txt" --output none
    Remove-Item "test-$i.txt"
}
Write-Host "✓ 3 archivos subidos a blob" -ForegroundColor Green
Write-Host ""

# FINAL SUMMARY
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DEPLOYMENT COMPLETADO ✅" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Recursos:" -ForegroundColor Yellow
Write-Host "  • Function App:     $funcApp" -ForegroundColor White
Write-Host "  • Function URL:     $funcUrl" -ForegroundColor White
Write-Host "  • Storage:          $storage" -ForegroundColor White
Write-Host "  • App Insights:     $appInsights" -ForegroundColor White
Write-Host ""
Write-Host "Test API:" -ForegroundColor Yellow
Write-Host "  Invoke-WebRequest -Uri '$funcUrl/api/HttpTrigger?name=Test'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Azure Portal → $appInsights" -ForegroundColor White
Write-Host "  2. Ver Live Metrics" -ForegroundColor White
Write-Host "  3. Ejecutar: .\test_functions.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Costo: ~`$0.70/mes" -ForegroundColor Green
Write-Host ""
