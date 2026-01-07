# 🚀 DEPLOYMENT RÁPIDO - Escenario 2
**Copia y pega estos comandos en PowerShell**

---

## ⚡ OPCIÓN 1: Script Automatizado (Recomendado)

```powershell
# Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions

# Ejecutar script de deployment
.\DEPLOY.ps1
```

**Tiempo:** 10-15 minutos  
**Qué hace:** Todo automatizado + verificaciones

---

## 📋 OPCIÓN 2: Comandos Manuales

### **Paso 1: Navegar (5 segundos)**
```powershell
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions
```

### **Paso 2: Terraform Init (30 segundos)**
```powershell
terraform init
```

### **Paso 3: Terraform Plan (1 minuto)**
```powershell
terraform plan
```

Revisar que dice: `Plan: 9 to add, 0 to change, 0 to destroy`

### **Paso 4: Terraform Apply (5-8 minutos)**
```powershell
terraform apply -auto-approve
```

### **Paso 5: Guardar Outputs (5 segundos)**
```powershell
terraform output -json > outputs.json
$funcApp = terraform output -raw function_app_name
$funcUrl = terraform output -raw function_app_url
$storage = terraform output -raw storage_account_name

Write-Host "Function App: $funcApp"
Write-Host "Function URL: $funcUrl"
Write-Host "Storage: $storage"
```

### **Paso 6: Deploy Functions (3-5 minutos)**
```powershell
# Crear ZIP
Push-Location functions
Compress-Archive -Path * -DestinationPath ..\functions.zip -Force
Pop-Location

# Deploy
az functionapp deployment source config-zip `
    --resource-group rg-azmon-poc-mexicocentral `
    --name $funcApp `
    --src functions.zip

# Cleanup
Remove-Item functions.zip -Force
```

### **Paso 7: Esperar (60 segundos)**
```powershell
Write-Host "Esperando que functions estén disponibles..."
Start-Sleep -Seconds 60
```

### **Paso 8: Test HttpTrigger (5 segundos)**
```powershell
Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POC" | Select-Object StatusCode, Content
```

### **Paso 9: Generar Test Data (30 segundos)**

**Queue messages:**
```powershell
for ($i=1; $i -le 5; $i++) {
    $msg = "{`"orderId`":`"ORDER-$(Get-Random -Min 1000 -Max 9999)`",`"customer`":`"Test-$i`",`"amount`":$($i*10)}"
    az storage message put --queue-name queue-orders --account-name $storage --content $msg --output none
}
Write-Host "✓ 5 mensajes enviados a queue"
```

**Blob files:**
```powershell
for ($i=1; $i -le 3; $i++) {
    "Test $i" | Out-File "test-$i.txt"
    az storage blob upload --account-name $storage --container-name uploads --name "test-$i.txt" --file "test-$i.txt" --output none
    Remove-Item "test-$i.txt"
}
Write-Host "✓ 3 archivos subidos a blob"
```

### **Paso 10: Verificar en Portal**
```powershell
$appInsights = terraform output -raw app_insights_name
Write-Host "Application Insights: $appInsights"
Write-Host "Abre Azure Portal y busca: $appInsights"
```

---

## ✅ VERIFICACIÓN RÁPIDA

```powershell
# Ver recursos creados
az resource list --resource-group rg-azmon-poc-mexicocentral --output table | Select-String "func-azmon|stazmon|appi-azmon-functions"

# Ver functions
az functionapp function list --name $funcApp --resource-group rg-azmon-poc-mexicocentral --output table

# Test API
curl "$funcUrl/api/HttpTrigger?name=Test"
```

---

## 🎯 RESULTADO ESPERADO

```
✓ 9 recursos creados
✓ 4 functions desplegadas
✓ HttpTrigger responde 200 OK
✓ Queue messages procesándose
✓ Blob files procesándose
✓ Application Insights recibiendo telemetría
```

---

## 🆘 SI ALGO FALLA

**Terraform init error:**
```powershell
terraform init -upgrade
```

**Functions no despliegan:**
```powershell
# Wait y retry
Start-Sleep -Seconds 60
az functionapp restart --name $funcApp --resource-group rg-azmon-poc-mexicocentral
```

**HttpTrigger 503:**
```
Cold start - espera 30 segundos y retry
```

---

## 💰 COSTO

```
Storage:     $0.50/mes
Functions:   $0.20/mes
TOTAL:       $0.70/mes
```

---

**Fecha:** 7 de enero de 2026  
**Tiempo total:** 10-15 minutos  
**Autor:** Brian Poch
