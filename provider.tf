terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.15"
    }
    azuread = {
      source = "azuread"
      version = ">=0.10"
    }
    random = {
      source = "random"
      version = ">=2.2"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
    tls = {
      source = "tls"
      version = ">=2.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
