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
    MONGODB_URI                         = azurerm_cosmosdb_account.cosmos_account.connection_strings[0]
  }
}


# Blob storage for FASTAPI

# Storage account
resource "azurerm_storage_account" "account" {
  name                     = "storehdmtest1"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Storage container
resource "azurerm_storage_container" "container" {
  name                  = "123hdmtest1"
  storage_account_name  = azurerm_storage_account.account.name
  container_access_type = "private"
}

# Blob
# source = "path/to/local/file.txt" - path to the file that you want to upload - https://registry.terraform.io/providers/tfproviders/azurerm/latest/docs/data-sources/storage_blob
resource "azurerm_storage_blob" "blob_fastAPI" {
  name                   = "FASTAPI1myfile.txt"
  storage_account_name   = azurerm_storage_account.account.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
}

# Qdrant Container APP

resource "azurerm_container_group" "qdrant_container" {
  name                = "qdrant-container-group12"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  
  container {
    name   = "qdrant"
    image  = "qdrant/qdrant:v1.10.1" # Hier kannst du die gewünschte Version angeben
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 6333
      protocol = "TCP"
    }

    environment_variables = {
      QDRANT__SERVICE__WEBSERVER__PORT = "6333"
    }
  }

  tags = {
    environment = "testing"
  }
}

# React Frontend Web App
resource "azurerm_linux_web_app" "react_frontend" {
  name                = "react-frontend-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "ghcr.io/software-dev-for-cloud-computing/react-app:latest"
      docker_registry_url = "https://ghcr.io"
    }

    health_check_path = "/"
  }
}
resource "azurerm_linux_web_app" "fastapi_app" {
  name                = "fastapi-app-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "ghcr.io/software-dev-for-cloud-computing/fastapi-app:latest"
      docker_registry_url = "https://ghcr.io"
    }

    health_check_path = "/"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    PORT                                = "8000"  # FastAPI standardmäßig auf Port 8000
  }
}
