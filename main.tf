
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
  name                = "my-app-service-plan"  // Wähle einen passenden Namen
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"  // Oder einen anderen passenden SKU-Namen, der deine Anforderungen erfüllt
}

resource "azurerm_container_group" "main_container" {
  name                = "rag-ss-dev4coud-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "rag-ss-dev4coud-hdm-stuttgart-2024"

  /*depends_on = [
    azurerm_linux_web_app.mongodb_app,
  ]*/


  
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
      LLM_DEFAULT_TEMP           = "0.0"
      LLM_MIN_TEMP               = "0.0"
      LLM_MAX_TEMP               = "1.0"
      EMBEDDING_MODEL            = "text-embedding-3-small"
      LLM_DEFAULT_TOKEN_LIMIT    = "200"
      LLM_MIN_TOKEN_LIMIT        = "1"
      LLM_MAX_TOKEN_LIMIT        = "1024"
      MIN_LENGTH_CONTEXT_MESSAGE = "1"
      MAX_LENGTH_CONTEXT_MESSAGE = "10240"
      MAX_K_RESULTS              = "5"
    }
  }
  


  container {
    name   = "mongodb"
    image  = "ghcr.io/software-dev-for-cloud-computing/mongo:latest"
    cpu    = "2"
    memory = "4"

    ports {
      port     = 27017
      protocol = "TCP"
    }


    environment_variables = {
      #MONGO_INITDB_ROOT_USERNAME = "user"
      #MONGO_INITDB_ROOT_PASSWORD = "password"
      MONGO_INITDB_DATABASE      = "dev4cloud"
      MONGODB_PORT               = "27017"
      DISABLE_MONGO_AUTH         = "true" # Dies deaktiviert die Authentifizierung
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
      # MONGODB_URI      = "${azurerm_linux_web_app.mongodb_app.connection_string}"
      MONGODB_URI      = "mongodb://localhost:27017/dev4cloud" 
      NODE_ENV         = "production"
      PORT             = "3000"
      CORS_ORIGIN      = "*"
      AI_SERVICE_URL   = "http://rag-ss-dev4coud-hdm-stuttgart-2024.germanywestcentral.azurecontainer.io:8000/api/v1/qa"
      DOCUMENT_API_URL = "http://rag-ss-dev4coud-hdm-stuttgart-2024.germanywestcentral.azurecontainer.io:8000/api/v1/document"
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