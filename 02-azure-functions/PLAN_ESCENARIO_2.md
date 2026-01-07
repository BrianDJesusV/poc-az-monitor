# 🚀 ESCENARIO 2: Azure Functions + Serverless Monitoring
## Plan de Implementación

**Fecha:** 7 de enero de 2026  
**Estado:** EN PLANIFICACIÓN  
**Objetivo:** Demostrar monitoreo de arquitectura serverless event-driven

---

## 🎯 OBJETIVOS DEL ESCENARIO

### **Capacidades a Demostrar**

1. **Serverless Architecture Monitoring**
   - Azure Functions (Consumption Plan)
   - Event-driven triggers (HTTP, Timer, Queue)
   - Cold start tracking
   - Execution time metrics

2. **Application Insights para Functions**
   - Telemetría automática
   - Distributed tracing entre functions
   - Dependency tracking (Storage, external APIs)
   - Custom metrics y events

3. **Cost Optimization**
   - Pay-per-execution model
   - Performance vs cost trade-offs
   - Consumption vs Premium plan analysis

4. **Event-Driven Patterns**
   - HTTP triggers (APIs)
   - Timer triggers (scheduled jobs)
   - Queue triggers (async processing)
   - Blob triggers (file processing)

---

## 🏗️ ARQUITECTURA PROPUESTA

### **Componentes Nuevos**

```
┌─────────────────────────────────────────────────────────────┐
│              ESCENARIO 2: SERVERLESS                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         EXISTING: Log Analytics Workspace             │  │
│  │       (Compartido desde Escenario 0)                 │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│                       ↓                                      │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      APPLICATION INSIGHTS (Functions)                 │  │
│  │      appi-azmon-functions-<random>                   │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│                       ↓ (monitorea)                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         STORAGE ACCOUNT                               │  │
│  │         stazmonpoc<random>                           │  │
│  │                                                       │  │
│  │  • Blobs (triggers)                                  │  │
│  │  • Queues (async messages)                           │  │
│  │  │  └─ queue-orders                                  │  │
│  │  │  └─ queue-notifications                           │  │
│  │  • Tables (simple storage)                           │  │
│  │  • Files (function code)                             │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│                       ↓ (usado por)                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         FUNCTION APP                                  │  │
│  │         func-azmon-demo-<random>                     │  │
│  │         Plan: Consumption (Y1)                       │  │
│  │                                                       │  │
│  │  Functions:                                          │  │
│  │  ├─ HttpTrigger (GET /api/hello)                    │  │
│  │  ├─ TimerTrigger (cada 5 min)                       │  │
│  │  ├─ QueueTrigger (procesa orders)                   │  │
│  │  └─ BlobTrigger (procesa archivos)                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### **Flujo de Eventos**

```
1. HTTP Request → HttpTrigger → Response + Log to App Insights

2. Timer (cron) → TimerTrigger → Generate message → Queue
                                                      ↓
3. Queue message → QueueTrigger → Process → Log results

4. File upload → Blob Storage → BlobTrigger → Process file
```

---

## 💰 COSTOS ESTIMADOS

```
Storage Account:     ~$0.50/mes
Function App:        ~$0.20/mes (dentro de free tier)
App Insights:        $0 (compartido)
────────────────────────────────
TOTAL:               ~$0.70/mes

POC COMPLETO:        $13.84/mes (Esc 0+1+2)
```

---

## 📊 COMPARATIVA: App Service vs Functions

| Aspecto | App Service (Esc 1) | Functions (Esc 2) |
|---------|---------------------|-------------------|
| Costo | $13/mes (always-on) | $0.70/mes (pay-per-exec) |
| Cold starts | No | Sí (~1-3 seg) |
| Scaling | Manual | Automático infinito |
| Ideal para | APIs constantes | Eventos, jobs |

---

## ✅ PRÓXIMOS PASOS

1. **Revisar este plan** ✅
2. **Crear Terraform infrastructure**
3. **Desplegar 4 functions básicas**
4. **Configurar monitoring**
5. **Documentar**

**¿Procedemos con la implementación?**

---

**Última actualización:** 7 de enero de 2026  
**Autor:** Brian Poch
