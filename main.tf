provider "azurerm" {
  features {}
}

resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "azurerm_resource_group" "main" {
  name     = "myResourceGroupHdmHdm"
  location = "Germany West Central"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "react_app" {
  name                = "react-app-${random_pet.name.id}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    app_command_line = "npm start"
    always_on        = false
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_CUSTOM_IMAGE_NAME            = "docker.io/jasonraimondi/react-demo:latest"
  }
}

output "react_app_url" {
  value = azurerm_linux_web_app.react_app.default_hostname
}

/*resource "azurerm_app_service" "fastapi_app" {
  name                = "fastapi-app-service"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL          = "https://myregistry.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME     = var.registry_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.registry_password
  }
  site_config {
    app_command_line = "uvicorn main:app --host 0.0.0.0 --port 8000"
  }
}

resource "azurerm_app_service" "nodejs_app" {
  name                = "nodejs-app-service"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL          = "https://myregistry.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME     = var.registry_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.registry_password
  }
  site_config {
    app_command_line = "node index.js"
  }
}

resource "azurerm_storage_account" "blob_storage" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}*/
