# 🚀 QUICK START - Postman Collection

## 📥 IMPORTAR EN POSTMAN (2 minutos)

1. **Abrir Postman** (descargar de https://postman.com si no lo tienes)

2. **Import** (botón superior izquierdo)
   - Selecciona: `Azure_Monitor_POC_Collection.postman_collection.json`
   - Selecciona: `Azure_Monitor_POC.postman_environment.json`

3. **Activar Environment**
   - Dropdown superior derecha → **"Azure Monitor POC - Environment"**

---

## ⚡ GENERAR TRÁFICO RÁPIDO

### **Opción 1: Test Rápido (30 requests en 30 segundos)**
```
1. Click derecho en la colección
2. "Run collection"
3. Iterations: 10
4. Delay: 1000 ms
5. Click "Run"
```

### **Opción 2: Tráfico Intenso (700 requests en 1 minuto)**
```
1. Click derecho en la colección
2. "Run collection"
3. Iterations: 100
4. Delay: 100 ms
5. Click "Run"
```

### **Opción 3: Tráfico Aleatorio (200 requests variados)**
```
1. Click derecho en carpeta "🎲 Random Endpoints"
2. "Run folder"
3. Iterations: 200
4. Delay: 300 ms
5. Click "Run"
```

---

## 📊 VER RESULTADOS

**En Postman:**
- Ver resultados del Runner al finalizar

**En Azure Portal:**
- Application Insights → **Live Metrics** (tiempo real)
- Application Insights → **Logs** (queries KQL)
- Application Insights → **Performance** (métricas agregadas)

**Link directo a Application Insights:**
```
https://portal.azure.com → buscar "appi-azmon-appservice-ltr94a"
```

---

## 📝 CONFIGURACIONES RECOMENDADAS

| Escenario | Iterations | Delay | Duración | Total Requests |
|-----------|------------|-------|----------|----------------|
| Demo rápida | 20 | 1000ms | ~2 min | ~140 |
| Test normal | 50 | 500ms | ~3 min | ~350 |
| Carga intensiva | 100 | 200ms | ~2 min | ~700 |
| Datos históricos | 150 | 2000ms | ~5 min | ~1050 |

---

## ⚠️ NOTAS IMPORTANTES

- **404 Errors son ESPERADOS** con la versión simple de la app
- Solo `/` y `/health` darán 200 OK
- Los 404 son ÚTILES para demostrar Application Insights
- Desmarca "Save responses" para mejor performance con muchas iterations

---

## 📁 ARCHIVOS

```
Azure_Monitor_POC_Collection.postman_collection.json  ← Importar este
Azure_Monitor_POC.postman_environment.json           ← Importar este
GUIA_POSTMAN.md                                      ← Guía completa
```

**Ubicación:**
```
C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\
```

---

**¡Listo en 2 minutos!** 🎉
