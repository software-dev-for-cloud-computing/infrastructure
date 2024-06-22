output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.cosmos_account.endpoint
}

output "cosmosdb_primary_key" {
  value     = azurerm_cosmosdb_account.cosmos_account.primary_key
  sensitive = true
}

output "cosmosdb_username" {
  value = var.prod_db_user
}

output "cosmosdb_password" {
  value = var.prod_db_password
}

output "cosmosdb_database_name" {
  value = azurerm_cosmosdb_mongo_database.mongo_database.name
}
