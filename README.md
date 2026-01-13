# POC Azure Monitor - Observabilidad Completa

## 📋 Descripción

Proof of Concept completo de Azure Monitor con tres escenarios que demuestran:
- Monitoreo centralizado con Log Analytics
- Observabilidad de aplicaciones con Application Insights
- Telemetría serverless con Azure Functions
- Queries KQL para análisis y correlación

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Escenario 0: Shared Infrastructure                    │
│  ┌───────────────────────────────────────────────┐    │
│  │  Log Analytics Workspace                       │    │
│  │  - Container Insights                          │    │
│  │  - Security Solution                           │    │
│  │  - Azure Activity Logs                         │    │
│  └───────────────────────────────────────────────┘    │
│                         ▲                               │
│                         │                               │
│         ┌───────────────┴───────────────┐              │
│         │                               │              │
│         │                               │              │
│  ┌──────┴────────┐              ┌──────┴────────┐    │
│  │ Escenario 1   │              │ Escenario 2   │    │
│  │ App Service   │              │ Functions     │    │
│  │ + App Insights│              │ + App Insights│    │
│  └───────────────┘              └───────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### **1. Configurar Seguridad**

El proyecto ya tiene `.gitignore` configurado para proteger credenciales.

### **2. Desplegar Todo**

```powershell
.\DEPLOY_SECURE.ps1
```

Cuando pregunte, escribe: `TODO`

### **3. Verificar Deployment**

```powershell
.\CHECK_READY.ps1
```

## 📂 Estructura del Proyecto

```
poc_azure_monitor/
├── .gitignore                      (Protección de credenciales)
├── README.md                       (este archivo)
├── DEPLOY_SECURE.ps1              (⭐ Script principal deployment)
├── CHECK_READY.ps1                (Verificación post-limpieza)
│
├── docs/                          (Documentación general)
│   ├── SECURITY_IMPROVEMENTS.md
│   ├── CLEANUP_GUIDE.md
│   └── guías rápidas (.txt)
│
├── scripts/                       (Scripts auxiliares)
│   ├── DELETE_ALL.ps1
│   ├── CLEAN_GIT_HISTORY.ps1
│   └── SECURITY_INCIDENT_RESPONSE.ps1
│
├── 00-shared-infrastructure/      (Escenario 0)
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── 01-app-service/               (Escenario 1)
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── app/                      (Código Flask)
│   ├── scripts/                  (Generate traffic)
│   ├── files/                    (Postman collections)
│   └── docs/                     (Guías Postman)
│
└── 02-azure-functions/           (Escenario 2)
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    ├── functions/                (Código Functions)
    ├── scripts/                  (Deployment scripts)
    └── docs/                     (Guías deployment)
```

## 📋 Escenarios

### **Escenario 0: Shared Infrastructure** 💰 $0/mes

Base compartida:
- Log Analytics Workspace
- Monitoring Solutions

📖 [Ver detalles](00-shared-infrastructure/README.md)

### **Escenario 1: App Service** 💰 ~$13/mes

Aplicación web con monitoreo:
- App Service (B1)
- Application Insights
- Flask Python app

📖 [Ver detalles](01-app-service/README.md)

### **Escenario 2: Azure Functions** 💰 ~$70/mes

Serverless con triggers:
- Function App (S1)
- 4 Functions (HTTP, Timer, Queue, Blob)
- Application Insights

📖 [Ver detalles](02-azure-functions/README.md)

## 💰 Costos

| Escenario | Recursos | Costo |
|-----------|----------|-------|
| 0 | Log Analytics Workspace | $0/mes |
| 1 | App Service B1 + App Insights | ~$13/mes |
| 2 | Functions S1 + Storage + App Insights | ~$70/mes |
| **TOTAL** | | **~$83/mes** |

## 🔒 Seguridad

### **Protecciones Implementadas**

✅ `.gitignore` configurado (previene exposure de credenciales)  
✅ NO se crean `outputs.json` con secrets  
✅ Credenciales solo en memoria durante deployment  
✅ ZIPs temporales excluidos de Git  
✅ Terraform states protegidos  

### **Archivos NUNCA comitear**

❌ `*.tfstate`  
❌ `*.tfstate.backup`  
❌ `outputs.json`  
❌ `outputs.txt`  
❌ `*.zip`  

## 🧹 Limpieza

Para eliminar todos los recursos:

```powershell
.\scripts\DELETE_ALL.ps1
```

Luego verifica que todo esté limpio:

```powershell
.\CHECK_READY.ps1
```

## 📊 Monitoreo y Queries

### **Acceso a Logs**

Azure Portal → Log Analytics Workspace → Logs

### **Queries de Ejemplo**

```kql
// Ver todas las requests de App Service
AppRequests
| where TimeGenerated > ago(24h)
| summarize Count=count() by bin(TimeGenerated, 5m)
| render timechart

// Ver ejecuciones de Functions
traces
| where cloud_RoleName contains "func-azmon"
| where TimeGenerated > ago(1h)
| project TimeGenerated, message, severityLevel
```

## 🛠️ Comandos Útiles

### **Deployment**
```powershell
.\DEPLOY_SECURE.ps1                 # Desplegar todo
```

### **Verificación**
```powershell
.\CHECK_READY.ps1                   # Verificar estado
az group list --query "[?starts_with(name, 'rg-azmon')].name"  # Ver resources
```

### **Limpieza**
```powershell
.\scripts\DELETE_ALL.ps1            # Eliminar todo
```

## 📚 Documentación Adicional

- [Mejoras de Seguridad](docs/SECURITY_IMPROVEMENTS.md)
- [Guía de Limpieza](docs/CLEANUP_GUIDE.md)
- [Deployment Manual Functions](docs/DEPLOYMENT_MANUAL_GUIDE.md)

## ⚠️ Notas Importantes

1. **Región**: Mexico Central para todos los recursos
2. **Orden de deployment**: Escenario 0 → 1 → 2
3. **Functions**: Deployment manual via Portal (CLI puede fallar)
4. **Quota**: Standard S1 usado por limitaciones de Consumption Plan
5. **Seguridad**: Siempre verificar `.gitignore` antes de commits

## 🎯 Próximos Pasos

Después del deployment:

1. ✅ Verificar recursos en Azure Portal
2. ✅ Ejecutar queries KQL en Log Analytics
3. ✅ Revisar Application Insights Live Metrics
4. ✅ Generar tráfico de prueba
5. ✅ Analizar telemetría y correlación

## 📝 Lecciones Aprendidas

- **Seguridad**: Nunca exponer `*.tfstate` o `outputs.json` en Git
- **Deployment**: Portal más confiable que CLI para Functions
- **Quotas**: Verificar disponibilidad regional antes de planear
- **Monitoreo**: Centralización en LAW facilita correlación

## 🔗 Enlaces

- [Azure Monitor Docs](https://docs.microsoft.com/azure/azure-monitor/)
- [KQL Reference](https://docs.microsoft.com/azure/data-explorer/kusto/query/)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)

---

**Fecha de última actualización**: Enero 2026  
**Estado**: Listo para deployment ✅
