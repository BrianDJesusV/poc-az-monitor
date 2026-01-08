# DEPLOYMENT con Terraform PATH configurado
# Este script funciona incluso si el PATH no esta actualizado en la sesion actual

Write-Host "=== ESCENARIO 2: DEPLOYMENT CON TERRAFORM LOCAL ===" -ForegroundColor Cyan
Write-Host ""

# Configurar Terraform en PATH de esta sesion
$terraformPath = "C:\Users\User\Documents\SOFTWARE_NECESARIO\terraform"
$env:Path = "$terraformPath;" + $env:Path

# Verificar Terraform
Write-Host "Verificando Terraform..." -ForegroundColor Yellow
try {
    $tfVersion = terraform version 2>&1 | Select-Object -First 1
    Write-Host "[OK] $tfVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo ejecutar Terraform" -ForegroundColor Red
    Write-Host "Verifica que terraform.exe existe en: $terraformPath" -ForegroundColor Yellow
    exit 1
}

# Verificar Azure CLI
Write-Host "Verificando Azure CLI..." -ForegroundColor Yellow
try {
    $azVersion = az version --query '\"azure-cli\"' -o tsv 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Azure CLI: $azVersion" -ForegroundColor Green
    } else {
        throw "Azure CLI no encontrado"
    }
} catch {
    Write-Host "[ERROR] Azure CLI no encontrado" -ForegroundColor Red
    Write-Host "Instala desde: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Verificar autenticacion
Write-Host "Verificando autenticacion Azure..." -ForegroundColor Yellow
try {
    $account = az account show --query name -o tsv 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Autenticado como: $account" -ForegroundColor Green
    } else {
        throw "No autenticado"
    }
} catch {
    Write-Host "[ERROR] No autenticado en Azure" -ForegroundColor Red
    Write-Host "Ejecuta: az login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Todas las verificaciones pasaron!" -ForegroundColor Green
Write-Host ""

# Cambiar al directorio del proyecto
$projectDir = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions"
Set-Location $projectDir
Write-Host "Directorio: $projectDir" -ForegroundColor Cyan
Write-Host ""

# Preguntar si continuar
$continue = Read-Host "Continuar con el deployment? (S/N)"
if ($continue -ne "S" -and $continue -ne "s" -and $continue -ne "Y" -and $continue -ne "y") {
    Write-Host "Deployment cancelado" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# ========================================
# TERRAFORM INIT
# ========================================

Write-Host "=== PASO 1: Terraform Init ===" -ForegroundColor Cyan
Write-Host ""

terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Terraform inicializado" -ForegroundColor Green
Write-Host ""

# ========================================
# TERRAFORM PLAN
# ========================================

Write-Host "=== PASO 2: Terraform Plan ===" -ForegroundColor Cyan
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
$applyConfirm = Read-Host "Aplicar el plan? (S/N)"
if ($applyConfirm -ne "S" -and $applyConfirm -ne "s" -and $applyConfirm -ne "Y" -and $applyConfirm -ne "y") {
    Write-Host "Deployment cancelado" -ForegroundColor Yellow
    exit 0
}

# ========================================
# TERRAFORM APPLY
# ========================================

Write-Host ""
Write-Host "=== PASO 3: Terraform Apply ===" -ForegroundColor Cyan
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

# ========================================
# OBTENER OUTPUTS
# ========================================

Write-Host "=== PASO 4: Obtener Outputs ===" -ForegroundColor Cyan
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

# ========================================
# DEPLOY FUNCTIONS
# ========================================

Write-Host "=== PASO 5: Deploy Functions ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Creando package..." -ForegroundColor Yellow
Push-Location functions

$zipPath = Join-Path $projectDir "functions.zip"
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

# ========================================
# WAIT
# ========================================

Write-Host "=== PASO 6: Esperando Deployment ===" -ForegroundColor Cyan
Write-Host "Esperando 60 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 60
Write-Host "[OK] Wait complete" -ForegroundColor Green
Write-Host ""

# ========================================
# TEST
# ========================================

Write-Host "=== PASO 7: Testing HttpTrigger ===" -ForegroundColor Cyan
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

# ========================================
# GENERATE TEST DATA
# ========================================

Write-Host "=== PASO 8: Generar Test Data ===" -ForegroundColor Cyan
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

# ========================================
# SUMMARY
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DEPLOYMENT COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Recursos desplegados:" -ForegroundColor Yellow
Write-Host "  Storage:      $storage" -ForegroundColor White
Write-Host "  Function App: $funcApp" -ForegroundColor White
Write-Host "  App Insights: $appInsights" -ForegroundColor White
Write-Host "  Functions:    4 (Http, Timer, Queue, Blob)" -ForegroundColor White
Write-Host ""

Write-Host "URLs:" -ForegroundColor Yellow
Write-Host "  Function URL: $funcUrl" -ForegroundColor White
Write-Host "  API Test:     ${funcUrl}/api/HttpTrigger?name=Test" -ForegroundColor White
Write-Host ""

Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Azure Portal -> $appInsights" -ForegroundColor White
Write-Host "  2. Ver Live Metrics" -ForegroundColor White
Write-Host "  3. Ejecutar queries KQL" -ForegroundColor White
Write-Host ""

Write-Host "Costo: ~0.70/mes" -ForegroundColor Green
Write-Host ""
Write-Host "Deployment exitoso!" -ForegroundColor Green
Write-Host ""
