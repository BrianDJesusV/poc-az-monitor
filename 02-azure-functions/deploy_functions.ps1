# Deploy Functions Script (PowerShell)
# Deploys Python functions to Azure Function App

Write-Host "=== DEPLOYING AZURE FUNCTIONS ===" -ForegroundColor Cyan
Write-Host ""

# Get Function App name from Terraform
Write-Host "Getting Function App name from Terraform..." -ForegroundColor Yellow
$functionAppName = terraform output -raw function_app_name

if ([string]::IsNullOrEmpty($functionAppName)) {
    Write-Host "Error: Could not get Function App name from Terraform" -ForegroundColor Red
    exit 1
}

Write-Host "Function App: $functionAppName" -ForegroundColor Green
Write-Host ""

# Get resource group name
$resourceGroupName = "rg-azmon-poc-mexicocentral"

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Yellow
Push-Location functions

# Create zip file
$zipPath = Join-Path $PSScriptRoot "functions.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Compress files
Compress-Archive -Path * -DestinationPath $zipPath -Force

Pop-Location

Write-Host "Deployment package created: functions.zip" -ForegroundColor Green
Write-Host ""

# Deploy to Azure
Write-Host "Deploying to Azure..." -ForegroundColor Yellow
az functionapp deployment source config-zip `
    --resource-group $resourceGroupName `
    --name $functionAppName `
    --src functions.zip

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Deployment successful!" -ForegroundColor Green
    Write-Host ""
    
    $functionAppUrl = terraform output -raw function_app_url
    Write-Host "Function App URL: $functionAppUrl" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Test the functions:" -ForegroundColor Yellow
    Write-Host "  curl $functionAppUrl/api/HttpTrigger?name=Test" -ForegroundColor White
    Write-Host "  or" -ForegroundColor Gray
    Write-Host "  Invoke-WebRequest -Uri '$functionAppUrl/api/HttpTrigger?name=Test'" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "Deployment failed!" -ForegroundColor Red
    exit 1
}

# Cleanup
Write-Host ""
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item functions.zip -Force

Write-Host "Deployment complete!" -ForegroundColor Green
