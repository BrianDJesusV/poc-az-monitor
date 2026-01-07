# 🔍 POC Azure Monitor - Observabilidad en Azure

> **Proof of Concept completado para demostrar capacidades de Azure Monitor, Log Analytics y Application Insights**

**Estado Actual:** ✅ Escenario 1 COMPLETADO (7 de enero, 2026)  
**Región:** Mexico Central  
**Tiempo de Setup:** 30 minutos desde cero

---

## 📋 ¿Qué es Este Proyecto?

POC **modular e incremental** para probar y visualizar los componentes de observabilidad de Azure en escenarios prácticos.

### 🎯 Objetivos Cumplidos

- ✅ **Infraestructura completa** desplegada con Terraform
- ✅ **Application Insights** capturando telemetría en tiempo real
- ✅ **Queries KQL** documentadas y probadas
- ✅ **Generación de tráfico** automatizada (PowerShell + Postman)
- ✅ **Documentación exhaustiva** para transfer de conocimiento
- ✅ **Lecciones aprendidas** documentadas (F1 vs B1, deployment methods)

---

## 🏗️ Estructura del Proyecto

```
poc_azure_monitor/
│
├── 📁 00-shared-infrastructure/     ✅ DESPLEGADO
│   └── Log Analytics Workspace + Solutions
│   └── Resource Group (Mexico Central)
│
├── 📁 01-app-service/               ✅ COMPLETADO
│   ├── App Service Plan (B1)
│   ├── Web App (Python Flask)
│   ├── Application Insights
│   ├── Scripts de tráfico
│   └── Postman Collection
│
├── 📁 docs/                         ✅ DOCUMENTACIÓN COMPLETA
│   ├── ESCENARIO_1_KNOWLEDGE_TRANSFER.md    ⭐⭐⭐ LEER PRIMERO
│   ├── RESUMEN_EJECUTIVO_ESCENARIO_1.md     ⭐⭐ Quick Reference
│   ├── INVENTARIO_PROYECTO.md               📂 Índice completo
│   └── [10+ documentos adicionales]
│
└── 📁 02-azure-functions/           ⏳ Próximamente
```

---

## 🚀 INICIO RÁPIDO (15 minutos)

### **Opción 1: Replicar Desde Cero**

```bash
# 1. Clonar/Navegar
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor

# 2. Autenticarse
az login
az account set --subscription "dd4fe3a1-a740-49ad-b613-b4f951aa474c"

# 3. Deploy infra compartida (5 min)
cd 00-shared-infrastructure
terraform init
terraform apply

# 4. Deploy App Service (5 min)
cd ../01-app-service
terraform init
terraform apply

# 5. Deploy aplicación (2 min)
cd files/flask_example
az webapp deploy \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-<random> \
  --src-path simple-flask.zip \
  --type zip

# 6. Generar tráfico (3 min)
cd ../..
.\generate_traffic.ps1 -TotalRequests 200
```

### **Opción 2: Explorar Proyecto Existente**

```bash
# 1. Revisar estado
cd 01-app-service
terraform show

# 2. Ver recursos desplegados
az resource list \
  --resource-group rg-azmon-poc-mexicocentral \
  --output table

# 3. Generar tráfico
.\generate_traffic.ps1 -TotalRequests 100

# 4. Ver métricas
# Azure Portal → Application Insights → appi-azmon-appservice-ltr94a
```

---

## 📚 DOCUMENTACIÓN ESENCIAL

### **🌟 Documento Principal (LEER PRIMERO)**
```
docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md (627 líneas)
```
**Contiene TODO lo importante:**
- ✅ Arquitectura completa con diagramas
- ✅ 6 queries KQL esenciales
- ✅ Lecciones aprendidas (F1 vs B1, deployments)
- ✅ Troubleshooting completo
- ✅ Scripts de demo (5 y 10 minutos)
- ✅ Checklist de validación
- ✅ Cómo replicar paso a paso

### **⚡ Resumen Ejecutivo (30 segundos)**
```
docs/RESUMEN_EJECUTIVO_ESCENARIO_1.md (175 líneas)
```
**Quick reference con:**
- ✅ Top 3 lecciones aprendidas
- ✅ Queries KQL copy-paste
- ✅ Replicación en 15 minutos
- ✅ Demo en 5 minutos

### **📂 Índice Completo**
```
docs/INVENTARIO_PROYECTO.md
```
**Mapa de todos los archivos del proyecto**

---

## 🎯 ESCENARIOS

| # | Escenario | Estado | Documentación | Recursos |
|---|-----------|--------|---------------|----------|
| 0 | Shared Infrastructure | ✅ | terraform.tfstate | LAW + Solutions |
| 1 | App Service + App Insights | ✅ | KNOWLEDGE_TRANSFER.md | ASP + Web App + App Insights |
| 2 | Azure Functions | ⏳ | - | Planeado |
| 3 | Container Apps | ⏳ | - | Planeado |

---

## 📊 LO QUE ESTE POC DEMUESTRA

### **1. Application Performance Monitoring (APM)**
- ✅ Telemetría automática de HTTP requests
- ✅ Response times y latencias
- ✅ Success/failure rates
- ✅ Dependency tracking
- ✅ Live Metrics (tiempo real)

### **2. Log Analytics Integration**
- ✅ Workspace compartido entre servicios
- ✅ Retención configurable (30 días)
- ✅ Queries KQL para análisis avanzado

### **3. Alertas y Smart Detection**
- ✅ Action Groups configurados
- ✅ Smart Detection habilitado
- ✅ Detección automática de anomalías

---

## 🔑 QUERIES KQL ESENCIALES

### **Request Distribution**
```kusto
requests
| where timestamp > ago(1h)
| summarize count() by name, resultCode
| order by count_ desc
```

### **Success Rate**
```kusto
requests
| where timestamp > ago(1h)
| summarize 
    Total = count(),
    Exitosos = countif(success == true),
    SuccessRate = round(100.0 * countif(success)/count(), 2)
```

### **Performance Analysis (P95)**
```kusto
requests
| where timestamp > ago(1h)
| summarize P95 = percentile(duration, 95) by name
| order by P95 desc
```

### **Timeline Visualization**
```kusto
requests
| where timestamp > ago(1h)
| summarize count() by bin(timestamp, 1m)
| render timechart
```

**Más queries:** Ver `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md`

---

## 🛠️ HERRAMIENTAS DE GENERACIÓN DE TRÁFICO

### **1. Script PowerShell (Recomendado)**
```powershell
cd 01-app-service
.\generate_traffic.ps1 -TotalRequests 200 -IntervalMs 500
```
**Ventajas:** Rápido, configurable, sin dependencias

### **2. Script Python**
```bash
python generate_traffic.py https://app-azmon-demo-ltr94a.azurewebsites.net
```
**Ventajas:** Cross-platform, detallado

### **3. Postman Collection (Testing Manual)**
```
Archivos:
- Azure_Monitor_POC_Collection.postman_collection.json
- Azure_Monitor_POC.postman_environment.json

Guías:
- GUIA_POSTMAN.md (512 líneas)
- POSTMAN_QUICKSTART.md (100 líneas)
```
**Ventajas:** Visual, Collection Runner, tests automáticos

---

## 💡 LECCIONES APRENDIDAS CLAVE

### **1. F1 Free Tier → No Sirve para POCs**
```
Problema: QuotaExceeded, builds fallan
Solución: Usar B1 Basic ($13/mes)
```

### **2. Deployment Method**
```
✅ FUNCIONA: az webapp deploy --type zip
❌ NO FUNCIONA: az webapp up (con F1/B1)
```

### **3. Regional Quotas**
```
East US 2: ❌ Quota bloqueada
Mexico Central: ✅ Quota disponible
```

### **4. Data Lag**
```
Live Metrics: Instantáneo
Logs/Performance: 2-5 minutos
→ Planear demos con esto en mente
```

**Más detalles:** `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md`

---

## 🎨 HACER UNA DEMO

### **Demo Rápida (5 minutos)**

1. **Mostrar arquitectura** (1 min)
   - Diagrama de componentes
   - Flujo de telemetría

2. **Generar tráfico** (1 min)
   ```powershell
   .\generate_traffic.ps1 -TotalRequests 50
   ```

3. **Live Metrics** (1 min)
   - Mostrar requests en tiempo real
   - Response times

4. **Queries KQL** (2 min)
   - Performance analysis
   - Error distribution

**Script completo:** `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md` (sección "Demos")

---

## 💰 COSTOS

### **Configuración Actual (B1)**
```
App Service Plan B1:      ~$13.14/mes
Application Insights:     $0.00 (5GB/mes gratis)
Log Analytics:            $0.00 (5GB/mes gratis)
TOTAL:                    ~$13.15/mes
```

### **Cómo Reducir Costos**
```bash
# Downgrade a F1 (si deployment ya está listo)
az appservice plan update \
  --resource-group rg-azmon-poc-mexicocentral \
  --name asp-azmon-poc-ltr94a \
  --sku F1

# Destruir recursos cuando no se usen
terraform destroy
```

---

## 🔧 TROUBLESHOOTING

### **No aparecen métricas en Application Insights**

**Solución rápida:**
```bash
# 1. Verificar Connection String
az webapp config appsettings list \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a \
  --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"

# 2. Reiniciar app
az webapp restart \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a

# 3. Esperar 5 minutos y verificar en Live Metrics
```

**Troubleshooting completo:** `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md`

---

## 📦 ARCHIVOS CRÍTICOS

### **Backup Inmediato (NO PERDER)**
```
✅ 00-shared-infrastructure/terraform.tfstate
✅ 00-shared-infrastructure/terraform.tfvars
✅ 01-app-service/terraform.tfstate
✅ 01-app-service/terraform.tfvars
```

### **Documentación Crítica**
```
✅ docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md
✅ docs/RESUMEN_EJECUTIVO_ESCENARIO_1.md
✅ docs/INVENTARIO_PROYECTO.md
```

### **Apps y Scripts**
```
✅ 01-app-service/files/flask_example/*.zip
✅ 01-app-service/generate_traffic.ps1
✅ 01-app-service/*.postman_collection.json
```

---

## 🌐 RECURSOS DESPLEGADOS

### **Resource Group: rg-azmon-poc-mexicocentral**
```
1. law-azmon-poc-mexicocentral              (Log Analytics)
2. AzureActivity(law-azmon-poc...)          (Solution)
3. ContainerInsights(law-azmon-poc...)      (Solution)
4. Security(law-azmon-poc...)               (Solution)
5. asp-azmon-poc-ltr94a                     (App Service Plan B1)
6. app-azmon-demo-ltr94a                    (Web App)
7. appi-azmon-appservice-ltr94a             (Application Insights)
8. Application Insights Smart Detection      (Action Group)
```

### **URLs de Acceso**
```
Web App:          https://app-azmon-demo-ltr94a.azurewebsites.net
Kudu:             https://app-azmon-demo-ltr94a.scm.azurewebsites.net
App Insights:     [Ver en Azure Portal]
```

---

## 🏆 CHECKLIST DE VALIDACIÓN

### **Infraestructura**
- [x] Resource Group creado
- [x] Log Analytics Workspace operacional
- [x] App Service Plan desplegado
- [x] Web App funcionando
- [x] Application Insights configurado

### **Aplicación**
- [x] Flask app desplegada
- [x] Endpoints /health y / responden 200 OK
- [x] Connection String configurado
- [x] Telemetría llegando a App Insights

### **Monitoreo**
- [x] Live Metrics muestra datos en tiempo real
- [x] Performance dashboard poblado
- [x] Queries KQL funcionan
- [x] Al menos 300 requests generados

### **Documentación**
- [x] KNOWLEDGE_TRANSFER.md completo
- [x] RESUMEN_EJECUTIVO.md creado
- [x] INVENTARIO_PROYECTO.md actualizado
- [x] Screenshots capturados
- [x] Terraform states respaldados

---

## 📈 ESTADÍSTICAS DEL PROYECTO

```
Recursos Azure:           8
Archivos Terraform:       20
Líneas Documentación:     ~3500+
Queries KQL:              6 esenciales + variaciones
Scripts:                  3 (PowerShell, Python, Postman)
Tiempo Setup:             30 minutos
Tiempo Demo:              5-10 minutos
Costo Mensual:            ~$13/mes (B1)
```

---

## 🚀 PRÓXIMOS PASOS

### **Inmediato**
1. Explorar Application Insights
2. Ejecutar queries KQL documentadas
3. Hacer una demo de 5 minutos

### **Corto Plazo**
1. Escenario 2: Azure Functions
2. Dashboard consolidado
3. Alertas personalizadas

### **Mediano Plazo**
1. Escenario 3: Container Apps
2. Distributed tracing avanzado
3. Integración con Prometheus

---

## 📞 RECURSOS Y SOPORTE

### **Documentación del Proyecto**
- **Principal:** `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md`
- **Quick Reference:** `docs/RESUMEN_EJECUTIVO_ESCENARIO_1.md`
- **Inventario:** `docs/INVENTARIO_PROYECTO.md`
- **Postman:** `01-app-service/GUIA_POSTMAN.md`

### **Documentación Oficial Azure**
- [Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/)
- [KQL Reference](https://docs.microsoft.com/azure/data-explorer/kudu-query-language)

---

## 🎓 ¿NUEVO EN EL PROYECTO?

### **Lee en este orden:**
1. Este README (overview general)
2. `docs/RESUMEN_EJECUTIVO_ESCENARIO_1.md` (30 segundos)
3. `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md` (documento completo)
4. `docs/INVENTARIO_PROYECTO.md` (mapa de archivos)

### **Para empezar:**
```bash
cd 01-app-service
.\generate_traffic.ps1 -TotalRequests 50
# Luego ir a Azure Portal → Application Insights
```

---

**📅 Última actualización:** 7 de enero de 2026  
**🔖 Versión:** 2.0 (Escenario 1 Completado)  
**👤 Mantenido por:** Brian Poch  
**📧 Contacto:** brian.poch@hotmail.com  

**⭐ Escenario 1: COMPLETADO ✅**  
**🎯 POC: FUNCIONAL Y DOCUMENTADO 100%**
