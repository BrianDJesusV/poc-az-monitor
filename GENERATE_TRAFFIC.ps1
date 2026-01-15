# GENERADOR DE TRAFICO - POC Azure Monitor
# Genera trafico en todos los componentes para visualizar metricas

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GENERADOR DE TRAFICO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rgName = "rg-azmon-poc-mexicocentral"

# Obtener recursos
Write-Host "Obteniendo recursos desplegados..." -ForegroundColor Yellow
Write-Host ""

$appService = az webapp list --resource-group $rgName --query "[?contains(name, 'app-azmon')].name" -o tsv
$funcApp = az functionapp list --resource-group $rgName --query "[0].name" -o tsv
$storage = az storage account list --resource-group $rgName --query "[0].name" -o tsv

if (-not $appService) {
    Write-Host "[ERROR] App Service no encontrado" -ForegroundColor Red
    exit 1
}

if (-not $funcApp) {
    Write-Host "[ERROR] Function App no encontrado" -ForegroundColor Red
    exit 1
}

if (-not $storage) {
    Write-Host "[ERROR] Storage Account no encontrado" -ForegroundColor Red
    exit 1
}

$appUrl = "https://$appService.azurewebsites.net"
$funcUrl = "https://$funcApp.azurewebsites.net"

Write-Host "Recursos encontrados:" -ForegroundColor Green
Write-Host "  App Service:  $appService" -ForegroundColor White
Write-Host "  Function App: $funcApp" -ForegroundColor White
Write-Host "  Storage:      $storage" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GENERANDO TRAFICO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ===================================
# 1. APP SERVICE - Escenario 1
# ===================================

Write-Host "1. APP SERVICE - Generando requests HTTP..." -ForegroundColor Cyan
Write-Host ""

$endpoints = @(
    "/",
    "/health",
    "/api/data",
    "/metrics"
)

$successCount = 0
$errorCount = 0

for ($i = 1; $i -le 20; $i++) {
    $endpoint = $endpoints[$i % $endpoints.Count]
    $url = "$appUrl$endpoint"
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "  [$i/20] $endpoint - HTTP $($response.StatusCode)" -ForegroundColor Gray
        $successCount++
    } catch {
        Write-Host "  [$i/20] $endpoint - ERROR" -ForegroundColor Yellow
        $errorCount++
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "[OK] App Service: $successCount exitosos, $errorCount errores" -ForegroundColor Green
Write-Host ""

# ===================================
# 2. AZURE FUNCTIONS - HttpTrigger
# ===================================

Write-Host "2. FUNCTION APP - HttpTrigger..." -ForegroundColor Cyan
Write-Host ""

$names = @("Test", "POC", "Azure", "Monitor", "Demo", "User", "Client", "API", "Service", "Cloud")

$funcSuccess = 0
$funcError = 0

for ($i = 1; $i -le 15; $i++) {
    $name = $names[$i % $names.Count]
    $url = "$funcUrl/api/HttpTrigger?name=$name"
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "  [$i/15] HttpTrigger?name=$name - HTTP $($response.StatusCode)" -ForegroundColor Gray
        $funcSuccess++
    } catch {
        Write-Host "  [$i/15] HttpTrigger?name=$name - ERROR" -ForegroundColor Yellow
        $funcError++
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "[OK] HttpTrigger: $funcSuccess exitosos, $funcError errores" -ForegroundColor Green
Write-Host ""

# ===================================
# 3. QUEUE TRIGGER - Mensajes
# ===================================

Write-Host "3. QUEUE TRIGGER - Enviando mensajes..." -ForegroundColor Cyan
Write-Host ""

$queueMessages = 0

for ($i = 1; $i -le 10; $i++) {
    $orderId = "ORDER-$(Get-Random -Min 1000 -Max 9999)"
    $customer = "Customer-$i"
    $amount = (Get-Random -Min 10 -Max 1000)
    
    $message = @{
        orderId = $orderId
        customer = $customer
        amount = $amount
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    } | ConvertTo-Json -Compress
    
    az storage message put `
        --queue-name queue-orders `
        --account-name $storage `
        --content $message `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [$i/10] $orderId - Amount: `$$amount" -ForegroundColor Gray
        $queueMessages++
    } else {
        Write-Host "  [$i/10] $orderId - ERROR" -ForegroundColor Yellow
    }
    
    Start-Sleep -Milliseconds 300
}

Write-Host ""
Write-Host "[OK] Queue: $queueMessages mensajes enviados" -ForegroundColor Green
Write-Host ""

# ===================================
# 4. BLOB TRIGGER - Archivos
# ===================================

Write-Host "4. BLOB TRIGGER - Subiendo archivos..." -ForegroundColor Cyan
Write-Host ""

$blobFiles = 0

for ($i = 1; $i -le 8; $i++) {
    $fileName = "traffic-test-$i-$(Get-Date -Format 'HHmmss').txt"
    $filePath = Join-Path $env:TEMP $fileName
    
    # Crear contenido
    $content = @"
Traffic Generation Test File
----------------------------
File Number: $i
Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Random Data: $(Get-Random -Min 10000 -Max 99999)

This file was generated automatically to trigger
the BlobTrigger Azure Function for monitoring purposes.
"@
    
    $content | Out-File -FilePath $filePath -Encoding UTF8
    
    az storage blob upload `
        --account-name $storage `
        --container-name uploads `
        --name $fileName `
        --file $filePath `
        --overwrite `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [$i/8] $fileName - Uploaded" -ForegroundColor Gray
        $blobFiles++
    } else {
        Write-Host "  [$i/8] $fileName - ERROR" -ForegroundColor Yellow
    }
    
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "[OK] Blob: $blobFiles archivos subidos" -ForegroundColor Green
Write-Host ""

# ===================================
# 5. GENERAR MAS TRAFICO (Bucle continuo)
# ===================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TRAFICO ADICIONAL (30 segundos)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date
$duration = 30
$additionalRequests = 0

Write-Host "Generando trafico continuo por $duration segundos..." -ForegroundColor Yellow
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Gray
Write-Host ""

while (((Get-Date) - $startTime).TotalSeconds -lt $duration) {
    # Request a App Service
    try {
        Invoke-WebRequest -Uri $appUrl -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop | Out-Null
        $additionalRequests++
    } catch { }
    
    # Request a Function
    try {
        Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=Continuous" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop | Out-Null
        $additionalRequests++
    } catch { }
    
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
    Write-Host "`r  Tiempo: $elapsed/$duration seg | Requests: $additionalRequests" -NoNewline -ForegroundColor Cyan
    
    Start-Sleep -Milliseconds 1000
}

Write-Host ""
Write-Host ""
Write-Host "[OK] Trafico adicional: $additionalRequests requests" -ForegroundColor Green
Write-Host ""

# ===================================
# RESUMEN
# ===================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE TRAFICO GENERADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalRequests = $successCount + $funcSuccess + $additionalRequests
$totalMessages = $queueMessages
$totalBlobs = $blobFiles

Write-Host "HTTP Requests:" -ForegroundColor Yellow
Write-Host "  App Service:       $successCount requests" -ForegroundColor White
Write-Host "  Function HTTP:     $funcSuccess requests" -ForegroundColor White
Write-Host "  Trafico continuo:  $additionalRequests requests" -ForegroundColor White
Write-Host "  ────────────────────────────────" -ForegroundColor Gray
Write-Host "  Total HTTP:        $totalRequests requests" -ForegroundColor Cyan
Write-Host ""

Write-Host "Event-Driven:" -ForegroundColor Yellow
Write-Host "  Queue messages:    $totalMessages mensajes" -ForegroundColor White
Write-Host "  Blob uploads:      $totalBlobs archivos" -ForegroundColor White
Write-Host "  Timer (automatico) En background" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VER METRICAS AHORA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. AZURE PORTAL:" -ForegroundColor Cyan
Write-Host "   https://portal.azure.com" -ForegroundColor White
Write-Host ""

Write-Host "2. APPLICATION INSIGHTS - Live Metrics:" -ForegroundColor Cyan
Write-Host "   Portal -> Application Insights -> Live Metrics" -ForegroundColor White
Write-Host "   Veras las requests en tiempo real" -ForegroundColor Gray
Write-Host ""

Write-Host "3. APPLICATION INSIGHTS - Logs (KQL):" -ForegroundColor Cyan
Write-Host "   Portal -> Application Insights -> Logs" -ForegroundColor White
Write-Host ""
Write-Host "   Queries de ejemplo:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   // Ver todos los requests HTTP" -ForegroundColor Gray
Write-Host "   requests" -ForegroundColor White
Write-Host "   | where timestamp > ago(10m)" -ForegroundColor White
Write-Host "   | summarize count() by name" -ForegroundColor White
Write-Host ""
Write-Host "   // Ver execuciones de Functions" -ForegroundColor Gray
Write-Host "   traces" -ForegroundColor White
Write-Host "   | where timestamp > ago(10m)" -ForegroundColor White
Write-Host "   | where message contains 'Function'" -ForegroundColor White
Write-Host ""

Write-Host "4. LOG ANALYTICS:" -ForegroundColor Cyan
Write-Host "   Portal -> Log Analytics Workspace -> Logs" -ForegroundColor White
Write-Host ""

Write-Host "[OK] Trafico generado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Nota: Las metricas pueden tomar 1-2 minutos en aparecer" -ForegroundColor Yellow
Write-Host ""
