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

/*resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = "cosmos-db-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  free_tier_enabled   = true

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

  index {
    keys = ["timestamp"]
  }

  index {
    keys = ["conversationId", "timestamp"]
  }

  index {
    keys = ["userId"]
  }

  index {
    keys = ["created_at"]
  }

  index {
  keys = ["conversationId", "created_at"]
}
}
*/


resource "azurerm_container_group" "main_container" {
  name                = "rag-ss-dev4coud-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Public"

  dns_name_label = "rag-ss-dev4coud-hdm-stuttgart-2024"

  container {
    name   = "qdrant"
    image  = "ghcr.io/software-dev-for-cloud-computing/qdrant:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 6333
      protocol = "TCP"
    }

    environment_variables = {
      QDRANT_PORT                = "6333"
      VECTOR_STORE_COLLECTION    = "CoStudy"
      VECTOR_STORE_DIMENSION     = "1536"
      LLM_MODEL                  = "gpt-4o-mini"
      LLM_DEFAULT_TEMP           = 0.0
      LLM_MIN_TEMP               = 0.0
      LLM_MAX_TEMP               = 1.0
      EMBEDDING_MODEL            = "text-embedding-3-small"
      LLM_DEFAULT_TOKEN_LIMIT    = 200
      LLM_MIN_TOKEN_LIMIT        = 1
      LLM_MAX_TOKEN_LIMIT        = 1024
      MIN_LENGTH_CONTEXT_MESSAGE = 1
      MAX_LENGTH_CONTEXT_MESSAGE = 10240
      MAX_K_RESULTS              = 5
    }
  }

  container {
    name   = "mongodb"
    image  = "ghcr.io/software-dev-for-cloud-computing/mongo:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 27017
      protocol = "TCP"
    }

    environment_variables = {
      MONGO_INITDB_ROOT_USERNAME = var.mongodb_username
      MONGO_INITDB_ROOT_PASSWORD = var.mongodb_password
      MONGO_INITDB_DATABASE      = var.mongodb_database
    }
  }


  container {
    name   = "nodejs"
    image  = "ghcr.io/software-dev-for-cloud-computing/node-app:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      #MONGODB_URI      = azurerm_cosmosdb_account.cosmos_account.connection_strings[0]
      MONGODB_URI      = "mongodb://${var.mongodb_username}:${var.mongodb_password}@mongodb:27017/${var.mongodb_database}"
      NODE_ENV         = "production"
      PORT             = "3000"
      CORS_ORIGIN      = "*"
      AI_SERVICE_URL   = "http://rag-ss-dev4coud-hdm-stuttgart-2024.germanywestcentral.azurecontainer.io:8000/api/v1/qa"
      DOCUMENT_API_URL = "http://rag-ss-dev4coud-hdm-stuttgart-2024.germanywestcentral.azurecontainer.io:8000/api/v1/document"
    }
  }

  container {
    name   = "react"
    image  = "ghcr.io/software-dev-for-cloud-computing/react-app:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      REACT_APP_API_URL = "http://rag-ss-dev4coud-hdm-stuttgart-2024.germanywestcentral.azurecontainer.io:3000"
    }

  }

  container {
    name   = "fastapi"
    image  = "ghcr.io/software-dev-for-cloud-computing/fastapi-app:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8000
      protocol = "TCP"
    }

    environment_variables = {
      UVICORN_PORT = "8000"
    }
  }

  exposed_port {
    port     = 80
    protocol = "TCP"
  }

  exposed_port {
    port     = 3000
    protocol = "TCP"
  }

  exposed_port {
    port     = 6333
    protocol = "TCP"
  }

  exposed_port {
    port     = 8000
    protocol = "TCP"
  }

  exposed_port {
    port     = 27017
    protocol = "TCP"
  }


}
