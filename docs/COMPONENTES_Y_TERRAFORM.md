# 📦 COMPONENTES DESPLEGADOS - Escenario 1
## Inventario Completo y Comandos Terraform

**Fecha:** 7 de enero de 2026  
**Región:** Mexico Central  
**Subscription ID:** dd4fe3a1-a740-49ad-b613-b4f951aa474c

---

## 🏗️ COMPONENTES DESPLEGADOS EN AZURE

### **ESCENARIO 0: Shared Infrastructure**

#### **Resource Group**
```
Nombre:     rg-azmon-poc-mexicocentral
Tipo:       Microsoft.Resources/resourceGroups
Región:     Mexico Central
Tags:       
  - environment: poc
  - project: azure-monitor
  - managed-by: terraform
```

#### **Log Analytics Workspace**
```
Nombre:     law-azmon-poc-mexicocentral
Tipo:       Microsoft.OperationalInsights/workspaces
Resource ID: /subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/rg-azmon-poc-mexicocentral/providers/Microsoft.OperationalInsights/workspaces/law-azmon-poc-mexicocentral
Workspace ID: 5c80a2b6-79df-4454-af3f-1fd3cb882f62

Configuración:
  - SKU: PerGB2018 (Pay-as-you-go)
  - Retención: 30 días
  - Daily Cap: No limit (puede configurarse)
```

#### **Monitoring Solutions (3)**

**1. AzureActivity Solution**
```
Nombre: AzureActivity(law-azmon-poc-mexicocentral)
Tipo:   Microsoft.OperationsManagement/solutions
Propósito: Captura Azure Activity Logs (operaciones a nivel de subscription)
```

**2. ContainerInsights Solution**
```
Nombre: ContainerInsights(law-azmon-poc-mexicocentral)
Tipo:   Microsoft.OperationsManagement/solutions
Propósito: Monitoreo de contenedores (preparado para futuros escenarios)
```

**3. Security Solution**
```
Nombre: Security(law-azmon-poc-mexicocentral)
Tipo:   Microsoft.OperationsManagement/solutions
Propósito: Security Center logs y recomendaciones
```

---

### **ESCENARIO 1: App Service + Application Insights**

#### **App Service Plan**
```
Nombre:     asp-azmon-poc-ltr94a
Tipo:       Microsoft.Web/serverfarms
SKU:        B1 (Basic)
  - Cores: 1
  - RAM: 1.75 GB
  - Instances: 1
OS:         Linux
Región:     Mexico Central

Pricing:    ~$13.14/mes
```

#### **Web App (App Service)**
```
Nombre:     app-azmon-demo-ltr94a
Tipo:       Microsoft.Web/sites
Runtime:    Python 3.11
URL:        https://app-azmon-demo-ltr94a.azurewebsites.net
Kudu URL:   https://app-azmon-demo-ltr94a.scm.azurewebsites.net

Configuración:
  - HTTPS Only: true
  - Always On: false (requiere S1+)
  - FTP: Disabled
  - HTTP Version: 2.0

App Settings:
  - APPLICATIONINSIGHTS_CONNECTION_STRING: [configurado]
  - SCM_DO_BUILD_DURING_DEPLOYMENT: true
```

#### **Application Insights**
```
Nombre:     appi-azmon-appservice-ltr94a
Tipo:       Microsoft.Insights/components
Kind:       web
App ID:     6721dfb4-fd7f-4a3f-871b-672e7f79307f
Instrumentation Key: 590a6fb4-16d7-4148-a868-82c0e7ece1f8

Connection String:
InstrumentationKey=590a6fb4-16d7-4148-a868-82c0e7ece1f8;
IngestionEndpoint=https://mexicocentral-1.in.applicationinsights.azure.com/;
LiveEndpoint=https://mexicocentral.livediagnostics.monitor.azure.com/

Vinculación:
  - Log Analytics Workspace: law-azmon-poc-mexicocentral
  - Retention: 90 días (default)
  - Daily Cap: 100 GB/day (default)

Capacidades habilitadas:
  - Smart Detection: ✅
  - Live Metrics: ✅
  - Profiler: ❌ (requiere S1+)
  - Snapshot Debugger: ❌ (requiere S1+)
```

#### **Action Group (Smart Detection)**
```
Nombre: Application Insights Smart Detection
Tipo:   Microsoft.Insights/actionGroups
Propósito: Notificaciones automáticas de Smart Detection
Acciones: Email notifications (configurables)
```

---

## 📊 RESUMEN DE RECURSOS

| Categoría | Cantidad | Recursos |
|-----------|----------|----------|
| **Escenario 0** | 5 | Resource Group, LAW, 3 Solutions |
| **Escenario 1** | 4 | App Service Plan, Web App, App Insights, Action Group |
| **TOTAL** | **9** | **9 recursos Azure** |

---

## 🚀 COMANDOS TERRAFORM - DESPLEGAR

### **OPCIÓN A: Deploy Completo (Desde Cero)**

#### **Paso 1: Preparar Terraform**

```bash
# Verificar que Terraform está instalado
terraform --version

# Autenticarse en Azure
az login
az account set --subscription "dd4fe3a1-a740-49ad-b613-b4f951aa474c"

# Verificar subscription
az account show --output table
```

#### **Paso 2: Deploy Escenario 0 (Infraestructura Compartida)**

```bash
# Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\00-shared-infrastructure

# Inicializar Terraform (primera vez)
terraform init

# Ver qué se va a crear (sin crear nada)
terraform plan

# Crear los recursos
terraform apply

# O crear sin confirmación (automatizado)
terraform apply -auto-approve

# Guardar outputs importantes
terraform output -json > outputs.json
```

**Recursos que se crearán:**
```
Plan: 5 to add, 0 to change, 0 to destroy.

  + azurerm_resource_group.main
  + azurerm_log_analytics_workspace.main
  + azurerm_log_analytics_solution.azure_activity
  + azurerm_log_analytics_solution.container_insights
  + azurerm_log_analytics_solution.security
```

**Tiempo estimado:** 3-5 minutos

#### **Paso 3: Deploy Escenario 1 (App Service + App Insights)**

```bash
# Navegar al directorio
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service

# Inicializar Terraform (primera vez)
terraform init

# Ver qué se va a crear
terraform plan

# Crear los recursos
terraform apply

# O crear sin confirmación
terraform apply -auto-approve

# Guardar outputs importantes
terraform output -json > outputs.json

# Ver outputs específicos
terraform output app_service_url
terraform output app_insights_connection_string
```

**Recursos que se crearán:**
```
Plan: 4 to add, 0 to change, 0 to destroy.

  + azurerm_service_plan.main
  + azurerm_linux_web_app.main
  + azurerm_application_insights.main
  + azurerm_monitor_action_group.smart_detection
```

**Tiempo estimado:** 5-8 minutos

#### **Paso 4: Desplegar Aplicación Flask**

```bash
# Opción 1: Deployment con az webapp deploy (RECOMENDADO)
cd files/flask_example

az webapp deploy \
  --resource-group rg-azmon-poc-mexicocentral \
  --name $(cd ../.. && terraform output -raw app_service_name) \
  --src-path simple-flask.zip \
  --type zip

# Opción 2: Deployment con nombre explícito
az webapp deploy \
  --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a \
  --src-path simple-flask.zip \
  --type zip
```

**Tiempo estimado:** 1-2 minutos

---

### **OPCIÓN B: Deploy Solo Escenario 1 (Si Escenario 0 Ya Existe)**

```bash
# Si Escenario 0 ya está desplegado, saltar directo a:
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service

terraform init
terraform plan
terraform apply -auto-approve
```

---

## 🔥 COMANDOS TERRAFORM - DESTRUIR

### **⚠️ ORDEN CORRECTO DE DESTRUCCIÓN**

**CRÍTICO:** Destruir en orden inverso al de creación para evitar errores de dependencias.

#### **Paso 1: Destruir Escenario 1 (PRIMERO)**

```bash
# Navegar al directorio del Escenario 1
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service

# Ver qué se va a destruir
terraform plan -destroy

# Destruir recursos
terraform destroy

# O destruir sin confirmación (cuidado!)
terraform destroy -auto-approve
```

**Recursos que se destruirán:**
```
Plan: 0 to add, 0 to change, 4 to destroy.

  - azurerm_monitor_action_group.smart_detection
  - azurerm_application_insights.main
  - azurerm_linux_web_app.main
  - azurerm_service_plan.main
```

**Tiempo estimado:** 3-5 minutos

**⚠️ IMPORTANTE:** Confirma escribiendo `yes` cuando se te solicite.

#### **Paso 2: Destruir Escenario 0 (DESPUÉS)**

```bash
# Navegar al directorio del Escenario 0
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\00-shared-infrastructure

# Ver qué se va a destruir
terraform plan -destroy

# Destruir recursos
terraform destroy

# O destruir sin confirmación (cuidado!)
terraform destroy -auto-approve
```

**Recursos que se destruirán:**
```
Plan: 0 to add, 0 to change, 5 to destroy.

  - azurerm_log_analytics_solution.security
  - azurerm_log_analytics_solution.container_insights
  - azurerm_log_analytics_solution.azure_activity
  - azurerm_log_analytics_workspace.main
  - azurerm_resource_group.main
```

**Tiempo estimado:** 5-8 minutos

**⚠️ NOTA:** El Resource Group se destruye al final, eliminando cualquier recurso residual.

---

### **OPCIÓN RÁPIDA: Script de Destrucción Completa**

**PowerShell:**
```powershell
# Script: destroy_all.ps1
Write-Host "Destruyendo Escenario 1..." -ForegroundColor Yellow
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service
terraform destroy -auto-approve

Write-Host "Destruyendo Escenario 0..." -ForegroundColor Yellow
cd ..\00-shared-infrastructure
terraform destroy -auto-approve

Write-Host "Todos los recursos destruidos!" -ForegroundColor Green
```

**Bash/WSL:**
```bash
#!/bin/bash
# Script: destroy_all.sh

echo "Destruyendo Escenario 1..."
cd ~/01-app-service
terraform destroy -auto-approve

echo "Destruyendo Escenario 0..."
cd ../00-shared-infrastructure
terraform destroy -auto-approve

echo "Todos los recursos destruidos!"
```

---

## 📁 ARCHIVOS TERRAFORM IMPORTANTES

### **Escenario 0 (Shared Infrastructure)**

```
00-shared-infrastructure/
├── main.tf                     ⭐ Definición de recursos
├── variables.tf                📝 Variables de entrada
├── outputs.tf                  📤 Outputs exportados
├── terraform.tfvars            🔒 Valores de configuración
├── terraform.tfvars.example    📄 Template de configuración
├── providers.tf                🔌 Configuración de providers
├── terraform.tfstate           💾 Estado actual (CRÍTICO)
├── terraform.tfstate.backup    💾 Backup del estado
└── .terraform.lock.hcl         🔒 Lock de versiones
```

**Archivos que DEBES respaldar:**
- ✅ `terraform.tfstate` (CRÍTICO - sin esto hay que recrear todo)
- ✅ `terraform.tfvars` (configuración actual)
- ⚠️ `terraform.tfstate.backup` (backup automático)

### **Escenario 1 (App Service)**

```
01-app-service/
├── main.tf                     ⭐ Definición de recursos
├── variables.tf                📝 Variables de entrada
├── outputs.tf                  📤 Outputs exportados
├── terraform.tfvars            🔒 Valores de configuración
├── terraform.tfvars.example    📄 Template de configuración
├── providers.tf                🔌 Configuración de providers
├── terraform.tfstate           💾 Estado actual (CRÍTICO)
├── terraform.tfstate.backup    💾 Backup del estado
├── .terraform.lock.hcl         🔒 Lock de versiones
└── files/
    └── flask_example/
        ├── simple-flask.zip    📦 App básica
        └── flask-deploy.zip    📦 App completa
```

**Archivos que DEBES respaldar:**
- ✅ `terraform.tfstate` (CRÍTICO)
- ✅ `terraform.tfvars` (configuración actual)
- ✅ `files/flask_example/*.zip` (aplicaciones)

---

## ✅ VERIFICACIÓN POST-DEPLOY

### **Después de Deploy**

```bash
# 1. Verificar recursos en Azure
az resource list \
  --resource-group rg-azmon-poc-mexicocentral \
  --output table

# 2. Verificar Web App
az webapp show \
  --name app-azmon-demo-ltr94a \
  --resource-group rg-azmon-poc-mexicocentral \
  --query "{Name:name, State:state, URL:defaultHostName}" \
  --output table

# 3. Test endpoint
curl https://app-azmon-demo-ltr94a.azurewebsites.net/health

# 4. Verificar Application Insights
az monitor app-insights component show \
  --app appi-azmon-appservice-ltr94a \
  --resource-group rg-azmon-poc-mexicocentral \
  --query "{Name:name, AppId:appId, ConnectionString:connectionString}" \
  --output table

# 5. Ver terraform state
cd 01-app-service
terraform show
```

**Resultado esperado:**
```
✅ 9 recursos creados
✅ Web App en estado "Running"
✅ Endpoint /health responde 200 OK
✅ Application Insights configurado
✅ Terraform state actualizado
```

---

## ✅ VERIFICACIÓN POST-DESTROY

### **Después de Destroy**

```bash
# 1. Verificar que Resource Group no existe
az group show \
  --name rg-azmon-poc-mexicocentral

# Resultado esperado:
# ResourceGroupNotFound: Resource group 'rg-azmon-poc-mexicocentral' could not be found.

# 2. Verificar terraform state vacío
cd 01-app-service
terraform show
# Resultado esperado: No resources.

cd ../00-shared-infrastructure
terraform show
# Resultado esperado: No resources.

# 3. Verificar archivos state
ls -la terraform.tfstate
# Debería mostrar archivo casi vacío (solo metadata)
```

**Resultado esperado:**
```
✅ Resource Group no existe
✅ 0 recursos en Azure
✅ Terraform state vacío
✅ No hay costos activos
```

---

## 🔄 COMANDOS TERRAFORM ÚTILES

### **Estado y Diagnóstico**

```bash
# Ver estado actual
terraform show

# Listar recursos en state
terraform state list

# Ver un recurso específico
terraform state show azurerm_linux_web_app.main

# Ver outputs
terraform output

# Ver output específico
terraform output app_service_url

# Validar configuración
terraform validate

# Formatear archivos .tf
terraform fmt

# Ver plan sin aplicar
terraform plan

# Ver plan de destrucción
terraform plan -destroy
```

### **Manejo de State**

```bash
# Backup manual del state
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# Importar recurso existente
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/rg-azmon-poc-mexicocentral

# Remover recurso del state (sin destruirlo en Azure)
terraform state rm azurerm_linux_web_app.main

# Refrescar state con estado real de Azure
terraform refresh
```

### **Troubleshooting**

```bash
# Ver logs detallados
export TF_LOG=DEBUG
terraform apply

# Desbloquear state (si quedó locked)
terraform force-unlock <LOCK_ID>

# Re-inicializar (si hay problemas con plugins)
rm -rf .terraform
terraform init -upgrade
```

---

## 📊 TIEMPO Y COSTO ESTIMADOS

### **Despliegue Completo**

| Fase | Tiempo | Acción |
|------|--------|--------|
| Terraform init (Escenario 0) | 30 seg | Primera vez |
| Terraform apply (Escenario 0) | 3-5 min | Crear LAW + Solutions |
| Terraform init (Escenario 1) | 30 seg | Primera vez |
| Terraform apply (Escenario 1) | 5-8 min | Crear App Service + App Insights |
| Deploy aplicación | 1-2 min | ZIP Deploy |
| **TOTAL** | **10-16 min** | **Deploy completo** |

### **Destrucción Completa**

| Fase | Tiempo | Acción |
|------|--------|--------|
| Terraform destroy (Escenario 1) | 3-5 min | Destruir App Service |
| Terraform destroy (Escenario 0) | 5-8 min | Destruir LAW + RG |
| **TOTAL** | **8-13 min** | **Destroy completo** |

### **Costos Operacionales**

```
Escenario 0 (siempre activo):
  - Log Analytics: $0 (5GB/mes gratis)
  - Solutions: $0 (incluido)

Escenario 1 (mientras esté activo):
  - App Service Plan B1: ~$13.14/mes (~$0.018/hora)
  - Application Insights: $0 (5GB/mes gratis)
  - Web App: $0 (incluido en plan)

TOTAL mensual: $13.14/mes
TOTAL por hora: $0.018/hora
```

**Recomendación para POC:**
- Levantar cuando necesites trabajar/hacer demos
- Destruir cuando no estés usándolo activamente
- Solo pagar por horas de uso

---

## 💾 BACKUP DE ARCHIVOS CRÍTICOS

### **Antes de Destroy (Obligatorio)**

```bash
# Crear directorio de backup
mkdir -p ~/backups/azure-monitor-poc/$(date +%Y%m%d)

# Backup Escenario 0
cp -r 00-shared-infrastructure/*.tfstate* ~/backups/azure-monitor-poc/$(date +%Y%m%d)/
cp 00-shared-infrastructure/terraform.tfvars ~/backups/azure-monitor-poc/$(date +%Y%m%d)/

# Backup Escenario 1
cp -r 01-app-service/*.tfstate* ~/backups/azure-monitor-poc/$(date +%Y%m%d)/
cp 01-app-service/terraform.tfvars ~/backups/azure-monitor-poc/$(date +%Y%m%d)/

# Backup aplicaciones
cp 01-app-service/files/flask_example/*.zip ~/backups/azure-monitor-poc/$(date +%Y%m%d)/

# Verificar backup
ls -lah ~/backups/azure-monitor-poc/$(date +%Y%m%d)/
```

**Archivos críticos respaldados:**
- ✅ terraform.tfstate (ambos escenarios)
- ✅ terraform.tfvars (ambos escenarios)
- ✅ Aplicaciones (.zip)

---

## 🎯 CHECKLIST DE OPERACIONES

### **Para Deploy**
- [ ] Autenticado en Azure CLI
- [ ] Subscription correcta seleccionada
- [ ] Terraform instalado y funcionando
- [ ] Deploy Escenario 0 completado
- [ ] Outputs de Escenario 0 verificados
- [ ] Deploy Escenario 1 completado
- [ ] Aplicación Flask desplegada
- [ ] Endpoints verificados (200 OK)
- [ ] Application Insights recibiendo telemetría
- [ ] Terraform states respaldados

### **Para Destroy**
- [ ] Backup de terraform.tfstate (ambos escenarios)
- [ ] Backup de terraform.tfvars (ambos escenarios)
- [ ] Screenshots de métricas guardados (si necesarios)
- [ ] Destroy Escenario 1 (PRIMERO)
- [ ] Verificado que Escenario 1 fue destruido
- [ ] Destroy Escenario 0 (DESPUÉS)
- [ ] Verificado que Resource Group no existe
- [ ] Verificado que no hay costos activos

---

## 📝 NOTAS IMPORTANTES

### **⚠️ Errores Comunes**

**Error: "Resource Group already exists"**
```bash
# Solución: Importar al state
terraform import azurerm_resource_group.main /subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/rg-azmon-poc-mexicocentral
```

**Error: "State is locked"**
```bash
# Solución: Forzar unlock
terraform force-unlock <LOCK_ID>
```

**Error: "Dependency between resources"**
```bash
# Solución: Destruir en orden correcto (Escenario 1 → Escenario 0)
```

**Error: "Cannot destroy LAW with Solutions"**
```bash
# Solución: terraform destroy maneja dependencias automáticamente
# Si falla, destruir manualmente en Azure Portal y limpiar state
```

### **💡 Best Practices**

1. **Siempre hacer backup antes de destroy**
2. **Usar terraform plan antes de apply/destroy**
3. **Destruir en orden inverso (1 → 0)**
4. **Verificar costos antes de dejar recursos activos**
5. **Usar -auto-approve solo en scripts automatizados**
6. **Mantener .tfvars versionado (sin secrets)**
7. **Backup de .tfstate después de cada apply**

---

## 🚀 COMANDOS RÁPIDOS (CHEAT SHEET)

```bash
# === DEPLOY COMPLETO ===
cd 00-shared-infrastructure
terraform init && terraform apply -auto-approve
cd ../01-app-service  
terraform init && terraform apply -auto-approve
az webapp deploy --resource-group rg-azmon-poc-mexicocentral \
  --name app-azmon-demo-ltr94a --src-path files/flask_example/simple-flask.zip --type zip

# === DESTROY COMPLETO ===
cd 01-app-service
terraform destroy -auto-approve
cd ../00-shared-infrastructure
terraform destroy -auto-approve

# === VERIFICACIÓN ===
az resource list --resource-group rg-azmon-poc-mexicocentral --output table
curl https://app-azmon-demo-ltr94a.azurewebsites.net/health

# === BACKUP ===
cp */terraform.tfstate* ~/backups/
```

---

**Última actualización:** 7 de enero de 2026  
**Autor:** Brian Poch  
**Versión:** 1.0 - Guía Completa de Deploy/Destroy
