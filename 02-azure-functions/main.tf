terraform {
  required_version = ">= 1.4.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Data source: Reference existing Resource Group from Scenario 0
data "azurerm_resource_group" "shared" {
  name = var.resource_group_name
}

# Data source: Reference existing Log Analytics Workspace from Scenario 0
data "azurerm_log_analytics_workspace" "shared" {
  name                = var.law_name
  resource_group_name = var.resource_group_name
}

# Storage Account for Functions
resource "azurerm_storage_account" "functions" {
  name                     = "stazmon${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.shared.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Enable for blob triggers
  blob_properties {
    versioning_enabled = false
  }

  tags = var.tags
}

# Storage Containers
resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.functions.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.functions.name
  container_access_type = "private"
}

# Storage Queues
resource "azurerm_storage_queue" "orders" {
  name                 = "queue-orders"
  storage_account_name = azurerm_storage_account.functions.name
}

resource "azurerm_storage_queue" "notifications" {
  name                 = "queue-notifications"
  storage_account_name = azurerm_storage_account.functions.name
}

# Application Insights for Functions
resource "azurerm_application_insights" "functions" {
  name                = "appi-azmon-functions-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared.name
  application_type    = "web"
  workspace_id        = data.azurerm_log_analytics_workspace.shared.id

  tags = var.tags
}

# App Service Plan for Functions (Standard S1)
resource "azurerm_service_plan" "functions" {
  name                = "asp-azmon-functions-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared.name
  os_type             = "Linux"
  sku_name            = "S1" # Standard plan

  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "main" {
  name                       = "func-azmon-demo-${random_string.suffix.result}"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.shared.name
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }

    # Enable Application Insights
    application_insights_key               = azurerm_application_insights.functions.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.functions.connection_string

    # CORS for testing
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.functions.connection_string
    "AzureWebJobsStorage"                   = azurerm_storage_account.functions.primary_connection_string
    
    # Storage connection strings for triggers
    "STORAGE_CONNECTION_STRING" = azurerm_storage_account.functions.primary_connection_string
    
    # Custom settings
    "ENVIRONMENT" = var.environment
  }

  tags = var.tags
}
