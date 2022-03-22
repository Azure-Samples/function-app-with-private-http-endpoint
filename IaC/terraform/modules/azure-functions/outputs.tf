output "azure_function_tenant_id" {
  value     = azurerm_function_app.func.identity[0].tenant_id
  sensitive = true
}

output "azure_function_principal_id" {
  value     = azurerm_function_app.func.identity[0].principal_id
  sensitive = true
}