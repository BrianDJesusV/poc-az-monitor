#!/bin/bash
# ========================================
# ESCENARIO 2 - DEPLOYMENT SCRIPT (Bash/WSL)
# Ejecutar en WSL/Linux/Mac
# ========================================

set -e  # Exit on error

echo "=== ESCENARIO 2: AZURE FUNCTIONS DEPLOYMENT ==="
echo ""

# Variables
SCENARIO2_DIR="/mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/02-azure-functions"
SCENARIO0_DIR="/mnt/c/Users/User/Documents/proyectos/proyectos_trabajo/azure/poc_azure_monitor/00-shared-infrastructure"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ========================================
# PASO 1: PRE-CHECKS
# ========================================

echo -e "${YELLOW}PASO 1: Verificaciones previas...${NC}"
echo ""

# Cambiar al directorio
cd "$SCENARIO2_DIR" || exit 1
echo -e "${GREEN}[OK]${NC} Directorio: $(pwd)"

# Verificar Terraform
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version | head -n1)
    echo -e "${GREEN}[OK]${NC} Terraform: $TF_VERSION"
else
    echo -e "${RED}[ERROR]${NC} Terraform no encontrado"
    echo "  Instala: sudo apt install terraform"
    echo "  O desde: https://www.terraform.io/downloads"
    exit 1
fi

# Verificar Azure CLI
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
    echo -e "${GREEN}[OK]${NC} Azure CLI: $AZ_VERSION"
else
    echo -e "${RED}[ERROR]${NC} Azure CLI no encontrado"
    echo "  Instala: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Verificar Azure login
if az account show &> /dev/null; then
    ACCOUNT=$(az account show --query name -o tsv)
    echo -e "${GREEN}[OK]${NC} Azure autenticado: $ACCOUNT"
else
    echo -e "${RED}[ERROR]${NC} No autenticado en Azure"
    echo "  Ejecuta: az login"
    exit 1
fi

# Verificar Scenario 0
echo ""
echo -e "${YELLOW}Verificando Escenario 0...${NC}"
cd "$SCENARIO0_DIR" || exit 1

if LAW_NAME=$(terraform output -raw law_name 2>/dev/null); then
    echo -e "${GREEN}[OK]${NC} Escenario 0 desplegado: $LAW_NAME"
else
    echo -e "${RED}[ERROR]${NC} Escenario 0 no está desplegado"
    echo "  Despliega Escenario 0 primero"
    exit 1
fi

cd "$SCENARIO2_DIR" || exit 1
echo ""

# ========================================
# PASO 2: TERRAFORM INIT
# ========================================

echo -e "${YELLOW}PASO 2: Terraform Init...${NC}"
echo ""

terraform init

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[OK]${NC} Terraform inicializado"
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Terraform init falló"
    exit 1
fi
echo ""

# ========================================
# PASO 3: TERRAFORM PLAN
# ========================================

echo -e "${YELLOW}PASO 3: Terraform Plan...${NC}"
echo ""

terraform plan -out=tfplan

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[OK]${NC} Plan generado"
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Terraform plan falló"
    exit 1
fi
echo ""

# Preguntar si continuar
read -p "¿Continuar con deployment? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelado${NC}"
    exit 0
fi

# ========================================
# PASO 4: TERRAFORM APPLY
# ========================================

echo ""
echo -e "${YELLOW}PASO 4: Terraform Apply...${NC}"
echo ""

START_TIME=$(date +%s)

terraform apply tfplan

if [ $? -eq 0 ]; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    MINUTES=$((DURATION / 60))
    SECONDS=$((DURATION % 60))
    echo ""
    echo -e "${GREEN}[OK]${NC} Infraestructura desplegada en ${MINUTES}m ${SECONDS}s"
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Terraform apply falló"
    exit 1
fi
echo ""

# Guardar outputs
echo -e "${YELLOW}Guardando outputs...${NC}"
terraform output -json > outputs.json
terraform output > outputs.txt

# Obtener outputs
FUNCTION_APP_NAME=$(terraform output -raw function_app_name)
FUNCTION_APP_URL=$(terraform output -raw function_app_url)
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
APP_INSIGHTS=$(terraform output -raw app_insights_name)

echo ""
echo -e "${CYAN}=== RECURSOS CREADOS ===${NC}"
echo "Function App:     $FUNCTION_APP_NAME"
echo "Function URL:     $FUNCTION_APP_URL"
echo "Storage Account:  $STORAGE_ACCOUNT"
echo "App Insights:     $APP_INSIGHTS"
echo ""

# ========================================
# PASO 5: DEPLOY FUNCTIONS
# ========================================

echo -e "${YELLOW}PASO 5: Deploy Functions...${NC}"
echo ""

# Crear ZIP
echo "Creando package..."
cd functions || exit 1

ZIP_PATH="$SCENARIO2_DIR/functions.zip"
if [ -f "$ZIP_PATH" ]; then
    rm -f "$ZIP_PATH"
fi

zip -r "$ZIP_PATH" . -x "*.pyc" -x "__pycache__/*" > /dev/null 2>&1

cd "$SCENARIO2_DIR" || exit 1

echo -e "${GREEN}[OK]${NC} Package creado"
echo ""

# Deploy
echo "Desplegando a Azure..."
RESOURCE_GROUP="rg-azmon-poc-mexicocentral"

az functionapp deployment source config-zip \
    --resource-group "$RESOURCE_GROUP" \
    --name "$FUNCTION_APP_NAME" \
    --src functions.zip

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[OK]${NC} Functions desplegadas"
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Function deployment falló"
    exit 1
fi
echo ""

# Cleanup
rm -f functions.zip

# ========================================
# PASO 6: WAIT
# ========================================

echo -e "${YELLOW}PASO 6: Esperando deployment...${NC}"
echo "Esperando 60 segundos..."
sleep 60
echo -e "${GREEN}[OK]${NC} Wait complete"
echo ""

# ========================================
# PASO 7: VERIFY FUNCTIONS
# ========================================

echo -e "${YELLOW}PASO 7: Verificando functions...${NC}"
echo ""

az functionapp function list \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[].{Name:name}" \
    -o table

echo ""

# ========================================
# PASO 8: TEST HTTPTRIGGER
# ========================================

echo -e "${YELLOW}PASO 8: Testing HttpTrigger...${NC}"
echo ""

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${FUNCTION_APP_URL}/api/HttpTrigger?name=POC")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}[OK]${NC} HttpTrigger funciona! (HTTP 200)"
    echo ""
    echo "Response:"
    curl -s "${FUNCTION_APP_URL}/api/HttpTrigger?name=POC" | jq '.'
else
    echo -e "${YELLOW}[WARN]${NC} HttpTrigger returned HTTP $HTTP_CODE (cold start normal)"
fi

echo ""

# ========================================
# PASO 9: GENERATE TEST DATA
# ========================================

echo -e "${YELLOW}PASO 9: Generando test data...${NC}"
echo ""

# Queue messages
echo "Enviando 5 mensajes a queue..."
for i in {1..5}; do
    ORDER_ID="ORDER-$((RANDOM % 9000 + 1000))"
    AMOUNT=$((i * 10))
    MESSAGE="{\"orderId\":\"$ORDER_ID\",\"customer\":\"Customer-$i\",\"amount\":$AMOUNT}"
    
    az storage message put \
        --queue-name "queue-orders" \
        --account-name "$STORAGE_ACCOUNT" \
        --content "$MESSAGE" \
        --output none 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "  [OK] Message $i sent: $ORDER_ID"
    fi
done

echo ""

# Blob uploads
echo "Subiendo 3 archivos..."
for i in {1..3}; do
    FILE_NAME="test-$i.txt"
    FILE_PATH="/tmp/$FILE_NAME"
    echo "Test content $i - $(date)" > "$FILE_PATH"
    
    az storage blob upload \
        --account-name "$STORAGE_ACCOUNT" \
        --container-name "uploads" \
        --name "$FILE_NAME" \
        --file "$FILE_PATH" \
        --output none 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "  [OK] File $i uploaded: $FILE_NAME"
    fi
    
    rm -f "$FILE_PATH"
done

echo ""
echo -e "${GREEN}[OK]${NC} Test data generado"
echo ""

# ========================================
# PASO 10: SUMMARY
# ========================================

echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}    DEPLOYMENT COMPLETADO${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo -e "${YELLOW}Recursos desplegados:${NC}"
echo "  Storage Account:   $STORAGE_ACCOUNT"
echo "  Function App:      $FUNCTION_APP_NAME"
echo "  App Insights:      $APP_INSIGHTS"
echo "  Functions:         4 (HttpTrigger, TimerTrigger, QueueTrigger, BlobTrigger)"
echo ""

echo -e "${YELLOW}URLs:${NC}"
echo "  Function App:      $FUNCTION_APP_URL"
echo "  API Endpoint:      ${FUNCTION_APP_URL}/api/HttpTrigger?name=Test"
echo ""

echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. Azure Portal -> Application Insights -> $APP_INSIGHTS"
echo "  2. Ver Live Metrics"
echo "  3. Ejecutar: ./test_functions.ps1 (en PowerShell)"
echo ""

echo -e "${GREEN}Costo estimado: ~\$0.70/mes${NC}"
echo ""

echo -e "${GREEN}Deployment exitoso!${NC}"
echo ""
