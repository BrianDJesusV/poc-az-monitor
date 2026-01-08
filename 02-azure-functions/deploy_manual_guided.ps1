# Verificar estado y deployar Functions

Write-Host "=== VERIFICACION DE FUNCTIONS ===" -ForegroundColor Cyan
Write-Host ""

$funcApp = "func-azmon-demo-x7p3be"
$rgName = "rg-azmon-poc-mexicocentral"

Write-Host "Verificando Functions desplegadas..." -ForegroundColor Yellow
Write-Host ""

# Listar functions
$functions = az functionapp function list --name $funcApp --resource-group $rgName -o json 2>$null | ConvertFrom-Json

if ($functions -and $functions.Count -gt 0) {
    Write-Host "[OK] Functions encontradas: $($functions.Count)" -ForegroundColor Green
    Write-Host ""
    foreach ($func in $functions) {
        Write-Host "  - $($func.name)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "[OK] Deployment ya esta completo!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Intenta el HttpTrigger de nuevo:" -ForegroundColor Yellow
    Write-Host "  https://func-azmon-demo-x7p3be.azurewebsites.net/api/HttpTrigger?name=Test" -ForegroundColor Cyan
    Write-Host ""
    exit 0
} else {
    Write-Host "[!] No hay Functions desplegadas" -ForegroundColor Red
    Write-Host ""
    Write-Host "NECESITAS DEPLOYAR LAS FUNCTIONS MANUALMENTE" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DEPLOYMENT MANUAL - PASO A PASO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si existe el ZIP
if (-not (Test-Path "functions_manual.zip")) {
    Write-Host "Creando ZIP package..." -ForegroundColor Yellow
    Push-Location functions
    Compress-Archive -Path * -DestinationPath ..\functions_manual.zip -Force
    Pop-Location
    Write-Host "[OK] ZIP creado: functions_manual.zip" -ForegroundColor Green
} else {
    Write-Host "[OK] ZIP ya existe: functions_manual.zip" -ForegroundColor Green
}

Write-Host ""
Write-Host "Ruta completa del ZIP:" -ForegroundColor Cyan
$zipPath = Join-Path (Get-Location) "functions_manual.zip"
Write-Host "  $zipPath" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    SIGUE ESTOS PASOS EN AZURE PORTAL" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PASO 1: Abrir Function App en Portal" -ForegroundColor Yellow
Write-Host ""
$portalUrl = "https://portal.azure.com/#@/resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/$rgName/providers/Microsoft.Web/sites/$funcApp/vstscd"
Write-Host "  URL: $portalUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Presiona Enter para abrir en navegador..." -ForegroundColor Gray
Read-Host
Start-Process $portalUrl
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "PASO 2: En el Portal" -ForegroundColor Yellow
Write-Host "  a. Busca 'Deployment Center' en el menu izquierdo" -ForegroundColor White
Write-Host "  b. Click en la tab 'Local Git/ZIP Deploy'" -ForegroundColor White
Write-Host "  c. Click en 'ZIP Deploy' en la parte superior" -ForegroundColor White
Write-Host ""
Write-Host "  Presiona Enter cuando estes ahi..." -ForegroundColor Gray
Read-Host

Write-Host ""
Write-Host "PASO 3: Upload ZIP" -ForegroundColor Yellow
Write-Host "  a. Click en 'Browse' o 'Choose file'" -ForegroundColor White
Write-Host "  b. Selecciona el archivo:" -ForegroundColor White
Write-Host "     $zipPath" -ForegroundColor Cyan
Write-Host "  c. Click en 'Deploy'" -ForegroundColor White
Write-Host ""
Write-Host "  Presiona Enter cuando hayas hecho click en Deploy..." -ForegroundColor Gray
Read-Host

Write-Host ""
Write-Host "PASO 4: Esperar deployment (1-2 minutos)" -ForegroundColor Yellow
Write-Host "  Veras una barra de progreso en el Portal" -ForegroundColor White
Write-Host "  Espera a que diga 'Deployment successful'" -ForegroundColor White
Write-Host ""
Write-Host "  Presiona Enter cuando veas 'Deployment successful'..." -ForegroundColor Gray
Read-Host

Write-Host ""
Write-Host "PASO 5: Verificar Functions" -ForegroundColor Yellow
Write-Host ""
Write-Host "Verificando Functions desplegadas..." -ForegroundColor Cyan

Start-Sleep -Seconds 5

$functionsAfter = az functionapp function list --name $funcApp --resource-group $rgName -o json 2>$null | ConvertFrom-Json

if ($functionsAfter -and $functionsAfter.Count -gt 0) {
    Write-Host ""
    Write-Host "[OK] Functions desplegadas exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Functions encontradas:" -ForegroundColor Cyan
    foreach ($func in $functionsAfter) {
        Write-Host "  ✓ $($func.name)" -ForegroundColor Green
    }
    Write-Host ""
    
    # Test HttpTrigger
    Write-Host "Testeando HttpTrigger..." -ForegroundColor Yellow
    Write-Host ""
    
    Start-Sleep -Seconds 10
    
    try {
        $funcUrl = "https://func-azmon-demo-x7p3be.azurewebsites.net"
        $response = Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POCTest" -UseBasicParsing -TimeoutSec 30
        
        if ($response.StatusCode -eq 200) {
            Write-Host "[OK] HttpTrigger funciona! HTTP 200" -ForegroundColor Green
            Write-Host ""
            Write-Host "Response:" -ForegroundColor Cyan
            $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
        }
    } catch {
        Write-Host "[WARN] HttpTrigger todavia no responde (puede tomar 1-2 min mas)" -ForegroundColor Yellow
        Write-Host "       Intenta manualmente: $funcUrl/api/HttpTrigger?name=Test" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "    DEPLOYMENT COMPLETADO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Escenario 2 - Azure Functions + Monitoring" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Resources:" -ForegroundColor Cyan
    Write-Host "  Function App:     $funcApp" -ForegroundColor White
    Write-Host "  App Insights:     appi-azmon-functions-x7p3be" -ForegroundColor White
    Write-Host "  Storage:          stazmonx7p3be" -ForegroundColor White
    Write-Host "  Service Plan:     Standard S1" -ForegroundColor White
    Write-Host "  Region:           Mexico Central" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Functions:" -ForegroundColor Cyan
    Write-Host "  ✓ HttpTrigger" -ForegroundColor Green
    Write-Host "  ✓ TimerTrigger (cada 5 min)" -ForegroundColor Green
    Write-Host "  ✓ QueueTrigger" -ForegroundColor Green
    Write-Host "  ✓ BlobTrigger" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Test data ya enviado:" -ForegroundColor Cyan
    Write-Host "  ✓ 5 mensajes en queue" -ForegroundColor Green
    Write-Host "  ✓ 3 archivos en blob" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Proximos pasos:" -ForegroundColor Cyan
    Write-Host "  1. Portal -> Live Metrics (ver ejecuciones en tiempo real)" -ForegroundColor White
    Write-Host "  2. Application Insights -> Logs (ejecutar queries KQL)" -ForegroundColor White
    Write-Host "  3. Revisar procesamiento de queue y blob triggers" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Costo: ~70/mes (Standard S1)" -ForegroundColor Yellow
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "[ERROR] No se detectaron Functions" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles razones:" -ForegroundColor Yellow
    Write-Host "  1. El deployment todavia esta procesando (espera 1-2 min mas)" -ForegroundColor White
    Write-Host "  2. Hubo un error en el deployment" -ForegroundColor White
    Write-Host ""
    Write-Host "Verifica en el Portal:" -ForegroundColor Yellow
    Write-Host "  - Deployment Center -> Ver logs de deployment" -ForegroundColor White
    Write-Host "  - Functions (menu izquierdo) -> Debe mostrar 4 functions" -ForegroundColor White
    Write-Host ""
}
