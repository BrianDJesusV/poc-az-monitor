# DEPLOYMENT FINAL - Mexico Central + Shared RG + Standard S1

Write-Host ""
Write-Host "=== ESTRATEGIA FINAL ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Region:          Mexico Central (donde SI funciona)" -ForegroundColor Green
Write-Host "  Resource Group:  rg-azmon-poc-mexicocentral (compartido con Escenario 1)" -ForegroundColor Green
Write-Host "  Service Plan:    Standard S1 (~70/mes)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Razon: En Escenario 1 ya desplegaste B1 exitosamente en Mexico Central" -ForegroundColor White
Write-Host "       Ahora usamos el MISMO resource group donde sabemos que funciona" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continuar? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 1: Limpiar todos los deployments fallidos
Write-Host ""
Write-Host "PASO 1: Limpiando deployments fallidos..." -ForegroundColor Cyan
Write-Host ""

$failedRGs = @("rg-azmon-functions-lvvw1w", "rg-azmon-functions-xm3zsy", "rg-azmon-functions-x2ytm6")

foreach ($rg in $failedRGs) {
    $exists = az group exists --name $rg
    if ($exists -eq "true") {
        Write-Host "  Eliminando $rg..." -ForegroundColor Yellow
        az group delete --name $rg --yes --no-wait 2>$null
    }
}

# Limpiar state
$filesToRemove = @("terraform.tfstate", "terraform.tfstate.backup", "tfplan", ".terraform.lock.hcl")
foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  [OK] $file eliminado" -ForegroundColor Gray
    }
}

Write-Host "[OK] Limpieza completada" -ForegroundColor Green
Write-Host ""

# PASO 2: Verificar configuracion
Write-Host "PASO 2: Verificando configuracion..." -ForegroundColor Cyan
Write-Host ""

$tfvars = Get-Content "terraform.tfvars" -Raw
if ($tfvars -match 'location\s*=\s*"mexicocentral"') {
    Write-Host "  [OK] Region: Mexico Central" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Region incorrecta" -ForegroundColor Red
    exit 1
}

$mainTf = Get-Content "main.tf" -Raw
if ($mainTf -match 'data "azurerm_resource_group" "shared"') {
    Write-Host "  [OK] Usando resource group compartido" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] main.tf incorrecto" -ForegroundColor Red
    exit 1
}

if ($mainTf -match 'sku_name\s*=\s*"S1"') {
    Write-Host "  [OK] Service Plan: Standard S1" -ForegroundColor Green
} else {
    Write-Host "  [WARN] SKU no es S1" -ForegroundColor Yellow
}

Write-Host ""

# PASO 3: Terraform Init
Write-Host "PASO 3: Terraform Init..." -ForegroundColor Cyan
Write-Host ""

terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Init fallo" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Init exitoso" -ForegroundColor Green
Write-Host ""

# PASO 4: Terraform Plan
Write-Host "PASO 4: Terraform Plan..." -ForegroundColor Cyan
Write-Host ""

terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Plan fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Plan generado - Recursos a crear: 9" -ForegroundColor Green
Write-Host "  (NO crea resource group - usa el existente)" -ForegroundColor Cyan
Write-Host ""

$apply = Read-Host "Aplicar el plan? (S/N)"
if ($apply -ne "S" -and $apply -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 5: Terraform Apply
Write-Host ""
Write-Host "PASO 5: Terraform Apply..." -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date
terraform apply tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Apply fallo" -ForegroundColor Red
    Write-Host ""
    Write-Host "Si el error es de quota otra vez:" -ForegroundColor Yellow
    Write-Host "  - Tu suscripcion tiene limitaciones muy severas" -ForegroundColor White
    Write-Host "  - Opcion: Solicitar quota en Azure Portal" -ForegroundColor White
    Write-Host "  - O: Usar el App Service del Escenario 1" -ForegroundColor White
    Write-Host ""
    exit 1
}

$duration = (Get-Date) - $startTime
$minutes = [math]::Round($duration.TotalMinutes, 2)

Write-Host ""
Write-Host "[OK] Infraestructura desplegada en $minutes minutos" -ForegroundColor Green
Write-Host ""

# PASO 6: Obtener outputs
Write-Host "PASO 6: Obteniendo informacion..." -ForegroundColor Cyan
Write-Host ""

terraform output -json > outputs.json
terraform output > outputs.txt

$funcApp = terraform output -raw function_app_name
$funcUrl = terraform output -raw function_app_url
$storage = terraform output -raw storage_account_name
$appInsights = terraform output -raw app_insights_name

$rgName = "rg-azmon-poc-mexicocentral"

Write-Host "Resource Group:   $rgName (compartido)" -ForegroundColor White
Write-Host "Function App:     $funcApp" -ForegroundColor White
Write-Host "Function URL:     $funcUrl" -ForegroundColor White
Write-Host "Storage Account:  $storage" -ForegroundColor White
Write-Host "App Insights:     $appInsights" -ForegroundColor White
Write-Host ""

# PASO 7: Deploy Functions
Write-Host "PASO 7: Deploy Functions..." -ForegroundColor Cyan
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

# PASO 8: Wait
Write-Host "PASO 8: Esperando deployment..." -ForegroundColor Cyan
Write-Host "Esperando 60 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
Write-Host "[OK] Wait complete" -ForegroundColor Green
Write-Host ""

# PASO 9: Test
Write-Host "PASO 9: Testing HttpTrigger..." -ForegroundColor Cyan
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
    Write-Host "[WARN] HttpTrigger no responde todavia (normal)" -ForegroundColor Yellow
}

Write-Host ""

# PASO 10: Generate test data
Write-Host "PASO 10: Generando test data..." -ForegroundColor Cyan
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

Write-Host "Escenario 2 - Azure Functions + Serverless Monitoring" -ForegroundColor Yellow
Write-Host ""

Write-Host "Recursos desplegados:" -ForegroundColor Cyan
Write-Host "  Resource Group:   $rgName (compartido)" -ForegroundColor White
Write-Host "  Storage:          $storage" -ForegroundColor White
Write-Host "  Function App:     $funcApp" -ForegroundColor White
Write-Host "  App Insights:     $appInsights" -ForegroundColor White
Write-Host "  Service Plan:     Standard S1" -ForegroundColor White
Write-Host "  Functions:        4 (Http, Timer, Queue, Blob)" -ForegroundColor White
Write-Host "  Region:           Mexico Central" -ForegroundColor White
Write-Host ""

Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  Function URL:     $funcUrl" -ForegroundColor White
Write-Host "  API Test:         ${funcUrl}/api/HttpTrigger?name=Test" -ForegroundColor White
Write-Host ""

Write-Host "Monitoreo:" -ForegroundColor Cyan
Write-Host "  Application Insights: $appInsights" -ForegroundColor White
Write-Host "  Log Analytics:        law-azmon-poc-mexicocentral" -ForegroundColor White
Write-Host ""

Write-Host "Costo estimado:" -ForegroundColor Cyan
Write-Host "  Escenario 0: $0/mes (compartido)" -ForegroundColor White
Write-Host "  Escenario 1: $13/mes (App Service B1)" -ForegroundColor White
Write-Host "  Escenario 2: $70/mes (Functions S1)" -ForegroundColor White
Write-Host "  ────────────────────────────────" -ForegroundColor Gray
Write-Host "  TOTAL:       $83/mes" -ForegroundColor Yellow
Write-Host ""

Write-Host "Proximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Azure Portal -> $appInsights" -ForegroundColor White
Write-Host "  2. Ver Live Metrics" -ForegroundColor White
Write-Host "  3. Ejecutar queries KQL (ver QUERIES.md)" -ForegroundColor White
Write-Host "  4. Analizar telemetria" -ForegroundColor White
Write-Host ""

Write-Host "Deployment exitoso!" -ForegroundColor Green
Write-Host ""
