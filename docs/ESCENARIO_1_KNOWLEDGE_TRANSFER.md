# 📚 ESCENARIO 1: APP SERVICE + APPLICATION INSIGHTS
## Lo Que Debes Rescatar y Documentar

**Fecha:** 7 de enero de 2026  
**Escenario:** Monitoring de aplicación web con Application Insights  
**Estado:** ✅ COMPLETADO Y VALIDADO

---

## 🎯 RESUMEN EJECUTIVO

### ¿Qué demuestra este escenario?

**Capacidades de Azure Monitor demostradas:**
1. ✅ **Application Performance Monitoring (APM)**
   - Telemetría automática de requests HTTP
   - Tiempos de respuesta y latencias
   - Success/failure rates
   - Dependency tracking

2. ✅ **Log Analytics Integration**
   - Workspace compartido entre servicios
   - Retención configurable (30 días)
   - Queries KQL para análisis

3. ✅ **Alertas y Detección Automática**
   - Smart Detection configurado
   - Action Groups para notificaciones

4. ✅ **Live Metrics**
   - Monitoreo en tiempo real
   - Visibilidad instantánea de la salud

---

## 🏗️ ARQUITECTURA DEL ESCENARIO

### **Componentes Desplegados:**

```
┌─────────────────────────────────────────────────────────────┐
│                    RESOURCE GROUP                            │
│            rg-azmon-poc-mexicocentral                       │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           LOG ANALYTICS WORKSPACE                    │   │
│  │        law-azmon-poc-mexicocentral                  │   │
│  │                                                      │   │
│  │  Solutions:                                         │   │
│  │  • AzureActivity                                    │   │
│  │  • ContainerInsights                                │   │
│  │  • Security                                         │   │
│  └──────────────────┬──────────────────────────────────┘   │
│                     │                                        │
│                     │ (vinculado)                           │
│                     ↓                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        APPLICATION INSIGHTS                          │   │
│  │      appi-azmon-appservice-ltr94a                   │   │
│  │                                                      │   │
│  │  • Connection String configurado                    │   │
│  │  • Smart Detection habilitado                       │   │
│  │  • Logs forwarding a LAW                           │   │
│  └──────────────────┬──────────────────────────────────┘   │
│                     │                                        │
│                     │ (monitorea)                           │
│                     ↓                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            WEB APP + APP SERVICE PLAN                │   │
│  │                                                      │   │
│  │  App Service Plan: asp-azmon-poc-ltr94a (B1)       │   │
│  │  Web App: app-azmon-demo-ltr94a                    │   │
│  │  Runtime: Python 3.11 (Flask)                      │   │
│  │  URL: app-azmon-demo-ltr94a.azurewebsites.net      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### **Flujo de Telemetría:**

```
1. Usuario → Request HTTP → Web App
2. Web App → Genera telemetría → Application Insights
3. Application Insights → Almacena logs → Log Analytics Workspace
4. Usuario → Queries KQL → Log Analytics → Visualiza métricas
```

---

## 📋 INFRAESTRUCTURA COMO CÓDIGO (TERRAFORM)

### **Archivos Clave a Conservar:**

#### 1. **Scenario 0 - Shared Infrastructure**
```
00-shared-infrastructure/
├── main.tf              ← Log Analytics Workspace + Solutions
├── variables.tf         ← Variables parametrizables
├── outputs.tf           ← Outputs para otros módulos
├── terraform.tfvars     ← Valores específicos del ambiente
└── terraform.tfstate    ← Estado actual (⚠️ backup crítico)
```

**Puntos clave:**
- Workspace ID exportado como output
- Solutions instaladas: AzureActivity, ContainerInsights, Security
- Retención: 30 días (configurable)
- SKU: PerGB2018 (pay-as-you-go)

#### 2. **Scenario 1 - App Service**
```
01-app-service/
├── main.tf              ← App Service Plan + Web App + App Insights
├── variables.tf         ← Variables parametrizables
├── outputs.tf           ← Connection strings y URLs
├── terraform.tfvars     ← Configuración específica
└── terraform.tfstate    ← Estado actual (⚠️ backup crítico)
```

**Puntos clave:**
- Data source para referenciar Scenario 0
- App Service Plan con SKU variable (F1/B1)
- Application Insights vinculado a LAW
- Connection String configurado en App Settings

---

## 🔑 CONFIGURACIONES CRÍTICAS

### **1. Application Insights Connection String**


**Cómo se obtiene:**
```bash
az monitor app-insights component show \
  --app appi-azmon-appservice-ltr94a \
  --resource-group rg-azmon-poc-mexicocentral \
  --query connectionString -o tsv
```

**Cómo se configura en Web App:**
```bash
az webapp config appsettings set \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a \
  --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=<valor>"
```

**Formato:**
```
InstrumentationKey=590a6fb4-16d7-4148-a868-82c0e7ece1f8;IngestionEndpoint=https://mexicocentral-1.in.applicationinsights.azure.com/;LiveEndpoint=https://mexicocentral.livediagnostics.monitor.azure.com/
```

### **2. Vinculación Log Analytics ↔ Application Insights**

**En Terraform:**
```hcl
resource "azurerm_application_insights" "app_insights" {
  workspace_id = data.azurerm_log_analytics_workspace.shared_law.id
  # Esto vincula App Insights con el workspace compartido
}
```

**Beneficio:** Todos los logs van al mismo workspace, queries unificadas

---

## 📊 QUERIES KQL ESENCIALES

### **1. Request Count y Distribution**
```kusto
// Ver todos los requests por endpoint
requests
| where timestamp > ago(1h)
| summarize count() by name, resultCode
| order by count_ desc
```

**Usar para:** Identificar endpoints más usados y patrones de error

### **2. Success Rate**
```kusto
// Calcular tasa de éxito
requests
| where timestamp > ago(1h)
| summarize 
    Total = count(),
    Exitosos = countif(success == true),
    Fallidos = countif(success == false),
    SuccessRate = round(100.0 * countif(success)/count(), 2)
```

**Usar para:** SLAs, métricas de confiabilidad

### **3. Performance Analysis (Percentiles)**
```kusto
// Análisis de tiempos de respuesta
requests
| where timestamp > ago(1h)
| summarize 
    P50 = percentile(duration, 50),
    P95 = percentile(duration, 95),
    P99 = percentile(duration, 99),
    Max = max(duration),
    Avg = avg(duration)
    by name
| order by Avg desc
```

**Usar para:** Identificar endpoints lentos, establecer baselines

### **4. Error Analysis**
```kusto
// Análisis detallado de errores
requests
| where timestamp > ago(1h)
| where success == false
| summarize count() by name, resultCode, cloud_RoleName
| order by count_ desc
```

**Usar para:** Troubleshooting, identificar patrones de fallo

### **5. Timeline de Requests**
```kusto
// Visualización temporal
requests
| where timestamp > ago(1h)
| summarize count() by bin(timestamp, 1m)
| render timechart
```

**Usar para:** Detectar picos de tráfico, incidentes, patrones horarios

### **6. Requests por Status Code**
```kusto
// Distribución de códigos de respuesta
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
| render piechart
```

**Usar para:** Vista rápida de salud de la aplicación

---

## 💡 LECCIONES APRENDIDAS CRÍTICAS

### **1. Problemas con F1 Free Tier**

**Problema:** 
- Estado "QuotaExceeded" bloquea deployments
- Build automation falla por falta de memoria
- CLI deployments con `az webapp up` no funcionan

**Solución:**
- Usar B1 tier para deployments confiables
- ZIP Deploy manual via Azure Portal
- Considerar F1 solo para apps muy simples pre-built

**Documentar en futuras implementaciones:** Siempre empezar con B1 para POCs, luego considerar downgrade si es apropiado

### **2. Deployment Methods Que Funcionan**

**✅ FUNCIONA:**
```bash
az webapp deploy \
  --resource-group <rg> \
  --name <app-name> \
  --src-path <zip-file> \
  --type zip
```

**✅ FUNCIONA:** Azure Portal → ZIP Deploy manual

**❌ NO FUNCIONA BIEN con F1:**
```bash
az webapp up --resource-group <rg> --name <app>
# Falla por limitaciones de memoria en build
```

### **3. Regional Quotas**

**Lección:** No todos los recursos están disponibles en todas las regiones, incluso si el servicio está "disponible"

**Ejemplo vivido:**
- East US 2: Quota bloqueada para App Service F1
- Mexico Central: Quota disponible

**Verificación previa:**
```bash
az vm list-usage --location <region> --output table
```

### **4. Application Insights Data Lag**

**Expectativa:** Datos instantáneos  
**Realidad:** 2-5 minutos de lag típico

**Implicación:** 
- Live Metrics para monitoreo en tiempo real
- Logs/Performance para análisis histórico (esperar 5 min)
- Planear demos con tráfico pre-generado

---

## 🎨 DEMOS Y PRESENTACIONES

### **Script de Demo (10 minutos)**

**1. Mostrar Arquitectura (2 min)**
- Diagrama de componentes
- Explicar flujo de telemetría
- Mencionar integración con Log Analytics

**2. Generar Tráfico en Vivo (2 min)**
```powershell
.\generate_traffic.ps1 -TotalRequests 50
```
O usar Postman Collection Runner

**3. Live Metrics (2 min)**
- Abrir Live Metrics en Azure Portal
- Mostrar incoming requests en tiempo real
- Señalar response times, success rate

**4. Queries KQL (3 min)**
- Ejecutar query de distribución de requests
- Mostrar timeline chart
- Ejecutar análisis de performance

**5. Alertas y Smart Detection (1 min)**
- Mostrar configuración de Action Group
- Mencionar detección automática de anomalías

### **Capturas de Pantalla Esenciales**

**Capturar para documentación:**

1. **Application Map**
   - Vista de la topología de la aplicación
   - Dependencias y health status

2. **Performance Dashboard**
   - Gráficos de response time
   - Tabla de operations con métricas

3. **Failures View**
   - Distribución de códigos de error
   - Timeline de fallos

4. **Query Results**
   - Al menos 3 queries diferentes ejecutadas
   - Charts y tablas resultantes

5. **Live Metrics**
   - Vista en tiempo real durante generación de tráfico

---

## 📈 MÉTRICAS Y KPIs CLAVE

### **KPIs a Trackear:**

1. **Availability**
   - Target: >99.5%
   - Query: `requests | summarize SuccessRate = 100.0 * countif(success)/count()`

2. **Performance (P95 Response Time)**
   - Target: <500ms para endpoints normales
   - Query: `requests | summarize P95 = percentile(duration, 95)`

3. **Error Rate**
   - Target: <1% para errores 5xx
   - Query: `requests | where resultCode >= 500 | count`

4. **Request Volume**
   - Baseline: establecer después de 1 semana
   - Query: `requests | summarize count() by bin(timestamp, 1h)`

### **Alertas Recomendadas:**

1. **High Error Rate**
   ```
   Condition: Failed request % > 5%
   Window: 5 minutes
   Action: Email + SMS
   ```

2. **Slow Response Time**
   ```
   Condition: P95 > 2000ms
   Window: 10 minutes
   Action: Email
   ```

3. **Low Availability**
   ```
   Condition: Success rate < 95%
   Window: 5 minutes
   Action: Email + SMS + PagerDuty
   ```

---

## 🔧 TROUBLESHOOTING COMÚN

### **Problema: No aparecen métricas en Application Insights**

**Checklist:**
1. ✅ Application Insights Connection String configurado en App Settings
2. ✅ Web App reiniciada después de configurar
3. ✅ Tráfico generado a la aplicación (requests HTTP)
4. ✅ Esperar 2-5 minutos para data lag
5. ✅ Verificar en Live Metrics primero (más rápido)

**Comando de verificación:**
```bash
az webapp config appsettings list \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a \
  --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"
```

### **Problema: Queries KQL retornan vacío**

**Causas comunes:**
1. Timeframe muy corto (expandir a `ago(24h)`)
2. Data lag (esperar 5 minutos)
3. No se ha generado tráfico
4. Filtros muy restrictivos

**Query de diagnóstico:**
```kusto
// Ver si hay ALGÚN dato
requests
| where timestamp > ago(24h)
| take 10
```

### **Problema: Deployment falla**

**Si ves QuotaExceeded:**
1. Cambiar a B1 tier
2. Reintentar deployment

**Si build falla:**
1. Usar ZIP Deploy en lugar de `az webapp up`
2. Pre-build localmente si es posible

---

## 💾 ARCHIVOS CRÍTICOS PARA BACKUP

### **Prioridad 1 (Esenciales):**
```
✅ 00-shared-infrastructure/terraform.tfstate
✅ 00-shared-infrastructure/terraform.tfvars
✅ 01-app-service/terraform.tfstate
✅ 01-app-service/terraform.tfvars
✅ 01-app-service/files/flask_example/*.zip
```

### **Prioridad 2 (Importantes):**
```
✅ docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md (este documento)
✅ docs/deployment_exitoso.md
✅ docs/trafico_generado.md
✅ GUIA_POSTMAN.md
✅ Azure_Monitor_POC_Collection.postman_collection.json
```

### **Prioridad 3 (Útiles):**
```
✅ generate_traffic.ps1
✅ Capturas de pantalla de métricas
✅ Resultados de queries KQL guardados
```

---

## 🚀 CÓMO REPLICAR ESTE ESCENARIO

### **Desde Cero (30 minutos):**

1. **Deploy Shared Infrastructure (5 min)**
   ```bash
   cd 00-shared-infrastructure
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy App Service Scenario (10 min)**
   ```bash
   cd ../01-app-service
   terraform init
   terraform plan
   terraform apply
   ```

3. **Deploy Application Code (5 min)**
   ```bash
   az webapp deploy \
     --resource-group rg-azmon-poc-mexicocentral \
     --name app-azmon-demo-<random> \
     --src-path flask_example/simple-flask.zip \
     --type zip
   ```

4. **Generar Tráfico (5 min)**
   ```powershell
   .\generate_traffic.ps1 -TotalRequests 200
   ```

5. **Verificar Métricas (5 min)**
   - Application Insights → Performance
   - Logs → Ejecutar queries KQL
   - Live Metrics → Monitoreo en tiempo real

---

## 📚 RECURSOS Y REFERENCIAS

### **Documentación Oficial:**
- Application Insights: https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview
- KQL Reference: https://docs.microsoft.com/azure/data-explorer/kudu-query-language
- Log Analytics: https://docs.microsoft.com/azure/azure-monitor/logs/log-analytics-overview

### **Documentación del Proyecto:**
- Architecture: `docs/architecture.md`
- Deployment Guide: `docs/deployment_exitoso.md`
- Traffic Generation: `docs/trafico_generado.md`
- Postman Guide: `GUIA_POSTMAN.md`

### **Scripts Útiles:**
- PowerShell Traffic Generator: `generate_traffic.ps1`
- Python Traffic Generator: `generate_traffic.py`
- Postman Collection: `Azure_Monitor_POC_Collection.postman_collection.json`

---

## ✅ CHECKLIST DE VALIDACIÓN

**Antes de dar por completado el escenario:**

- [ ] Infraestructura desplegada via Terraform
- [ ] Application Insights configurado y vinculado
- [ ] Aplicación desplegada y funcionando
- [ ] Tráfico generado (mínimo 200 requests)
- [ ] Métricas visibles en Application Insights
- [ ] Al menos 5 queries KQL ejecutadas exitosamente
- [ ] Live Metrics verificado en tiempo real
- [ ] Screenshots capturados de todas las vistas
- [ ] Terraform state files respaldados
- [ ] Documentación actualizada
- [ ] Código de aplicación versionado en Git
- [ ] Colección de Postman probada
- [ ] Costos estimados y documentados

---

## 💰 COSTOS ESTIMADOS

### **Con Plan B1:**
```
App Service Plan B1:     ~$13.14/mes
Application Insights:    $0.00 (5GB/mes gratis)
Log Analytics:           $0.00 (5GB/mes gratis)
Storage (state files):   ~$0.01/mes

TOTAL:                   ~$13.15/mes
```

### **Con Plan F1 (si funciona):**
```
App Service Plan F1:     $0.00/mes
Application Insights:    $0.00 (5GB/mes gratis)
Log Analytics:           $0.00 (5GB/mes gratis)

TOTAL:                   $0.00/mes
```

**Nota:** Los costos reales pueden variar según el volumen de telemetría

---

## 🎓 PRÓXIMOS ESCENARIOS SUGERIDOS

Basándote en este escenario, puedes expandir a:

1. **Escenario 2: Container Monitoring**
   - Azure Container Apps + Application Insights
   - Multi-container scenarios
   - Container-specific metrics

2. **Escenario 3: VM Monitoring**
   - Azure Monitor Agent
   - Performance counters
   - Custom logs

3. **Escenario 4: Database Monitoring**
   - Azure SQL + Insights
   - Query performance
   - Connection pooling metrics

4. **Escenario 5: Multi-Component Application**
   - Distributed tracing
   - Application Map con múltiples servicios
   - End-to-end transaction tracking

---

## 📝 NOTAS FINALES

Este documento captura lo esencial del Escenario 1. Mantenlo actualizado con:
- Nuevas queries KQL descubiertas
- Problemas y soluciones encontradas
- Mejores prácticas emergentes
- Feedback de presentaciones/demos

**Última actualización:** 7 de enero de 2026  
**Próxima revisión:** Después de completar Escenario 2  
**Mantenido por:** Brian Poch
