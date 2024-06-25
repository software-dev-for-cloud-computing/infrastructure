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
  value = azurerm_cosmosdb_account.cosmos_account.primary_key
}

output "cosmosdb_database_name" {
  value = azurerm_cosmosdb_mongo_database.mongo_database.name
}
