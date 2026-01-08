# Diagnosticar error de deployment

Write-Host "=== DIAGNOSTICO DE DEPLOYMENT FALLIDO ===" -ForegroundColor Cyan
Write-Host ""

$funcApp = "func-azmon-demo-x7p3be"
$rgName = "rg-azmon-poc-mexicocentral"

Write-Host "Obteniendo logs del deployment..." -ForegroundColor Yellow
Write-Host ""

az webapp log deployment show -n $funcApp -g $rgName

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
