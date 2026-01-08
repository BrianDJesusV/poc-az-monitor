# ⚠️ PROBLEMA DE QUOTA - SIN CUOTA PARA CONSUMPTION PLAN

## 🔍 **DIAGNÓSTICO**

Error recibido:
```
Current Limit (Dynamic VMs): 0
Current Usage: 0
```

**Significado:** Tu suscripción NO tiene cuota aprobada para Consumption Plan (serverless).

---

## ✅ **SOLUCIÓN INMEDIATA: USAR BASIC B1**

### **Ejecuta este comando:**

```powershell
.\DEPLOY_BASIC.ps1
```

Este script hace TODO automáticamente:
1. ✅ Cambia de Consumption (Y1) a Basic (B1)
2. ✅ Limpia recursos parciales
3. ✅ Re-inicializa Terraform
4. ✅ Ejecuta deployment completo

**Tiempo:** 12-15 minutos

---

## 📊 **COMPARATIVA: CONSUMPTION vs BASIC**

| Característica | Consumption (Y1) | Basic (B1) |
|---------------|------------------|------------|
| **Costo** | ~$0.70/mes | ~$13/mes |
| **Tipo** | Serverless | Always-on |
| **Cold Starts** | Sí (1-3 segundos) | No |
| **Quota Requerida** | Dynamic VMs | Ninguna especial ❌ |
| **Tu Quota** | 0 ❌ | Disponible ✅ |
| **Disponibilidad** | NO DISPONIBLE | DISPONIBLE ✅ |
| **Funcionalidad** | Completa | Completa ✅ |

**Conclusión:** Basic B1 funciona **exactamente igual**, solo cuesta más pero **NO requiere quota especial**.

---

## 🔍 **VERIFICAR TUS QUOTAS**

```powershell
.\check_quotas.ps1
```

Este script muestra:
- ✅ Quotas disponibles por región
- ✅ Planes disponibles
- ✅ Qué requiere quota especial
- ✅ Recomendaciones

---

## 📋 **OPCIONES DISPONIBLES**

### **OPCIÓN 1: Basic B1 (RECOMENDADO - Inmediato)**

**Ventajas:**
- ✅ NO requiere quota especial
- ✅ Disponible inmediatamente
- ✅ Funciona exactamente igual que Consumption
- ✅ No cold starts (mejor performance)
- ✅ Always-on (más confiable)

**Desventajas:**
- ❌ Costo: ~$13/mes (vs $0.70/mes)
- ❌ No es serverless (siempre corriendo)

**Cómo usarlo:**
```powershell
.\DEPLOY_BASIC.ps1
```

---

### **OPCIÓN 2: Solicitar Quota Consumption (1-2 días)**

**Pasos:**
1. Azure Portal → Quotas
2. New support request
3. Tipo: Service and subscription limits (quotas)
4. Quota type: Compute-VM (cores)
5. Location: East US
6. SKU family: Dynamic VMs
7. New limit: 10 o más
8. Esperar aprobación: 1-2 días hábiles

**Ventajas:**
- ✅ Consumption Plan disponible
- ✅ Costo: ~$0.70/mes (mucho más barato)
- ✅ Serverless (pay-per-use)

**Desventajas:**
- ❌ Requiere esperar 1-2 días
- ❌ Puede ser rechazado (suscripciones trial/free)
- ❌ Cold starts (1-3 segundos)

---

### **OPCIÓN 3: Premium EP1 (~$150/mes)**

**Solo si necesitas:**
- Pre-warming (sin cold starts)
- VNET integration
- Performance superior
- Features empresariales

**NO recomendado para POC** (muy caro)

---

## 🚀 **COMANDO RECOMENDADO**

```powershell
.\DEPLOY_BASIC.ps1
```

**Por qué Basic B1:**
- ✅ Funciona AHORA (sin esperar)
- ✅ NO requiere quota
- ✅ Funcionalidad idéntica
- ✅ Mejor performance (no cold starts)
- ✅ Mismo POC, diferente costo

---

## 📊 **COSTO TOTAL DEL POC**

### **Con Consumption (si tuvieras quota):**
```
Escenario 0: $0/mes (compartido)
Escenario 1: $13.14/mes (App Service)
Escenario 2: $0.70/mes (Functions Consumption)
────────────────────────────────────
TOTAL:       $13.84/mes
```

### **Con Basic B1 (disponible ahora):**
```
Escenario 0: $0/mes (compartido)
Escenario 1: $13.14/mes (App Service)
Escenario 2: $13/mes (Functions Basic)
────────────────────────────────────
TOTAL:       $26.14/mes
```

**Diferencia:** +$12.30/mes (sigue siendo barato para un POC completo)

---

## 🔧 **CAMBIO MANUAL (si prefieres)**

Si prefieres hacer el cambio manualmente:

```powershell
# 1. Modificar main.tf (línea 98)
# Cambiar:
sku_name = "Y1"

# Por:
sku_name = "B1"

# 2. Limpiar y re-deployar
.\cleanup.ps1
terraform init
.\DEPLOY_NOW.ps1
```

---

## 📞 **SCRIPTS DISPONIBLES**

| Script | Propósito |
|--------|-----------|
| **check_quotas.ps1** | Verificar quotas disponibles |
| **switch_to_basic.ps1** | Cambiar de Y1 a B1 |
| **DEPLOY_BASIC.ps1** | ⭐ Deployment completo con B1 |
| cleanup.ps1 | Limpiar recursos parciales |
| DEPLOY_NOW.ps1 | Deployment normal |

---

## 💡 **RECOMENDACIÓN FINAL**

Para **continuar inmediatamente** con el POC:

```powershell
.\DEPLOY_BASIC.ps1
```

**Resultado:**
- ✅ Escenario 2 funcionando en 12-15 minutos
- ✅ 4 Azure Functions desplegadas
- ✅ Same functionality as Consumption
- ✅ Costo: ~$13/mes (aceptable para POC)

Si quieres **optimizar costos después**, solicita quota para Consumption y re-deploya.

---

## 📝 **NOTAS IMPORTANTES**

1. **Basic B1 es perfectamente válido** para el POC
2. La funcionalidad es **idéntica** a Consumption
3. La única diferencia es **costo** y **no serverless**
4. Puedes **cambiar después** si consigues quota

---

**Fecha:** 8 de enero de 2026  
**Problema:** Sin quota para Consumption Plan  
**Solución:** Usar Basic B1 (no requiere quota)  
**Comando:** `.\DEPLOY_BASIC.ps1`
