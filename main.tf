terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.107.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "azurerm_resource_group" "main" {
  name     = "myResourceGroup-${random_pet.name.id}"
  location = "Germany West Central"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = "cosmos-db-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "mongo_database" {
  name                = "mydatabase"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
}

resource "azurerm_cosmosdb_mongo_collection" "mongo_collection" {
  name                = "mongoDbCollection"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_mongo_database.mongo_database.name
  shard_key           = "id"

  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_linux_web_app" "nodejs_app" {
  name                = "nodejs-app-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "ghcr.io/software-dev-for-cloud-computing/node-app:latest"
      docker_registry_url = "https://ghcr.io"
    }

    health_check_path = "/"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    PORT                                = "80"
    NODE_ENV                            = "production"
    MONGODB_URI                         = "mongodb://${var.prod_db_user}:${var.prod_db_password}@${azurerm_cosmosdb_account.cosmos_account.endpoint}:${var.prod_db_port}/${var.prod_db_name}?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${var.prod_db_user}@"
  }

  connection_string {
    name  = "MONGODB_URI"
    value = "mongodb://${var.prod_db_user}:${var.prod_db_password}@${azurerm_cosmosdb_account.cosmos_account.endpoint}:${var.prod_db_port}/${var.prod_db_name}?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${var.prod_db_user}@"
    type  = "Custom"
  }

  logs {
    application_logs {
      file_system_level = "Verbose"
    }
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
}
