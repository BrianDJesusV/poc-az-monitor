# 🌐 Escenario 1: Azure App Service

## 📋 Descripción

Este escenario despliega una **aplicación web Flask** en Azure App Service con integración completa de monitoreo a través de Application Insights y Log Analytics. El objetivo es demostrar observabilidad end-to-end de aplicaciones web tradicionales.

## 🎯 Objetivos de Aprendizaje

Al completar este escenario, entenderás:

1. **Métricas de aplicación:**
   - Request rate, response time, throughput
   - Uso de CPU y memoria del App Service Plan
   - Tasa de errores (4xx, 5xx)

2. **Logs estructurados:**
   - HTTP access logs
   - Application logs (Python logging)
   - Console logs
   - Platform logs

3. **Trazas distribuidas:**
   - End-to-end request tracking
   - Performance bottlenecks
   - Dependencies tracking

4. **Application Insights:**
   - Live Metrics Stream
   - Application Map
   - Performance profiling
   - Failure analysis

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Internet → App Service (Flask App)                    │
│              ↓                                          │
│              Application Insights                       │
│              ↓                                          │
│              Log Analytics Workspace                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Desplegados

### 1. Application Insights
- **Nombre:** `appi-azmon-appservice-{suffix}`
- **Tipo:** Web application
- **Conexión:** Integrado con Log Analytics Workspace
- **Sampling:** 100% (POC - en producción usar 10-20%)

### 2. App Service Plan
- **Nombre:** `asp-azmon-poc-{suffix}`
- **SKU:** B1 (Basic)
- **OS:** Linux
- **Always On:** Habilitado

### 3. App Service (Web App)
- **Nombre:** `app-azmon-demo-{suffix}`
- **Runtime:** Python 3.11
- **HTTPS:** Obligatorio
- **Logging:** Detallado habilitado

### 4. Aplicación Flask
Una aplicación de demostración que expone múltiples endpoints:

| Endpoint | Método | Descripción | Status Code |
|----------|--------|-------------|-------------|
| `/` | GET | Página principal con info | 200 |
| `/health` | GET | Health check | 200 |
| `/api/success` | GET | Request exitoso | 200 |
| `/api/slow` | GET | Simula latencia (2-4s) | 200 |
| `/api/error` | GET | Genera error 500 | 500 |
| `/api/notfound` | GET | Genera error 404 | 404 |
| `/api/data` | POST | Recibe datos JSON | 201 |
| `/metrics` | GET | Métricas Prometheus | 200 |

### 5. Diagnostic Settings
Configurado para enviar a Log Analytics:
- AppServiceHTTPLogs
- AppServiceConsoleLogs
- AppServiceAppLogs
- AppServiceAuditLogs
- AppServicePlatformLogs
- AllMetrics

## 📊 Datos Observables

### Métricas Clave

**App Service Plan:**
- CPU Percentage
- Memory Percentage
- Data In / Data Out
- HTTP Queue Length

**Application Insights:**
- Server response time (avg, p95, p99)
- Server requests (rate per second)
- Failed requests (count)
- Availability (%)
- Server exceptions (count)

### Logs Disponibles

**AppServiceHTTPLogs:**
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| where CsMethod == "GET" and ScStatus >= 400
| project TimeGenerated, CsUriStem, ScStatus, TimeTaken, CsUserAgent
| order by TimeGenerated desc
```

**AppServiceAppLogs (Python logs):**
```kusto
AppServiceConsoleLogs
| where TimeGenerated > ago(1h)
| where ResultDescription contains "INFO" or ResultDescription contains "ERROR"
| project TimeGenerated, ResultDescription
| order by TimeGenerated desc
```

### Trazas (Traces)

Application Insights captura automáticamente:
- Duración de cada request
- Dependencias externas (si las hay)
- Stack traces de excepciones
- Custom dimensions (datos extra en logs)

## 🚀 Instrucciones de Despliegue

### Prerrequisitos
✅ Escenario 0 (infraestructura compartida) desplegado
✅ Azure CLI instalado y autenticado
✅ Terraform instalado

### Paso 1: Desplegar Infraestructura

```powershell
# Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service

# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Revisar plan
terraform plan

# Aplicar cambios
terraform apply -auto-approve
```

**Tiempo estimado:** 3-5 minutos

### Paso 2: Desplegar Aplicación

```powershell
# Navegar a scripts
cd scripts

# Ejecutar script de despliegue
.\deploy-app.ps1
```

El script:
1. Empaqueta la aplicación Flask
2. La despliega al App Service
3. Verifica que esté respondiendo

**Tiempo estimado:** 2-3 minutos

### Paso 3: Verificar Despliegue

```powershell
# Obtener URL de la aplicación
terraform output app_service_url

# Abrir en navegador o probar con curl
$appUrl = terraform output -raw app_service_url
Invoke-WebRequest -Uri "$appUrl/health"
```

Deberías ver:
```json
{
  "status": "healthy",
  "timestamp": 1736121600,
  "version": "1.0.0"
}
```

### Paso 4: Generar Tráfico

```powershell
# Generar tráfico durante 5 minutos
.\generate-traffic.ps1 -DurationMinutes 5 -RequestsPerMinute 10
```

El script genera tráfico variado:
- 40% requests exitosos
- 30% home page
- 10% requests lentos
- 10% errores 500
- 5% errores 404
- 5% POST con datos

## 🔍 Visualización en Azure Portal

### Opción 1: Application Insights (Recomendado)

1. **Abrir Application Insights**
   ```
   Portal Azure → Buscar "appi-azmon-appservice" → Seleccionar el recurso
   ```

2. **Live Metrics Stream (Tiempo Real)**
   - Sidebar izquierdo → `Investigate` → `Live Metrics`
   - Verás requests en tiempo real mientras ejecutas generate-traffic.ps1

3. **Application Map (Topología)**
   - `Investigate` → `Application Map`
   - Vista visual de la aplicación y sus dependencias

4. **Performance (Análisis de Performance)**
   - `Investigate` → `Performance`
   - Ver operaciones más lentas
   - Drill-down en requests individuales

5. **Failures (Análisis de Errores)**
   - `Investigate` → `Failures`
   - Ver errores 4xx y 5xx
   - Excepciones con stack traces

6. **Logs (Queries KQL)**
   - `Monitoring` → `Logs`
   - Ejecutar queries Kusto (ver sección siguiente)

### Opción 2: Log Analytics Workspace

1. **Abrir Log Analytics Workspace**
   ```
   Portal Azure → "law-azmon-poc-eastus2" → Logs
   ```

2. **Ejecutar queries** (ver sección de Queries)

## 📝 Queries de Validación (KQL)

### Query 1: Requests HTTP por Status Code
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| summarize count() by ScStatus
| order by count_ desc
| render piechart
```

### Query 2: Top 10 Endpoints Más Lentos
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| where TimeTaken > 0
| summarize avg_time=avg(TimeTaken), count=count() by CsUriStem
| order by avg_time desc
| take 10
```

### Query 3: Tasa de Errores por Hora
```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| summarize 
    total=count(),
    errors=countif(ScStatus >= 400)
    by bin(TimeGenerated, 1h)
| extend error_rate = (errors * 100.0) / total
| project TimeGenerated, total, errors, error_rate
| render timechart
```

### Query 4: Logs de Aplicación (Python)
```kusto
AppServiceConsoleLogs
| where TimeGenerated > ago(1h)
| where ResultDescription contains "custom_dimensions"
| project TimeGenerated, ResultDescription
| order by TimeGenerated desc
| take 50
```

### Query 5: Trazas de Application Insights
```kusto
requests
| where timestamp > ago(1h)
| project 
    timestamp,
    name,
    url,
    success,
    resultCode,
    duration,
    operation_Id
| order by timestamp desc
| take 100
```

### Query 6: Excepciones Capturadas
```kusto
exceptions
| where timestamp > ago(1h)
| project 
    timestamp,
    type,
    outerMessage,
    operation_Name,
    problemId
| order by timestamp desc
```

### Query 7: Performance Percentiles
```kusto
requests
| where timestamp > ago(1h)
| where success == true
| summarize 
    p50=percentile(duration, 50),
    p90=percentile(duration, 90),
    p95=percentile(duration, 95),
    p99=percentile(duration, 99)
    by name
| order by p99 desc
```

## 💰 Estimación de Costos

### Componentes

| Recurso | SKU/Tier | Costo Mensual (USD) |
|---------|----------|---------------------|
| App Service Plan | B1 (Basic) | ~$13 |
| Application Insights | Pay-as-you-go | ~$2-5 (POC) |
| Log Analytics (compartido) | Incluido en Escenario 0 | $0 |

**Total mensual:** ~$15-18 USD

### Optimizaciones para Costos

- **Desarrollo:** Usar Free tier de App Service (F1)
- **POC:** B1 es suficiente
- **Producción:** S1 o superior para SLA 99.95%

## 🔧 Troubleshooting

### La aplicación no responde después del despliegue

```powershell
# Verificar logs del App Service
az webapp log tail --name <app-name> --resource-group rg-azmon-poc-eastus2

# Verificar configuración de startup
az webapp config show --name <app-name> --resource-group rg-azmon-poc-eastus2 --query linuxFxVersion
```

### No aparecen datos en Application Insights

**Causas comunes:**
1. **Delay natural:** Los datos tardan 1-2 minutos en aparecer
2. **Connection string incorrecta:** Verificar app settings del App Service
3. **Sampling:** Verificar que no esté configurado al 0%

```powershell
# Verificar connection string
az webapp config appsettings list --name <app-name> --resource-group rg-azmon-poc-eastus2 | grep APPLICATIONINSIGHTS
```

### Errores 500 constantes

```powershell
# Ver logs de error detallados
az webapp log download --name <app-name> --resource-group rg-azmon-poc-eastus2

# Verificar que las dependencias se instalaron
az webapp ssh --name <app-name> --resource-group rg-azmon-poc-eastus2
# Dentro del SSH:
pip list | grep opencensus
```

## 🎓 Aprendizajes Clave

### 1. Application Insights vs Log Analytics

**Application Insights:**
- Frontend de observabilidad (UI y SDK)
- Orientado a desarrolladores
- Visualizaciones out-of-the-box
- Live metrics, Application Map, Smart Detection

**Log Analytics:**
- Backend de almacenamiento
- Queries avanzadas con KQL
- Retención configurable
- Integración cross-resource

**Relación:** Application Insights envía datos a Log Analytics Workspace

### 2. Tipos de Telemetría

**Requests:** Cada llamada HTTP
**Dependencies:** Llamadas a servicios externos (DB, APIs)
**Exceptions:** Errores no controlados
**Traces:** Logs custom con logging framework
**Events:** Eventos custom de negocio
**Metrics:** Valores numéricos (counters, gauges)

### 3. Sampling en Application Insights

**¿Qué es?**
Reducir volumen de datos capturando solo un % de requests

**Cuándo usar:**
- POC: 100% (para ver todo)
- Dev/QA: 50-100%
- Producción: 10-20% (ahorra costos)

**Tipos:**
- Fixed: Mismo % siempre
- Adaptive: Se ajusta automáticamente según tráfico

### 4. Custom Dimensions

Enriquecen logs con contexto adicional:
```python
logger.info('User action', extra={
    'custom_dimensions': {
        'user_id': '12345',
        'action': 'purchase',
        'amount': 99.99
    }
})
```

Luego se pueden consultar:
```kusto
traces
| where customDimensions.action == "purchase"
| summarize total=sum(todouble(customDimensions.amount))
```

### 5. Buenas Prácticas Empresariales

**Alertas:**
- Configurar alertas en errores >5%
- Latencia >3 segundos
- CPU >80%
- Disponibilidad <99%

**Dashboards:**
- Crear dashboards compartidos para el equipo
- Incluir métricas de negocio (usuarios activos, transacciones)

**Retención:**
- Producción: 90-180 días en Application Insights
- Archive: Exportar a Storage Account para >180 días

**Seguridad:**
- Nunca loguear información sensible (passwords, PII)
- Usar sampling en producción
- Configurar RBAC apropiado

## 🧹 Limpieza de Recursos

```powershell
# Destruir infraestructura del escenario
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service
terraform destroy -auto-approve
```

**Nota:** Esto NO destruye el escenario 0 (infraestructura compartida)

## 🔗 Recursos Relacionados

### Escenarios
- ⬅️ [Escenario 0 - Infraestructura Compartida](../00-shared-infrastructure/README.md)
- ➡️ [Escenario 2 - Azure Functions](../02-azure-functions/README.md) (próximamente)

### Documentación Microsoft
- [Application Insights Overview](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [OpenCensus Python](https://github.com/census-instrumentation/opencensus-python)
- [KQL Quick Reference](https://learn.microsoft.com/azure/data-explorer/kql-quick-reference)
- [App Service Monitoring](https://learn.microsoft.com/azure/app-service/troubleshoot-diagnostic-logs)

### Tutoriales
- [Monitor Python apps with Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/opencensus-python)
- [Query Application Insights with KQL](https://learn.microsoft.com/azure/azure-monitor/logs/get-started-queries)

---

**📊 Estado del Escenario:** ✅ Completo y listo para uso

**👨‍💼 Autor:** Arquitecto Cloud Senior
**📅 Última actualización:** 2025-01-06
