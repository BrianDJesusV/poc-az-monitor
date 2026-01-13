# Escenario 1: App Service + Application Insights

## 📋 Descripción

Deployment de App Service con monitoreo completo:
- App Service (Flask app Python)
- Application Insights
- Integración con Log Analytics Workspace

## 🚀 Deployment

Automático con el script principal:

```powershell
# Desde la raíz del proyecto
.\DEPLOY_SECURE.ps1
```

O manualmente:

```powershell
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Deploy código de la aplicación
cd app
Compress-Archive -Path * -DestinationPath ..\app.zip -Force
cd ..
az webapp deployment source config-zip --resource-group rg-azmon-poc-mexicocentral --name <app-name> --src app.zip
```

## 📊 Recursos Creados

- **App Service Plan**: B1 (Basic)
- **App Service**: Aplicación Flask Python
- **Application Insights**: Telemetría de la aplicación

## 🔗 Dependencias

- **Escenario 0** (Shared Infrastructure) debe estar desplegado primero

## 💰 Costo

**~$13/mes** - App Service Plan B1

## 📁 Estructura

```
01-app-service/
├── main.tf                  (Infraestructura)
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── README.md               (este archivo)
├── app/                    (Código de la aplicación Flask)
│   ├── app.py
│   ├── requirements.txt
│   └── ...
├── scripts/                (Scripts de generación de tráfico)
│   ├── generate_traffic.ps1
│   └── generate_traffic.py
├── files/                  (Colecciones Postman)
│   ├── *.postman_collection.json
│   └── *.postman_environment.json
└── docs/                   (Documentación)
    ├── README.md
    ├── GUIA_POSTMAN.md
    └── POSTMAN_QUICKSTART.md
