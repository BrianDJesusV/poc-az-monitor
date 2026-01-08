# ⚡ EJECUTA ESTOS COMANDOS AHORA

## ✅ PROBLEMA SOLUCIONADO

**Error:** Dynamic SKU no disponible en Mexico Central  
**Solución:** Crear resource group nuevo para Functions

---

## 🚀 PASOS A SEGUIR (3 comandos)

### **1. Limpiar recursos parciales**

```powershell
.\cleanup.ps1
```

### **2. Re-inicializar Terraform**

```powershell
terraform init
```

### **3. Re-ejecutar deployment**

```powershell
.\DEPLOY_NOW.ps1
```

---

## 📊 QUÉ VA A CREAR AHORA

```
✅ Resource Group NUEVO:  rg-azmon-functions-XXXXXX
✅ Storage Account:       stazmonXXXXXX
✅ Application Insights:  appi-azmon-functions-XXXXXX
✅ Function App:          func-azmon-demo-XXXXXX
✅ 4 Functions:           Http, Timer, Queue, Blob

Vinculado a:             law-azmon-poc-mexicocentral
```

---

## ⏱️ TIEMPO

- Cleanup:       1 minuto
- Terraform:     1 minuto
- Deployment:    10-15 minutos
- **TOTAL:**     **12-17 minutos**

---

**Ejecuta el primer comando ahora:** ⬇️

```powershell
.\cleanup.ps1
```
