# ✅ CHECKLIST DE DEPLOYMENT - Escenario 2

**Usa esto mientras ejecutas el deployment**

---

## ANTES DE EMPEZAR

- [ ] PowerShell abierto como **Administrador**
- [ ] Terraform instalado: `terraform --version`
- [ ] Azure CLI instalado: `az --version`
- [ ] Azure autenticado: `az account show`
- [ ] Escenario 0 desplegado: `az group show --name rg-azmon-poc-mexicocentral`
- [ ] En directorio correcto: `cd ...\02-azure-functions`

---

## DEPLOYMENT

### Fase 1: Terraform Infrastructure

- [ ] `terraform init` ejecutado ✅
- [ ] `terraform plan` revisado ✅
- [ ] Plan muestra: "9 to add, 0 to change, 0 to destroy"
- [ ] `terraform apply` ejecutado ✅
- [ ] Apply completado sin errores
- [ ] Outputs guardados: `terraform output -json > outputs.json`

**Variables guardadas:**
- [ ] `$funcApp = terraform output -raw function_app_name`
- [ ] `$funcUrl = terraform output -raw function_app_url`
- [ ] `$storage = terraform output -raw storage_account_name`
- [ ] `$appInsights = terraform output -raw app_insights_name`

---

### Fase 2: Function Deployment

- [ ] ZIP creado: `Compress-Archive -Path functions\* -DestinationPath functions.zip`
- [ ] Deploy ejecutado: `az functionapp deployment source config-zip ...`
- [ ] Deploy completado sin errores
- [ ] ZIP eliminado: `Remove-Item functions.zip`
- [ ] Wait 60 segundos: `Start-Sleep -Seconds 60`

---

### Fase 3: Verification

- [ ] HttpTrigger tested: `Invoke-WebRequest -Uri "$funcUrl/api/HttpTrigger?name=POC"`
- [ ] Response: 200 OK
- [ ] JSON válido recibido

---

### Fase 4: Test Data Generation

**Queue Messages:**
- [ ] 5 mensajes enviados a queue-orders
- [ ] Comando ejecutado sin errores

**Blob Files:**
- [ ] 3 archivos subidos a uploads container
- [ ] Uploads exitosos

---

### Fase 5: Verification en Azure Portal

- [ ] Azure Portal abierto
- [ ] Application Insights encontrado: `$appInsights`
- [ ] Live Metrics abierto
- [ ] Actividad visible en Live Metrics
- [ ] Logs abierto
- [ ] Query KQL ejecutada exitosamente

---

## POST-DEPLOYMENT

### Testing

- [ ] `.\test_functions.ps1` ejecutado
- [ ] Test 1: HttpTrigger PASS
- [ ] Test 2: Queue messages PASS
- [ ] Test 3: Blob uploads PASS
- [ ] Test 4: App Insights PASS
- [ ] Success Rate: 100%

---

### Verification Checks

**Functions desplegadas:**
```powershell
az functionapp function list --name $funcApp --resource-group rg-azmon-poc-mexicocentral --output table
```

- [ ] HttpTrigger listada
- [ ] TimerTrigger listada
- [ ] QueueTrigger listada
- [ ] BlobTrigger listada

**Recursos en Azure:**
```powershell
az resource list --resource-group rg-azmon-poc-mexicocentral --output table
```

- [ ] Storage Account visible
- [ ] Function App visible
- [ ] Application Insights visible
- [ ] Service Plan visible

---

### Application Insights

**Live Metrics:**
- [ ] HttpTrigger requests visible
- [ ] QueueTrigger executions visible
- [ ] BlobTrigger executions visible
- [ ] TimerTrigger executions visible (esperar 5 min)

**Logs - Query 1:**
```kusto
requests
| where cloud_RoleName contains "func-azmon"
| summarize count() by operation_Name
```
- [ ] Query ejecutada
- [ ] Resultados muestran 4 functions
- [ ] HttpTrigger tiene mayor count

**Logs - Query 2:**
```kusto
requests
| where cloud_RoleName contains "func-azmon"
| summarize 
    Executions = count(),
    AvgMs = avg(duration),
    P95Ms = percentile(duration, 95)
    by operation_Name
```
- [ ] Performance metrics visibles
- [ ] HttpTrigger < 500ms promedio
- [ ] QueueTrigger < 1000ms promedio

---

### Documentation

- [ ] Screenshots de Application Insights guardados
- [ ] Queries KQL que funcionaron documentadas
- [ ] Observaciones de cold starts anotadas
- [ ] Terraform outputs respaldados

---

## SUCCESS CRITERIA

**✅ Deployment exitoso si:**

- [ ] 9 recursos creados en Azure
- [ ] 4 functions desplegadas
- [ ] HttpTrigger responde 200 OK
- [ ] Queue messages procesándose
- [ ] Blob files procesándose
- [ ] Application Insights muestra telemetría
- [ ] Live Metrics muestra actividad
- [ ] Queries KQL funcionan
- [ ] Test script 100% PASS
- [ ] Costo estimado: $0.70/mes

---

## COMPARATIVA CON ESCENARIO 1

- [ ] Escenario 1 costo: $13/mes
- [ ] Escenario 2 costo: $0.70/mes
- [ ] Ahorro: 95%
- [ ] Cold starts observados: Sí (normal)
- [ ] Auto-scaling: Infinito (vs manual)
- [ ] Use cases identificados: Event-driven patterns

---

## BACKUP

- [ ] `terraform.tfstate` respaldado
- [ ] `terraform.tfvars` respaldado
- [ ] `outputs.json` guardado
- [ ] Screenshots guardados

**Backup command:**
```powershell
$date = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item terraform.tfstate "backups\terraform.tfstate.$date"
```

---

## CLEANUP (opcional)

**Si quieres destruir después:**

- [ ] Backup completado primero
- [ ] `terraform destroy -auto-approve` ejecutado
- [ ] Destroy completado: 3-5 minutos
- [ ] Resource group verificado: no existe
- [ ] Costo después: $0/mes

---

## NOTAS

**Observations:**

- Cold start time: _____ segundos
- Warm start time: _____ milisegundos
- Queue processing lag: _____ segundos
- Most expensive function: _____
- Cheapest function: _____

**Issues encontrados:**

1. _____________________________________
2. _____________________________________
3. _____________________________________

**Soluciones aplicadas:**

1. _____________________________________
2. _____________________________________
3. _____________________________________

---

**Deployment completado:** ___/___/______  
**Tiempo total:** _____ minutos  
**Success:** ✅ / ❌  
**Notas finales:** _____________________

---

**Próximos pasos:**

- [ ] Documentar learnings en KNOWLEDGE_TRANSFER.md
- [ ] Comparar con Escenario 1
- [ ] Planear Escenario 3 (Container Apps)
- [ ] Presentar a equipo
