# ===========================================================================
# Script de Despliegue de Aplicación - Azure Monitor POC
# ===========================================================================
#
# Este script despliega la aplicación Flask al App Service de Azure
#
# Uso:
#   .\deploy-app.ps1
#
# ===========================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$AppName
)

# Colores
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"
$ColorInfo = "Cyan"

Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host "  📦 Despliegue de Aplicación - Azure Monitor POC" -ForegroundColor $ColorInfo
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host ""

# Obtener nombre del App Service desde Terraform si no se proporciona
if (-not $AppName) {
    Write-Host "📍 Obteniendo nombre del App Service desde Terraform..." -ForegroundColor $ColorInfo
    try {
        $AppName = terraform output -raw app_service_name 2>$null
        if ($LASTEXITCODE -eq 0 -and $AppName) {
            Write-Host "✅ App Service encontrado: $AppName" -ForegroundColor $ColorSuccess
        } else {
            throw "No se pudo obtener el nombre"
        }
    } catch {
        Write-Host "❌ Error: No se pudo obtener el nombre del App Service" -ForegroundColor $ColorError
        Write-Host "Asegúrate de haber ejecutado 'terraform apply' primero" -ForegroundColor $ColorWarning
        exit 1
    }
}

Write-Host ""

# Verificar que estamos en el directorio correcto
$appPath = "..\test-app"
if (-not (Test-Path $appPath)) {
    Write-Host "❌ Error: No se encuentra el directorio de la aplicación" -ForegroundColor $ColorError
    Write-Host "   Buscando en: $appPath" -ForegroundColor $ColorError
    Write-Host "   Ejecuta este script desde el directorio 'scripts'" -ForegroundColor $ColorWarning
    exit 1
}

Write-Host "📂 Directorio de la aplicación: $appPath" -ForegroundColor $ColorInfo
Write-Host ""

# Verificar archivos necesarios
$requiredFiles = @("app.py", "requirements.txt", "startup.txt")
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $appPath $file
    if (Test-Path $filePath) {
        Write-Host "  ✓ $file" -ForegroundColor $ColorSuccess
    } else {
        Write-Host "  ✗ $file (FALTA)" -ForegroundColor $ColorError
        $missingFiles = $true
    }
}

if ($missingFiles) {
    Write-Host ""
    Write-Host "❌ Faltan archivos necesarios" -ForegroundColor $ColorError
    exit 1
}

Write-Host ""
Write-Host "🔐 Verificando autenticación con Azure..." -ForegroundColor $ColorInfo
try {
    $account = az account show 2>$null | ConvertFrom-Json
    Write-Host "✅ Autenticado como: $($account.user.name)" -ForegroundColor $ColorSuccess
    Write-Host "   Subscription: $($account.name)" -ForegroundColor White
} catch {
    Write-Host "❌ No estás autenticado en Azure" -ForegroundColor $ColorError
    Write-Host "   Ejecuta: az login" -ForegroundColor $ColorWarning
    exit 1
}

Write-Host ""
Write-Host "📦 Preparando despliegue..." -ForegroundColor $ColorInfo

# Crear archivo ZIP temporal
$zipPath = Join-Path $env:TEMP "app-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"

try {
    Write-Host "  📁 Creando archivo ZIP..." -ForegroundColor White
    
    # Crear ZIP con todos los archivos de la app
    Compress-Archive -Path "$appPath\*" -DestinationPath $zipPath -Force
    
    $zipSize = (Get-Item $zipPath).Length / 1KB
    Write-Host "  ✅ ZIP creado: $([math]::Round($zipSize, 2)) KB" -ForegroundColor $ColorSuccess
    
} catch {
    Write-Host "  ❌ Error creando ZIP: $($_.Exception.Message)" -ForegroundColor $ColorError
    exit 1
}

Write-Host ""
Write-Host "🚀 Desplegando aplicación a Azure App Service..." -ForegroundColor $ColorInfo
Write-Host "   App Service: $AppName" -ForegroundColor White
Write-Host "   Este proceso puede tardar 2-3 minutos..." -ForegroundColor $ColorWarning
Write-Host ""

try {
    # Desplegar usando Azure CLI
    az webapp deployment source config-zip `
        --name $AppName `
        --src $zipPath `
        --timeout 600 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Aplicación desplegada exitosamente" -ForegroundColor $ColorSuccess
    } else {
        throw "Error en el despliegue"
    }
    
} catch {
    Write-Host "❌ Error durante el despliegue: $($_.Exception.Message)" -ForegroundColor $ColorError
    exit 1
} finally {
    # Limpiar archivo ZIP temporal
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
}

Write-Host ""
Write-Host "⏳ Esperando que la aplicación esté lista (30 segundos)..." -ForegroundColor $ColorInfo
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "🔍 Verificando que la aplicación responde..." -ForegroundColor $ColorInfo

# Obtener URL del App Service
$appUrl = "https://$AppName.azurewebsites.net"

try {
    $response = Invoke-WebRequest -Uri "$appUrl/health" -Method GET -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Aplicación está respondiendo correctamente" -ForegroundColor $ColorSuccess
    }
} catch {
    Write-Host "⚠️  La aplicación aún no responde (puede tomar unos minutos)" -ForegroundColor $ColorWarning
    Write-Host "   URL: $appUrl/health" -ForegroundColor White
}

Write-Host ""
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host "  ✅ DESPLIEGUE COMPLETADO" -ForegroundColor $ColorSuccess
Write-Host "=" * 70 -ForegroundColor $ColorInfo
Write-Host ""
Write-Host "🌐 URL de la aplicación:" -ForegroundColor $ColorInfo
Write-Host "   $appUrl" -ForegroundColor White
Write-Host ""
Write-Host "📊 Próximos pasos:" -ForegroundColor $ColorInfo
Write-Host "   1. Abre la aplicación en tu navegador" -ForegroundColor White
Write-Host "   2. Genera tráfico con: .\generate-traffic.ps1" -ForegroundColor White
Write-Host "   3. Verifica métricas en Application Insights (en 1-2 minutos)" -ForegroundColor White
Write-Host ""
