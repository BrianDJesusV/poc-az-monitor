output "function_app_name" {
  description = "Name of the Function App"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_url" {
  description = "URL of the Function App"
  value       = "https://${azurerm_linux_function_app.main.default_hostname}"
}

output "function_app_id" {
  description = "Resource ID of the Function App"
  value       = azurerm_linux_function_app.main.id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.functions.name
}

output "storage_connection_string" {
  description = "Connection string for Storage Account"
  value       = azurerm_storage_account.functions.primary_connection_string
  sensitive   = true
}

output "app_insights_name" {
  description = "Name of Application Insights"
  value       = azurerm_application_insights.functions.name
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation Key for Application Insights"
  value       = azurerm_application_insights.functions.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Connection String for Application Insights"
  value       = azurerm_application_insights.functions.connection_string
  sensitive   = true
}

output "queue_orders_name" {
  description = "Name of the orders queue"
  value       = azurerm_storage_queue.orders.name
}

output "queue_notifications_name" {
  description = "Name of the notifications queue"
  value       = azurerm_storage_queue.notifications.name
}

output "container_uploads_name" {
  description = "Name of the uploads container"
  value       = azurerm_storage_container.uploads.name
}

output "container_processed_name" {
  description = "Name of the processed container"
  value       = azurerm_storage_container.processed.name
}
