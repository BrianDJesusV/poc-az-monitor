# 📖 GUÍA DE DEPLOYMENT COMPLETA - Escenario 2

**Tiempo total:** 30 minutos  
**Dificultad:** Media  
**Prerequisites:** Escenario 0 desplegado

---

## ✅ CHECKLIST PRE-DEPLOYMENT

Antes de empezar, verifica:

- [ ] Escenario 0 está desplegado (Log Analytics Workspace)
- [ ] Azure CLI autenticado (`az login`)
- [ ] Terraform instalado (`terraform --version`)
- [ ] Python 3.11 disponible (solo para development local)
- [ ] Subscription correcta (`az account show`)

---

## 🚀 PASO A PASO

### **PASO 1: Preparación (1 min)**

```powershell
# Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions

# Verificar archivos
ls
# Deberías ver: main.tf, variables.tf, outputs.tf, functions/, etc.

# Verificar Scenario 0
cd ..\00-shared-infrastructure
terraform output law_name
# Debería mostrar: law-azmon-poc-mexicocentral

# Regresar a Scenario 2
cd ..\02-azure-functions
```

---

### **PASO 2: Deploy Infraestructura (5-8 min)**

```powershell
# Inicializar Terraform (primera vez)
terraform init

# Ver qué se va a crear
terraform plan

# Deberías ver:
#   Plan: 9 to add, 0 to change, 0 to destroy.
#
#   Recursos:
#   + Storage Account
#   + 2 Containers
#   + 2 Queues
#   + Application Insights
#   + Service Plan (Consumption)
#   + Function App

# Crear recursos
terraform apply -auto-approve

# Esperar 5-8 minutos...
```

**Verificación:**
```powershell
# Ver outputs
terraform output

# Guardar en archivo
terraform output -json > outputs.json

# Ver Function App URL
terraform output function_app_url
# Ejemplo: https://func-azmon-demo-abc123.azurewebsites.net
```

---

### **PASO 3: Deploy Functions (3-5 min)**

```powershell
# Opción recomendada: PowerShell script
.\deploy_functions.ps1
```

**Lo que hace el script:**
1. Obtiene Function App name de Terraform
2. Comprime carpeta `functions/` en ZIP
3. Deploy a Azure usando `az functionapp deployment`
4. Limpia archivos temporales

**Salida esperada:**
```
=== DEPLOYING AZURE FUNCTIONS ===

Getting Function App name from Terraform...
Function App: func-azmon-demo-abc123

Creating deployment package...
Deployment package created: functions.zip

Deploying to Azure...
Deployment successful!

Function App URL: https://func-azmon-demo-abc123.azurewebsites.net

Test the functions:
  Invoke-WebRequest -Uri 'https://func-azmon-demo-abc123.azurewebsites.net/api/HttpTrigger?name=Test'
```

---

### **PASO 4: Verificación (2 min)**

**Test manual del HttpTrigger:**
```powershell
$url = terraform output -raw function_app_url
Invoke-WebRequest -Uri "$url/api/HttpTrigger?name=POC" | Select-Object -ExpandProperty Content
```

**Salida esperada:**
```json
{
  "message": "Hello, POC!",
  "timestamp": "2026-01-07T20:00:00.000Z",
  "function": "func-azmon-demo-abc123",
  "environment": "poc",
  "triggerType": "http"
}
```

**Ver functions desplegadas:**
```powershell
$funcApp = terraform output -raw function_app_name
az functionapp function list --name $funcApp --resource-group rg-azmon-poc-mexicocentral --output table
```

**Salida esperada:**
```
Name           InvokeUrlTemplate
-------------  ---------------------------------------------------
HttpTrigger    https://func-azmon-demo-abc123.azurewebsites.net/api/HttpTrigger
QueueTrigger   N/A (Queue triggered)
BlobTrigger    N/A (Blob triggered)
TimerTrigger   N/A (Timer triggered every 5 min)
```

---

### **PASO 5: Testing Completo (5 min)**

```powershell
# Ejecutar suite de tests
.\test_functions.ps1

# O con más iteraciones
.\test_functions.ps1 -TestIterations 20
```

**El script hace:**
1. ✅ Test HttpTrigger (GET request)
2. ✅ Genera 10+ mensajes en queue
3. ✅ Sube 3 archivos a blob storage
4. ✅ Verifica Application Insights

**Salida esperada:**
```
=== TESTING AZURE FUNCTIONS ===

Function App URL: https://func-azmon-demo-abc123.azurewebsites.net

=== TEST 1: HttpTrigger ===
[PASS] HttpTrigger returned 200 OK
Response: Hello, POC!

=== TEST 2: Generate Queue Messages ===
Generating 10 queue messages...
  [1/10] Message sent: orderId=ORDER-1234
  [2/10] Message sent: orderId=ORDER-5678
  ...
[PASS] Generated 10 queue messages

=== TEST 3: Upload Test Files ===
  Uploaded: test-file-1.txt
  Uploaded: test-file-2.txt
  Uploaded: test-file-3.txt
[PASS] Uploaded 3 test files

Waiting 30 seconds for functions to process...

=== TEST 4: Verify Application Insights ===
[INFO] Check Application Insights in Azure Portal for telemetry
[PASS] Application Insights configured

=== TEST SUMMARY ===
Total Tests:  4
Passed:       4
Failed:       0
Success Rate: 100%

All tests passed! Functions are working correctly.
```

---

### **PASO 6: Monitoreo en Application Insights (5 min)**

**Abrir Azure Portal:**
```powershell
# Get App Insights name
terraform output app_insights_name
# Ejemplo: appi-azmon-functions-abc123
```

1. **Azure Portal** → Search "appi-azmon-functions-abc123"
2. Click en el recurso
3. **Live Metrics** → Ver telemetría en tiempo real
4. **Logs** → Ejecutar queries KQL
5. **Performance** → Ver execution times

**Query KQL básica:**
```kusto
requests
| where timestamp > ago(1h)
| where cloud_RoleName contains "func-azmon"
| summarize count() by operation_Name
| render barchart
```

---

### **PASO 7: Generar Más Tráfico (opcional)**

**Test manual de cada function:**

```powershell
# HttpTrigger
Invoke-WebRequest -Uri "$url/api/HttpTrigger?name=Test1"
Invoke-WebRequest -Uri "$url/api/HttpTrigger?name=Test2"

# QueueTrigger (enviar mensajes)
$storage = terraform output -raw storage_account_name
for ($i=1; $i -le 20; $i++) {
    $msg = "{`"orderId`":`"ORDER-$i`",`"customer`":`"Cust-$i`",`"amount`":$($i*10)}"
    az storage message put --queue-name queue-orders --account-name $storage --content $msg
}

# BlobTrigger (subir archivos)
for ($i=1; $i -le 5; $i++) {
    "Content $i" | Out-File "temp-$i.txt"
    az storage blob upload --account-name $storage --container-name uploads --name "temp-$i.txt" --file "temp-$i.txt"
    Remove-Item "temp-$i.txt"
}

# TimerTrigger se ejecuta automáticamente cada 5 minutos
```

---

## 📊 VERIFICACIÓN FINAL

### **Checklist de Éxito:**

- [ ] Terraform apply completado sin errores
- [ ] 9 recursos creados en Azure
- [ ] Functions desplegadas (4 functions)
- [ ] HttpTrigger responde 200 OK
- [ ] Queue messages procesados
- [ ] Blobs procesados
- [ ] Application Insights recibe telemetría
- [ ] Live Metrics muestra actividad
- [ ] Queries KQL funcionan

### **Comandos de Verificación:**

```powershell
# 1. Recursos en Azure
az resource list --resource-group rg-azmon-poc-mexicocentral --output table | Select-String "func-azmon|stazmon|appi-azmon-functions"

# 2. Function App status
$funcApp = terraform output -raw function_app_name
az functionapp show --name $funcApp --resource-group rg-azmon-poc-mexicocentral --query "{Name:name, State:state, URL:defaultHostName}" --output table

# 3. Functions desplegadas
az functionapp function list --name $funcApp --resource-group rg-azmon-poc-mexicocentral --output table

# 4. Storage containers
$storage = terraform output -raw storage_account_name
az storage container list --account-name $storage --output table

# 5. Storage queues
az storage queue list --account-name $storage --output table
```

---

## 🎓 QUÉ ACABAS DE CREAR

### **Infraestructura:**
- ✅ Storage Account con blobs y queues
- ✅ Function App (Consumption plan)
- ✅ Application Insights (serverless monitoring)

### **Functions:**
- ✅ HttpTrigger - REST API serverless
- ✅ TimerTrigger - Scheduled job (cada 5 min)
- ✅ QueueTrigger - Async message processing
- ✅ BlobTrigger - Event-driven file processing

### **Monitoring:**
- ✅ Telemetría automática en App Insights
- ✅ Distributed tracing configurado
- ✅ Custom logging implementado
- ✅ Cold start tracking

---

## 🔥 CLEANUP (cuando termines)

```powershell
# Backup state files
Copy-Item terraform.tfstate "terraform.tfstate.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Destroy resources
terraform destroy -auto-approve

# Tiempo: 3-5 minutos
# Costo después: $0
```

---

## 🆘 TROUBLESHOOTING

### **Error: "Resource group not found"**
```powershell
# Verifica que Escenario 0 esté desplegado
az group show --name rg-azmon-poc-mexicocentral

# Si no existe, despliega Escenario 0 primero
cd ..\00-shared-infrastructure
terraform apply -auto-approve
cd ..\02-azure-functions
```

### **Error: "Function app already exists"**
```powershell
# El nombre es aleatorio, esto no debería pasar
# Si pasa, modifica terraform.tfvars o destruye recurso existente
```

### **Functions no aparecen después de deploy**
```powershell
# Espera 2-3 minutos y verifica
az functionapp function list --name <func-app-name> --resource-group rg-azmon-poc-mexicocentral

# Si no aparecen, redeploy
.\deploy_functions.ps1
```

### **HttpTrigger returns 503**
```
# Cold start - espera 30 segundos
Start-Sleep -Seconds 30

# Retry
Invoke-WebRequest -Uri "$url/api/HttpTrigger?name=Test"
```

### **Queue messages no se procesan**
```powershell
# Verifica logs
az functionapp log tail --name <func-app-name> --resource-group rg-azmon-poc-mexicocentral

# Verifica que hay mensajes
$storage = terraform output -raw storage_account_name
az storage message peek --queue-name queue-orders --account-name $storage
```

---

## 📚 SIGUIENTES PASOS

1. **Explorar Application Insights**
   - Live Metrics (tiempo real)
   - Performance (P50, P95, P99)
   - Failures (error analysis)
   - Logs (KQL queries)

2. **Generar Más Datos**
   - Run test_functions.ps1 multiple times
   - Create custom test scenarios
   - Analyze cold starts vs warm starts

3. **Documentar Aprendizajes**
   - Capture screenshots
   - Document KQL queries that work well
   - Note any issues encountered

4. **Comparar con Escenario 1**
   - App Service (always-on) vs Functions (serverless)
   - Cost comparison
   - Performance comparison
   - Use case fit

---

**Última actualización:** 7 de enero de 2026  
**Status:** ✅ Tested and verified  
**Autor:** Brian Poch
