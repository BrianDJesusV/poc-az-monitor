# 🔍 POC Azure Monitor - Observabilidad en Azure

> **Prueba de Concepto (POC) educativa para entender y visualizar Azure Monitor, Log Analytics e Insights**

## 📋 Descripción

Este proyecto es una **POC modular e incremental** diseñada para probar, entender y visualizar los componentes de observabilidad de Azure en escenarios prácticos y realistas.

### 🎯 Objetivos

- ✅ **Probar** Azure Monitor, Log Analytics e Insights
- ✅ **Entender** la diferencia entre logs, métricas y trazas
- ✅ **Visualizar** datos de telemetría en escenarios reales
- ✅ **Aprender** KQL (Kusto Query Language)
- ✅ **Dominar** Application Insights para APM

## 🏗️ Estructura del Proyecto

```
poc_azure_monitor/
│
├── 00-shared-infrastructure/    ✅ Infraestructura base (PREREQUISITO)
│   └── Log Analytics Workspace + Resource Group
│
├── 01-app-service/             ✅ Azure App Service + Application Insights
│   └── Python Flask app con monitoreo completo
│
├── 02-azure-functions/         ⏳ Azure Functions serverless
│   └── Event-driven monitoring
│
├── 03-container-apps/          ⏳ Azure Container Apps
│   └── Container monitoring
│
├── 04-aro-openshift/           ⏳ Azure Red Hat OpenShift (opcional)
│   └── Kubernetes enterprise monitoring
│
└── docs/                       📚 Documentación técnica
    ├── architecture.md         ← LEER PRIMERO
    └── monitoring-guide.md
```

## 🚀 Inicio Rápido

### Prerequisitos

```bash
# Herramientas necesarias
- Azure CLI (az) >= 2.50
- Terraform >= 1.4.0
- Python >= 3.11
- Git

# Verificar instalación
az --version
terraform --version
python --version
```

### Paso 1: Clonar o Navegar al Proyecto

```bash
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor
```

### Paso 2: Autenticarse en Azure

```bash
az login
az account set --subscription "<TU_SUBSCRIPTION_ID>"
```


### Paso 3: Desplegar Escenario 0 (Infraestructura Base)

```bash
cd 00-shared-infrastructure
terraform init
terraform plan
terraform apply

# Guardar outputs para próximos escenarios
terraform output
```

### Paso 4: Desplegar Escenario 1 (App Service)

```bash
cd ../01-app-service
terraform init
terraform apply

# Obtener URL del App Service
terraform output app_service_url
```

### Paso 5: Deployar Aplicación de Prueba

```bash
cd test-app

# Opción A: Deploy rápido con az webapp up
az webapp up \
  --name $(cd .. && terraform output -raw app_service_name) \
  --resource-group rg-azmon-poc-eastus2

# Opción B: Deploy con ZIP
zip -r ../app.zip .
cd ..
az webapp deploy \
  --resource-group rg-azmon-poc-eastus2 \
  --name $(terraform output -raw app_service_name) \
  --src-path app.zip \
  --type zip
```

### Paso 6: Generar Tráfico y Observar

```bash
# Instalar dependencias del generador
pip install requests

# Obtener URL
APP_URL=$(terraform output -raw app_service_url)

# Generar tráfico (10 minutos)
python generate_traffic.py $APP_URL
```

### Paso 7: Explorar Azure Portal

1. **Application Insights**: Ver métricas y trazas en tiempo real
2. **Log Analytics**: Ejecutar queries KQL
3. **Azure Monitor**: Crear dashboards personalizados

## 📊 Escenarios Disponibles

| # | Escenario | Estado | Complejidad | Costo Mensual |
|---|-----------|--------|-------------|---------------|
| 0 | Shared Infrastructure | ✅ Listo | Baja | ~$5-10 |
| 1 | App Service | ✅ Listo | Baja-Media | ~$15-20 |
| 2 | Azure Functions | ⏳ Próximamente | Baja | ~$5-10 |
| 3 | Container Apps | ⏳ Próximamente | Media | ~$10-15 |
| 4 | ARO/OpenShift | ⏳ Opcional | Alta | ~$500-800 |

## 💡 Lo Que Aprenderás

### Escenario 0: Fundamentos
- Log Analytics Workspace
- Naming conventions
- Tagging strategy
- Cost management

### Escenario 1: App Service
- **Métricas**: Request rate, response time, CPU/Memory
- **Logs**: HTTP logs, application logs, console logs
- **Trazas**: Distributed tracing con Application Insights
- **KQL**: Queries para análisis de logs
- **Dashboards**: Visualizaciones personalizadas


## 🔍 Queries KQL de Ejemplo

### Ver requests HTTP por status code
```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| summarize Count=count() by ScStatus
| render piechart
```

### Top 10 endpoints más lentos
```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| top 10 by TimeTaken desc
| project TimeGenerated, CsUriStem, TimeTaken, ScStatus
```

### Tasa de éxito vs errores
```kql
requests
| where timestamp > ago(1h)
| summarize 
    Total=count(),
    Success=countif(success == true),
    Failed=countif(success == false)
| extend SuccessRate = (Success * 100.0 / Total)
```

## 🎓 Recursos de Aprendizaje

### Documentación Oficial
- [Azure Monitor Overview](https://learn.microsoft.com/azure/azure-monitor/)
- [Log Analytics Workspace](https://learn.microsoft.com/azure/azure-monitor/logs/log-analytics-workspace-overview)
- [Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [KQL Quick Reference](https://learn.microsoft.com/azure/data-explorer/kql-quick-reference)

### Tutoriales
- [Monitor Azure resources](https://learn.microsoft.com/training/paths/monitor-azure-resources/)
- [Distributed Tracing](https://learn.microsoft.com/azure/azure-monitor/app/distributed-tracing)

## 💰 Gestión de Costos

### Costos Estimados (Total POC)
```
Escenario 0 + 1:  $20-30 USD/mes
Con Escenarios 2-3: $35-55 USD/mes
Con ARO (Escenario 4): $500-850 USD/mes
```

### Tips para Reducir Costos
```bash
# Destruir recursos cuando no los uses
cd 01-app-service
terraform destroy

# Mantener solo la infraestructura compartida
cd 00-shared-infrastructure
# No destruir este escenario hasta finalizar toda la POC
```

### Configurar Límites de Ingesta
En `00-shared-infrastructure/terraform.tfvars`:
```hcl
daily_quota_gb = 5  # Límite diario de 5 GB
```

## 🔧 Troubleshooting

### Application Insights no muestra datos
```bash
# Verificar connection string
az webapp config appsettings list \
  --name <APP_NAME> \
  --resource-group rg-azmon-poc-eastus2 \
  --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"

# Reiniciar App Service
az webapp restart --name <APP_NAME> --resource-group rg-azmon-poc-eastus2
```

### Logs no aparecen en Log Analytics
**Causa**: Puede tomar 5-10 minutos para la primera ingesta

**Solución**: Esperar y verificar diagnostic settings

```bash
az monitor diagnostic-settings list \
  --resource <RESOURCE_ID>
```


### Terraform errors
```bash
# Limpiar estado corrupto
rm -rf .terraform .terraform.lock.hcl terraform.tfstate*

# Re-inicializar
terraform init
```

## 🏆 Mejores Prácticas Implementadas

- ✅ **IaC**: Todo desplegado con Terraform
- ✅ **Modularidad**: Escenarios independientes
- ✅ **Naming Convention**: Consistente y descriptiva
- ✅ **Tagging**: Para cost tracking y gestión
- ✅ **Seguridad**: HTTPS only, secrets management
- ✅ **Documentación**: Exhaustiva por escenario
- ✅ **Observabilidad**: Logs, métricas y trazas
- ✅ **Automation**: Scripts de generación de tráfico

## 📈 Roadmap

### ✅ Fase 1: Fundamentos (Completado)
- [x] Escenario 0: Shared Infrastructure
- [x] Escenario 1: App Service
- [x] Documentación técnica
- [x] Scripts de automatización

### ⏳ Fase 2: Serverless (Próximamente)
- [ ] Escenario 2: Azure Functions
- [ ] Event-driven monitoring patterns
- [ ] Cost optimization queries

### ⏳ Fase 3: Contenedores (Próximamente)
- [ ] Escenario 3: Container Apps
- [ ] Container metrics y logs
- [ ] Scaling patterns

### ⏳ Fase 4: Enterprise (Opcional)
- [ ] Escenario 4: ARO/AKS
- [ ] Prometheus integration
- [ ] Advanced distributed tracing

## 🤝 Contribuciones

Este es un proyecto educativo de CloudTeam. Para sugerencias:

1. Crear un issue describiendo la mejora
2. Proponer cambios en la documentación
3. Compartir queries KQL útiles

## 📝 Licencia

Este proyecto es de uso interno educativo para CloudTeam.

## 👥 Equipo

- **Arquitecto Cloud Senior**: Diseño y arquitectura
- **CloudTeam**: Implementación y validación

## 📞 Soporte

Para preguntas o problemas:
- Revisar documentación en `/docs/`
- Consultar README de cada escenario
- Buscar en [Azure Monitor Documentation](https://learn.microsoft.com/azure/azure-monitor/)

---

## 🎯 Checklist de Validación

Antes de considerar la POC completa:

### Escenario 0
- [ ] Resource Group creado
- [ ] Log Analytics Workspace operacional
- [ ] Queries KQL básicas funcionan

### Escenario 1
- [ ] App Service desplegado
- [ ] Aplicación Flask corriendo
- [ ] Application Insights capturando datos
- [ ] Logs visibles en Log Analytics
- [ ] Tráfico generado exitosamente
- [ ] Application Map mostrando topología
- [ ] Distributed traces funcionando
- [ ] Dashboards creados

---

**📅 Última actualización:** 2025-01-05  
**🔖 Versión:** 1.0  
**👤 Mantenido por:** CloudTeam  
**⏱️ Duración estimada:** 2-4 semanas (completo)

---

## 🚀 ¡Empecemos!

```bash
# Paso 1: Navegar al proyecto
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor

# Paso 2: Leer arquitectura
cat docs/architecture.md

# Paso 3: Desplegar Escenario 0
cd 00-shared-infrastructure
terraform init && terraform apply

# Paso 4: Continuar con Escenario 1
cd ../01-app-service
terraform init && terraform apply
```

**¡Éxito en tu aprendizaje de Azure Monitor! 🎓**
