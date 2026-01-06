# 🏛️ Arquitectura General - POC Azure Monitor

## 📋 Visión General

Esta POC está diseñada para **entender, probar y visualizar** los componentes de observabilidad de Azure de manera práctica y educativa.

## 🎯 Objetivos de la POC

1. **Comprender** cómo funciona Azure Monitor, Log Analytics e Insights
2. **Visualizar** métricas, logs y trazas en escenarios reales
3. **Experimentar** con diferentes tipos de recursos de Azure
4. **Aprender** KQL (Kusto Query Language) para análisis de logs
5. **Dominar** Application Insights para APM (Application Performance Monitoring)

## 🏗️ Arquitectura de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Subscription                        │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Escenario 0: Infraestructura Compartida              │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Resource Group: rg-azmon-poc-{region}          │ │ │
│  │  │  Log Analytics Workspace (Central)              │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                         ↑                                    │
│                         │ Envía logs/métricas                │
│                         │                                    │
│  ┌─────────────────────┴──────────────────────────────────┐ │
│  │  Escenarios de Monitoreo (Independientes)             │ │
│  │                                                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │ │
│  │  │ Escenario 1  │  │ Escenario 2  │  │ Escenario 3│ │ │
│  │  │ App Service  │  │   Functions  │  │Container   │ │ │
│  │  │              │  │              │  │   Apps     │ │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │ │
│  │                                                        │ │
│  │  ┌──────────────┐                                     │ │
│  │  │ Escenario 4  │                                     │ │
│  │  │   ARO/AKS    │                                     │ │
│  │  └──────────────┘                                     │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📂 Estructura del Proyecto

```
poc_azure_monitor/
│
├── 00-shared-infrastructure/    # Base compartida (PREREQUISITO)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
│
├── 01-app-service/             # Web Apps tradicionales
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── test-app/
│   │   ├── app.py
│   │   └── requirements.txt
│   ├── generate_traffic.py
│   └── README.md
```

│
├── 02-azure-functions/         # Serverless/Event-driven
│   └── README.md
│
├── 03-container-apps/          # Contenedores modernos
│   └── README.md
│
├── 04-aro-openshift/           # Kubernetes enterprise
│   └── README.md
│
└── docs/                       # Documentación general
    ├── architecture.md         # Este archivo
    ├── monitoring-guide.md     # Guía de monitoreo
    └── kql-queries.md          # Queries útiles
```

## 🧩 Componentes Clave

### 1. Log Analytics Workspace
**Rol:** Repositorio central de todos los logs y métricas

**Características:**
- Almacenamiento centralizado
- Query engine (KQL)
- Retención configurable (30-730 días)
- Pricing: Pay-per-GB ingested

**Uso en la POC:**
- Recibe logs de todos los escenarios
- Permite queries cross-resource
- Facilita correlación de eventos

### 2. Application Insights
**Rol:** APM (Application Performance Monitoring)

**Características:**
- Workspace-based (envía a Log Analytics)
- Distributed tracing
- Smart detection (anomalías automáticas)
- Live metrics stream
- Application Map

**Uso en la POC:**
- Monitoreo de App Service
- Monitoreo de Functions
- Tracking de dependencias
- Performance profiling

### 3. Azure Monitor
**Rol:** Plataforma unificada de observabilidad

**Características:**
- Metrics Explorer
- Log queries (KQL)
- Alertas y notificaciones
- Dashboards
- Workbooks (reportes interactivos)

**Uso en la POC:**
- Visualización de métricas
- Configuración de alertas
- Creación de dashboards

## 🔄 Flujo de Datos

```
┌─────────────────┐
│  Azure Resource │
│  (App Service,  │
│   Functions,    │
│   Containers)   │
└────────┬────────┘
         │
         │ 1. Genera telemetría
         ↓
┌────────────────────────────┐
│  Diagnostic Settings       │
│  • Logs categories         │
│  • Metrics                 │
└────────┬───────────────────┘
         │
         │ 2. Envía datos
         ↓
┌────────────────────────────┐
│  Log Analytics Workspace   │
│  • Almacena logs           │
│  • Indexa para búsqueda    │
└────────┬───────────────────┘
         │
         │ 3. Query/Visualización
         ↓
┌────────────────────────────┐
│  Consumo                   │
│  • KQL Queries             │
│  • Dashboards              │
│  • Alertas                 │
│  • Application Insights UI │
└────────────────────────────┘
```


## 🎨 Decisiones de Diseño

### 1. Infraestructura Compartida (Escenario 0)
**Decisión:** Un solo Log Analytics Workspace para toda la POC

**Justificación:**
- ✅ Centralización de logs facilita correlación
- ✅ Reducción de costos (un solo ingestion pipeline)
- ✅ Queries cross-resource más simples
- ✅ Patrón empresarial estándar

**Alternativa descartada:** Workspace por escenario
- ❌ Mayor complejidad
- ❌ Mayor costo
- ❌ Dificultad para correlacionar eventos

### 2. Modularidad de Escenarios
**Decisión:** Cada escenario es independiente y desplegable por separado

**Justificación:**
- ✅ Facilita aprendizaje incremental
- ✅ Permite destruir recursos no usados
- ✅ Aisla problemas de deployment
- ✅ Reutilizable como templates

### 3. Naming Convention
**Patrón:** `{resource-type}-{project}-{scenario}-{environment}-{random}`

**Ejemplos:**
- `rg-azmon-poc-eastus2`
- `law-azmon-poc-eastus2`
- `app-azmon-appservice-poc-abc123`

**Justificación:**
- ✅ Autodescriptivo
- ✅ Facilita búsqueda en portal
- ✅ Previene colisiones de nombres
- ✅ Sigue Azure naming best practices

### 4. Tagging Strategy
**Tags obligatorios:**
```hcl
{
  Environment = "POC"
  Project     = "AzureMonitor"
  Scenario    = "01-AppService"
  Owner       = "CloudTeam"
  CostCenter  = "IT-Learning"
  ManagedBy   = "Terraform"
}
```

**Justificación:**
- ✅ Cost tracking por escenario
- ✅ Identificación de recursos
- ✅ Auditabilidad
- ✅ Automatización (cleanup scripts)

## 💰 Estimación de Costos

| Escenario | Componentes | Costo Mensual (Estimado) |
|-----------|-------------|--------------------------|
| **0: Shared Infra** | Log Analytics Workspace | $5-10 USD |
| **1: App Service** | B1 Plan + App Insights | $15-20 USD |
| **2: Functions** | Consumption + Storage | $5-10 USD |
| **3: Container Apps** | 0.5 vCPU, 1GB | $10-15 USD |
| **4: ARO** | 3+3 nodes mínimo | $500-800 USD |
| **TOTAL (sin ARO)** | | **$35-55 USD/mes** |

> **Nota:** Costos estimados para tráfico bajo. ARO es significativamente más costoso.

## 🎓 Curva de Aprendizaje Recomendada

```
Semana 1: Fundamentos
├─ Día 1-2: Escenario 0 (Infraestructura)
├─ Día 3-4: Escenario 1 (App Service)
└─ Día 5: Queries KQL básicas

Semana 2: Serverless
├─ Día 1-3: Escenario 2 (Functions)
├─ Día 4-5: Comparación App Service vs Functions
└─ Weekend: Crear dashboards personalizados

Semana 3: Contenedores
├─ Día 1-3: Escenario 3 (Container Apps)
└─ Día 4-5: Análisis de métricas de contenedores

Semana 4 (Opcional): Enterprise Kubernetes
└─ Evaluar necesidad de ARO/AKS
```


## 🏆 Mejores Prácticas Implementadas

### 1. Observabilidad
- ✅ Tres pilares: Logs, Métricas y Trazas
- ✅ Diagnostic Settings configurados desde IaC
- ✅ Application Insights integrado nativamente
- ✅ Distributed tracing habilitado

### 2. Costos
- ✅ Retención de logs ajustable (30 días para POC)
- ✅ Sampling de Application Insights configurable
- ✅ Recursos destruibles cuando no se usan
- ✅ Tags para cost tracking

### 3. Seguridad
- ✅ HTTPS only en App Service
- ✅ Connection strings como secrets
- ✅ Diagnostic settings audit logs habilitados
- ✅ Principle of least privilege

### 4. Operaciones
- ✅ Infrastructure as Code (Terraform)
- ✅ Documentación exhaustiva por escenario
- ✅ Scripts de automatización incluidos
- ✅ Naming convention consistente

## 📊 Comparación de Escenarios

| Característica | App Service | Functions | Container Apps | ARO |
|----------------|-------------|-----------|----------------|-----|
| **Complejidad** | Baja | Baja | Media | Alta |
| **Costo Mensual** | $15-20 | $5-10 | $10-15 | $500-800 |
| **Mejor para** | Web apps | Event-driven | Microservices | Enterprise K8s |
| **Cold Start** | No | Sí (Consumption) | Configurable | No |
| **Scaling** | Manual/Auto | Automático | Automático | Manual/Auto |
| **Observabilidad** | Excelente | Excelente | Buena | Avanzada |

## 🎯 Qué Aprenderás en Cada Escenario

### Escenario 1: App Service
- Request/Response tracking
- HTTP logs analysis
- Performance metrics
- Error rate monitoring
- Distributed tracing básico

### Escenario 2: Functions
- Execution count/duration
- Cold start monitoring
- Event-driven patterns
- Cost optimization
- Invocation logs

### Escenario 3: Container Apps
- Container metrics (CPU/Memory)
- Replica scaling
- Container logs
- Startup time analysis
- Multi-container patterns

### Escenario 4: ARO (Opcional)
- Node-level metrics
- Pod monitoring
- Cluster health
- Prometheus integration
- Distributed tracing avanzado

## 🔗 Integración entre Escenarios

Todos los escenarios comparten:
- ✅ Log Analytics Workspace (centralizado)
- ✅ Resource Group (mismo)
- ✅ Tagging strategy (consistente)
- ✅ Naming convention (estandarizada)

Esto permite:
- 🔍 Queries cross-resource
- 📊 Dashboards unificados
- 🚨 Alertas correlacionadas
- 💰 Cost tracking consolidado


## 🚀 Cómo Empezar

### Paso 1: Prerequisitos
```bash
# Verificar herramientas instaladas
az --version
terraform --version
python --version

# Login a Azure
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

### Paso 2: Desplegar Base
```bash
cd 00-shared-infrastructure
terraform init
terraform apply
```

### Paso 3: Primer Escenario
```bash
cd ../01-app-service
terraform init
terraform apply

# Deployar aplicación
cd test-app
az webapp up --name <APP_NAME> --resource-group <RG_NAME>

# Generar tráfico
cd ..
python generate_traffic.py https://<APP_NAME>.azurewebsites.net
```

### Paso 4: Explorar Observabilidad
1. Azure Portal → Application Insights
2. Ver Application Map
3. Ejecutar queries KQL
4. Crear dashboards

## 📚 Recursos Adicionales

### Documentación Microsoft
- [Azure Monitor Overview](https://learn.microsoft.com/azure/azure-monitor/)
- [Log Analytics Tutorial](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-tutorial)
- [KQL Reference](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
- [Application Insights Best Practices](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)

### Cursos Recomendados
- Microsoft Learn: "Monitor Azure resources"
- Pluralsight: "Azure Monitor Fundamentals"
- Udemy: "Azure Monitoring and Analytics"

### Comunidad
- [Azure Monitor Forum](https://techcommunity.microsoft.com/t5/azure-monitor/bd-p/AzureMonitor)
- [Stack Overflow - Azure Monitor Tag](https://stackoverflow.com/questions/tagged/azure-monitor)
- [GitHub - Azure Monitor Examples](https://github.com/Azure/azure-monitor-examples)

## 🎓 Certificaciones Relevantes

- **AZ-104**: Azure Administrator Associate
  - Módulo: Monitor and maintain Azure resources

- **AZ-305**: Azure Solutions Architect Expert
  - Módulo: Design monitoring solutions

- **AZ-500**: Azure Security Engineer Associate
  - Módulo: Manage security operations

## 🏁 Conclusión

Esta POC te proporciona:
- ✅ Experiencia práctica con Azure Monitor
- ✅ Comprensión de logs, métricas y trazas
- ✅ Habilidades en KQL
- ✅ Conocimiento de Application Insights
- ✅ Patterns de observabilidad empresariales

**Próximo Nivel:**
- Configurar alertas automáticas
- Crear workbooks personalizados
- Integrar con Azure DevOps
- Implementar en producción

---

**Mantenido por:** CloudTeam  
**Última actualización:** 2025-01-05  
**Versión:** 1.0  
**Estado:** Activo
