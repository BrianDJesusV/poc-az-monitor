# ELIMINACION COMPLETA DE TODOS LOS RECURSOS DEL POC
# Respuesta a incidente de seguridad

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "  ELIMINACION TOTAL DEL POC" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "Este script eliminara TODOS los recursos del POC:" -ForegroundColor Yellow
Write-Host ""

# Resource groups a eliminar
$resourceGroups = @(
    "rg-azmon-poc-mexicocentral",        # Principal (Escenarios 0, 1, 2)
    "rg-azmon-functions-lvvw1w",         # Intento fallido 1
    "rg-azmon-functions-xm3zsy",         # Intento fallido 2
    "rg-azmon-functions-x2ytm6",         # Intento fallido 3
    "rg-azmon-functions-7wue34",         # Intento fallido 4
    "rg-azmon-functions-7f0gvv"          # Intento fallido 5
)

Write-Host "Resource Groups que seran eliminados:" -ForegroundColor Cyan
Write-Host ""

$existingRGs = @()

foreach ($rg in $resourceGroups) {
    $exists = az group exists --name $rg 2>$null
    if ($exists -eq "true") {
        Write-Host "  [!] $rg (EXISTE)" -ForegroundColor Yellow
        $existingRGs += $rg
    } else {
        Write-Host "  [ ] $rg (no existe)" -ForegroundColor Gray
    }
}

Write-Host ""

if ($existingRGs.Count -eq 0) {
    Write-Host "[INFO] No hay resource groups para eliminar" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host "Total a eliminar: $($existingRGs.Count) resource group(s)" -ForegroundColor Yellow
Write-Host ""

# Listar recursos en cada RG
Write-Host "Recursos que seran eliminados:" -ForegroundColor Cyan
Write-Host ""

foreach ($rg in $existingRGs) {
    Write-Host "En $rg" -ForegroundColor Yellow
    $resources = az resource list --resource-group $rg --query "[].{Name:name, Type:type}" -o json 2>$null | ConvertFrom-Json
    
    if ($resources -and $resources.Count -gt 0) {
        foreach ($res in $resources) {
            $typeName = $res.type.Split('/')[-1]
            Write-Host "  - $($res.name) ($typeName)" -ForegroundColor White
        }
    } else {
        Write-Host "  (vacío)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "ADVERTENCIA:" -ForegroundColor Red
Write-Host "  - Esta accion es IRREVERSIBLE" -ForegroundColor White
Write-Host "  - Se eliminaran TODOS los recursos" -ForegroundColor White
Write-Host "  - Se perderan TODOS los datos" -ForegroundColor White
Write-Host "  - No hay forma de recuperar" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Estas ABSOLUTAMENTE SEGURO? Escribe 'DELETE ALL' para confirmar"

if ($confirmation -ne "DELETE ALL") {
    Write-Host ""
    Write-Host "Cancelado - no se elimino nada" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "Segunda confirmacion..." -ForegroundColor Yellow
$confirmation2 = Read-Host "Ultima oportunidad. Escribe 'SI' para eliminar TODO"

if ($confirmation2 -ne "SI") {
    Write-Host ""
    Write-Host "Cancelado - no se elimino nada" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO ELIMINACION" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$deleted = @()
$failed = @()

foreach ($rg in $existingRGs) {
    Write-Host "Eliminando $rg..." -ForegroundColor Yellow
    
    # No-wait para eliminar en paralelo
    az group delete --name $rg --yes --no-wait 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Eliminacion iniciada (background)" -ForegroundColor Green
        $deleted += $rg
    } else {
        Write-Host "  [ERROR] Fallo al iniciar eliminacion" -ForegroundColor Red
        $failed += $rg
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LIMPIEZA DE ARCHIVOS LOCALES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Limpiar archivos con credenciales en Escenario 1
$scenario1Path = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service"
if (Test-Path $scenario1Path) {
    Write-Host "Limpiando archivos Escenario 1..." -ForegroundColor Yellow
    
    $filesToRemove = @(
        "terraform.tfstate",
        "terraform.tfstate.backup",
        "outputs.json",
        "outputs.txt",
        ".terraform.lock.hcl"
    )
    
    foreach ($file in $filesToRemove) {
        $fullPath = Join-Path $scenario1Path $file
        if (Test-Path $fullPath) {
            Remove-Item $fullPath -Force
            Write-Host "  [OK] Eliminado: $file" -ForegroundColor Gray
        }
    }
    
    if (Test-Path (Join-Path $scenario1Path ".terraform")) {
        Remove-Item (Join-Path $scenario1Path ".terraform") -Recurse -Force
        Write-Host "  [OK] Eliminado: .terraform/" -ForegroundColor Gray
    }
}

# Limpiar archivos con credenciales en Escenario 2
$scenario2Path = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions"
if (Test-Path $scenario2Path) {
    Write-Host "Limpiando archivos Escenario 2..." -ForegroundColor Yellow
    
    $filesToRemove = @(
        "terraform.tfstate",
        "terraform.tfstate.backup",
        "outputs.json",
        "outputs.txt",
        "functions.zip",
        "functions_manual.zip",
        ".terraform.lock.hcl"
    )
    
    foreach ($file in $filesToRemove) {
        $fullPath = Join-Path $scenario2Path $file
        if (Test-Path $fullPath) {
            Remove-Item $fullPath -Force
            Write-Host "  [OK] Eliminado: $file" -ForegroundColor Gray
        }
    }
    
    if (Test-Path (Join-Path $scenario2Path ".terraform")) {
        Remove-Item (Join-Path $scenario2Path ".terraform") -Recurse -Force
        Write-Host "  [OK] Eliminado: .terraform/" -ForegroundColor Gray
    }
}

# Limpiar shared infrastructure
$sharedPath = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\00-shared-infrastructure"
if (Test-Path $sharedPath) {
    Write-Host "Limpiando archivos Shared Infrastructure..." -ForegroundColor Yellow
    
    $filesToRemove = @(
        "terraform.tfstate",
        "terraform.tfstate.backup",
        "outputs.json",
        "outputs.txt",
        ".terraform.lock.hcl"
    )
    
    foreach ($file in $filesToRemove) {
        $fullPath = Join-Path $sharedPath $file
        if (Test-Path $fullPath) {
            Remove-Item $fullPath -Force
            Write-Host "  [OK] Eliminado: $file" -ForegroundColor Gray
        }
    }
    
    if (Test-Path (Join-Path $sharedPath ".terraform")) {
        Remove-Item (Join-Path $sharedPath ".terraform") -Recurse -Force
        Write-Host "  [OK] Eliminado: .terraform/" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Resource Groups eliminandose:" -ForegroundColor Green
foreach ($rg in $deleted) {
    Write-Host "  [OK] $rg" -ForegroundColor White
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Resource Groups con error:" -ForegroundColor Red
    foreach ($rg in $failed) {
        Write-Host "  [!] $rg" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Archivos locales eliminados:" -ForegroundColor Green
Write-Host "  [OK] Terraform states" -ForegroundColor White
Write-Host "  [OK] Outputs con credenciales" -ForegroundColor White
Write-Host "  [OK] ZIPs de deployment" -ForegroundColor White
Write-Host ""

Write-Host "IMPORTANTE:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Las eliminaciones estan en progreso (background)" -ForegroundColor White
Write-Host "   Tomara 5-10 minutos completarse" -ForegroundColor White
Write-Host ""
Write-Host "2. Verifica en Azure Portal en 10 minutos:" -ForegroundColor White
Write-Host "   https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. TODAVIA PENDIENTE:" -ForegroundColor Red
Write-Host "   - Limpiar repositorio GitHub" -ForegroundColor White
Write-Host "   - Eliminar secrets del historial de Git" -ForegroundColor White
Write-Host "   - O eliminar repo completo" -ForegroundColor White
Write-Host ""

Write-Host "Para verificar el progreso:" -ForegroundColor Cyan
Write-Host "  az group list --query '[?starts_with(name, ''rg-azmon'')].name' -o table" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ELIMINACION INICIADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
