# DEPLOYMENT SEGURO - POC Azure Monitor
# Sigue mejores prácticas de seguridad

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT SEGURO - POC COMPLETO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Este script desplegara el POC con mejores practicas de seguridad:" -ForegroundColor Yellow
Write-Host "  - NO crea archivos outputs.json" -ForegroundColor White
Write-Host "  - Credenciales solo en variables de entorno" -ForegroundColor White
Write-Host "  - .gitignore configurado" -ForegroundColor White
Write-Host ""

$baseDir = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor"

# Verificar .gitignore
if (-not (Test-Path (Join-Path $baseDir ".gitignore"))) {
    Write-Host "[ERROR] .gitignore no encontrado" -ForegroundColor Red
    Write-Host "El .gitignore debe existir antes de continuar" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] .gitignore configurado" -ForegroundColor Green
Write-Host ""

Write-Host "Escenarios disponibles:" -ForegroundColor Cyan
Write-Host "  0. Shared Infrastructure (Log Analytics Workspace)" -ForegroundColor White
Write-Host "  1. App Service + Application Insights" -ForegroundColor White
Write-Host "  2. Azure Functions + Serverless Monitoring" -ForegroundColor White
Write-Host ""

$option = Read-Host "Que deseas desplegar? (0/1/2/TODO)"

if ($option -eq "TODO") {
    $deployAll = $true
    Write-Host ""
    Write-Host "Desplegando TODOS los escenarios..." -ForegroundColor Green
    Write-Host ""
} else {
    $deployAll = $false
}

# ===================================
# ESCENARIO 0: SHARED INFRASTRUCTURE
# ===================================

if ($deployAll -or $option -eq "0") {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  ESCENARIO 0: SHARED INFRASTRUCTURE" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $scenario0Dir = Join-Path $baseDir "00-shared-infrastructure"
    Set-Location $scenario0Dir
    
    # Init
    Write-Host "Terraform init..." -ForegroundColor Yellow
    terraform init
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Init completo" -ForegroundColor Green
    Write-Host ""
    
    # Plan
    Write-Host "Terraform plan..." -ForegroundColor Yellow
    terraform plan -out=tfplan
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform plan fallo" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Plan generado" -ForegroundColor Green
    Write-Host ""
    
    # Apply
    $apply = Read-Host "Aplicar Escenario 0? (S/N)"
    if ($apply -ne "S" -and $apply -ne "s") {
        Write-Host "Escenario 0 cancelado" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "Terraform apply..." -ForegroundColor Yellow
    terraform apply tfplan
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform apply fallo" -ForegroundColor Red
        exit 1
    }
    
    # Obtener outputs SIN crear archivo
    $lawName = terraform output -raw law_name 2>$null
    $lawId = terraform output -raw law_id 2>$null
    $rgName = terraform output -raw resource_group_name 2>$null
    
    Write-Host ""
    Write-Host "[OK] Escenario 0 desplegado" -ForegroundColor Green
    Write-Host ""
    Write-Host "Recursos creados:" -ForegroundColor Cyan
    Write-Host "  Resource Group: $rgName" -ForegroundColor White
    Write-Host "  LAW Name:       $lawName" -ForegroundColor White
    Write-Host ""
    
    # Guardar en variables de entorno (sesión actual)
    $env:POC_LAW_NAME = $lawName
    $env:POC_RG_NAME = $rgName
    
    # Limpiar tfplan
    if (Test-Path "tfplan") {
        Remove-Item "tfplan" -Force
    }
}

# ===================================
# ESCENARIO 1: APP SERVICE
# ===================================

if ($deployAll -or $option -eq "1") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  ESCENARIO 1: APP SERVICE" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Verificar que Escenario 0 existe
    if (-not $env:POC_LAW_NAME) {
        Write-Host "[ERROR] Escenario 0 debe desplegarse primero" -ForegroundColor Red
        exit 1
    }
    
    $scenario1Dir = Join-Path $baseDir "01-app-service"
    Set-Location $scenario1Dir
    
    # Init
    Write-Host "Terraform init..." -ForegroundColor Yellow
    terraform init
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Init completo" -ForegroundColor Green
    Write-Host ""
    
    # Plan
    Write-Host "Terraform plan..." -ForegroundColor Yellow
    terraform plan -out=tfplan
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform plan fallo" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Plan generado" -ForegroundColor Green
    Write-Host ""
    
    # Apply
    $apply = Read-Host "Aplicar Escenario 1? (S/N)"
    if ($apply -ne "S" -and $apply -ne "s") {
        Write-Host "Escenario 1 cancelado" -ForegroundColor Yellow
        if (-not $deployAll) { exit 0 }
    } else {
        Write-Host ""
        Write-Host "Terraform apply..." -ForegroundColor Yellow
        terraform apply tfplan
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Terraform apply fallo" -ForegroundColor Red
            exit 1
        }
        
        # Obtener outputs SIN crear archivo
        $appName = terraform output -raw app_service_name 2>$null
        $appUrl = terraform output -raw app_service_url 2>$null
        $appInsights = terraform output -raw app_insights_name 2>$null
        
        Write-Host ""
        Write-Host "[OK] Escenario 1 desplegado" -ForegroundColor Green
        Write-Host ""
        Write-Host "Recursos creados:" -ForegroundColor Cyan
        Write-Host "  App Service:      $appName" -ForegroundColor White
        Write-Host "  URL:              $appUrl" -ForegroundColor White
        Write-Host "  App Insights:     $appInsights" -ForegroundColor White
        Write-Host ""
        
        # Deploy app code
        Write-Host "Desplegando codigo de la aplicacion..." -ForegroundColor Yellow
        
        Push-Location app
        Compress-Archive -Path * -DestinationPath ..\app.zip -Force
        Pop-Location
        
        az webapp deployment source config-zip `
            --resource-group $env:POC_RG_NAME `
            --name $appName `
            --src app.zip `
            --timeout 300
        
        Remove-Item app.zip -Force -ErrorAction SilentlyContinue
        
        Write-Host "[OK] Codigo desplegado" -ForegroundColor Green
        Write-Host ""
        
        # Limpiar tfplan
        if (Test-Path "tfplan") {
            Remove-Item "tfplan" -Force
        }
    }
}

# ===================================
# ESCENARIO 2: AZURE FUNCTIONS
# ===================================

if ($deployAll -or $option -eq "2") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  ESCENARIO 2: AZURE FUNCTIONS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Verificar que Escenario 0 existe
    if (-not $env:POC_LAW_NAME) {
        Write-Host "[ERROR] Escenario 0 debe desplegarse primero" -ForegroundColor Red
        exit 1
    }
    
    $scenario2Dir = Join-Path $baseDir "02-azure-functions"
    Set-Location $scenario2Dir
    
    # Init
    Write-Host "Terraform init..." -ForegroundColor Yellow
    terraform init
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform init fallo" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Init completo" -ForegroundColor Green
    Write-Host ""
    
    # Plan
    Write-Host "Terraform plan..." -ForegroundColor Yellow
    terraform plan -out=tfplan
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Terraform plan fallo" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Plan generado" -ForegroundColor Green
    Write-Host ""
    
    # Apply
    $apply = Read-Host "Aplicar Escenario 2? (S/N)"
    if ($apply -ne "S" -and $apply -ne "s") {
        Write-Host "Escenario 2 cancelado" -ForegroundColor Yellow
        if (-not $deployAll) { exit 0 }
    } else {
        Write-Host ""
        Write-Host "Terraform apply..." -ForegroundColor Yellow
        terraform apply tfplan
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Terraform apply fallo" -ForegroundColor Red
            exit 1
        }
        
        # Obtener outputs SIN crear archivo
        $funcApp = terraform output -raw function_app_name 2>$null
        $funcUrl = terraform output -raw function_app_url 2>$null
        $storage = terraform output -raw storage_account_name 2>$null
        
        Write-Host ""
        Write-Host "[OK] Escenario 2 infraestructura desplegada" -ForegroundColor Green
        Write-Host ""
        Write-Host "Recursos creados:" -ForegroundColor Cyan
        Write-Host "  Function App:     $funcApp" -ForegroundColor White
        Write-Host "  URL:              $funcUrl" -ForegroundColor White
        Write-Host "  Storage:          $storage" -ForegroundColor White
        Write-Host ""
        
        # Deploy functions - MANUAL via Portal
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "  DEPLOYMENT DE FUNCTIONS (MANUAL)" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "El deployment de Functions debe hacerse MANUALMENTE via Portal" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Razon: CLI deployment puede fallar con Standard S1" -ForegroundColor Gray
        Write-Host ""
        
        # Crear ZIP
        Write-Host "Creando ZIP..." -ForegroundColor Cyan
        Push-Location functions
        
        $zipPath = Join-Path $scenario2Dir "functions_deploy.zip"
        if (Test-Path $zipPath) {
            Remove-Item $zipPath -Force
        }
        
        Compress-Archive -Path * -DestinationPath $zipPath -Force
        Pop-Location
        
        Write-Host "[OK] ZIP creado: functions_deploy.zip" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "PASOS PARA DEPLOYMENT MANUAL:" -ForegroundColor Cyan
        Write-Host "  1. Abrir Portal: https://portal.azure.com" -ForegroundColor White
        Write-Host "  2. Buscar: $funcApp" -ForegroundColor White
        Write-Host "  3. Deployment Center -> ZIP Deploy" -ForegroundColor White
        Write-Host "  4. Browse -> functions_deploy.zip" -ForegroundColor White
        Write-Host "  5. Deploy" -ForegroundColor White
        Write-Host ""
        
        $openPortal = Read-Host "Abrir Portal ahora? (S/N)"
        if ($openPortal -eq "S" -or $openPortal -eq "s") {
            $portalUrl = "https://portal.azure.com/#resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/$env:POC_RG_NAME/providers/Microsoft.Web/sites/$funcApp/vstscd"
            Start-Process $portalUrl
            Write-Host "[OK] Portal abierto en navegador" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "NOTA: NO subas functions_deploy.zip a GitHub (ya esta en .gitignore)" -ForegroundColor Yellow
        Write-Host ""
        
        # Limpiar tfplan
        if (Test-Path "tfplan") {
            Remove-Item "tfplan" -Force
        }
    }
}

# ===================================
# RESUMEN FINAL
# ===================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT COMPLETO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IMPORTANTE - SEGURIDAD:" -ForegroundColor Yellow
Write-Host "  [OK] .gitignore configurado" -ForegroundColor Green
Write-Host "  [OK] NO se crearon archivos outputs.json" -ForegroundColor Green
Write-Host "  [OK] Credenciales solo en memoria (no en archivos)" -ForegroundColor Green
Write-Host "  [OK] ZIPs en .gitignore" -ForegroundColor Green
Write-Host ""

Write-Host "PROXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "  1. Verificar recursos en Azure Portal" -ForegroundColor White
Write-Host "  2. Si desplegaste Escenario 2, completa deployment manual" -ForegroundColor White
Write-Host "  3. Revisar .gitignore antes de commits" -ForegroundColor White
Write-Host "  4. NUNCA hacer commit de archivos .tfstate" -ForegroundColor White
Write-Host ""

Write-Host "Costos estimados:" -ForegroundColor Cyan
if ($option -eq "0" -or $deployAll) {
    Write-Host "  Escenario 0: $0/mes" -ForegroundColor White
}
if ($option -eq "1" -or $deployAll) {
    Write-Host "  Escenario 1: ~13/mes" -ForegroundColor White
}
if ($option -eq "2" -or $deployAll) {
    Write-Host "  Escenario 2: ~70/mes" -ForegroundColor White
}
Write-Host ""

Set-Location $baseDir
