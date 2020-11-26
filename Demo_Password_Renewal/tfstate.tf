# Configure tfstate on Azure
terraform {
  backend "azurerm" {
    resource_group_name = "TERRAFORM-PRD-RG01"
    storage_account_name = "terraformst001"
    container_name       = "tfstate"
    key                  = "demo-onag.tfstate"
  }
}