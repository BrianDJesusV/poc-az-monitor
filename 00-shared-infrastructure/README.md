# 🏗️ Escenario 0: Infraestructura Compartida

## 📋 Descripción

Este escenario despliega la **infraestructura base compartida** que será utilizada por todos los demás escenarios de la POC. Contiene los componentes fundamentales de observabilidad en Azure.

## 🎯 Objetivo

Establecer una base centralizada de observabilidad que permita:
- **Centralizar logs** de todas las aplicaciones y servicios
- **Reducir costos** mediante un workspace compartido
- **Facilitar correlación** entre diferentes recursos
- **Aplicar buenas prácticas** de arquitectura empresarial

## 🔧 Componentes Desplegados

### 1. Resource Group
- **Nombre:** `rg-azmon-poc-eastus2`
- **Ubicación:** East US 2
- **Propósito:** Contenedor lógico para todos los recursos de la POC

### 2. Log Analytics Workspace
- **Nombre:** `law-azmon-poc-eastus2`
- **SKU:** PerGB2018 (pay-as-you-go)
- **Retención:** 30 días
- **Propósito:** Repositorio centralizado de logs y métricas

### 3. Log Analytics Solutions
Las siguientes soluciones se instalan automáticamente:

#### Container Insights
- Monitoreo de contenedores (Container Apps, AKS, ARO)
- Métricas de CPU/memoria por contenedor
- Logs de contenedores

#### Security
- Recomendaciones de seguridad
- Alertas de amenazas
- Análisis de vulnerabilidades

#### Azure Activity
- Registro de operaciones en Azure Resource Manager
- Auditoría de cambios en recursos
- Tracking de eventos administrativos

## 📊 ¿Qué veremos en este escenario?

### Métricas
- Ingesta de datos (GB/día)
- Queries ejecutadas
- Performance de queries

### Logs
- AzureActivity (operaciones ARM)
- AzureDiagnostics (diagnósticos de recursos)

### Insights
- Uso de workspace por tipo de dato
- Tendencias de ingesta
- Alertas configuradas

## 🚀 Despliegue

### Prerrequisitos
```bash
# 1. Azure CLI instalado y autenticado
az login
az account show

# 2. Terraform instalado (>= 1.4.0)
terraform --version
```

### Pasos de Despliegue

```bash
# 1. Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\00-shared-infrastructure

# 2. Inicializar Terraform
terraform init

# 3. Validar configuración
terraform validate

# 4. Ver plan de ejecución
terraform plan

# 5. Aplicar cambios
terraform apply -auto-approve

# 6. Verificar outputs
terraform output
```

### Tiempo Estimado de Despliegue
⏱️ **5-7 minutos**

## ✅ Validación Post-Despliegue

### 1. Verificar Resource Group
```bash
az group show --name rg-azmon-poc-eastus2 --output table
```

### 2. Verificar Log Analytics Workspace
```bash
az monitor log-analytics workspace show \
  --resource-group rg-azmon-poc-eastus2 \
  --workspace-name law-azmon-poc-eastus2 \
  --output table
```

### 3. Obtener Workspace ID y Key
```bash
# Workspace ID
terraform output log_analytics_workspace_workspace_id

# Primary Key (sensitive)
terraform output -raw log_analytics_primary_shared_key
```

### 4. Verificar en Portal Azure
1. Navegar a: https://portal.azure.com
2. Buscar: `law-azmon-poc-eastus2`
3. Verificar:
   - Estado: Activo
   - SKU: PerGB2018
   - Retención: 30 días
   - Solutions instaladas

## 📊 Queries de Validación (Log Analytics)

Ejecutar estas queries en el workspace para verificar funcionalidad:

### Query 1: Verificar Ingesta de Datos
```kusto
Usage
| where TimeGenerated > ago(24h)
| summarize TotalGB = sum(Quantity) / 1000 by DataType
| order by TotalGB desc
```

### Query 2: Activity Logs
```kusto
AzureActivity
| where TimeGenerated > ago(1h)
| summarize count() by OperationNameValue, ResourceProviderValue
| order by count_ desc
```

### Query 3: Soluciones Instaladas
```kusto
ConfigurationData
| where ConfigDataType == "Solutions"
| distinct SolutionId
```

## 💰 Estimación de Costos

### Log Analytics Workspace
- **SKU:** PerGB2018
- **Costo por GB:** ~$2.30 USD/GB (East US 2)
- **Ingesta esperada POC:** 1-2 GB/día
- **Costo mensual estimado:** $70-150 USD

### Log Analytics Solutions
- **Container Insights:** Incluido en ingesta de LA
- **Security:** Incluido en ingesta de LA
- **Azure Activity:** Sin costo adicional

**Total mensual estimado:** $70-150 USD

> ⚠️ **Nota:** Costos reales dependen de la cantidad de datos ingeridos.

## 🔗 Dependencias

Este escenario es **PREREQUISITO** para:
- ✅ Escenario 1: Azure App Service
- ✅ Escenario 2: Azure Functions
- ✅ Escenario 3: Container Apps
- ✅ Escenario 4: ARO (OpenShift)

## 🧹 Limpieza de Recursos

```bash
# Destruir infraestructura
terraform destroy -auto-approve

# Verificar eliminación
az group show --name rg-azmon-poc-eastus2
```

## 📚 Referencias

- [Log Analytics Workspace Overview](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-workspace-overview)
- [Log Analytics Pricing](https://azure.microsoft.com/pricing/details/monitor/)
- [Kusto Query Language (KQL)](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
- [Azure Monitor Documentation](https://learn.microsoft.com/azure/azure-monitor/)

## 🎓 Aprendizajes Clave

### ¿Por qué un workspace centralizado?
1. **Centralización:** Un solo lugar para todos los logs
2. **Correlación:** Queries cross-resource más simples
3. **Costos:** Un solo pipeline de ingesta
4. **Gestión:** Configuración única de retención y alertas

### ¿Cuándo usar workspaces separados?
- Diferentes unidades de negocio con presupuestos separados
- Requisitos de compliance (aislamiento de datos)
- Diferentes políticas de retención por tipo de aplicación

### Log Analytics vs Application Insights
- **Log Analytics:** Repositorio de datos (backend)
- **Application Insights:** SDK y visualización para apps (frontend)
- Ambos se integran: Application Insights envía datos a Log Analytics

---

**Siguiente paso:** [Escenario 1 - Azure App Service](../01-app-service/README.md)
