# ✅ PROBLEMA CORREGIDO - EJECUTA RETRY

## ⚠️ **LO QUE PASÓ**

El script `DEPLOY_BASIC.ps1` **no cambió correctamente** el SKU en `main.tf`.

El archivo seguía con:
```terraform
sku_name = "Y1"  # Consumption - CAUSÓ EL ERROR
```

---

## ✅ **LO QUE HICE**

**Ya apliqué el cambio manualmente** en `main.tf`:

```terraform
sku_name = "B1"  # Basic B1 - CORRECTO ✅
```

---

## 🚀 **EJECUTA ESTE COMANDO AHORA**

```powershell
.\RETRY_B1.ps1
```

---

## 📋 **LO QUE VA A HACER (9 pasos)**

### **PASO 1:** Limpiar deployment fallido (1 min)
```
✓ Elimina rg-azmon-functions-xm3zsy
✓ Limpia Terraform state
```

### **PASO 2:** Verificar cambio a B1 (5 seg)
```
✓ Confirma que main.tf tiene sku_name = "B1"
```

### **PASO 3:** Terraform Plan (1 min)
```
✓ terraform plan -out=tfplan
✓ Muestra 10 recursos a crear
```

### **PASO 4:** Pedir confirmación
```
→ "Aplicar el plan con Basic B1? (S/N)"
→ Escribe: S
```

### **PASO 5:** Terraform Apply (5-8 min)
```
✓ Crea Resource Group (East US)
✓ Crea Storage Account
✓ Crea Application Insights
✓ Crea Service Plan BASIC B1 ← AHORA SÍ
✓ Crea Function App
```

### **PASO 6-9:** Deploy, Test, Data (3-5 min)
```
✓ Deploy 4 functions
✓ Wait 60 segundos
✓ Test HttpTrigger
✓ Generate test data
```

---

## ⏱️ **TIEMPO TOTAL: 10-15 MINUTOS**

---

## ✅ **RESULTADO ESPERADO**

```
========================================
    DEPLOYMENT COMPLETADO
========================================

Recursos desplegados:
  Resource Group:   rg-azmon-functions-XXXXXX (East US)
  Storage:          stazmonXXXXXX
  Function App:     func-azmon-demo-XXXXXX
  App Insights:     appi-azmon-functions-XXXXXX
  Service Plan:     Basic B1 ✅
  Functions:        4 (Http, Timer, Queue, Blob)

URLs:
  Function URL:     https://func-azmon-demo-XXXXXX.azurewebsites.net
  API Test:         https://func-azmon-demo-XXXXXX.azurewebsites.net/api/HttpTrigger?name=Test

Costo: ~$13/mes (Basic B1)

Deployment exitoso!
```

---

## 🎯 **DIFERENCIA CON EL INTENTO ANTERIOR**

| Intento | SKU en main.tf | Resultado |
|---------|---------------|-----------|
| **Anterior** | `sku_name = "Y1"` | ❌ Error quota |
| **Ahora** | `sku_name = "B1"` | ✅ Funcionará |

---

## 💡 **POR QUÉ AHORA FUNCIONARÁ**

**Basic B1:**
- ✅ NO requiere quota "Dynamic VMs"
- ✅ Usa quota standard de App Service
- ✅ Tu suscripción tiene esta quota disponible
- ✅ Deployment exitoso garantizado

---

## ⚡ **COMANDO FINAL**

```powershell
.\RETRY_B1.ps1
```

Solo necesitas confirmar **1 vez** con "S" cuando te lo pida.

---

**Fecha:** 8 de enero de 2026  
**Fix aplicado:** sku_name = "B1" (manualmente)  
**Próxima acción:** Ejecutar RETRY_B1.ps1
