# ===========================================================================
# Script de Generación de Tráfico - Azure Monitor POC
# ===========================================================================
# 
# Este script genera tráfico HTTP variado hacia el App Service para generar
# métricas, logs y trazas en Application Insights.
#
# Uso:
#   .\generate-traffic.ps1 -AppUrl "https://your-app.azurewebsites.net"
#
# ===========================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$AppUrl,
    
    [Parameter(Mandatory=$false)]
    [int]$DurationMinutes = 5,
    
    [Parameter(Mandatory=$false)]
    [int]$RequestsPerMinute = 10
)

# Colores para output
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"
$ColorInfo = "Cyan"

# Banner
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host "  🚀 Generador de Tráfico - Azure Monitor POC" -ForegroundColor $ColorInfo
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host ""

# Si no se proporciona URL, intentar obtenerla del Terraform output
if (-not $AppUrl) {
    Write-Host "📍 Intentando obtener URL del App Service desde Terraform..." -ForegroundColor $ColorInfo
    try {
        $AppUrl = terraform output -raw app_service_url 2>$null
        if ($LASTEXITCODE -eq 0 -and $AppUrl) {
            Write-Host "✅ URL obtenida: $AppUrl" -ForegroundColor $ColorSuccess
        } else {
            throw "No se pudo obtener la URL"
        }
    } catch {
        Write-Host "❌ Error: No se pudo obtener la URL automáticamente" -ForegroundColor $ColorError
        Write-Host "Por favor proporciona la URL manualmente:" -ForegroundColor $ColorWarning
        Write-Host "  .\generate-traffic.ps1 -AppUrl 'https://your-app.azurewebsites.net'" -ForegroundColor $ColorWarning
        exit 1
    }
}

# Validar URL
if (-not $AppUrl.StartsWith("http")) {
    $AppUrl = "https://$AppUrl"
}

# Remover trailing slash
$AppUrl = $AppUrl.TrimEnd('/')

Write-Host ""
Write-Host "⚙️  Configuración:" -ForegroundColor $ColorInfo
Write-Host "   URL destino:          $AppUrl" -ForegroundColor White
Write-Host "   Duración:             $DurationMinutes minutos" -ForegroundColor White
Write-Host "   Requests por minuto:  $RequestsPerMinute" -ForegroundColor White
Write-Host ""

# Verificar conectividad
Write-Host "🔍 Verificando conectividad con el App Service..." -ForegroundColor $ColorInfo
try {
    $response = Invoke-WebRequest -Uri "$AppUrl/health" -Method GET -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ App Service está accesible y respondiendo" -ForegroundColor $ColorSuccess
    }
} catch {
    Write-Host "❌ Error: No se puede conectar al App Service" -ForegroundColor $ColorError
    Write-Host "   Detalles: $($_.Exception.Message)" -ForegroundColor $ColorError
    exit 1
}

Write-Host ""
Write-Host "🎯 Iniciando generación de tráfico..." -ForegroundColor $ColorInfo
Write-Host "   Presiona Ctrl+C para detener" -ForegroundColor $ColorWarning
Write-Host ""

# Estadísticas
$stats = @{
    Total = 0
    Success = 0
    Errors = 0
    Slow = 0
    NotFound = 0
}

# Endpoints disponibles con sus pesos (probabilidad)
$endpoints = @(
    @{ Path = "/"; Method = "GET"; Weight = 30; Type = "Home" }
    @{ Path = "/api/success"; Method = "GET"; Weight = 40; Type = "Success" }
    @{ Path = "/api/slow"; Method = "GET"; Weight = 10; Type = "Slow" }
    @{ Path = "/api/error"; Method = "GET"; Weight = 10; Type = "Error" }
    @{ Path = "/api/notfound"; Method = "GET"; Weight = 5; Type = "NotFound" }
    @{ Path = "/api/data"; Method = "POST"; Weight = 5; Type = "Data"; Body = @{ test = "data"; timestamp = (Get-Date).ToString("o") } }
)

# Calcular tiempo total y delay entre requests
$totalSeconds = $DurationMinutes * 60
$delaySeconds = 60 / $RequestsPerMinute
$endTime = (Get-Date).AddMinutes($DurationMinutes)

Write-Host "⏱️  Tiempo de ejecución: $DurationMinutes minutos" -ForegroundColor $ColorInfo
Write-Host "🔄 Delay entre requests: $([math]::Round($delaySeconds, 2)) segundos" -ForegroundColor $ColorInfo
Write-Host ""

# Función para seleccionar endpoint basado en peso
function Select-WeightedEndpoint {
    $totalWeight = ($endpoints | Measure-Object -Property Weight -Sum).Sum
    $random = Get-Random -Minimum 0 -Maximum $totalWeight
    
    $cumulative = 0
    foreach ($ep in $endpoints) {
        $cumulative += $ep.Weight
        if ($random -lt $cumulative) {
            return $ep
        }
    }
    return $endpoints[0]
}

# Loop principal
$requestNumber = 0
while ((Get-Date) -lt $endTime) {
    $requestNumber++
    $stats.Total++
    
    # Seleccionar endpoint aleatoriamente según peso
    $endpoint = Select-WeightedEndpoint
    $url = "$AppUrl$($endpoint.Path)"
    
    try {
        $requestStart = Get-Date
        
        # Realizar request
        if ($endpoint.Method -eq "POST" -and $endpoint.Body) {
            $body = $endpoint.Body | ConvertTo-Json
            $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $endpoint.Method -UseBasicParsing -TimeoutSec 30
        }
        
        $duration = ((Get-Date) - $requestStart).TotalMilliseconds
        
        # Actualizar estadísticas según tipo
        switch ($endpoint.Type) {
            "Success" { $stats.Success++; $color = $ColorSuccess }
            "Slow" { $stats.Slow++; $color = $ColorWarning }
            "Home" { $stats.Success++; $color = $ColorSuccess }
            "Data" { $stats.Success++; $color = $ColorSuccess }
            default { $color = $ColorInfo }
        }
        
        Write-Host ("[$requestNumber] ✓ {0,-12} {1,-25} | {2}ms | HTTP {3}" -f $endpoint.Type, $endpoint.Path, [int]$duration, $response.StatusCode) -ForegroundColor $color
        
    } catch {
        $errorCode = $_.Exception.Response.StatusCode.value__
        $stats.Errors++
        
        if ($errorCode -eq 404) {
            $stats.NotFound++
            $color = $ColorWarning
        } else {
            $color = $ColorError
        }
        
        Write-Host ("[$requestNumber] ✗ {0,-12} {1,-25} | HTTP {2} | {3}" -f $endpoint.Type, $endpoint.Path, $errorCode, $_.Exception.Message) -ForegroundColor $color
    }
    
    # Esperar antes del siguiente request
    Start-Sleep -Seconds $delaySeconds
}

# Resumen final
Write-Host ""
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host "  📊 RESUMEN DE TRÁFICO GENERADO" -ForegroundColor $ColorInfo
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host ""
Write-Host "Total de requests:    $($stats.Total)" -ForegroundColor White
Write-Host "  ✅ Exitosos:         $($stats.Success)" -ForegroundColor $ColorSuccess
Write-Host "  ⏱️  Lentos:           $($stats.Slow)" -ForegroundColor $ColorWarning
Write-Host "  ❌ Errores:          $($stats.Errors)" -ForegroundColor $ColorError
Write-Host "  🔍 Not Found:        $($stats.NotFound)" -ForegroundColor $ColorWarning
Write-Host ""

$successRate = if ($stats.Total -gt 0) { [math]::Round(($stats.Success / $stats.Total) * 100, 2) } else { 0 }
Write-Host "Tasa de éxito:        $successRate%" -ForegroundColor $(if ($successRate -gt 80) { $ColorSuccess } else { $ColorWarning })
Write-Host ""
Write-Host "🔍 Los datos deberían aparecer en Application Insights en 1-2 minutos" -ForegroundColor $ColorInfo
Write-Host ""
