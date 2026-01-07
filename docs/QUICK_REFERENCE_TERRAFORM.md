# 🎯 QUICK REFERENCE - Componentes y Terraform
**Resumen de 1 página**

---

## 📦 COMPONENTES DESPLEGADOS (9 recursos)

### **ESCENARIO 0 (5 recursos)**
```
✅ Resource Group: rg-azmon-poc-mexicocentral
✅ Log Analytics Workspace: law-azmon-poc-mexicocentral
✅ AzureActivity Solution
✅ ContainerInsights Solution  
✅ Security Solution
```

### **ESCENARIO 1 (4 recursos)**
```
✅ App Service Plan: asp-azmon-poc-ltr94a (B1 - $13/mes)
✅ Web App: app-azmon-demo-ltr94a
   URL: https://app-azmon-demo-ltr94a.azurewebsites.net
✅ Application Insights: appi-azmon-appservice-ltr94a
✅ Action Group: Smart Detection
```

---

## 🚀 COMANDOS DEPLOY

### **Deploy Completo (10-16 minutos)**
```bash
# Paso 1: Escenario 0
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\00-shared-infrastructure
terraform init
terraform apply -auto-approve

# Paso 2: Escenario 1
cd ..\01-app-service
terraform init
terraform apply -auto-approve

# Paso 3: Deploy app
cd files\flask_example
az webapp deploy --resource-group rg-azmon-poc-mexicocentral `
  --name app-azmon-demo-ltr94a --src-path simple-flask.zip --type zip
```

### **Deploy Rápido (si ya tienes init)**
```bash
cd 00-shared-infrastructure && terraform apply -auto-approve
cd ..\01-app-service && terraform apply -auto-approve
```

---

## 🔥 COMANDOS DESTROY

### **⚠️ ORDEN CRÍTICO: 1 → 0 (inverso)**

```bash
# Paso 1: Destruir Escenario 1 PRIMERO
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service
terraform destroy -auto-approve

# Paso 2: Destruir Escenario 0 DESPUÉS
cd ..\00-shared-infrastructure
terraform destroy -auto-approve
```

### **Destrucción Completa (8-13 minutos)**
```powershell
# PowerShell one-liner
cd 01-app-service; terraform destroy -auto-approve; cd ..\00-shared-infrastructure; terraform destroy -auto-approve
```

---

## 📁 ARCHIVOS CRÍTICOS A RESPALDAR

```bash
# Antes de destroy, siempre backup:
✅ 00-shared-infrastructure/terraform.tfstate
✅ 00-shared-infrastructure/terraform.tfvars
✅ 01-app-service/terraform.tfstate
✅ 01-app-service/terraform.tfvars
✅ 01-app-service/files/flask_example/*.zip
```

**Script de backup:**
```powershell
$date = Get-Date -Format "yyyyMMdd_HHmmss"
mkdir "C:\Backups\azure-monitor-poc\$date"
copy 00-shared-infrastructure\terraform.tfstate* "C:\Backups\azure-monitor-poc\$date\"
copy 00-shared-infrastructure\terraform.tfvars "C:\Backups\azure-monitor-poc\$date\"
copy 01-app-service\terraform.tfstate* "C:\Backups\azure-monitor-poc\$date\"
copy 01-app-service\terraform.tfvars "C:\Backups\azure-monitor-poc\$date\"
copy 01-app-service\files\flask_example\*.zip "C:\Backups\azure-monitor-poc\$date\"
```

---

## ✅ VERIFICACIÓN

### **Post-Deploy**
```bash
# Verificar recursos
az resource list --resource-group rg-azmon-poc-mexicocentral --output table

# Test endpoint
curl https://app-azmon-demo-ltr94a.azurewebsites.net/health

# Ver estado terraform
cd 01-app-service
terraform show | Select-String "resource"
```

### **Post-Destroy**
```bash
# Verificar que RG no existe
az group show --name rg-azmon-poc-mexicocentral
# Esperado: ResourceGroupNotFound

# Verificar terraform state vacío
terraform show
# Esperado: No resources.
```

---

## 💰 COSTOS

```
Activo (por hora):    $0.018/hora
Activo (por día):     $0.43/día  
Activo (por mes):     $13.14/mes
Destruido:            $0/mes
```

**Estrategia de ahorro:**
- Levantar para trabajar/demos
- Destruir cuando no se usa
- Solo pagas horas activas

---

## 🆘 TROUBLESHOOTING RÁPIDO

| Error | Solución |
|-------|----------|
| "Resource Group already exists" | `terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/rg-azmon-poc-mexicocentral` |
| "State is locked" | `terraform force-unlock <LOCK_ID>` |
| "Cannot destroy LAW" | Destruir Escenario 1 primero |
| Apply falla | `terraform init -upgrade` |

---

## 📞 RECURSOS

**Documentación completa:** `docs/COMPONENTES_Y_TERRAFORM.md` (736 líneas)  
**Knowledge Transfer:** `docs/ESCENARIO_1_KNOWLEDGE_TRANSFER.md`  
**Casos de Uso:** `docs/CASOS_DE_USO_Y_UTILIDAD.md`

---

**Última actualización:** 7 de enero de 2026
