# LIMPIEZA Y RE-DEPLOYMENT

## ✅ PROBLEMA SOLUCIONADO

El error era que Mexico Central no permite "Dynamic SKU + Linux Worker" en el resource group existente.

**Solución aplicada:** Crear un resource group nuevo específico para Functions.

---

## 🔧 PASO 1: LIMPIAR RECURSOS PARCIALES

Primero elimina los recursos que se crearon parcialmente:

```powershell
# Listar recursos creados
az resource list --resource-group rg-azmon-poc-mexicocentral --output table | Select-String "7wue34"

# Eliminar Storage Account
az storage account delete --name stazmon7wue34 --resource-group rg-azmon-poc-mexicocentral --yes

# Eliminar Application Insights
az monitor app-insights component delete --app appi-azmon-functions-7wue34 --resource-group rg-azmon-poc-mexicocentral
```

---

## 🔧 PASO 2: LIMPIAR ESTADO DE TERRAFORM

```powershell
# Eliminar estado local (para empezar limpio)
Remove-Item terraform.tfstate -ErrorAction SilentlyContinue
Remove-Item terraform.tfstate.backup -ErrorAction SilentlyContinue
Remove-Item tfplan -ErrorAction SilentlyContinue
Remove-Item .terraform.lock.hcl -ErrorAction SilentlyContinue
```

---

## 🚀 PASO 3: RE-EJECUTAR DEPLOYMENT

```powershell
# Re-inicializar Terraform
terraform init

# Ejecutar deployment
.\DEPLOY_NOW.ps1
```

---

## 📋 QUÉ CAMBIÓ

**ANTES:**
- Usaba: `rg-azmon-poc-mexicocentral` (compartido)
- Error: Dynamic SKU no permitido

**AHORA:**
- Crea: `rg-azmon-functions-<random>` (nuevo)
- Solución: Resource group dedicado permite Dynamic SKU

**Recursos nuevos:**
- ✅ Resource Group nuevo (rg-azmon-functions-XXXXXX)
- ✅ Storage Account
- ✅ Application Insights (vinculado al LAW del Escenario 0)
- ✅ Function App (Consumption Y1)
- ✅ 4 Functions

---

## 💡 VENTAJAS DEL CAMBIO

1. **Aislamiento** - Functions en su propio resource group
2. **Sin restricciones** - Dynamic SKU permitido
3. **Fácil cleanup** - Un solo `az group delete`
4. **Mejor organización** - Recursos separados por escenario

---

## 🎯 RESULTADO ESPERADO

```
Resource Group:   rg-azmon-functions-XXXXXX
Function App:     func-azmon-demo-XXXXXX
Storage:          stazmonXXXXXX
App Insights:     appi-azmon-functions-XXXXXX

Vinculado a LAW:  law-azmon-poc-mexicocentral (Escenario 0)
```

---

## ⏱️ TIMELINE

```
1. Limpiar recursos:    2-3 minutos
2. Limpiar Terraform:   10 segundos
3. Re-deployment:       10-15 minutos
────────────────────────────────────
Total:                  13-18 minutos
```

---

**Ejecuta estos comandos ahora:** ⬇️
