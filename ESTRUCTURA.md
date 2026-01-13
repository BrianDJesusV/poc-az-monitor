# 📁 Estructura del Proyecto - POC Azure Monitor

## 🗂️ Organización

El proyecto está organizado de forma limpia y estructurada:

```
poc_azure_monitor/
│
├── 📄 .gitignore                   Protección de credenciales
├── 📄 README.md                    Documentación principal
├── ⭐ DEPLOY_SECURE.ps1            Script principal de deployment
├── ⭐ CHECK_READY.ps1              Verificación post-limpieza
│
├── 📂 docs/                        📚 Documentación general
│   ├── SECURITY_IMPROVEMENTS.md   Mejoras de seguridad aplicadas
│   ├── CLEANUP_GUIDE.md           Guía de limpieza completa
│   ├── architecture.md            Arquitectura del POC
│   ├── CASOS_DE_USO_Y_UTILIDAD.md Casos de uso
│   └── *.txt                      Guías rápidas
│
├── 📂 scripts/                     🔧 Scripts auxiliares
│   ├── DELETE_ALL.ps1             Eliminar todos los recursos
│   ├── CLEAN_GIT_HISTORY.ps1      Limpiar historial Git
│   └── SECURITY_INCIDENT_RESPONSE.ps1
│
├── 📂 00-shared-infrastructure/    🏗️ Escenario 0
│   ├── README.md                  Documentación del escenario
│   ├── main.tf                    Infraestructura Terraform
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── 📂 01-app-service/             🌐 Escenario 1
│   ├── README.md
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   │
│   ├── 📂 app/                    Código Flask Python
│   │   ├── app.py
│   │   └── requirements.txt
│   │
│   ├── 📂 scripts/                Scripts de tráfico
│   │   ├── generate_traffic.ps1
│   │   └── generate_traffic.py
│   │
│   ├── 📂 files/                  Colecciones Postman
│   │   ├── *.postman_collection.json
│   │   └── *.postman_environment.json
│   │
│   └── 📂 docs/                   Documentación específica
│       ├── README.md
│       ├── GUIA_POSTMAN.md
│       └── POSTMAN_QUICKSTART.md
│
└── 📂 02-azure-functions/         ⚡ Escenario 2
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    │
    ├── 📂 functions/              Código Functions Python
    │   ├── HttpTrigger/
    │   ├── TimerTrigger/
    │   ├── QueueTrigger/
    │   ├── BlobTrigger/
    │   ├── host.json
    │   └── requirements.txt
    │
    ├── 📂 scripts/                Scripts de deployment
    │   ├── deploy_via_portal.ps1
    │   ├── test_functions.ps1
    │   ├── check_*.ps1
    │   └── ...
    │
    └── 📂 docs/                   Documentación extensa
        ├── guías de deployment
        ├── troubleshooting
        └── ...
```

## 📝 Convenciones

### **Raíz del Proyecto**

Solo contiene:
- ✅ Scripts principales (`DEPLOY_SECURE.ps1`, `CHECK_READY.ps1`)
- ✅ Archivos de configuración (`.gitignore`)
- ✅ Documentación principal (`README.md`)

### **Carpeta `/docs`**

Documentación general del proyecto:
- Guías de seguridad
- Arquitectura
- Casos de uso
- Guías rápidas (.txt)

### **Carpeta `/scripts`**

Scripts auxiliares:
- Limpieza
- Respuesta a incidentes
- Mantenimiento

### **Carpetas de Escenarios**

Cada escenario (`00-`, `01-`, `02-`) tiene:

#### **Archivos Terraform (raíz del escenario)**
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `terraform.tfvars`
- `README.md`

#### **Subcarpetas organizadas**
- `/app` o `/functions` - Código de la aplicación
- `/scripts` - Scripts específicos del escenario
- `/docs` - Documentación específica
- `/files` - Archivos adicionales (Postman, configs, etc)

## 🎯 Beneficios de esta Estructura

### **1. Claridad**
- Fácil encontrar archivos
- Separación lógica por tipo
- README en cada nivel

### **2. Seguridad**
- Archivos sensibles en `.gitignore`
- No hay credenciales sueltas
- Scripts de limpieza centralizados

### **3. Mantenibilidad**
- Scripts organizados por propósito
- Documentación junto al código
- Estructura escalable

### **4. Navegación**
```
¿Buscar qué?              → Ir a:
──────────────────────────────────────────
Desplegar POC             → DEPLOY_SECURE.ps1 (raíz)
Ver arquitectura          → docs/architecture.md
Guía de seguridad         → docs/SECURITY_IMPROVEMENTS.md
Limpiar todo              → scripts/DELETE_ALL.ps1
Info Escenario 1          → 01-app-service/README.md
Scripts Functions         → 02-azure-functions/scripts/
Código Flask              → 01-app-service/app/
```

## 🚫 Archivos Protegidos

El `.gitignore` protege:
- `*.tfstate` (en todos los escenarios)
- `outputs.json`
- `*.zip`
- `.terraform/`
- Credenciales

## ✅ Resultado

Antes tenías:
```
❌ 60+ archivos sueltos
❌ Scripts mezclados con docs
❌ Difícil navegación
❌ Confusión
```

Ahora tienes:
```
✅ Estructura clara
✅ Scripts organizados
✅ Docs centralizados
✅ Fácil navegación
```

## 📖 Próximos Pasos

1. ✅ Familiarízate con la estructura
2. ✅ Lee el README principal
3. ✅ Ejecuta `DEPLOY_SECURE.ps1` para desplegar
4. ✅ Consulta docs/ para guías específicas

---

**Todo está organizado y listo para usar.** 🎯
