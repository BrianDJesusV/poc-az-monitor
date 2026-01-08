# Test Functions despues del deployment manual

Write-Host "=== TESTING FUNCTIONS ===" -ForegroundColor Cyan
Write-Host ""

$funcApp = "func-azmon-demo-x7p3be"
$rgName = "rg-azmon-poc-mexicocentral"
$storage = "stazmonx7p3be"

# Obtener URL
$funcUrl = az functionapp show --name $funcApp --resource-group $rgName --query "defaultHostName" -o tsv
$funcUrl = "https://$funcUrl"

Write-Host "Function App: $funcApp" -ForegroundColor White
Write-Host "Function URL: $funcUrl" -ForegroundColor White
Write-Host ""

# Test HttpTrigger
Write-Host "1. Testing HttpTrigger..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POCTest" -UseBasicParsing -TimeoutSec 30
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] HttpTrigger funciona! HTTP 200" -ForegroundColor Green
        Write-Host ""
        Write-Host "   Response:" -ForegroundColor Cyan
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
    }
} catch {
    Write-Host "   [ERROR] HttpTrigger no responde" -ForegroundColor Red
    Write-Host "   Detalles: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""
Write-Host ""

# Generar test data
Write-Host "2. Generando test data..." -ForegroundColor Yellow
Write-Host ""

Write-Host "   Enviando 5 mensajes a queue..." -ForegroundColor Cyan
for ($i=1; $i -le 5; $i++) {
    $orderId = "ORDER-$(Get-Random -Min 1000 -Max 9999)"
    $msg = "{`"orderId`":`"$orderId`",`"customer`":`"Customer-$i`",`"amount`":$($i*10)}"
    
    az storage message put `
        --queue-name queue-orders `
        --account-name $storage `
        --content $msg `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Message $i - $orderId" -ForegroundColor Gray
    } else {
        Write-Host "   [ERROR] Message $i fallo" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "   Subiendo 3 archivos a blob..." -ForegroundColor Cyan
for ($i=1; $i -le 3; $i++) {
    $fileName = "test-file-$i.txt"
    $filePath = Join-Path $env:TEMP $fileName
    
    "Test content $i - Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $filePath -Encoding UTF8
    
    az storage blob upload `
        --account-name $storage `
        --container-name uploads `
        --name $fileName `
        --file $filePath `
        --overwrite `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] File $i - $fileName" -ForegroundColor Gray
    } else {
        Write-Host "   [ERROR] File $i fallo" -ForegroundColor Red
    }
    
    Remove-Item $filePath -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[OK] Test data generado" -ForegroundColor Green
Write-Host ""

# Resumen
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    VERIFICACION COMPLETA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Functions desplegadas:" -ForegroundColor Yellow
Write-Host "  - HttpTrigger: Testeado arriba" -ForegroundColor White
Write-Host "  - TimerTrigger: Se ejecuta cada 5 min" -ForegroundColor White
Write-Host "  - QueueTrigger: 5 mensajes enviados" -ForegroundColor White
Write-Host "  - BlobTrigger: 3 archivos subidos" -ForegroundColor White
Write-Host ""

Write-Host "Proximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Azure Portal -> $funcApp" -ForegroundColor White
Write-Host "  2. Monitor -> Live Metrics" -ForegroundColor White
Write-Host "  3. Application Insights -> Logs" -ForegroundColor White
Write-Host "  4. Ejecutar queries KQL (ver QUERIES.md)" -ForegroundColor White
Write-Host ""

Write-Host "URLs importantes:" -ForegroundColor Cyan
Write-Host "  Function App: https://portal.azure.com/#resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/$rgName/providers/Microsoft.Web/sites/$funcApp" -ForegroundColor Cyan
Write-Host "  API Test: ${funcUrl}/api/HttpTrigger?name=Test" -ForegroundColor Cyan
Write-Host ""
