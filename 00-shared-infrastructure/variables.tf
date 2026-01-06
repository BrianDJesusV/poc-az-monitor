########################
# GENERAL VARIABLES
########################
variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eastus2"

  validation {
    condition     = can(regex("^[a-z]+[0-9]*$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group for shared infrastructure"
  type        = string
  default     = "rg-azmon-poc-eastus2"
}

########################
# LOG ANALYTICS VARIABLES
########################
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "law-azmon-poc-eastus2"
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "PerGB2018", "PerNode", "Premium", "Standalone"], var.log_analytics_sku)
    error_message = "SKU must be one of: Free, PerGB2018, PerNode, Premium, Standalone."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics Workspace"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Retention days must be between 30 and 730."
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
