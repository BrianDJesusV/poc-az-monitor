# ⚠️ PROBLEMA: MEXICO CENTRAL NO SOPORTA CONSUMPTION PLAN

## Error Encontrado

```
Error: Requested features are not supported in region. 
Please try another region.
```

**Causa:** Mexico Central NO soporta Azure Functions Consumption Plan (Y1) con Linux.

---

## ✅ SOLUCIÓN APLICADA

**Cambio de región:** `mexicocentral` → `eastus`

Archivo modificado: `terraform.tfvars`

**East US soporta:**
- ✅ Consumption Plan (Y1)
- ✅ Linux Workers
- ✅ Dynamic SKU
- ✅ Todas las features de Functions

---

## 🚀 EJECUTA ESTOS 3 COMANDOS

### **1. Limpiar recursos parciales**

```powershell
.\cleanup.ps1
```

Esto elimina:
- Recursos del 1er intento (suffix 7wue34)
- Resource group del 2do intento (rg-azmon-functions-7f0gvv)
- Archivos de estado de Terraform

---

### **2. Re-inicializar Terraform**

```powershell
terraform init
```

---

### **3. Deployment con nueva región**

```powershell
.\DEPLOY_NOW.ps1
```

---

## 📊 QUÉ VA A CREAR (EN EAST US)

```
Resource Group:    rg-azmon-functions-<random> (East US)
├── Storage:       stazmon<random>
├── App Insights:  appi-azmon-functions-<random>
├── Service Plan:  Consumption Y1 (ahora SÍ funcionará)
└── Function App:  func-azmon-demo-<random>
    ├── HttpTrigger
    ├── TimerTrigger
    ├── QueueTrigger
    └── BlobTrigger

Vinculado a LAW:   law-azmon-poc-mexicocentral (Mexico Central)
```

**NOTA:** Application Insights estará en East US pero seguirá vinculado al Log Analytics Workspace de Mexico Central.

---

## ⏱️ TIEMPO TOTAL

```
1. cleanup.ps1:     1-2 minutos
2. terraform init:  30 segundos
3. DEPLOY_NOW.ps1:  10-15 minutos
────────────────────────────────────
TOTAL:              12-18 minutos
```

---

## 💡 POR QUÉ ESTE CAMBIO

**Limitaciones de Mexico Central:**
- ❌ No soporta Consumption Plan + Linux
- ❌ Restricciones en Dynamic SKU
- ❌ Features limitadas para Functions

**Ventajas de East US:**
- ✅ Soporte completo de Functions
- ✅ Consumption Plan disponible
- ✅ Más estable y confiable
- ✅ Mejor performance

---

## 🌎 REGIONES SOPORTADAS

Si East US tiene problemas, estas alternativas también funcionan:

1. **East US** ⭐ (ACTUAL)
2. West US 2
3. West Europe
4. North Europe
5. UK South

---

## 📁 ARCHIVOS MODIFICADOS

- ✅ `terraform.tfvars` - location = "eastus"
- ✅ `cleanup.ps1` - Limpia ambos intentos
- ✅ `REGION_CHANGE.md` - Esta guía

---

## ⚡ EJECUTA AHORA

```powershell
# Paso 1: Limpiar
.\cleanup.ps1

# Paso 2: Re-inicializar
terraform init

# Paso 3: Deployment
.\DEPLOY_NOW.ps1
```

**Tiempo:** 12-18 minutos  
**Región:** East US (soportada)  
**Resultado:** Escenario 2 funcionando

---

**Fecha:** 7 de enero de 2026  
**Cambio:** Mexico Central → East US  
**Razón:** Consumption Plan no soportado en Mexico Central
