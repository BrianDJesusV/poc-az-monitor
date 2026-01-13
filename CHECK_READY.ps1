# VERIFICACION DE LIMPIEZA Y PREPARACION PARA REDESPLIEGUE

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION DE LIMPIEZA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Resource Groups
Write-Host "Verificando Resource Groups en Azure..." -ForegroundColor Yellow
Write-Host ""

$azmonGroups = az group list --query "[?starts_with(name, 'rg-azmon')].{Name:name, State:properties.provisioningState}" -o json | ConvertFrom-Json

if ($azmonGroups -and $azmonGroups.Count -gt 0) {
    Write-Host "[!] Todavia hay Resource Groups:" -ForegroundColor Yellow
    Write-Host ""
    foreach ($rg in $azmonGroups) {
        $stateColor = if ($rg.State -eq "Deleting") { "Yellow" } else { "Red" }
        Write-Host "  - $($rg.Name): $($rg.State)" -ForegroundColor $stateColor
    }
    Write-Host ""
    Write-Host "Espera 5-10 minutos y vuelve a ejecutar este script" -ForegroundColor Yellow
    Write-Host ""
    exit 0
} else {
    Write-Host "[OK] No hay Resource Groups - Azure limpio" -ForegroundColor Green
    Write-Host ""
}

# Verificar archivos locales
Write-Host "Verificando archivos locales..." -ForegroundColor Yellow
Write-Host ""

$baseDir = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor"

$scenarios = @(
    @{Name="Escenario 0"; Path="00-shared-infrastructure"},
    @{Name="Escenario 1"; Path="01-app-service"},
    @{Name="Escenario 2"; Path="02-azure-functions"}
)

$allClean = $true

foreach ($scenario in $scenarios) {
    $scenarioPath = Join-Path $baseDir $scenario.Path
    
    $sensitiveFiles = @(
        "terraform.tfstate",
        "terraform.tfstate.backup",
        "outputs.json",
        "outputs.txt",
        "tfplan"
    )
    
    $foundFiles = @()
    foreach ($file in $sensitiveFiles) {
        $filePath = Join-Path $scenarioPath $file
        if (Test-Path $filePath) {
            $foundFiles += $file
        }
    }
    
    if ($foundFiles.Count -gt 0) {
        Write-Host "  [!] $($scenario.Name): Archivos sensibles encontrados" -ForegroundColor Yellow
        foreach ($file in $foundFiles) {
            Write-Host "      - $file" -ForegroundColor Gray
        }
        $allClean = $false
    } else {
        Write-Host "  [OK] $($scenario.Name): Limpio" -ForegroundColor Green
    }
}

Write-Host ""

if (-not $allClean) {
    Write-Host "[WARN] Hay archivos sensibles - deberias eliminarlos manualmente" -ForegroundColor Yellow
    Write-Host ""
}

# Verificar .gitignore
Write-Host "Verificando .gitignore..." -ForegroundColor Yellow

$gitignorePath = Join-Path $baseDir ".gitignore"
if (Test-Path $gitignorePath) {
    Write-Host "[OK] .gitignore configurado" -ForegroundColor Green
} else {
    Write-Host "[!] .gitignore NO encontrado - debe crearse" -ForegroundColor Red
    $allClean = $false
}

Write-Host ""

# Verificar DEPLOY_SECURE.ps1
Write-Host "Verificando DEPLOY_SECURE.ps1..." -ForegroundColor Yellow

$deployScript = Join-Path $baseDir "DEPLOY_SECURE.ps1"
if (Test-Path $deployScript) {
    Write-Host "[OK] Script de deployment seguro disponible" -ForegroundColor Green
} else {
    Write-Host "[!] DEPLOY_SECURE.ps1 NO encontrado" -ForegroundColor Red
    $allClean = $false
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESULTADO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($azmonGroups -and $azmonGroups.Count -gt 0) {
    Write-Host "Estado: LIMPIEZA EN PROGRESO" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Accion: Espera 5-10 minutos y ejecuta este script de nuevo" -ForegroundColor White
    Write-Host ""
} elseif ($allClean) {
    Write-Host "Estado: LISTO PARA REDESPLEGAR" -ForegroundColor Green
    Write-Host ""
    Write-Host "✓ Azure: Limpio" -ForegroundColor Green
    Write-Host "✓ Archivos locales: Limpios" -ForegroundColor Green
    Write-Host "✓ .gitignore: Configurado" -ForegroundColor Green
    Write-Host "✓ Script deployment: Disponible" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  LISTO PARA REDESPLEGAR" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ejecuta:" -ForegroundColor Yellow
    Write-Host "  .\DEPLOY_SECURE.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Cuando pregunte, escribe: TODO" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Estado: REQUIERE ATENCION" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Revisa los warnings arriba y corrige antes de redesplegar" -ForegroundColor White
    Write-Host ""
}
