########################
# TERRAFORM CONFIGURATION
########################
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

########################
# PROVIDERS
########################
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

########################
# DATA SOURCES
########################
data "azurerm_client_config" "current" {}

########################
# RANDOM SUFFIX
########################
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

########################
# RESOURCE GROUP
########################
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.common_tags,
    {
      Scenario = "00-SharedInfrastructure"
    }
  )

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

########################
# LOG ANALYTICS WORKSPACE
########################
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # SKU Options: Free, PerGB2018, PerNode, Premium, Standalone, Unlimited
  sku               = var.log_analytics_sku
  retention_in_days = var.log_retention_days

  # Enable internet ingestion and query
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = merge(
    var.common_tags,
    {
      Scenario = "00-SharedInfrastructure"
      Purpose  = "CentralizedLogging"
    }
  )

  lifecycle {
    ignore_changes = [tags["CreatedDate"]]
  }
}

########################
# LOG ANALYTICS SOLUTIONS
########################

# Container Insights Solution (útil para Container Apps y AKS/ARO)
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.common_tags
}

# Security Center Solution
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  tags = var.common_tags
}

# Azure Activity Solution
resource "azurerm_log_analytics_solution" "azure_activity" {
  solution_name         = "AzureActivity"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureActivity"
  }

  tags = var.common_tags
}
