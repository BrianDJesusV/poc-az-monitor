# LIMPIAR HISTORIAL DE GIT - Eliminar credenciales expuestas

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LIMPIEZA DE HISTORIAL GIT" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Este script limpiara los archivos con credenciales del historial de Git" -ForegroundColor Yellow
Write-Host ""

# Verificar que estamos en el directorio correcto
$currentDir = Get-Location
$expectedPath = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor"

if ($currentDir.Path -ne $expectedPath) {
    Write-Host "Cambiando al directorio del proyecto..." -ForegroundColor Yellow
    Set-Location $expectedPath
}

# Verificar que es un repositorio Git
if (-not (Test-Path ".git")) {
    Write-Host "[ERROR] Este no es un repositorio Git" -ForegroundColor Red
    Write-Host "Ubicacion actual: $(Get-Location)" -ForegroundColor Gray
    exit 1
}

Write-Host "Repositorio Git encontrado: $expectedPath" -ForegroundColor Green
Write-Host ""

Write-Host "Archivos que seran eliminados del HISTORIAL completo:" -ForegroundColor Cyan
Write-Host ""

$filesToRemove = @(
    "00-shared-infrastructure/terraform.tfstate",
    "00-shared-infrastructure/terraform.tfstate.backup",
    "00-shared-infrastructure/outputs.json",
    "00-shared-infrastructure/outputs.txt",
    "01-app-service/terraform.tfstate",
    "01-app-service/terraform.tfstate.backup",
    "01-app-service/outputs.json",
    "01-app-service/outputs.txt",
    "02-azure-functions/terraform.tfstate",
    "02-azure-functions/terraform.tfstate.backup",
    "02-azure-functions/outputs.json",
    "02-azure-functions/outputs.txt",
    "02-azure-functions/functions.zip",
    "02-azure-functions/functions_manual.zip"
)

foreach ($file in $filesToRemove) {
    Write-Host "  - $file" -ForegroundColor White
}

Write-Host ""
Write-Host "ADVERTENCIA:" -ForegroundColor Red
Write-Host "  - Esto reescribira el historial de Git" -ForegroundColor White
Write-Host "  - Requerira force push" -ForegroundColor White
Write-Host "  - No se puede deshacer" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continuar? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "=== PASO 1: Instalar git-filter-repo ===" -ForegroundColor Cyan
Write-Host ""

# Verificar si git-filter-repo esta instalado
$filterRepoInstalled = $false
try {
    $result = git filter-repo --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] git-filter-repo ya esta instalado" -ForegroundColor Green
        $filterRepoInstalled = $true
    }
} catch {
    Write-Host "[INFO] git-filter-repo no esta instalado" -ForegroundColor Yellow
}

if (-not $filterRepoInstalled) {
    Write-Host "Instalando git-filter-repo con pip..." -ForegroundColor Yellow
    
    # Verificar pip
    try {
        pip --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] pip no esta instalado" -ForegroundColor Red
            Write-Host "Instala Python y pip primero" -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "[ERROR] pip no esta disponible" -ForegroundColor Red
        exit 1
    }
    
    pip install git-filter-repo
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] git-filter-repo instalado" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] No se pudo instalar git-filter-repo" -ForegroundColor Red
        Write-Host ""
        Write-Host "ALTERNATIVA: Usa BFG Repo-Cleaner o elimina el repo" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "=== PASO 2: Hacer backup del repo ===" -ForegroundColor Cyan
Write-Host ""

$backupPath = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor_BACKUP_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Write-Host "Creando backup en: $backupPath" -ForegroundColor Yellow

Copy-Item -Path $expectedPath -Destination $backupPath -Recurse -Force

if (Test-Path $backupPath) {
    Write-Host "[OK] Backup creado" -ForegroundColor Green
} else {
    Write-Host "[ERROR] No se pudo crear backup" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== PASO 3: Limpiar historial ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Limpiando archivos del historial (esto puede tomar 1-2 minutos)..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $filesToRemove) {
    Write-Host "Eliminando: $file" -ForegroundColor Gray
    git filter-repo --path $file --invert-paths --force 2>$null
}

Write-Host ""
Write-Host "[OK] Historial limpiado" -ForegroundColor Green
Write-Host ""

Write-Host "=== PASO 4: Verificar limpieza ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Archivos en el commit actual:" -ForegroundColor Yellow
git ls-files | Select-String -Pattern "tfstate|outputs"

Write-Host ""
Write-Host "[OK] Verificacion completa" -ForegroundColor Green
Write-Host ""

Write-Host "=== PASO 5: Configurar .gitignore ===" -ForegroundColor Cyan
Write-Host ""

$gitignorePath = Join-Path $expectedPath ".gitignore"
$gitignoreContent = @"
# Terraform
*.tfstate
*.tfstate.*
*.tfstate.backup
.terraform/
.terraform.lock.hcl
tfplan
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Sensitive outputs
outputs.json
outputs.txt

# Credentials
*.pem
*.key
*.pfx
*.p12
credentials.json

# Azure Functions
local.settings.json
*.zip

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
"@

$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8 -Force

Write-Host "[OK] .gitignore configurado" -ForegroundColor Green
Write-Host ""

Write-Host "=== PASO 6: Commit del .gitignore ===" -ForegroundColor Cyan
Write-Host ""

git add .gitignore
git commit -m "Add .gitignore to prevent future credential exposure"

Write-Host "[OK] .gitignore commiteado" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LIMPIEZA COMPLETA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Proximo paso: FORCE PUSH a GitHub" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Red
Write-Host "  Esto reescribira el historial en GitHub" -ForegroundColor White
Write-Host "  Cualquier colaborador debera re-clonar el repo" -ForegroundColor White
Write-Host ""

$push = Read-Host "Hacer force push ahora? (S/N)"

if ($push -eq "S" -or $push -eq "s") {
    Write-Host ""
    Write-Host "Haciendo force push..." -ForegroundColor Yellow
    
    git push --force origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[OK] Force push completado!" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  REPOSITORIO LIMPIO" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Historial de Git limpio de credenciales" -ForegroundColor Green
        Write-Host "Backup guardado en: $backupPath" -ForegroundColor White
        Write-Host ""
        Write-Host "Ahora es SEGURO volver a desplegar recursos" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[ERROR] Force push fallo" -ForegroundColor Red
        Write-Host "Intenta manualmente: git push --force origin main" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "Force push cancelado" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Para hacer force push manualmente:" -ForegroundColor Cyan
    Write-Host "  git push --force origin main" -ForegroundColor White
    Write-Host ""
}
