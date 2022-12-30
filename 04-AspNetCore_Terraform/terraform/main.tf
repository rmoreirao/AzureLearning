# To run this
## terraform init
## terraform plan -out main.tfplan
## terraform apply main.tfplan

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_cosmosdb_account" "comsmosdb_account" {
  name                      = var.cosmosdb_account_name
  location                  = azurerm_resource_group.resource_group.location
  resource_group_name       = azurerm_resource_group.resource_group.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  geo_location {
    location          = azurerm_resource_group.resource_group.location
    failover_priority = 0
    zone_redundant = false
  }
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  depends_on = [
    azurerm_resource_group.resource_group
  ]
}

resource "azurerm_cosmosdb_sql_database" "comsmosdb_database" {
  name                = "Tasks"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.comsmosdb_account.name
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = var.webapp_name
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  service_plan_id       = azurerm_app_service_plan.app_service_plan.id
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
  }
  app_settings = {
    "ConnectionString": azurerm_cosmosdb_account.comsmosdb_account.connection_strings[0]
  }
}