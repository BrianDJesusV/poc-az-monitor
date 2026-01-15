# DEPLOYMENT VIA KUDU - Metodo mas confiable

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT VIA KUDU" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$funcApp = "func-azmon-demo-m5snfk"
$rgName = "rg-azmon-poc-mexicocentral"

Write-Host "Function App: $funcApp" -ForegroundColor White
Write-Host ""

# Verificar que el ZIP existe
$zipPath = "C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions\functions-deploy.zip"

if (-not (Test-Path $zipPath)) {
    Write-Host "[ERROR] functions-deploy.zip no encontrado" -ForegroundColor Red
    Write-Host "Ubicacion esperada: $zipPath" -ForegroundColor Gray
    exit 1
}

$zipSize = (Get-Item $zipPath).Length / 1KB
Write-Host "[OK] ZIP encontrado: $([math]::Round($zipSize, 2)) KB" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  METODO 1: KUDU ZIP PUSH (RECOMENDADO)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PASOS:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Abriendo Kudu en navegador..." -ForegroundColor Cyan

# Obtener Kudu URL
$kuduUrl = "https://$funcApp.scm.azurewebsites.net"
Write-Host "   URL Kudu: $kuduUrl" -ForegroundColor Gray
Write-Host ""

Start-Process $kuduUrl
Start-Sleep -Seconds 3

Write-Host "2. En la pagina de Kudu:" -ForegroundColor Cyan
Write-Host "   a. Menu superior: Tools -> Zip Push Deploy" -ForegroundColor White
Write-Host "   b. Arrastra el archivo a la ventana:" -ForegroundColor White
Write-Host "      $zipPath" -ForegroundColor Gray
Write-Host "   c. Espera el mensaje: 'Deployment successful'" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  METODO 2: API DIRECTA (SI KUDU NO FUNCIONA)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Si Kudu no funciona, usa PowerShell API:" -ForegroundColor Yellow
Write-Host ""

Write-Host "Obteniendo credenciales..." -ForegroundColor Cyan

# Obtener publishing profile
$profile = az functionapp deployment list-publishing-profiles `
    --name $funcApp `
    --resource-group $rgName `
    --xml 2>$null

if ($LASTEXITCODE -eq 0 -and $profile) {
    # Parse XML para obtener username y password
    $profileXml = [xml]$profile
    $publishProfile = $profileXml.publishData.publishProfile | Where-Object { $_.publishMethod -eq "ZipDeploy" } | Select-Object -First 1
    
    if ($publishProfile) {
        $username = $publishProfile.userName
        $password = $publishProfile.userPWD
        
        Write-Host "[OK] Credenciales obtenidas" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "Intentando deployment via API..." -ForegroundColor Yellow
        
        # Base64 encode credentials
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
        
        # Deploy via API
        try {
            $headers = @{
                "Authorization" = "Basic $base64Auth"
            }
            
            $apiUrl = "https://$funcApp.scm.azurewebsites.net/api/zipdeploy"
            
            Write-Host "POST $apiUrl" -ForegroundColor Gray
            
            $response = Invoke-RestMethod -Uri $apiUrl `
                -Method POST `
                -InFile $zipPath `
                -Headers $headers `
                -ContentType "application/zip" `
                -TimeoutSec 300
            
            Write-Host ""
            Write-Host "[OK] Deployment via API exitoso!" -ForegroundColor Green
            Write-Host ""
            
            Write-Host "Verificando Functions..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            
            $functions = az functionapp function list `
                --name $funcApp `
                --resource-group $rgName `
                --query "[].name" -o tsv 2>$null
            
            if ($functions) {
                Write-Host ""
                Write-Host "[OK] Functions desplegadas:" -ForegroundColor Green
                foreach ($func in $functions) {
                    Write-Host "  - $func" -ForegroundColor White
                }
            }
            
        } catch {
            Write-Host ""
            Write-Host "[ERROR] API deployment fallo: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "Usa el METODO 1 (Kudu) manualmente" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[ERROR] No se pudieron obtener credenciales" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usa el METODO 1 (Kudu) manualmente" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Para verificar el deployment:" -ForegroundColor Cyan
Write-Host "  1. Portal -> $funcApp -> Functions" -ForegroundColor White
Write-Host "  2. Debes ver 4 functions listadas" -ForegroundColor White
Write-Host ""

Write-Host "O ejecuta:" -ForegroundColor Cyan
Write-Host "  az functionapp function list --name $funcApp --resource-group $rgName" -ForegroundColor White
Write-Host ""
