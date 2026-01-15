# Verificacion rapida del deployment

$funcUrl = "https://func-azmon-demo-m5snfk.azurewebsites.net/api/HttpTrigger?name=Test"

Write-Host ""
Write-Host "Probando HttpTrigger..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $funcUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "[OK] DEPLOYMENT EXITOSO" -ForegroundColor Green
    Write-Host "Response: HTTP $($response.StatusCode)" -ForegroundColor White
    Write-Host ""
    Write-Host "POC COMPLETO AL 100%" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 404) {
        Write-Host "[!] DEPLOYMENT PENDIENTE" -ForegroundColor Red
        Write-Host "HttpTrigger devuelve 404 - Functions NO desplegadas" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "SOLUCION:" -ForegroundColor Cyan
        Write-Host "Abre esta URL en tu navegador:" -ForegroundColor White
        Write-Host "https://func-azmon-demo-m5snfk.scm.azurewebsites.net/ZipDeployUI" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Y arrastra: functions-deploy.zip" -ForegroundColor White
    } else {
        Write-Host "[!] Error: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host ""
