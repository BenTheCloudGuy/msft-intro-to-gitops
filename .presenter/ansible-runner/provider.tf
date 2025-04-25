terraform {
  required_version = "~> 1.11.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg_bmmsidvgl"
    storage_account_name = "strartifactsbmmsidvgl"
    container_name       = "tfstate"
    key                  = "github-runner.tfstate"
    tenant_id            = "477bacc4-4ada-4431-940b-b91cf6cb3fd4"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = "f5cc0b2b-b4ba-437f-b770-863a80cf9da0"
}