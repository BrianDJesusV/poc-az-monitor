# 🚀 GUÍA DE DEPLOYMENT - FLASK APP AL AZURE APP SERVICE

**Fecha:** 2026-01-06  
**App Service:** app-azmon-demo-ltr94a  
**Resource Group:** rg-azmon-poc-mexicocentral  
**Región:** Mexico Central  

---

## 📋 SITUACIÓN ACTUAL

✅ **Infraestructura desplegada:**
- App Service Plan (F1 Free): `asp-azmon-poc-ltr94a`
- Web App: `app-azmon-demo-ltr94a`
- Application Insights: `appi-azmon-appservice-ltr94a`
- URL: https://app-azmon-demo-ltr94a.azurewebsites.net

⚠️ **Pendiente:**
- Desplegar código de la aplicación Flask

---

## 🎯 OPCIONES DE DEPLOYMENT

Tienes **3 opciones** para desplegar la aplicación (ordenadas de más simple a más compleja):

---

### **OPCIÓN 1: DEPLOYMENT MANUAL DESDE PORTAL AZURE** ⭐ RECOMENDADO

Esta es la opción **más confiable** y fácil de debuggear.

#### **Pasos:**

1. **Acceder al Portal de Azure:**
   ```
   https://portal.azure.com/#resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/rg-azmon-poc-mexicocentral/providers/Microsoft.Web/sites/app-azmon-demo-ltr94a
   ```

2. **Ir a Deployment Center:**
   - En el menú izquierdo, busca **"Deployment Center"**
   - Click en **"Local Git"** o **"ZIP Deploy"**

3. **Opción A - ZIP Deploy (MÁS RÁPIDO):**
   - Selecciona **"ZIP Deploy"**
   - Sube el archivo: `simple-flask.zip` o `flask-deploy.zip`
   - Click en **"Deploy"**
   - Espera 2-3 minutos

4. **Opción B - Local Git:**
   - Click en **"Local Git"** 
   - Copia la URL del repositorio Git
   - Desde tu máquina local:
     ```bash
     cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\test-app
     git init
     git add .
     git commit -m "Initial deployment"
     git remote add azure [URL_DEL_GIT]
     git push azure master
     ```

5. **Verificar deployment:**
   - Ir a **"Log stream"** en el portal
   - Ver los logs en tiempo real del build y startup

---

### **OPCIÓN 2: DEPLOYMENT CON AZURE CLI (AUTOMATIZADO)**

Usar el comando `az webapp up` desde la carpeta de la aplicación.

#### **Versión Simple (APP BÁSICA):**

```powershell
# 1. Descargar aplicación simple
# Descarga: simple-flask.zip

# 2. Extraer en carpeta temporal
New-Item -ItemType Directory -Force -Path C:\temp\flask-simple
Expand-Archive -Path "C:\Downloads\simple-flask.zip" -DestinationPath "C:\temp\flask-simple" -Force

# 3. Desplegar
cd C:\temp\flask-simple
wsl az webapp up `
    --resource-group rg-azmon-poc-mexicocentral `
    --name app-azmon-demo-ltr94a `
    --runtime PYTHON:3.11 `
    --sku F1 `
    --plan asp-azmon-poc-ltr94a

# 4. Esperar build (2-5 minutos)
# 5. Verificar
curl https://app-azmon-demo-ltr94a.azurewebsites.net/health
```

#### **Versión Completa (CON APPLICATION INSIGHTS):**

```powershell
# 1. Ir a carpeta de la app completa
cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\test-app

# 2. Configurar Application Insights
$ConnectionString = wsl az monitor app-insights component show `
    --app appi-azmon-appservice-ltr94a `
    --resource-group rg-azmon-poc-mexicocentral `
    --query connectionString -o tsv

wsl az webapp config appsettings set `
    --resource-group rg-azmon-poc-mexicocentral `
    --name app-azmon-demo-ltr94a `
    --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$ConnectionString"

# 3. Desplegar
wsl az webapp up `
    --resource-group rg-azmon-poc-mexicocentral `
    --name app-azmon-demo-ltr94a `
    --runtime PYTHON:3.11 `
    --sku F1 `
    --plan asp-azmon-poc-ltr94a

# 4. Reiniciar app
wsl az webapp restart `
    --resource-group rg-azmon-poc-mexicocentral `
    --name app-azmon-demo-ltr94a

# 5. Ver logs en tiempo real
wsl az webapp log tail `
    --resource-group rg-azmon-poc-mexicocentral `
    --name app-azmon-demo-ltr94a
```

---

### **OPCIÓN 3: DEPLOYMENT CON GITHUB ACTIONS (CI/CD)**

Configurar deployment automático desde un repositorio de GitHub.

#### **Pasos:**

1. **Crear repositorio en GitHub:**
   ```bash
   # Subir código a GitHub
   cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\test-app
   git init
   git add .
   git commit -m "Azure Monitor POC Flask App"
   git remote add origin https://github.com/TU_USUARIO/azure-monitor-poc.git
   git push -u origin main
   ```

2. **Configurar GitHub Actions en Azure:**
   - En el Portal de Azure, ir a **Deployment Center**
   - Seleccionar **"GitHub"**
   - Autenticarse con GitHub
   - Seleccionar el repositorio
   - Azure creará automáticamente el workflow file

3. **Cada push a main desplegará automáticamente**

---

## 🔧 TROUBLESHOOTING

### **Error: "Build failed"**

**Causa:** El tier F1 tiene recursos limitados y puede fallar el build con dependencias pesadas.

**Solución:**
1. Usar la **app simple** (`simple-flask.zip`) primero
2. Una vez funcionando, agregar dependencias gradualmente
3. Alternativa: Usar un tier superior temporalmente (B1) para el build inicial

### **Error: "Module not found"**

**Causa:** `requirements.txt` no se procesó correctamente.

**Solución:**
```bash
# Forzar rebuild
wsl az webapp config appsettings set `
    --resource-group rg-azmon-poc-mexicocentral `
    --name app-azmon-demo-ltr94a `
    --settings "SCM_DO_BUILD_DURING_DEPLOYMENT=true"

# Reintentar deployment
wsl az webapp restart --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a
```

### **App no responde después de deployment**

**Solución:**
```bash
# Ver logs en tiempo real
wsl az webapp log tail --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a

# Reiniciar app
wsl az webapp restart --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a

# Verificar configuración
wsl az webapp config show --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a
```

---

## 📦 ARCHIVOS DISPONIBLES

| Archivo | Tamaño | Descripción |
|---------|--------|-------------|
| `simple-flask.zip` | 896 bytes | App Flask básica (solo Flask + gunicorn) |
| `flask-deploy.zip` | 3.6 KB | App completa con Application Insights |
| `deploy-flask.ps1` | - | Script PowerShell automatizado |

---

## ✅ VERIFICACIÓN POST-DEPLOYMENT

Una vez desplegada la aplicación, verifica:

```bash
# 1. Health check
curl https://app-azmon-demo-ltr94a.azurewebsites.net/health

# Respuesta esperada:
# {"status":"healthy","timestamp":1234567890,"version":"1.0.0"}

# 2. Página principal
curl https://app-azmon-demo-ltr94a.azurewebsites.net/

# 3. Endpoint de test
curl https://app-azmon-demo-ltr94a.azurewebsites.net/api/success
```

### **Endpoints Disponibles (App Completa):**

```
GET  /                  → Página principal con info
GET  /health            → Health check
GET  /api/success       → Request exitoso
GET  /api/slow          → Request lento (2-4s)
GET  /api/error         → Error 500
GET  /api/notfound      → Error 404
POST /api/data          → Recibe JSON
GET  /metrics           → Métricas Prometheus
```

---

## 🎯 RECOMENDACIÓN

**Para completar el POC rápidamente:**

1. ✅ Usar **OPCIÓN 1** (Portal Azure) con `simple-flask.zip`
2. ✅ Verificar que funciona
3. ✅ Luego actualizar a la app completa con Application Insights
4. ✅ Generar tráfico de prueba con `generate_traffic.py`
5. ✅ Explorar métricas en Application Insights

**Tiempo estimado:** 10-15 minutos

---

## 📞 COMANDOS ÚTILES

```powershell
# Ver logs en tiempo real
wsl az webapp log tail --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a

# Descargar logs
wsl az webapp log download --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a

# Reiniciar app
wsl az webapp restart --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a

# Ver estado
wsl az webapp show --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a --query state

# Abrir en browser
start https://app-azmon-demo-ltr94a.azurewebsites.net
```

---

## 🚀 PRÓXIMOS PASOS

Una vez que la app esté funcionando:

1. **Generar tráfico de prueba:**
   ```bash
   cd C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service
   python generate_traffic.py
   ```

2. **Explorar Application Insights:**
   - Portal → Application Insights → `appi-azmon-appservice-ltr94a`
   - Ver métricas, logs, trazas, excepciones

3. **Queries KQL de ejemplo:**
   ```kusto
   requests
   | where timestamp > ago(1h)
   | summarize count() by resultCode
   ```

4. **Crear dashboards personalizados**

5. **Configurar alertas**

---

**¿Necesitas ayuda?** Ver logs con:
```bash
wsl az webapp log tail --resource-group rg-azmon-poc-mexicocentral --name app-azmon-demo-ltr94a
```

¡Buena suerte! 🎉
