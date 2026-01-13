# Escenario 0: Shared Infrastructure

## 📋 Descripción

Infraestructura compartida base del POC de Azure Monitor:
- Log Analytics Workspace
- Monitoring Solutions (Container Insights, Security, Azure Activity)

## 🚀 Deployment

Este escenario se despliega automáticamente con:

```powershell
# Desde la raíz del proyecto
.\DEPLOY_SECURE.ps1
```

O manualmente:

```powershell
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## 📊 Recursos Creados

- **Resource Group**: `rg-azmon-poc-mexicocentral`
- **Log Analytics Workspace**: `law-azmon-poc-mexicocentral`
- **Container Insights Solution**
- **Security Solution**
- **Azure Activity Solution**

## 💰 Costo

**$0/mes** - Los costos se asocian a los recursos que envían datos al workspace.

## 📁 Archivos

- `main.tf` - Definición de recursos
- `variables.tf` - Variables de entrada
- `outputs.tf` - Outputs (LAW ID, nombre, etc)
- `terraform.tfvars` - Valores de configuración

## 🔗 Dependencias

Ninguna - Este es el escenario base.

## 📝 Notas

- Este workspace es compartido por todos los escenarios
- Los escenarios 1 y 2 referencian este workspace vía data sources
- Región: Mexico Central
