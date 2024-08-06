output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.cosmos_account.endpoint
}

output "cosmosdb_primary_key" {
  value     = azurerm_cosmosdb_account.cosmos_account.primary_key
  sensitive = true
}

output "cosmosdb_username" {
  value = azurerm_cosmosdb_account.cosmos_account.name
}

output "cosmosdb_password" {
  value     = azurerm_cosmosdb_account.cosmos_account.primary_key
  sensitive = true
}

output "cosmosdb_database_name" {
  value = azurerm_cosmosdb_mongo_database.mongo_database.name
}

output "ip_adress_qdrant" {
  value = azurerm_container_group.qdrant_container.ip_address
}

output "app_url" {
  value = azurerm_linux_web_app.react_frontend.default_hostname
}