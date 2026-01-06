########################
# APP SERVICE OUTPUTS
########################
output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.app.name
}

output "app_service_url" {
  description = "Default URL of the App Service"
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "app_service_id" {
  description = "ID of the App Service"
  value       = azurerm_linux_web_app.app.id
}

########################
# APP SERVICE PLAN OUTPUTS
########################
output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.app.name
}

output "app_service_plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.app.id
}

########################
# APPLICATION INSIGHTS OUTPUTS
########################
output "application_insights_name" {
  description = "Name of Application Insights"
  value       = azurerm_application_insights.app.name
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = azurerm_application_insights.app.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation Key for Application Insights (sensitive)"
  value       = azurerm_application_insights.app.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection String for Application Insights (sensitive)"
  value       = azurerm_application_insights.app.connection_string
  sensitive   = true
}

output "application_insights_app_id" {
  description = "Application ID for querying Application Insights"
  value       = azurerm_application_insights.app.app_id
}

########################
# UTILITY OUTPUTS
########################
output "random_suffix" {
  description = "Random suffix used for resource naming"
  value       = random_string.suffix.result
}
