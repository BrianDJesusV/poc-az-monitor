# 📮 COLECCIÓN DE POSTMAN CREADA - Azure Monitor POC

**Fecha:** 7 de enero de 2026  
**Estado:** ✅ COMPLETADO

---

## 🎉 RESUMEN

Se ha creado una colección completa de Postman para generar tráfico sintético a tu aplicación Azure Monitor POC.

---

## 📦 ARCHIVOS GENERADOS

### **1. Colección Principal**
```
📄 Azure_Monitor_POC_Collection.postman_collection.json
```
**Contiene:**
- ✅ 2 endpoints exitosos (/, /health)
- ⚠️ 5 endpoints API (para versión completa)
- 🎲 1 endpoint aleatorio (para variedad)
- 📝 Tests automáticos en cada request
- 🔧 Scripts pre-request para logging

**Total:** 8 requests configurados

### **2. Environment File**
```
📄 Azure_Monitor_POC.postman_environment.json
```
**Variables incluidas:**
- `base_url`: https://app-azmon-demo-ltr94a.azurewebsites.net
- `app_name`: app-azmon-demo-ltr94a
- `resource_group`: rg-azmon-poc-mexicocentral
- `region`: mexicocentral

### **3. Documentación**
```
📄 GUIA_POSTMAN.md (guía completa, 500+ líneas)
📄 POSTMAN_QUICKSTART.md (quick start, 100 líneas)
```

**Ubicación de todos los archivos:**
```
C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\
```

---

## 🚀 CÓMO EMPEZAR

### **Paso 1: Instalar Postman**
Si no lo tienes: https://www.postman.com/downloads/

### **Paso 2: Importar Archivos**
1. Abrir Postman
2. Click en **"Import"**
3. Seleccionar ambos archivos .json
4. Activar el environment en el dropdown superior derecho

### **Paso 3: Generar Tráfico**
```
Click derecho en colección → "Run collection"
Iterations: 50
Delay: 500 ms
Click "Run"
```

**Resultado:** ~350 requests en ~3 minutos

---

## 📊 ESTRUCTURA DE LA COLECCIÓN

```
📁 Azure Monitor POC - Traffic Generator
│
├── 📂 ✅ Endpoints Exitosos (200 OK)
│   ├── GET /               [200 OK]
│   └── GET /health         [200 OK, JSON]
│
├── 📂 ⚠️ API Endpoints (404 en versión simple)
│   ├── GET /api/success    [404 con simple, 200 con completa]
│   ├── GET /api/slow       [404 con simple, 200+delay con completa]
│   ├── GET /api/error      [404 con simple, 500 con completa]
│   ├── GET /api/notfound   [404 siempre]
│   └── POST /api/data      [404 con simple, 200 con completa]
│
└── 📂 🎲 Random Endpoints (para variedad)
    └── Random GET Request  [Endpoint aleatorio cada ejecución]
```

---

## 🎯 CASOS DE USO

### **1. Demo Rápida (2 minutos)**
```
Folder: "✅ Endpoints Exitosos"
Iterations: 50
Delay: 1000 ms
Resultado: 100 requests, todos 200 OK
```

### **2. Generar Variedad (3 minutos)**
```
Folder: "🎲 Random Endpoints"
Iterations: 200
Delay: 500 ms
Resultado: 200 requests variados
```

### **3. Test de Carga (1 minuto)**
```
Colección completa
Iterations: 100
Delay: 100 ms
Resultado: ~700 requests intensivos
```

### **4. Tráfico Realista (5 minutos)**
```
Colección completa
Iterations: 150
Delay: 1500 ms
Resultado: ~1050 requests distribuidos
```

---

## 🔍 TESTS AUTOMÁTICOS INCLUIDOS

Cada request tiene tests que verifican:

✅ **Status Code** correcto (200, 404, o 500 según endpoint)  
✅ **Response Time** aceptable (<500ms para endpoints normales)  
✅ **Content-Type** presente en headers  
✅ **JSON válido** (para endpoints que retornan JSON)  
✅ **Campos requeridos** presentes en respuesta  

**Resultado:** Dashboard automático de success/failure en Collection Runner

---

## 📈 MÉTRICAS ESPERADAS EN APPLICATION INSIGHTS

Después de ejecutar 50 iterations de la colección completa:

```
Total Requests: ~350
├── 200 OK: ~100 (28.6%)
│   ├── GET /: ~50
│   └── GET /health: ~50
│
└── 404 Not Found: ~250 (71.4%)
    ├── GET /api/success: ~50
    ├── GET /api/slow: ~50
    ├── GET /api/error: ~50
    ├── GET /api/notfound: ~50
    └── POST /api/data: ~50
```

**Duración:** ~3-4 minutos  
**Rate Promedio:** ~2 req/s

---

## 💡 TIPS IMPORTANTES

### **Para Mejor Performance en Runner:**

1. **Desmarca "Save responses"** (ahorra memoria)
2. **Usa delays apropiados** (500-1000ms recomendado)
3. **Empieza con pocas iterations** (10-20 para probar)
4. **Monitorea en Live Metrics** (Azure Portal)

### **Para Análisis en Application Insights:**

Después de generar tráfico, ejecuta estas queries KQL:

```kusto
// Distribución de status codes
requests
| where timestamp > ago(10m)
| summarize count() by resultCode
| render piechart
```

```kusto
// Timeline de requests
requests
| where timestamp > ago(10m)
| summarize count() by bin(timestamp, 30s)
| render timechart
```

```kusto
// Top endpoints por cantidad
requests
| where timestamp > ago(10m)
| summarize count() by name
| order by count_ desc
```

---

## 🔗 LINKS ÚTILES

**Application Insights:**
```
https://portal.azure.com → buscar "appi-azmon-appservice-ltr94a"
```

**Live Metrics (tiempo real):**
```
Application Insights → Investigate → Live Metrics
```

**Logs (KQL queries):**
```
Application Insights → Logs
```

**Performance Dashboard:**
```
Application Insights → Investigate → Performance
```

---

## 📚 DOCUMENTACIÓN

### **Guía Completa:**
`GUIA_POSTMAN.md`
- Instrucciones detalladas paso a paso
- Configuraciones avanzadas
- Troubleshooting
- Scripts personalizados
- Mejores prácticas

### **Quick Start:**
`POSTMAN_QUICKSTART.md`
- Empezar en 2 minutos
- Comandos esenciales
- Configuraciones recomendadas

---

## 🎓 PRÓXIMOS PASOS

### **Opción 1: Usar Postman Ahora**
1. Instalar Postman
2. Importar colección
3. Generar tráfico
4. Ver métricas en Azure

### **Opción 2: Combinar con Script PowerShell**
- Usar Postman para tests manuales
- Usar `generate_traffic.ps1` para automatización
- Combinar ambos para máxima cobertura

### **Opción 3: Actualizar a Versión Completa**
Desplegar `flask-deploy.zip` para:
- Más endpoints funcionales
- Respuestas variadas (200, 404, 500)
- Endpoints lentos simulados
- Mejor demostración de Application Insights

---

## ✅ CHECKLIST DE VERIFICACIÓN

Antes de usar la colección:

- [ ] Postman instalado
- [ ] Archivos .json descargados/localizados
- [ ] Colección importada en Postman
- [ ] Environment importado y activado
- [ ] Variable `base_url` verificada
- [ ] Probado 1 request manual exitosamente
- [ ] Azure Portal abierto en Application Insights
- [ ] Live Metrics listo para monitorear

Después de generar tráfico:

- [ ] Verificar métricas en Performance
- [ ] Ver errores en Failures
- [ ] Ejecutar queries KQL en Logs
- [ ] Exportar resultados de Runner
- [ ] Documentar hallazgos importantes
- [ ] (Opcional) Crear dashboard personalizado
- [ ] (Opcional) Configurar alertas

---

**¡Colección de Postman lista para usar!** 🎉

**Archivos ubicados en:**
```
C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\
```

**Última actualización:** 7 de enero de 2026, 19:15 UTC
