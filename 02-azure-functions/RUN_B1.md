# ⚡ EJECUTA ESTO EN TU POWERSHELL AHORA

```powershell
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\02-azure-functions

.\DEPLOY_BASIC.ps1
```

## 📋 QUÉ VA A PASAR (4 pasos automáticos)

### PASO 1: Cambio a Basic B1
```
Modificando main.tf...
[OK] sku_name = "Y1" -> sku_name = "B1"
```

### PASO 2: Limpieza
```
Eliminando rg-azmon-functions-lvvw1w...
Limpiando Terraform state...
[OK] Cleanup completado
```

### PASO 3: Terraform Init
```
terraform init
[OK] Terraform inicializado
```

### PASO 4: Deployment Completo
```
terraform plan -> Muestra 10 recursos
terraform apply -> Crea recursos (5-8 min)
Deploy functions -> Sube código (3-5 min)
Test HttpTrigger -> Verifica funcionamiento
Generate test data -> 5 queue + 3 blobs
[OK] Deployment completado
```

## ⏱️ TIEMPO TOTAL: 12-15 minutos

## ✅ RESULTADO FINAL

```
Resource Group:    rg-azmon-functions-XXXXXX (East US)
Storage:           stazmonXXXXXX
App Insights:      appi-azmon-functions-XXXXXX
Function App:      func-azmon-demo-XXXXXX
Service Plan:      Basic B1 ($13/mes)
Functions:         4 desplegadas

Test API:          https://func-azmon-demo-XXXXXX.azurewebsites.net/api/HttpTrigger
```

## 🎯 CONFIRMACIONES

Durante el deployment te pedirá confirmar 2 veces:

1. **Inicio:** "Continuar? (S/N)" → Escribe **S**
2. **Después del plan:** "Aplicar el plan? (S/N)" → Escribe **S**

---

**EJECUTA AHORA:**

```powershell
.\DEPLOY_BASIC.ps1
```
