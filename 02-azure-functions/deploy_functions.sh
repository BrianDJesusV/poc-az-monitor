#!/bin/bash
# Deploy Functions Script
# Deploys Python functions to Azure Function App

set -e

echo "=== DEPLOYING AZURE FUNCTIONS ==="
echo ""

# Get Function App name from Terraform
FUNCTION_APP_NAME=$(terraform output -raw function_app_name)

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo "Error: Could not get Function App name from Terraform"
    exit 1
fi

echo "Function App: $FUNCTION_APP_NAME"
echo ""

# Navigate to functions directory
cd functions

# Create deployment package
echo "Creating deployment package..."
zip -r ../functions.zip . -x "*.pyc" -x "__pycache__/*" -x "local.settings.json"

cd ..

echo "Deployment package created: functions.zip"
echo ""

# Deploy to Azure
echo "Deploying to Azure..."
az functionapp deployment source config-zip \
    --resource-group $(terraform output -json | jq -r '.resource_group_name.value') \
    --name $FUNCTION_APP_NAME \
    --src functions.zip

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "Function App URL: $(terraform output -raw function_app_url)"
    echo ""
    echo "Test the functions:"
    echo "  curl $(terraform output -raw function_app_url)/api/HttpTrigger?name=Test"
else
    echo ""
    echo "❌ Deployment failed!"
    exit 1
fi

# Cleanup
rm functions.zip

echo ""
echo "Deployment complete!"
