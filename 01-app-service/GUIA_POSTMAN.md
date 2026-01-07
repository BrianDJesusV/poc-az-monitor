# 📮 GUÍA: Colección de Postman - Azure Monitor POC

**Fecha:** 7 de enero de 2026   
**Propósito:** Generar tráfico sintético a la aplicación Flask para observar métricas en Application Insights

---

## 📦 ARCHIVOS INCLUIDOS

```
Azure_Monitor_POC_Collection.postman_collection.json  (Colección principal)
Azure_Monitor_POC.postman_environment.json           (Variables de entorno)
```

**Ubicación:**
```
C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\
```

---

## 🚀 INSTALACIÓN Y CONFIGURACIÓN

### **PASO 1: Descargar e Instalar Postman**

Si no tienes Postman instalado:

1. Ve a: https://www.postman.com/downloads/
2. Descarga Postman para Windows
3. Instala y abre la aplicación
4. (Opcional) Crea una cuenta gratuita o usa como invitado

---

### **PASO 2: Importar la Colección**

1. **Abrir Postman**

2. **Importar Colección:**
   - Click en **"Import"** (esquina superior izquierda)
   - Click en **"Choose Files"**
   - Navega a: `C:\Users\User\Documents\proyectos\proyectos_trabajo\azure\poc_azure_monitor\01-app-service\`
   - Selecciona: **`Azure_Monitor_POC_Collection.postman_collection.json`**
   - Click en **"Import"**

3. **Importar Environment:**
   - Click nuevamente en **"Import"**
   - Selecciona: **`Azure_Monitor_POC.postman_environment.json`**
   - Click en **"Import"**

4. **Activar Environment:**
   - En la esquina superior derecha, verás un dropdown de environments
   - Selecciona: **"Azure Monitor POC - Environment"**
   - Verifica que el ícono del "ojo" muestre `base_url = https://app-azmon-demo-ltr94a.azurewebsites.net`

---

### **PASO 3: Verificar la Colección**

En el panel izquierdo verás la colección con estas carpetas:

```
📁 Azure Monitor POC - Traffic Generator
  ├── ✅ Endpoints Exitosos (200 OK)
  │   ├── GET / (Home Page)
  │   └── GET /health (Health Check)
  │
  ├── ⚠️ API Endpoints (404 en versión simple)
  │   ├── GET /api/success
  │   ├── GET /api/slow
  │   ├── GET /api/error
  │   ├── GET /api/notfound
  │   └── POST /api/data
  │
  └── 🎲 Random Endpoints (para variedad)
      └── Random GET Request
```

---

## 🧪 PROBAR REQUESTS INDIVIDUALES

### **Método 1: Click Manual**

1. Expande la carpeta **"✅ Endpoints Exitosos"**
2. Click en **"GET /health"**
3. Click en el botón azul **"Send"**
4. Verás la respuesta:
   ```json
   {
       "status": "healthy",
       "version": "1.0.0"
   }
   ```
5. Observa:
   - **Status:** 200 OK (en verde)
   - **Time:** Tiempo de respuesta en ms
   - **Size:** Tamaño de la respuesta
   - **Test Results:** Tests automáticos que pasan

6. Prueba otros endpoints:
   - **GET /** → Retorna HTML
   - **GET /api/success** → 404 (con versión simple)
   - **GET /api/error** → 404 (con versión simple)

---

## 🏃 GENERAR TRÁFICO CON COLLECTION RUNNER

Esta es la forma **MÁS EFECTIVA** de generar mucho tráfico rápidamente.

### **OPCIÓN A: Runner con Todos los Endpoints**

1. **Abrir Collection Runner:**
   - Click derecho en la colección **"Azure Monitor POC - Traffic Generator"**
   - Selecciona **"Run collection"**
   - O usa el botón **"Run"** en la parte superior de la colección

2. **Configurar el Runner:**

   - **Iterations:** 50 (ejecutará todos los requests 50 veces)
   - **Delay:** 500 ms (espera entre requests)
   - **Data:** (dejar vacío)
   - **Save responses:** (opcional, solo si quieres ver detalles)

3. **Seleccionar Requests:**
   - Por defecto, todos están seleccionados ✅
   - Puedes desmarcar algunos si solo quieres probar ciertos endpoints

4. **Ejecutar:**
   - Click en el botón azul **"Run Azure Monitor POC..."**
   - Verás el progreso en tiempo real:
     - Requests ejecutados
     - Tests pasados/fallados
     - Tiempos de respuesta

5. **Resultados:**
   - Al finalizar verás un resumen:
     - Total requests ejecutados
     - Success rate
     - Average response time
     - Test results

**EJEMPLO DE CONFIGURACIÓN:**
```
Iterations: 50
Delay: 500 ms
Total Requests: 50 iterations × 7 requests = 350 requests
Duración estimada: ~3-4 minutos
```

---

### **OPCIÓN B: Runner Solo con Endpoints Exitosos**

Si solo quieres generar tráfico limpio (200 OK):

1. Click derecho en la carpeta **"✅ Endpoints Exitosos (200 OK)"**
2. Selecciona **"Run folder"**
3. Configura:
   - **Iterations:** 100
   - **Delay:** 300 ms
4. Click **"Run..."**

**Resultado:**
```
100 iterations × 2 requests = 200 requests
Todos con status 200 OK
```

---

### **OPCIÓN C: Runner con Endpoint Aleatorio**

Para máxima variedad:

1. Click derecho en la carpeta **"🎲 Random Endpoints"**
2. Selecciona **"Run folder"**
3. Configura:
   - **Iterations:** 200
   - **Delay:** 200 ms
4. Click **"Run..."**

**Resultado:**
```
200 requests con endpoints aleatorios
Mezcla natural de 200, 404, y potencialmente 500
```

---

## 📊 MONITOREAR EN TIEMPO REAL

### **Durante la Ejecución del Runner:**

1. **En Postman:**
   - Verás el progreso de cada request
   - Tests pasando o fallando
   - Tiempos de respuesta

2. **En Azure Portal:**
   - Abre Application Insights
   - Ve a **"Live Metrics"**
   - Observa en tiempo real:
     - Incoming requests rate
     - Request duration
     - Request success rate
     - Server health

**Link a Live Metrics:**
```
https://portal.azure.com/#@/resource/subscriptions/dd4fe3a1-a740-49ad-b613-b4f951aa474c/resourceGroups/rg-azmon-poc-mexicocentral/providers/Microsoft.Insights/components/appi-azmon-appservice-ltr94a/liveMetrics
```

---

## 🎯 ESTRATEGIAS DE GENERACIÓN DE TRÁFICO

### **Estrategia 1: Tráfico Constante (5 minutos)**
```
Iterations: 150
Delay: 2000 ms (2 segundos)
Total requests: ~1050
Duración: ~5 minutos
```

### **Estrategia 2: Tráfico Intensivo (1 minuto)**
```
Iterations: 100
Delay: 100 ms
Total requests: ~700
Duración: ~1 minuto
```

### **Estrategia 3: Tráfico Realista (10 minutos)**
```
Iterations: 300
Delay: 1500 ms
Total requests: ~2100
Duración: ~10 minutos
```

### **Estrategia 4: Test de Carga**
```
Iterations: 500
Delay: 50 ms
Total requests: ~3500
Duración: ~3 minutos
⚠️ CUIDADO: Puede generar mucha carga
```

---

## 🔍 ANALIZAR RESULTADOS

### **En Postman:**

Después de ejecutar el Runner:

1. **View Results** te muestra:
   - Requests individuales
   - Status codes
   - Response times
   - Test results

2. **Export Results:**
   - Click en "Export Results" para guardar un reporte
   - Formato JSON con todos los detalles

### **En Application Insights:**

1. **Ir a Logs** y ejecutar:
   ```kusto
   requests
   | where timestamp > ago(10m)
   | summarize 
       Total = count(),
       Avg_Duration = avg(duration),
       Success_Rate = 100.0 * countif(success)/count()
       by bin(timestamp, 1m)
   | render timechart
   ```

2. **Performance View:**
   - Ver distribución de response times
   - Identificar requests lentos
   - Analizar percentiles (P50, P95, P99)

3. **Failures View:**
   - Ver todos los 404
   - Analizar patrones de error

---

## 💡 TIPS Y TRUCOS

### **Tip 1: Variables Dinámicas**

Postman tiene variables dinámicas que puedes usar:

- `{{$timestamp}}` - Unix timestamp actual
- `{{$randomInt}}` - Número aleatorio
- `{{$guid}}` - GUID aleatorio

Ejemplo en POST /api/data:
```json
{
    "request_id": "{{$guid}}",
    "timestamp": "{{$timestamp}}",
    "user_id": {{$randomInt}}
}
```

### **Tip 2: Scripts Pre-Request**

Puedes ejecutar código JavaScript antes de cada request:

```javascript
// Establecer header dinámico
pm.request.headers.add({
    key: 'X-Request-ID',
    value: pm.variables.replaceIn('{{$guid}}')
});

// Log para debugging
console.log('Sending request to:', pm.request.url);
```

### **Tip 3: Scripts de Test**

Agregar validaciones personalizadas:

```javascript
pm.test("Response time is acceptable", function () {
    pm.expect(pm.response.responseTime).to.be.below(1000);
});

pm.test("Has correct content type", function () {
    pm.expect(pm.response.headers.get('Content-Type')).to.include('application/json');
});
```

### **Tip 4: Exportar Métricas**

Después de un Runner largo, exporta los resultados:

1. Click en "Export Results"
2. Guarda el JSON
3. Analiza con Python/Excel:
   ```python
   import json
   with open('results.json') as f:
       data = json.load(f)
   
   # Analizar response times, success rate, etc.
   ```

---

## 🚨 TROUBLESHOOTING

### **Problema: "Could not get any response"**

**Causa:** La app está caída o hay problemas de red

**Solución:**
1. Verifica que la app esté running en Azure Portal
2. Prueba la URL en el navegador
3. Reinicia la Web App si es necesario

### **Problema: "Too many 404 errors"**

**Causa:** Estás usando la versión simple de la app

**Solución:**
- Es ESPERADO con versión simple
- Solo / y /health dan 200 OK
- Los 404 son ÚTILES para demostrar manejo de errores
- (Opcional) Actualiza a versión completa para más variedad

### **Problema: "Tests failing"**

**Causa:** Tests esperan comportamiento de versión completa

**Solución:**
- Los tests están diseñados para aceptar tanto 200 como 404
- Si un test falla inesperadamente, revisa la respuesta real
- Modifica los tests según tus necesidades

### **Problema: Postman se cuelga con muchas iteraciones**

**Causa:** Demasiados requests guardados en memoria

**Solución:**
- Desmarca "Save responses" en Runner
- Reduce el número de iteraciones
- Usa delay más largo entre requests

---

## 📈 MEJORES PRÁCTICAS

1. **Empieza Pequeño:**
   - Primera vez: 10-20 iterations
   - Verifica que todo funciona
   - Luego incrementa gradualmente

2. **Monitorea en Tiempo Real:**
   - Abre Live Metrics en Azure
   - Observa el impacto mientras ejecutas

3. **Varía el Tráfico:**
   - No uses siempre los mismos endpoints
   - Alterna entre carpetas diferentes
   - Usa el endpoint aleatorio

4. **Documenta tus Tests:**
   - Anota configuraciones que usaste
   - Guarda screenshots de métricas
   - Exporta resultados importantes

5. **Respeta los Límites:**
   - Plan B1 tiene límites de CPU/memoria
   - No generes tráfico 24/7
   - Deja descansar entre tests largos

---

## 🎯 ESCENARIOS DE USO

### **Escenario 1: Demo Rápida**
```
Objetivo: Mostrar Application Insights en acción
Configuración:
  - Carpeta: Random Endpoints
  - Iterations: 30
  - Delay: 1000 ms
  - Duración: ~3 minutos
```

### **Escenario 2: Testing de Performance**
```
Objetivo: Ver cómo responde la app bajo carga
Configuración:
  - Colección completa
  - Iterations: 100
  - Delay: 200 ms
  - Duración: ~2 minutos
```

### **Escenario 3: Generar Datos Históricos**
```
Objetivo: Poblar Application Insights con datos
Configuración:
  - Ejecutar varias veces al día
  - Iterations: 50-100 cada vez
  - Delay: 500-2000 ms
  - Total diario: 500-1000 requests
```

### **Escenario 4: Testing de Errores**
```
Objetivo: Verificar manejo de errores
Configuración:
  - Solo carpeta "API Endpoints"
  - Iterations: 50
  - Delay: 500 ms
  - Resultado: Muchos 404 para analizar
```

---

## 📚 RECURSOS ADICIONALES

**Documentación Oficial de Postman:**
- Collection Runner: https://learning.postman.com/docs/running-collections/intro-to-collection-runs/
- Writing Tests: https://learning.postman.com/docs/writing-scripts/test-scripts/
- Variables: https://learning.postman.com/docs/sending-requests/variables/

**Tutoriales en Video:**
- YouTube: "Postman Collection Runner Tutorial"
- YouTube: "Load Testing with Postman"

---

## ✅ CHECKLIST RÁPIDO

Antes de generar tráfico:

- [ ] Postman instalado
- [ ] Colección importada
- [ ] Environment activado
- [ ] Variable `base_url` correcta
- [ ] Probado al menos un request manual
- [ ] Application Insights abierto en Azure Portal
- [ ] Live Metrics listo para monitorear

Después de generar tráfico:

- [ ] Exportar resultados del Runner
- [ ] Verificar métricas en Application Insights
- [ ] Ejecutar queries KQL en Logs
- [ ] Documentar hallazgos
- [ ] (Opcional) Crear dashboard con métricas

---

**¡Listo para generar tráfico con Postman!** 🚀

**Última actualización:** 7 de enero de 2026
