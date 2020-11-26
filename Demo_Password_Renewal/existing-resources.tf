#####################################################
## Existing Azure resources
#####################################################
# Tenant
data "azurerm_client_config" "tf-tenant-id" {
}

# User to give rights on secret - Key Vault
data "azuread_user" "tf-user" {
  user_principal_name = "YOUR_AZURE_EMAIL_ACCOUNT"
}
