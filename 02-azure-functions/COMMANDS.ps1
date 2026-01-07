# 🚀 DEPLOYMENT RÁPIDO - Comandos One-Liner
# Copia y pega estos comandos UNO POR UNO en PowerShell

# ========================================
# SETUP INICIAL (30 segundos)
# ========================================

# Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions

# Verificar archivos
ls *.tf

# ========================================
# TERRAFORM DEPLOYMENT (5-8 minutos)
# ========================================

# Init
terraform init

# Plan
terraform plan -out=tfplan

# Apply (revisar plan y confirmar)
terraform apply tfplan

# Guardar outputs
terraform output -json > outputs.json; terraform output > outputs.txt

# ========================================
# OBTENER VARIABLES (5 segundos)
# ========================================

$funcApp = terraform output -raw function_app_name; $funcUrl = terraform output -raw function_app_url; $storage = terraform output -raw storage_account_name; $appInsights = terraform output -raw app_insights_name; Write-Host "Function App: $funcApp`nURL: $funcUrl`nStorage: $storage`nApp Insights: $appInsights" -ForegroundColor Cyan

# ========================================
# DEPLOY FUNCTIONS (3-5 minutos)
# ========================================

# Crear ZIP
Push-Location functions; Compress-Archive -Path * -DestinationPath ..\functions.zip -Force; Pop-Location

# Deploy a Azure
az functionapp deployment source config-zip --resource-group rg-azmon-poc-mexicocentral --name $funcApp --src functions.zip

# Cleanup
Remove-Item functions.zip -Force

# Wait for deployment (60 segundos)
Write-Host "Esperando 60 segundos..." -ForegroundColor Yellow; Start-Sleep -Seconds 60

# ========================================
# TEST HTTPTRIGGER (5 segundos)
# ========================================

Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POC" -UseBasicParsing | Select-Object StatusCode, Content

# ========================================
# GENERATE TEST DATA (30 segundos)
# ========================================

# Queue messages (5)
for ($i=1; $i -le 5; $i++) { $msg = "{`"orderId`":`"ORDER-$(Get-Random -Min 1000 -Max 9999)`",`"customer`":`"Test-$i`",`"amount`":$($i*10)}"; az storage message put --queue-name queue-orders --account-name $storage --content $msg --output none }; Write-Host "✓ 5 mensajes enviados" -ForegroundColor Green

# Blob files (3)
for ($i=1; $i -le 3; $i++) { "Test $i" | Out-File "test-$i.txt"; az storage blob upload --account-name $storage --container-name uploads --name "test-$i.txt" --file "test-$i.txt" --output none; Remove-Item "test-$i.txt" }; Write-Host "✓ 3 archivos subidos" -ForegroundColor Green

# ========================================
# VERIFICACIÓN (10 segundos)
# ========================================

# Ver functions desplegadas
az functionapp function list --name $funcApp --resource-group rg-azmon-poc-mexicocentral --output table

# Ver recursos
az resource list --resource-group rg-azmon-poc-mexicocentral --output table | Select-String "func-azmon|stazmon|appi-azmon-functions"

# ========================================
# RESUMEN
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan; Write-Host "    DEPLOYMENT COMPLETADO ✅" -ForegroundColor Green; Write-Host "========================================" -ForegroundColor Cyan; Write-Host "`nFunction App:  $funcApp`nURL:           $funcUrl`nStorage:       $storage`nApp Insights:  $appInsights`n`nTest API:`n  Invoke-WebRequest -Uri '$funcUrl/api/HttpTrigger?name=Test'`n`nCosto: ~`$0.70/mes`n" -ForegroundColor White

# ========================================
# TESTING COMPLETO (opcional)
# ========================================

# Ejecutar suite completa de tests
.\test_functions.ps1

# ========================================
# APPLICATION INSIGHTS
# ========================================

Write-Host "`nApplication Insights: $appInsights" -ForegroundColor Cyan; Write-Host "Abre Azure Portal y busca este recurso para ver telemetría`n" -ForegroundColor Yellow

# ========================================
# QUERIES KQL (copiar en Azure Portal)
# ========================================

<#
Ejecuta estas queries en Application Insights → Logs:

// Ver todas las executions
requests
| where cloud_RoleName contains "func-azmon"
| summarize count() by operation_Name
| render barchart

// Cold starts
requests
| where cloud_RoleName contains "func-azmon"
| extend IsColdStart = tobool(customDimensions.isColdStart)
| summarize Total = count(), ColdStarts = countif(IsColdStart)

// Performance
requests
| where cloud_RoleName contains "func-azmon"
| summarize 
    Executions = count(),
    AvgMs = avg(duration),
    P95Ms = percentile(duration, 95)
    by operation_Name
| order by P95Ms desc
#>
