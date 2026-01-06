########################
# SHARED INFRASTRUCTURE VARIABLES
########################
variable "shared_resource_group_name" {
  description = "Name of the shared resource group (from Scenario 0)"
  type        = string
  default     = "rg-azmon-poc-eastus2"
}

variable "shared_log_analytics_workspace_name" {
  description = "Name of the shared Log Analytics Workspace (from Scenario 0)"
  type        = string
  default     = "law-azmon-poc-eastus2"
}

########################
# APP SERVICE PLAN VARIABLES
########################
variable "app_service_plan_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "F1"  # Free tier - sin costo, ideal para POC
  
  validation {
    condition     = contains(["F1", "B1", "B2", "B3", "S1", "S2", "S3", "P1v2", "P2v2", "P3v2"], var.app_service_plan_sku)
    error_message = "SKU must be a valid App Service Plan SKU."
  }
}

########################
# TAGGING VARIABLES
########################
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "POC"
    Project     = "AzureMonitor"
    Owner       = "CloudTeam"
    CostCenter  = "IT-Learning"
    ManagedBy   = "Terraform"
  }
}
