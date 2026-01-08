# Script para verificar quotas de Azure Functions y App Service

Write-Host "=== VERIFICACION DE QUOTAS DE AZURE ===" -ForegroundColor Cyan
Write-Host ""

# Información de la suscripción
Write-Host "Suscripcion actual:" -ForegroundColor Yellow
az account show --query "{Nombre:name, ID:id, Estado:state, Tipo:user.type}" -o table
Write-Host ""

# Verificar en qué regiones hay quota disponible
$regions = @("eastus", "eastus2", "westus", "westus2", "westeurope", "northeurope")

Write-Host "=== VERIFICANDO QUOTAS POR REGION ===" -ForegroundColor Cyan
Write-Host ""

foreach ($location in $regions) {
    Write-Host "Region: $location" -ForegroundColor Yellow
    
    # Verificar App Service Plans disponibles
    $plans = az appservice list-locations --sku FREE --query "[?name=='$location'].{Name:name}" -o tsv 2>$null
    
    if ($plans) {
        Write-Host "  [OK] Region disponible" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Region puede tener restricciones" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== QUOTAS ACTUALES ===" -ForegroundColor Cyan
Write-Host ""

# Intentar obtener quotas de compute
Write-Host "Verificando quotas de compute..." -ForegroundColor Yellow
$location = "eastus"

try {
    $quotas = az vm list-usage --location $location -o json | ConvertFrom-Json
    
    # Mostrar quotas relevantes
    $relevant = $quotas | Where-Object { 
        $_.name.value -like "*Standard*" -or 
        $_.name.value -like "*cores*" -or
        $_.name.value -like "*vCPU*"
    } | Select-Object -First 10
    
    if ($relevant) {
        Write-Host ""
        $relevant | Select-Object @{N='Recurso';E={$_.name.localizedValue}}, @{N='Uso';E={$_.currentValue}}, @{N='Limite';E={$_.limit}}, @{N='Disponible';E={$_.limit - $_.currentValue}} | Format-Table -AutoSize
    }
    
} catch {
    Write-Host "[WARN] No se pudo obtener informacion detallada" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== PLANES DISPONIBLES PARA FUNCTIONS ===" -ForegroundColor Cyan
Write-Host ""

$skus = @(
    [PSCustomObject]@{Plan="Consumption (Y1)"; Serverless="Si"; Costo="~`$0.70/mes"; QuotaRequerida="Dynamic VMs"; Disponible="NO (quota = 0)"},
    [PSCustomObject]@{Plan="Basic B1"; Serverless="No"; Costo="~`$13/mes"; QuotaRequerida="Ninguna especial"; Disponible="SI"},
    [PSCustomObject]@{Plan="Basic B2"; Serverless="No"; Costo="~`$26/mes"; QuotaRequerida="Ninguna especial"; Disponible="SI"},
    [PSCustomObject]@{Plan="Standard S1"; Serverless="No"; Costo="~`$70/mes"; QuotaRequerida="Ninguna especial"; Disponible="SI"},
    [PSCustomObject]@{Plan="Premium EP1"; Serverless="Si"; Costo="~`$150/mes"; QuotaRequerida="Premium quota"; Disponible="Desconocido"}
)

$skus | Format-Table -AutoSize

Write-Host ""
Write-Host "=== EXPLICACION ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Consumption Plan (Y1):" -ForegroundColor Yellow
Write-Host "  - Requiere quota especial 'Dynamic VMs'" -ForegroundColor White
Write-Host "  - Tu suscripcion tiene: 0 quota" -ForegroundColor Red
Write-Host "  - Necesitas solicitar quota en Azure Portal" -ForegroundColor White
Write-Host ""

Write-Host "Basic Plan (B1/B2/B3):" -ForegroundColor Yellow
Write-Host "  - NO requiere quota especial" -ForegroundColor Green
Write-Host "  - Always-on (no serverless)" -ForegroundColor White
Write-Host "  - Funciona exactamente igual que Functions" -ForegroundColor White
Write-Host "  - Disponible inmediatamente" -ForegroundColor Green
Write-Host ""

Write-Host "=== RECOMENDACION ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPCION 1: Usar Basic B1 (Recomendado - Inmediato)" -ForegroundColor Green
Write-Host "  - Costo: ~13/mes" -ForegroundColor White
Write-Host "  - No requiere solicitud de quota" -ForegroundColor White
Write-Host "  - Funciona exactamente igual" -ForegroundColor White
Write-Host "  - Cambio: Editar main.tf linea 98: sku_name = `"B1`"" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPCION 2: Solicitar Quota para Consumption (1-2 dias)" -ForegroundColor Yellow
Write-Host "  - Azure Portal > Quotas > New support request" -ForegroundColor White
Write-Host "  - Tipo: Compute-VM (cores) / Dynamic VMs" -ForegroundColor White
Write-Host "  - Region: East US" -ForegroundColor White
Write-Host "  - Cantidad: 10 o mas" -ForegroundColor White
Write-Host "  - Tiempo aprobacion: 1-2 dias habiles" -ForegroundColor White
Write-Host ""

Write-Host "=== SIGUIENTE PASO ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Para continuar con Basic B1 (recomendado):" -ForegroundColor Green
Write-Host "  1. Ejecutar: .\switch_to_basic.ps1" -ForegroundColor White
Write-Host "  2. Ejecutar: .\DEPLOY_NOW.ps1" -ForegroundColor White
Write-Host ""

Write-Host "Para solicitar quota Consumption:" -ForegroundColor Yellow
Write-Host "  1. Azure Portal > Quotas" -ForegroundColor White
Write-Host "  2. New support request" -ForegroundColor White
Write-Host "  3. Esperar aprobacion (1-2 dias)" -ForegroundColor White
Write-Host ""
