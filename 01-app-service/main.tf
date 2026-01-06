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
# DATA SOURCES - SHARED INFRASTRUCTURE
########################
# Obtener el Resource Group compartido
data "azurerm_resource_group" "shared" {
  name = var.shared_resource_group_name
}

# Obtener el Log Analytics Workspace compartido
data "azurerm_log_analytics_workspace" "shared" {
  name                = var.shared_log_analytics_workspace_name
  resource_group_name = var.shared_resource_group_name
}

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
# APPLICATION INSIGHTS
########################
resource "azurerm_application_insights" "app" {
  name                = "appi-azmon-appservice-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.shared.location
  resource_group_name = data.azurerm_resource_group.shared.name
  
  # Tipo de aplicación
  application_type = "web"
  
  # Conectar a Log Analytics Workspace compartido
  workspace_id = data.azurerm_log_analytics_workspace.shared.id
  
  # Retención local (además de LA Workspace)
  retention_in_days = 30
  
  # Habilitar muestreo adaptativo
  sampling_percentage = 100

  tags = merge(
    var.common_tags,
    {
      Scenario = "01-AppService"
      Purpose  = "APM-Monitoring"
    }
  )
}

########################
# APP SERVICE PLAN
########################
resource "azurerm_service_plan" "app" {
  name                = "asp-azmon-poc-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.shared.location
  resource_group_name = data.azurerm_resource_group.shared.name
  
  # Linux plan
  os_type = "Linux"
  
  # SKU - B1 es suficiente para POC
  sku_name = var.app_service_plan_sku
  
  tags = merge(
    var.common_tags,
    {
      Scenario = "01-AppService"
    }
  )
}

########################
# APP SERVICE (WEB APP)
########################
resource "azurerm_linux_web_app" "app" {
  name                = "app-azmon-demo-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.shared.location
  resource_group_name = data.azurerm_resource_group.shared.name
  service_plan_id     = azurerm_service_plan.app.id

  # HTTPS obligatorio
  https_only = true
  
  # Configuración de la aplicación
  site_config {
    # Stack de runtime - Python 3.11
    application_stack {
      python_version = "3.11"
    }
    
    # Always On - Deshabilitado para tier F1 (Free)
    # Nota: Si cambias a B1 o superior, puedes habilitar always_on = true
    always_on = false
    
    # Health check
    health_check_path = "/health"
    
    # CORS para testing
    cors {
      allowed_origins = ["*"]
    }
  }
  
  # Variables de entorno de la aplicación
  app_settings = {
    # Application Insights
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    
    # Python settings
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"              = "true"
    
    # Custom variables para la app de demo
    "DEMO_MODE"     = "true"
    "LOG_LEVEL"     = "INFO"
    "APP_VERSION"   = "1.0.0"
  }
  
  # Logs de la aplicación
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    
    application_logs {
      file_system_level = "Information"
    }
    
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }
  
  tags = merge(
    var.common_tags,
    {
      Scenario = "01-AppService"
      Purpose  = "Demo-WebApp"
    }
  )
}

########################
# DIAGNOSTIC SETTINGS - APP SERVICE
########################
resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "diag-app-to-law"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  # Logs de HTTP
  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  
  # Logs de la consola
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  
  # Logs de la aplicación
  enabled_log {
    category = "AppServiceAppLogs"
  }
  
  # Logs de auditoría
  enabled_log {
    category = "AppServiceAuditLogs"
  }
  
  # Logs de plataforma
  enabled_log {
    category = "AppServicePlatformLogs"
  }
  
  # Métricas
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

########################
# DIAGNOSTIC SETTINGS - APP SERVICE PLAN
########################
resource "azurerm_monitor_diagnostic_setting" "plan" {
  name                       = "diag-plan-to-law"
  target_resource_id         = azurerm_service_plan.app.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id
  
  # Métricas del plan
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
