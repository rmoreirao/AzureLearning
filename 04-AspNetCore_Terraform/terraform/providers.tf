terraform {
    backend "azurerm" {
        resource_group_name  = "rg-04-todoapp"
        storage_account_name = "stgtfstate04todoapp"
        container_name       = "tfstate"
        key                  = "actions.tfstate"
    }
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = ">=3.0.0"
        }
    }
}

provider "azurerm" {
    features {}
}