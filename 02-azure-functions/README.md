# Escenario 2: Azure Functions + Serverless Monitoring

## 📋 Descripción

Azure Functions con monitoreo serverless completo:
- Function App (4 Functions Python)
- Storage Account (queues, blobs)
- Application Insights
- Event-driven triggers

## 🚀 Deployment

### **Infraestructura (Automático)**

```powershell
# Desde la raíz del proyecto
.\DEPLOY_SECURE.ps1
```

### **Functions (Manual via Portal)**

1. El script creará `functions_deploy.zip`
2. Azure Portal → Function App → Deployment Center
3. ZIP Deploy → Browse → `functions_deploy.zip`
4. Deploy

**Razón del deployment manual**: CLI puede fallar con Standard S1. Portal es más confiable.

## 📊 Recursos Creados

- **Storage Account**: Queues y Blobs para triggers
- **Function App**: 4 funciones Python
- **Application Insights**: Telemetría serverless
- **Service Plan**: Standard S1 (Linux)

## 🔗 Dependencias

- **Escenario 0** (Shared Infrastructure) debe estar desplegado primero

## 💰 Costo

**~$70/mes** - Service Plan Standard S1

## 📁 Estructura

```
02-azure-functions/
├── main.tf                  (Infraestructura)
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── README.md               (este archivo)
├── functions/              (Código Functions)
│   ├── HttpTrigger/
│   ├── TimerTrigger/
│   ├── QueueTrigger/
│   ├── BlobTrigger/
│   ├── host.json
│   └── requirements.txt
├── scripts/                (Scripts de deployment)
│   ├── deploy_*.ps1
│   ├── test_functions.ps1
│   └── ...
└── docs/                   (Documentación)
    ├── guías de deployment
    ├── troubleshooting
    └── ...
```

## 🎯 Functions Incluidas

1. **HttpTrigger**: API REST endpoint
2. **TimerTrigger**: Ejecución programada (cada 5 min)
3. **QueueTrigger**: Procesa mensajes de queue
4. **BlobTrigger**: Procesa archivos subidos

## 📝 Notas

- Region: Mexico Central (misma que Escenario 0 y 1)
- Standard S1 es necesario debido a limitaciones de quota
- Consumption Plan (Y1) no está disponible en la suscripción actual
