variable "resource_group_name" {
  description = "Name of the existing resource group (from Scenario 0)"
  type        = string
  default     = "rg-azmon-poc-mexicocentral"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "mexicocentral"
}

variable "law_name" {
  description = "Name of the existing Log Analytics Workspace (from Scenario 0)"
  type        = string
  default     = "law-azmon-poc-mexicocentral"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "poc"
    project     = "azure-monitor"
    scenario    = "functions-serverless"
    managed-by  = "terraform"
  }
}
