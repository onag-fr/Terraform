# configure azure provider
provider "azurerm" {
  version = "=2.29.0"

  features {}
}

# configure azuread provider
provider "azuread" {
  version = "= 1.0.0"
}