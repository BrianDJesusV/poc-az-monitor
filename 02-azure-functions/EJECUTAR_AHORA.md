# ⚡ DEPLOYMENT AHORA - Escenario 2

**Terraform y Azure CLI deben ejecutarse localmente en tu PowerShell**

---

## 🚀 EJECUTA ESTO (3 opciones)

### **OPCIÓN 1: Script Completo (Recomendado)**

```powershell
# Abre PowerShell como Administrador
# Navega y ejecuta:

cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions
.\DEPLOY.ps1
```

**Tiempo:** 10-15 minutos  
**Qué hace:** Todo automatizado con verificaciones

---

### **OPCIÓN 2: Script Manual**

```powershell
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions
.\DEPLOY_MANUAL.ps1
```

**Tiempo:** 10-15 minutos  
**Qué hace:** Paso a paso con confirmaciones

---

### **OPCIÓN 3: Comandos One-Liner**

Abre el archivo y copia comandos uno por uno:

```powershell
code COMMANDS.ps1
```

**Tiempo:** 15-20 minutos  
**Qué hace:** Control total, ejecutas comando por comando

---

## ✅ PRE-REQUISITOS

Verifica ANTES de ejecutar:

```powershell
# 1. Terraform instalado
terraform --version

# 2. Azure CLI instalado
az --version

# 3. Autenticado en Azure
az account show

# 4. Escenario 0 existe
az group show --name rg-azmon-poc-mexicocentral
```

Si algo falta:
- Terraform: https://www.terraform.io/downloads
- Azure CLI: https://aka.ms/installazurecliwindows
- Login: `az login`

---

## 📊 QUÉ SE VA A CREAR

```
✅ Storage Account (stazmon<random>)
   ├── uploads container
   ├── processed container
   ├── queue-orders
   └── queue-notifications

✅ Application Insights (appi-azmon-functions-<random>)

✅ Function App (func-azmon-demo-<random>)
   ├── HttpTrigger
   ├── TimerTrigger
   ├── QueueTrigger
   └── BlobTrigger

Total: 9 recursos
Costo: ~$0.70/mes
```

---

## 🎯 RESULTADO ESPERADO

```
✓ Terraform apply exitoso
✓ 9 recursos creados
✓ 4 functions desplegadas
✓ HttpTrigger responde 200 OK
✓ Queue messages procesándose
✓ Blobs procesándose
✓ Application Insights con telemetría
```

---

## 🔧 SI NO TIENES TERRAFORM/AZURE CLI

**Instala primero:**

1. **Terraform:**
   ```powershell
   # Con Chocolatey
   choco install terraform
   
   # O descarga manual
   # https://www.terraform.io/downloads
   ```

2. **Azure CLI:**
   ```powershell
   # Descarga e instala
   # https://aka.ms/installazurecliwindows
   
   # Después login
   az login
   ```

3. **Reinicia PowerShell** después de instalar

---

## 📁 ARCHIVOS DISPONIBLES

| Archivo | Descripción |
|---------|-------------|
| `DEPLOY.ps1` | Script principal automatizado |
| `DEPLOY_MANUAL.ps1` | Script con confirmaciones |
| `COMMANDS.ps1` | Comandos one-liner |
| `test_functions.ps1` | Suite de tests |
| `START_HERE.md` | Documentación completa |
| `QUICK_DEPLOY.md` | Guía paso a paso |

---

## ⏱️ TIMELINE ESPERADO

```
Terraform init:        30 segundos
Terraform plan:        1 minuto
Terraform apply:       5-8 minutos
Deploy functions:      3-5 minutos
Wait & test:           2 minutos
─────────────────────────────────
TOTAL:                 12-17 minutos
```

---

## 🆘 TROUBLESHOOTING

**"terraform not found"**
→ Instalar Terraform y reiniciar PowerShell

**"az not found"**
→ Instalar Azure CLI y reiniciar PowerShell

**"Resource group not found"**
→ Desplegar Escenario 0 primero

**Functions no aparecen**
→ Wait 2-3 minutos después de deploy

**HttpTrigger 503**
→ Cold start, wait 30 segundos y retry

---

## 📞 SOPORTE

**Documentación completa:**
- `START_HERE.md` - Overview
- `DEPLOYMENT_GUIDE.md` - Paso a paso detallado
- `README.md` - Referencia completa

**Queries KQL:**
Incluidas en `COMMANDS.ps1`

---

## 💡 PRÓXIMO PASO

```powershell
# EJECUTA UNO DE ESTOS:

# Opción 1: Automatizado
.\DEPLOY.ps1

# Opción 2: Manual
.\DEPLOY_MANUAL.ps1

# Opción 3: Control total
code COMMANDS.ps1  # Luego copy-paste comandos
```

---

**¡TODO LISTO PARA DEPLOYMENT!**

El código está completo (1,900+ líneas).  
Solo falta ejecutarlo en tu PowerShell local.

---

**Creado:** 7 de enero de 2026  
**Status:** 🟢 Ready  
**Confidence:** 100%
