# 🐧 DEPLOYMENT DESDE WSL - Guía Completa

**WSL es la mejor opción para ejecutar Terraform y Azure CLI**

---

## ✅ VENTAJAS DE USAR WSL

- ✅ **Más confiable** que PowerShell para Terraform
- ✅ **Mejor performance** con scripts bash
- ✅ **Menos problemas** con paths y caracteres especiales
- ✅ **Compatibilidad** total con Azure CLI
- ✅ **Familiar** si usas Linux/Mac

---

## 🚀 OPCIÓN 1: SCRIPT AUTOMATIZADO (Recomendado)

### **Paso 1: Abrir WSL**

```bash
# Desde PowerShell o CMD:
wsl

# O desde Windows Terminal: selecciona Ubuntu/WSL
```

### **Paso 2: Navegar al directorio**

```bash
cd /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions
```

### **Paso 3: Dar permisos de ejecución**

```bash
chmod +x deploy_wsl.sh
```

### **Paso 4: Ejecutar el script**

```bash
./deploy_wsl.sh
```

**Tiempo:** 10-15 minutos  
**Resultado:** Escenario 2 completo y funcionando

---

## 📋 OPCIÓN 2: COMANDOS MANUALES

Si prefieres ejecutar paso a paso:

### **Setup**

```bash
# 1. Abrir WSL
wsl

# 2. Navegar
cd /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions
```

### **Verificar Prerequisites**

```bash
# Terraform
terraform version

# Azure CLI
az version

# Azure login
az account show

# Escenario 0
cd ../00-shared-infrastructure
terraform output law_name
cd ../02-azure-functions
```

### **Terraform Deployment**

```bash
# Init
terraform init

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Guardar outputs
terraform output -json > outputs.json
```

### **Obtener Variables**

```bash
FUNC_APP=$(terraform output -raw function_app_name)
FUNC_URL=$(terraform output -raw function_app_url)
STORAGE=$(terraform output -raw storage_account_name)
APP_INSIGHTS=$(terraform output -raw app_insights_name)

echo "Function App: $FUNC_APP"
echo "URL: $FUNC_URL"
echo "Storage: $STORAGE"
echo "App Insights: $APP_INSIGHTS"
```

### **Deploy Functions**

```bash
# Crear ZIP
cd functions
zip -r ../functions.zip . -x "*.pyc" -x "__pycache__/*"
cd ..

# Deploy a Azure
az functionapp deployment source config-zip \
    --resource-group rg-azmon-poc-mexicocentral \
    --name $FUNC_APP \
    --src functions.zip

# Cleanup
rm functions.zip

# Wait
echo "Esperando 60 segundos..."
sleep 60
```

### **Test HttpTrigger**

```bash
# Test simple
curl "${FUNC_URL}/api/HttpTrigger?name=POC"

# Test con formato JSON
curl -s "${FUNC_URL}/api/HttpTrigger?name=POC" | jq '.'
```

### **Generate Test Data**

```bash
# Queue messages
for i in {1..5}; do
    ORDER_ID="ORDER-$((RANDOM % 9000 + 1000))"
    MSG="{\"orderId\":\"$ORDER_ID\",\"customer\":\"Test-$i\",\"amount\":$((i*10))}"
    az storage message put --queue-name queue-orders --account-name $STORAGE --content "$MSG" --output none
    echo "Message $i sent: $ORDER_ID"
done

# Blob files
for i in {1..3}; do
    echo "Test content $i" > /tmp/test-$i.txt
    az storage blob upload --account-name $STORAGE --container-name uploads --name test-$i.txt --file /tmp/test-$i.txt --output none
    echo "File $i uploaded"
    rm /tmp/test-$i.txt
done
```

### **Verify**

```bash
# Ver functions desplegadas
az functionapp function list --name $FUNC_APP --resource-group rg-azmon-poc-mexicocentral --output table

# Ver recursos
az resource list --resource-group rg-azmon-poc-mexicocentral --output table | grep -E "func-azmon|stazmon|appi-azmon-functions"
```

---

## 🛠️ INSTALAR PREREQUISITES EN WSL

Si no tienes las herramientas instaladas:

### **Terraform**

```bash
# Opción 1: Desde repo oficial
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Opción 2: Desde paquete directo
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

### **Azure CLI**

```bash
# Método recomendado
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verificar
az version

# Login
az login
```

### **Utilidades (opcional pero recomendado)**

```bash
# jq - para formato JSON
sudo apt install jq

# zip - para comprimir
sudo apt install zip
```

---

## ✅ VERIFICACIÓN PRE-DEPLOYMENT

```bash
# Checklist completo
echo "=== PRE-DEPLOYMENT CHECKLIST ==="
echo ""

# 1. WSL version
echo "WSL: $(wsl.exe --version 2>/dev/null || echo 'WSL 1')"

# 2. Terraform
if command -v terraform &> /dev/null; then
    echo "✓ Terraform: $(terraform version | head -n1)"
else
    echo "✗ Terraform no instalado"
fi

# 3. Azure CLI
if command -v az &> /dev/null; then
    echo "✓ Azure CLI: $(az version --query '\"azure-cli\"' -o tsv)"
else
    echo "✗ Azure CLI no instalado"
fi

# 4. Azure autenticado
if az account show &> /dev/null; then
    echo "✓ Azure: $(az account show --query name -o tsv)"
else
    echo "✗ No autenticado (ejecuta: az login)"
fi

# 5. Escenario 0
cd /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/00-shared-infrastructure
if LAW=$(terraform output -raw law_name 2>/dev/null); then
    echo "✓ Escenario 0: $LAW"
else
    echo "✗ Escenario 0 no desplegado"
fi

# 6. jq instalado (opcional)
if command -v jq &> /dev/null; then
    echo "✓ jq: instalado"
else
    echo "○ jq: no instalado (opcional: sudo apt install jq)"
fi

# 7. zip instalado
if command -v zip &> /dev/null; then
    echo "✓ zip: instalado"
else
    echo "✗ zip: no instalado (ejecuta: sudo apt install zip)"
fi

echo ""
```

---

## 🎯 RESULTADO ESPERADO

```
✓ Terraform init exitoso
✓ Terraform plan: 9 recursos a crear
✓ Terraform apply exitoso (5-8 min)
✓ Functions desplegadas (3-5 min)
✓ HttpTrigger responde 200 OK
✓ 5 mensajes en queue
✓ 3 archivos en blob
✓ Application Insights activo

Tiempo total: 10-15 minutos
Costo: $0.70/mes
```

---

## 🆘 TROUBLESHOOTING WSL

### **"terraform: command not found"**

```bash
# Instalar Terraform
sudo apt update
sudo apt install terraform

# O método manual (ver arriba)
```

### **"az: command not found"**

```bash
# Instalar Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### **"Please run 'az login'"**

```bash
# Autenticarse
az login

# Se abrirá navegador, completa el login
# Después verifica:
az account show
```

### **"Permission denied: ./deploy_wsl.sh"**

```bash
# Dar permisos
chmod +x deploy_wsl.sh

# Ejecutar
./deploy_wsl.sh
```

### **"No such file or directory" con paths Windows**

```bash
# Verificar path correcto en WSL
ls /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions

# Si no existe, ajustar path en script
```

### **"zip: command not found"**

```bash
# Instalar zip
sudo apt install zip
```

---

## 💡 TIPS WSL

### **Acceso rápido desde Windows Explorer**

1. Abre Windows Explorer
2. En la barra de direcciones escribe: `\\wsl$\Ubuntu\home\`
3. Bookmark para acceso rápido

### **Abrir VS Code desde WSL**

```bash
# Desde el directorio del proyecto
cd /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions

# Abrir VS Code
code .
```

### **Copiar outputs a clipboard de Windows**

```bash
# Instalar clip.exe
terraform output | clip.exe

# Ahora está en tu clipboard de Windows
```

### **Ver archivos de Windows en WSL**

```bash
# Windows C:\ está en /mnt/c/
# Windows D:\ está en /mnt/d/
# etc.

# Tu proyecto:
cd /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions
```

---

## 📊 COMPARATIVA: WSL vs PowerShell

| Aspecto | WSL | PowerShell |
|---------|-----|------------|
| **Terraform** | ✅ Nativo | ⚠️ Puede tener issues |
| **Azure CLI** | ✅ Perfecto | ✅ Funciona bien |
| **Scripts** | ✅ Bash (estándar) | ⚠️ PS (Windows only) |
| **Performance** | ✅ Rápido | ⚠️ Más lento |
| **Compatibilidad** | ✅ Linux/Mac/Win | ❌ Solo Windows |
| **Paths** | ✅ Unix style | ⚠️ Windows style |

**Recomendación:** Usa WSL si estás cómodo con Linux/bash

---

## 🚀 COMANDO FINAL

```bash
# Todo en uno (ejecuta desde WSL):

# 1. Abrir WSL
wsl

# 2. Navegar
cd /mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions

# 3. Permisos
chmod +x deploy_wsl.sh

# 4. Deploy
./deploy_wsl.sh
```

**Tiempo:** 10-15 minutos  
**Resultado:** Escenario 2 desplegado y funcionando

---

## 📁 ARCHIVOS DISPONIBLES

```
02-azure-functions/

Scripts para WSL:
├── deploy_wsl.sh          ⭐ SCRIPT PRINCIPAL (bash)
└── deploy_functions.sh    (deploy solo functions)

Scripts para PowerShell:
├── DEPLOY_SIMPLE.ps1
├── DEPLOY.ps1
└── DEPLOY_MANUAL.ps1

Infraestructura:
├── main.tf
├── variables.tf
└── outputs.tf

Functions:
└── functions/
    ├── HttpTrigger/
    ├── TimerTrigger/
    ├── QueueTrigger/
    └── BlobTrigger/
```

---

## ✅ CHECKLIST DEPLOYMENT

- [ ] WSL abierto
- [ ] Terraform instalado en WSL
- [ ] Azure CLI instalado en WSL
- [ ] Azure autenticado (`az login`)
- [ ] zip instalado (`sudo apt install zip`)
- [ ] Navegado al directorio
- [ ] Permisos dados (`chmod +x deploy_wsl.sh`)
- [ ] Script ejecutado (`./deploy_wsl.sh`)
- [ ] Deployment exitoso
- [ ] HttpTrigger testeado
- [ ] Application Insights verificado

---

**Creado:** 7 de enero de 2026  
**Recomendación:** ⭐ Usa WSL - Es más confiable  
**Comando:** `./deploy_wsl.sh`
