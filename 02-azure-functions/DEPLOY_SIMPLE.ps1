# ESCENARIO 2 - DEPLOYMENT SCRIPT (Sin caracteres especiales)
# Ejecutar en PowerShell como Administrador

Write-Host "=== ESCENARIO 2: AZURE FUNCTIONS DEPLOYMENT ===" -ForegroundColor Cyan
Write-Host ""

# Variables
$BaseDir = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor"
$Scenario2Dir = "$BaseDir\02-azure-functions"
$Scenario0Dir = "$BaseDir\00-shared-infrastructure"

# PASO 1: PRE-CHECKS
Write-Host "PASO 1: Verificaciones previas..." -ForegroundColor Yellow
Write-Host ""

Set-Location $Scenario2Dir
Write-Host "[OK] Directorio: $(Get-Location)" -ForegroundColor Green

# Verificar Terraform
try {
    $tfVersion = terraform version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Terraform instalado" -ForegroundColor Green
    } else {
        throw "Terraform no encontrado"
    }
} catch {
    Write-Host "[ERROR] Terraform no encontrado" -ForegroundColor Red
    Write-Host "  Instala desde: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Verificar Azure CLI
try {
    $azVersion = az version --query '\"azure-cli\"' -o tsv 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Azure CLI instalado" -ForegroundColor Green
    } else {
        throw "Azure CLI no encontrado"
    }
} catch {
    Write-Host "[ERROR] Azure CLI no encontrado" -ForegroundColor Red
    Write-Host "  Instala desde: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Verificar Azure login
try {
    $account = az account show --query name -o tsv 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Azure autenticado: $account" -ForegroundColor Green
    } else {
        throw "No autenticado"
    }
} catch {
    Write-Host "[ERROR] No autenticado en Azure" -ForegroundColor Red
    Write-Host "  Ejecuta: az login" -ForegroundColor Yellow
    exit 1
}

# Verificar Scenario 0
Write-Host ""
Write-Host "Verificando Escenario 0..." -ForegroundColor Yellow
Push-Location $Scenario0Dir

try {
    $lawName = terraform output -raw law_name 2>$null
    if ($lawName) {
        Write-Host "[OK] Escenario 0 desplegado: $lawName" -ForegroundColor Green
    } else {
        throw "Escenario 0 no desplegado"
    }
} catch {
    Write-Host "[ERROR] Escenario 0 no esta desplegado" -ForegroundColor Red
    Write-Host "  Despliega Escenario 0 primero" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

Pop-Location
Write-Host ""

# PASO 2: TERRAFORM INIT
Write-Host "PASO 2: Terraform Init..." -ForegroundColor Yellow
Write-Host ""

Set-Location $Scenario2Dir

terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Terraform inicializado" -ForegroundColor Green
Write-Host ""

# PASO 3: TERRAFORM PLAN
Write-Host "PASO 3: Terraform Plan..." -ForegroundColor Yellow
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

# Preguntar si continuar
$continue = Read-Host "Continuar con deployment? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Deployment cancelado" -ForegroundColor Yellow
    exit 0
}

# PASO 4: TERRAFORM APPLY
Write-Host ""
Write-Host "PASO 4: Terraform Apply..." -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

terraform apply tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Terraform apply fallo" -ForegroundColor Red
    exit 1
}

$duration = (Get-Date) - $startTime
Write-Host ""
Write-Host "[OK] Infraestructura desplegada en $([math]::Round($duration.TotalMinutes, 2)) minutos" -ForegroundColor Green
Write-Host ""

# Guardar outputs
Write-Host "Guardando outputs..." -ForegroundColor Yellow
terraform output -json > outputs.json
terraform output > outputs.txt

# Obtener outputs
$functionAppName = terraform output -raw function_app_name
$functionAppUrl = terraform output -raw function_app_url
$storageAccount = terraform output -raw storage_account_name
$appInsights = terraform output -raw app_insights_name

Write-Host ""
Write-Host "=== RECURSOS CREADOS ===" -ForegroundColor Cyan
Write-Host "Function App:     $functionAppName" -ForegroundColor White
Write-Host "Function URL:     $functionAppUrl" -ForegroundColor White
Write-Host "Storage Account:  $storageAccount" -ForegroundColor White
Write-Host "App Insights:     $appInsights" -ForegroundColor White
Write-Host ""

# PASO 5: DEPLOY FUNCTIONS
Write-Host "PASO 5: Deploy Functions..." -ForegroundColor Yellow
Write-Host ""

# Crear ZIP
Write-Host "Creando package..." -ForegroundColor Yellow
Push-Location functions

$zipPath = Join-Path $Scenario2Dir "functions.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path * -DestinationPath $zipPath -Force
Pop-Location

Write-Host "[OK] Package creado" -ForegroundColor Green
Write-Host ""

# Deploy
Write-Host "Desplegando a Azure..." -ForegroundColor Yellow
$resourceGroup = "rg-azmon-poc-mexicocentral"

az functionapp deployment source config-zip `
    --resource-group $resourceGroup `
    --name $functionAppName `
    --src functions.zip

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Function deployment fallo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Functions desplegadas" -ForegroundColor Green
Write-Host ""

# Cleanup
Remove-Item functions.zip -Force

# PASO 6: WAIT
Write-Host "PASO 6: Esperando deployment..." -ForegroundColor Yellow
Write-Host "Esperando 60 segundos..." -ForegroundColor Gray
Start-Sleep -Seconds 60
Write-Host "[OK] Wait complete" -ForegroundColor Green
Write-Host ""

# PASO 7: VERIFY FUNCTIONS
Write-Host "PASO 7: Verificando functions..." -ForegroundColor Yellow
Write-Host ""

$functions = az functionapp function list `
    --name $functionAppName `
    --resource-group $resourceGroup `
    --query "[].{Name:name}" `
    -o table

Write-Host $functions
Write-Host ""

# PASO 8: TEST HTTPTRIGGER
Write-Host "PASO 8: Testing HttpTrigger..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "$functionAppUrl/api/HttpTrigger?name=POC" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] HttpTrigger funciona!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Cyan
        Write-Host $response.Content -ForegroundColor White
    } else {
        Write-Host "[WARN] HttpTrigger returned: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[WARN] HttpTrigger no responde aun (cold start normal)" -ForegroundColor Yellow
}

Write-Host ""

# PASO 9: GENERATE TEST DATA
Write-Host "PASO 9: Generando test data..." -ForegroundColor Yellow
Write-Host ""

# Queue messages
Write-Host "Enviando 5 mensajes a queue..." -ForegroundColor Gray
for ($i = 1; $i -le 5; $i++) {
    $orderId = "ORDER-$(Get-Random -Minimum 1000 -Maximum 9999)"
    $message = "{`"orderId`":`"$orderId`",`"customer`":`"Customer-$i`",`"amount`":$(Get-Random -Minimum 10 -Maximum 500)}"
    
    az storage message put `
        --queue-name "queue-orders" `
        --account-name $storageAccount `
        --content $message `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Message $i sent: $orderId" -ForegroundColor Gray
    }
}

Write-Host ""

# Blob uploads
Write-Host "Subiendo 3 archivos..." -ForegroundColor Gray
$tempDir = $env:TEMP
for ($i = 1; $i -le 3; $i++) {
    $fileName = "test-$i.txt"
    $filePath = Join-Path $tempDir $fileName
    "Test content $i - $(Get-Date)" | Out-File -FilePath $filePath -Encoding UTF8
    
    az storage blob upload `
        --account-name $storageAccount `
        --container-name "uploads" `
        --name $fileName `
        --file $filePath `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] File $i uploaded: $fileName" -ForegroundColor Gray
    }
    
    Remove-Item $filePath -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[OK] Test data generado" -ForegroundColor Green
Write-Host ""

# PASO 10: SUMMARY
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DEPLOYMENT COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Recursos desplegados:" -ForegroundColor Yellow
Write-Host "  Storage Account:   $storageAccount" -ForegroundColor White
Write-Host "  Function App:      $functionAppName" -ForegroundColor White
Write-Host "  App Insights:      $appInsights" -ForegroundColor White
Write-Host "  Functions:         4 (HttpTrigger, TimerTrigger, QueueTrigger, BlobTrigger)" -ForegroundColor White
Write-Host ""

Write-Host "URLs:" -ForegroundColor Yellow
Write-Host "  Function App:      $functionAppUrl" -ForegroundColor White
Write-Host "  API Endpoint:      $functionAppUrl/api/HttpTrigger?name=Test" -ForegroundColor White
Write-Host ""

Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Azure Portal -> Application Insights -> $appInsights" -ForegroundColor White
Write-Host "  2. Ver Live Metrics" -ForegroundColor White
Write-Host "  3. Ejecutar: .\test_functions.ps1" -ForegroundColor White
Write-Host ""

Write-Host "Costo estimado: ~0.70/mes" -ForegroundColor Green
Write-Host ""

Write-Host "Deployment exitoso!" -ForegroundColor Green
Write-Host ""
