output "instrumentation_key" {
  sensitive = true
  value     = azurerm_application_insights.appi.instrumentation_key
}
