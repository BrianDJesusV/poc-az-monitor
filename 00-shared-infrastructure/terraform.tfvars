# Variables para Escenario 0 - Shared Infrastructure
# Región: Mexico Central

location = "mexicocentral"
resource_group_name = "rg-azmon-poc-mexicocentral"
log_analytics_workspace_name = "law-azmon-poc-mexicocentral"

log_analytics_sku = "PerGB2018"
log_retention_days = 30

common_tags = {
  Environment = "POC"
  Project     = "AzureMonitor"
  Owner       = "CloudTeam"
  CostCenter  = "IT-Learning"
  ManagedBy   = "Terraform"
  Region      = "MexicoCentral"
}
