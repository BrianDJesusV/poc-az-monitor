# Traffic Generator Script
# Genera tráfico sintético a la aplicación para Application Insights

param(
    [string]$AppUrl = "https://app-azmon-demo-ltr94a.azurewebsites.net",
    [int]$TotalRequests = 100,
    [int]$IntervalMs = 500
)

Write-Host "=== GENERADOR DE TRAFICO ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL: $AppUrl" -ForegroundColor Yellow
Write-Host "Total Requests: $TotalRequests" -ForegroundColor Yellow
Write-Host "Intervalo: $IntervalMs ms" -ForegroundColor Yellow
Write-Host ""

# Endpoints a probar (ponderados)
$endpoints = @(
    "/",           # Página principal
    "/",           # Más peso a la principal
    "/health",     # Health check
    "/health",     # Más peso al health
    "/api/success", # Éxito (404 en versión simple)
    "/api/slow",   # Lento (404 en versión simple)
    "/api/error",  # Error (404 en versión simple)
    "/api/notfound" # Not found (404 en versión simple)
)

$count = 0
$success = 0
$errors = 0
$startTime = Get-Date

Write-Host "Iniciando generación de tráfico..." -ForegroundColor Green
Write-Host ""

while ($count -lt $TotalRequests) {
    # Seleccionar endpoint aleatorio
    $endpoint = $endpoints | Get-Random
    $fullUrl = "$AppUrl$endpoint"
    
    try {
        $response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        $count++
        $success++
        $statusCode = $response.StatusCode
        $elapsed = $response.ResponseTime
        
        Write-Host "[$count/$TotalRequests] GET $endpoint - $statusCode OK" -ForegroundColor Green
        
    } catch {
        $count++
        $errors++
        
        $statusCode = "ERR"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
        }
        
        Write-Host "[$count/$TotalRequests] GET $endpoint - $statusCode ERROR" -ForegroundColor Red
    }
    
    # Esperar antes del siguiente request
    Start-Sleep -Milliseconds $IntervalMs
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

# Resumen final
Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Total Requests: $count" -ForegroundColor White
Write-Host "Exitosos: $success ($([math]::Round($success/$count*100, 1))%)" -ForegroundColor Green
Write-Host "Errores: $errors ($([math]::Round($errors/$count*100, 1))%)" -ForegroundColor Red
Write-Host "Duracion: $([math]::Round($duration, 1)) segundos" -ForegroundColor White
Write-Host "Rate: $([math]::Round($count/$duration, 2)) req/s" -ForegroundColor White
Write-Host ""
Write-Host "Listo! Verifica Application Insights en Azure Portal" -ForegroundColor Green
