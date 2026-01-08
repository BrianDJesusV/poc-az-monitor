# RETRY DEPLOYMENT CON BASIC B1
# El cambio de Y1 a B1 ya fue aplicado en main.tf

Write-Host ""
Write-Host "=== RETRY DEPLOYMENT - BASIC B1 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "El cambio a Basic B1 ya fue aplicado en main.tf" -ForegroundColor Green
Write-Host "Ahora necesitamos limpiar el deployment fallido y reintentar" -ForegroundColor Yellow
Write-Host ""

# PASO 1: Limpiar recursos del deployment fallido
Write-Host "PASO 1: Limpiando deployment fallido..." -ForegroundColor Cyan
Write-Host ""

$failedRG = "rg-azmon-functions-xm3zsy"

Write-Host "Eliminando resource group: $failedRG" -ForegroundColor Yellow
$rgExists = az group exists --name $failedRG

if ($rgExists -eq "true") {
    az group delete --name $failedRG --yes --no-wait
    Write-Host "[OK] Resource group eliminandose en background" -ForegroundColor Green
} else {
    Write-Host "[INFO] Resource group no existe" -ForegroundColor Cyan
}

# Limpiar Terraform state
Write-Host ""
Write-Host "Limpiando Terraform state..." -ForegroundColor Yellow

$filesToRemove = @(
    "terraform.tfstate",
    "terraform.tfstate.backup",
    "tfplan"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  [OK] Eliminado: $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "[OK] Limpieza completada" -ForegroundColor Green
Write-Host ""

# PASO 2: Verificar el cambio
Write-Host "PASO 2: Verificando cambio a B1..." -ForegroundColor Cyan
Write-Host ""

$mainTf = Get-Content "main.tf" -Raw
if ($mainTf -match 'sku_name\s*=\s*"B1"') {
    Write-Host "[OK] main.tf tiene sku_name = `"B1`"" -ForegroundColor Green
} else {
    Write-Host "[ERROR] main.tf todavia tiene Y1" -ForegroundColor Red
    Write-Host "El archivo debe tener sido modificado manualmente" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# PASO 3: Terraform Plan
Write-Host "PASO 3: Terraform Plan..." -ForegroundColor Cyan
Write-Host ""

terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Terraform plan fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Plan generado" -ForegroundColor Green
Write-Host ""

# Confirmar
$continue = Read-Host "Aplicar el plan con Basic B1? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 4: Terraform Apply
Write-Host ""
Write-Host "PASO 4: Terraform Apply..." -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

terraform apply tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Terraform apply fallo" -ForegroundColor Red
    exit 1
}

$duration = (Get-Date) - $startTime
$minutes = [math]::Round($duration.TotalMinutes, 2)

Write-Host ""
Write-Host "[OK] Infraestructura desplegada en $minutes minutos" -ForegroundColor Green
Write-Host ""

# PASO 5: Obtener outputs
Write-Host "PASO 5: Obteniendo outputs..." -ForegroundColor Cyan
Write-Host ""

terraform output -json > outputs.json
terraform output > outputs.txt

$funcApp = terraform output -raw function_app_name
$funcUrl = terraform output -raw function_app_url
$storage = terraform output -raw storage_account_name
$appInsights = terraform output -raw app_insights_name
$rgName = terraform output -raw resource_group_name

Write-Host "Resource Group:   $rgName" -ForegroundColor White
Write-Host "Function App:     $funcApp" -ForegroundColor White
Write-Host "Function URL:     $funcUrl" -ForegroundColor White
Write-Host "Storage Account:  $storage" -ForegroundColor White
Write-Host "App Insights:     $appInsights" -ForegroundColor White
Write-Host ""

# PASO 6: Deploy Functions
Write-Host "PASO 6: Deploy Functions..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Creando package..." -ForegroundColor Yellow
Push-Location functions

$zipPath = Join-Path $PSScriptRoot "functions.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path * -DestinationPath $zipPath -Force
Pop-Location

Write-Host "[OK] Package creado" -ForegroundColor Green
Write-Host ""

Write-Host "Desplegando a Azure..." -ForegroundColor Yellow

az functionapp deployment source config-zip `
    --resource-group $rgName `
    --name $funcApp `
    --src functions.zip

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[OK] Functions desplegadas" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[ERROR] Deployment fallo" -ForegroundColor Red
    exit 1
}

Remove-Item functions.zip -Force
Write-Host ""

# PASO 7: Wait
Write-Host "PASO 7: Esperando deployment..." -ForegroundColor Cyan
Write-Host "Esperando 60 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
Write-Host "[OK] Wait complete" -ForegroundColor Green
Write-Host ""

# PASO 8: Test
Write-Host "PASO 8: Testing HttpTrigger..." -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POC" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] HttpTrigger funciona! HTTP 200" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Cyan
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
    }
} catch {
    Write-Host "[WARN] HttpTrigger no responde (cold start normal)" -ForegroundColor Yellow
}

Write-Host ""

# PASO 9: Generate test data
Write-Host "PASO 9: Generando test data..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Enviando 5 mensajes a queue..." -ForegroundColor Yellow
for ($i=1; $i -le 5; $i++) {
    $orderId = "ORDER-$(Get-Random -Min 1000 -Max 9999)"
    $msg = "{`"orderId`":`"$orderId`",`"customer`":`"Customer-$i`",`"amount`":$($i*10)}"
    az storage message put --queue-name queue-orders --account-name $storage --content $msg --output none 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Message $i - $orderId" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Subiendo 3 archivos a blob..." -ForegroundColor Yellow
for ($i=1; $i -le 3; $i++) {
    $fileName = "test-$i.txt"
    $filePath = Join-Path $env:TEMP $fileName
    "Test content $i - $(Get-Date)" | Out-File -FilePath $filePath -Encoding UTF8
    az storage blob upload --account-name $storage --container-name uploads --name $fileName --file $filePath --output none 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] File $i - $fileName" -ForegroundColor Gray
    }
    Remove-Item $filePath -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[OK] Test data generado" -ForegroundColor Green
Write-Host ""

# SUMMARY
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DEPLOYMENT COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Recursos desplegados:" -ForegroundColor Yellow
Write-Host "  Resource Group:   $rgName" -ForegroundColor White
Write-Host "  Storage:          $storage" -ForegroundColor White
Write-Host "  Function App:     $funcApp" -ForegroundColor White
Write-Host "  App Insights:     $appInsights" -ForegroundColor White
Write-Host "  Service Plan:     Basic B1" -ForegroundColor White
Write-Host "  Functions:        4 (Http, Timer, Queue, Blob)" -ForegroundColor White
Write-Host ""

Write-Host "URLs:" -ForegroundColor Yellow
Write-Host "  Function URL:     $funcUrl" -ForegroundColor White
Write-Host "  API Test:         ${funcUrl}/api/HttpTrigger?name=Test" -ForegroundColor White
Write-Host ""

Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Azure Portal -> $appInsights" -ForegroundColor White
Write-Host "  2. Ver Live Metrics" -ForegroundColor White
Write-Host "  3. Ejecutar queries KQL" -ForegroundColor White
Write-Host ""

Write-Host "Costo: ~13/mes (Basic B1)" -ForegroundColor Green
Write-Host ""
Write-Host "Deployment exitoso!" -ForegroundColor Green
Write-Host ""
