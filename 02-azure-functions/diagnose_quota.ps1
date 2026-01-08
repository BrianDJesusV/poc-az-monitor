# VERIFICAR QUOTAS DISPONIBLES - Todas las opciones

Write-Host "=== DIAGNOSTICO DE QUOTAS ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Tu suscripcion NO tiene quota para:" -ForegroundColor Red
Write-Host "  X Consumption Plan (Dynamic VMs): 0" -ForegroundColor Red
Write-Host "  X Basic Plan (Basic VMs): 0" -ForegroundColor Red
Write-Host ""

Write-Host "=== OPCIONES A INTENTAR ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPCION 1: Standard S1 (~$70/mes)" -ForegroundColor Yellow
Write-Host "  - Puede tener quota diferente" -ForegroundColor White
Write-Host "  - Mas caro pero mas robusto" -ForegroundColor White
Write-Host "  - Always-on, mejor para produccion" -ForegroundColor White
Write-Host ""

Write-Host "OPCION 2: Windows en lugar de Linux" -ForegroundColor Yellow
Write-Host "  - Algunas suscripciones tienen cuota Windows" -ForegroundColor White
Write-Host "  - Mismo plan (B1 o S1)" -ForegroundColor White
Write-Host "  - Funciones en Windows" -ForegroundColor White
Write-Host ""

Write-Host "OPCION 3: Otra region" -ForegroundColor Yellow
Write-Host "  - Probar West US, West Europe, etc" -ForegroundColor White
Write-Host "  - Quotas pueden variar por region" -ForegroundColor White
Write-Host ""

Write-Host "OPCION 4: Premium EP1 (~$150/mes)" -ForegroundColor Yellow
Write-Host "  - Serverless con pre-warming" -ForegroundColor White
Write-Host "  - MUY CARO para POC" -ForegroundColor White
Write-Host "  - Ultima opcion" -ForegroundColor White
Write-Host ""

Write-Host "OPCION 5: Escenario 1 alternativo" -ForegroundColor Yellow
Write-Host "  - Ya tienes App Service funcionando (Escenario 1)" -ForegroundColor White
Write-Host "  - Podrias agregar Functions AHI" -ForegroundColor White
Write-Host "  - Mismo App Service Plan que ya funciona" -ForegroundColor White
Write-Host ""

Write-Host "=== VERIFICANDO QUOTAS ACTUALES ===" -ForegroundColor Cyan
Write-Host ""

$location = "eastus"

Write-Host "Verificando quotas en $location..." -ForegroundColor Yellow
Write-Host ""

try {
    $quotas = az vm list-usage --location $location -o json | ConvertFrom-Json
    
    Write-Host "Quotas de compute:" -ForegroundColor Cyan
    $relevant = $quotas | Where-Object { 
        $_.name.value -like "*Standard*" -or 
        $_.name.value -like "*cores*" -or
        $_.name.localizedValue -like "*vCPU*"
    } | Select-Object -First 10
    
    if ($relevant) {
        $relevant | Select-Object @{N='Recurso';E={$_.name.localizedValue}}, @{N='Uso';E={$_.currentValue}}, @{N='Limite';E={$_.limit}}, @{N='Disponible';E={$_.limit - $_.currentValue}} | Format-Table -AutoSize
    }
} catch {
    Write-Host "[WARN] No se pudo obtener informacion" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== INFORMACION DE SUSCRIPCION ===" -ForegroundColor Cyan
Write-Host ""

az account show --query "{Nombre:name, Tipo:user.type, Estado:state}" -o table

Write-Host ""
Write-Host "=== RECOMENDACION ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Dado que NO tienes quota para Basic ni Consumption:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. PRIMERO: Intenta Standard S1 (puede tener quota)" -ForegroundColor White
Write-Host "   Ejecuta: .\try_standard.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. SI S1 falla: Intenta Windows en lugar de Linux" -ForegroundColor White
Write-Host "   Ejecuta: .\try_windows.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. SI TODO falla: Usa el App Service del Escenario 1" -ForegroundColor White
Write-Host "   Ya funciona y puedes agregar Functions ahi" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. LARGO PLAZO: Solicita quota en Azure Portal" -ForegroundColor White
Write-Host "   Portal > Quotas > New support request" -ForegroundColor Gray
Write-Host ""
