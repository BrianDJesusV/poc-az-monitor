# 🎉 TRÁFICO GENERADO EXITOSAMENTE - Azure Monitor POC
**Fecha:** 7 de enero de 2026
**Estado:** COMPLETADO

---

## 📊 RESUMEN DE TRÁFICO GENERADO

### **Primera Tanda**
```
Total Requests: 100
Exitosos (200 OK): 48 (48%)
Errores (404): 52 (52%)
Duración: 58.3 segundos
Rate: 1.72 req/s
```

### **Segunda Tanda**
```
Total Requests: 200
Exitosos (200 OK): 101 (50.5%)
Errores (404): 99 (49.5%)
Duración: 72.2 segundos
Rate: 2.77 req/s
```

### **TOTAL GENERADO**
```
Total Requests: 300
Exitosos: 149 requests (49.7%)
Errores: 151 requests (50.3%)
Tiempo Total: ~130 segundos
```

---

## 🎯 DISTRIBUCIÓN DE ENDPOINTS

**Endpoints con 200 OK:**
- `/` (página principal)
- `/health` (health check)

**Endpoints con 404 Not Found:**
- `/api/success`
- `/api/slow`
- `/api/error`
- `/api/notfound`

**NOTA:** Los errores 404 son **esperados y útiles** ya que la versión simple de la app solo tiene `/` y `/health`. Esto demuestra cómo Application Insights captura y reporta errores.

---

## 📈 VISUALIZAR TELEMETRÍA EN APPLICATION INSIGHTS

### **PASO 1: Acceder a Application Insights**

**Opción A - Link Directo:**
```
https://portal.azure.com/#@/resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/rg-azmon-poc-mexicocentral/providers/Microsoft.Insights/components/appi-azmon-appservice-ltr94a
```

**Opción B - Manual:**
1. Ir a https://portal.azure.com
2. Buscar: `appi-azmon-appservice-ltr94a`
3. Click en el recurso de Application Insights

---

### **PASO 2: Explorar Telemetría**

#### **A. Performance (Rendimiento)**

1. En el menú izquierdo, click en **"Performance"** o **"Investigate" → "Performance"**
2. Verás un dashboard con:
   - **Server response time** (tiempo de respuesta del servidor)
   - **Server requests** (número de requests)
   - **Failed requests** (requests fallidos)

3. **Analizar por endpoint:**
   - Scroll down para ver la tabla de operations
   - Click en `/` o `/health` para ver detalles
   - Observa:
     - Count (número de requests)
     - Duration (tiempo promedio de respuesta)
     - Success rate (tasa de éxito)

#### **B. Failures (Fallos)**

1. Click en **"Failures"** en el menú izquierdo
2. Verás:
   - **Failed requests** con códigos de error
   - Gráficos de tendencias
   - Desglose por tipo de error

3. **Analizar errores 404:**
   - Click en **"404"** en el filtro de response codes
   - Verás todos los endpoints que dieron 404
   - Click en cualquiera para ver stack trace y detalles

#### **C. Logs (Consultas KQL)**

1. Click en **"Logs"** en el menú izquierdo
2. Se abrirá el editor de queries KQL
3. Cierra cualquier ventana de ayuda que aparezca

**Queries útiles para ejecutar:**

```kusto
// Ver todos los requests de la última hora
requests
| where timestamp > ago(1h)
| summarize count() by name, resultCode
| order by count_ desc
```

```kusto
// Requests exitosos vs fallidos
requests
| where timestamp > ago(1h)
| summarize 
    Total = count(),
    Exitosos = countif(success == true),
    Fallidos = countif(success == false)
```

```kusto
// Requests por endpoint con tiempos
requests
| where timestamp > ago(1h)
| summarize 
    Count = count(),
    AvgDuration = avg(duration),
    MaxDuration = max(duration),
    MinDuration = min(duration)
    by name
| order by Count desc
```

```kusto
// Requests al endpoint /health específicamente
requests
| where name == "GET /health"
| where timestamp > ago(1h)
| project timestamp, duration, resultCode, success
| order by timestamp desc
| take 20
```

```kusto
// Distribución de códigos de respuesta
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
| render piechart
```

```kusto
// Timeline de requests (últimos 10 minutos)
requests
| where timestamp > ago(10m)
| summarize count() by bin(timestamp, 1m), name
| render timechart
```

```kusto
// Requests lentos (más de 500ms)
requests  
| where timestamp > ago(1h)
| where duration > 500
| project timestamp, name, duration, resultCode
| order by duration desc
```

#### **D. Application Map (Mapa de Aplicación)**

1. Click en **"Application Map"** en el menú izquierdo
2. Verás una visualización de tu aplicación y sus dependencias
3. Cada nodo muestra:
   - Número de requests
   - Tasa de fallo
   - Tiempo promedio de respuesta

---

## 🔍 QUÉ BUSCAR EN LA TELEMETRÍA

### **Métricas Clave:**

1. **Request Count**
   - Deberías ver ~300 requests en total
   - Distribuidos en los últimos ~2 minutos

2. **Success Rate**
   - ~50% exitosos (200 OK)
   - ~50% fallidos (404)

3. **Response Times**
   - `/health` y `/` deberían ser muy rápidos (<100ms)
   - Los 404 también son rápidos

4. **Error Distribution**
   - Todos los errores deberían ser 404 (Not Found)
   - No deberías ver 500 (Server Error)

---

## 📝 QUERIES KQL AVANZADAS

### **1. Análisis de Tendencias**
```kusto
requests
| where timestamp > ago(1h)
| summarize 
    Requests = count(),
    SuccessRate = round(100.0 * countif(success)/count(), 2)
    by bin(timestamp, 1m)
| render timechart
```

### **2. Top Endpoints**
```kusto
requests
| where timestamp > ago(1h)
| summarize 
    Total = count(),
    P50 = percentile(duration, 50),
    P95 = percentile(duration, 95),
    P99 = percentile(duration, 99)
    by name
| order by Total desc
```

### **3. Error Analysis**
```kusto
requests
| where timestamp > ago(1h)
| where success == false
| summarize count() by name, resultCode
| order by count_ desc
```

---

## 🎨 CREAR DASHBOARD PERSONALIZADO

1. En Application Insights, click en **"Dashboards"** → **"New Dashboard"**
2. Arrastra widgets de:
   - Request count
   - Failed request rate
   - Server response time
   - Application map
3. Guarda el dashboard con un nombre descriptivo

---

## 🔔 CONFIGURAR ALERTAS (OPCIONAL)

1. Click en **"Alerts"** en el menú izquierdo
2. Click en **"+ Create"** → **"Alert rule"**
3. Configura una alerta, por ejemplo:
   - **Condition:** Failed request rate > 10%
   - **Action:** Email notification
   - **Name:** "High Error Rate Alert"

---

## 📊 PRÓXIMOS PASOS

### **Opción 1: Generar Más Tráfico**

Ejecuta el script nuevamente:
```powershell
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service
.\generate_traffic.ps1 -TotalRequests 500
```

### **Opción 2: Actualizar a Versión Completa**

Para tener endpoints que respondan exitosamente a `/api/*`:

```bash
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\files\flask_example

wsl az webapp deploy \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a \
  --src-path "/mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/01-app-service/files/flask_example/flask-deploy.zip" \
  --type zip
```

Luego genera tráfico nuevamente para ver métricas con variedad de:
- Requests exitosos
- Requests lentos (2-4 segundos)
- Errores 500
- Errores 404

---

## ✅ VERIFICACIÓN RÁPIDA

**Para verificar que la telemetría está llegando:**

1. Ir a Application Insights
2. Click en "Live Metrics"
3. Generar tráfico con el script
4. Ver en tiempo real:
   - Incoming requests
   - Request duration
   - Request rate
   - Server metrics

---

**¡Telemetría generada exitosamente!** 🎉

**Timestamp:** 2026-01-07 19:00:00 UTC
