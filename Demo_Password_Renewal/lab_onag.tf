
#####################################################
## RG
#####################################################
# Main RG
resource "azurerm_resource_group" "tf-main-rg" {
  name     = var.var_main_rg_name
  location = var.var_location

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }
}


#####################################################
## Network
#####################################################
# VNET
resource "azurerm_virtual_network" "tf-main-vnet" {
  name                = var.var_main_vnet_name
  location            = var.var_location
  resource_group_name = azurerm_resource_group.tf-main-rg.name
  address_space       = var.var_vnet_add_space

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }
}

# Front subnet
resource "azurerm_subnet" "tf-front-subnet" {
  name                 = var.var_front_subnet
  resource_group_name  = azurerm_resource_group.tf-main-rg.name
  virtual_network_name = azurerm_virtual_network.tf-main-vnet.name
  address_prefixes     = var.var_front_subnet_prefix

}


#####################################################
## Service Principal Name
#####################################################
# Create random secret for sp-demo-onag
resource "random_password" "tf-sp-demo-onag-secret" {
  length  = 40
  special = true
}
# Store the secret in a secret KV
resource "azurerm_key_vault_secret" "tf-main-kv-sp-demo-onag-secret" {
  name         = "${var.var_sp_demo_onag}-secret"
  value        = random_password.tf-sp-demo-onag-secret.result
  key_vault_id = azurerm_key_vault.tf-main-kv.id
}
# Create sp-demo-onag
resource "azuread_application" "tf-sp-app-demo-onag" {
  name = var.var_sp_demo_onag
}
resource "azuread_service_principal" "tf-sp-demo-onag" {
  application_id = azuread_application.tf-sp-app-demo-onag.application_id
}
resource "azuread_service_principal_password" "tf-sp-demo-onag-secret" {
  service_principal_id = azuread_service_principal.tf-sp-demo-onag.id
  description          = "${var.var_sp_demo_onag}-secret"
  value                = azurerm_key_vault_secret.tf-main-kv-sp-demo-onag-secret.value
  end_date             = "2099-01-01T01:02:03Z"
}


#####################################################
## Role Assignment
#####################################################
# Virtual Machine Contributor for sp-demo-on on winsrv001 VM
resource "azurerm_role_assignment" "tf-sp-demo-onag-vm-contributor" {
  scope                = azurerm_windows_virtual_machine.tf-demo-vm.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azuread_service_principal.tf-sp-demo-onag.object_id
}
# Key Vault Contributor for sp-demo-on on onag-kv KV
resource "azurerm_role_assignment" "tf-sp-demo-onag-kv-contributor" {
  scope                = azurerm_key_vault.tf-main-kv.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = azuread_service_principal.tf-sp-demo-onag.object_id
}


#####################################################
## Main KV
#####################################################
resource "azurerm_key_vault" "tf-main-kv" {
  name                        = var.var_main_kv_name
  location                    = var.var_location
  resource_group_name         = azurerm_resource_group.tf-main-rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.tf-tenant-id.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false
  enabled_for_deployment      = true

  sku_name = "standard"

  # Give access policy for you 
  access_policy {
    tenant_id          = data.azurerm_client_config.tf-tenant-id.tenant_id
    object_id          = data.azuread_user.tf-user.id
    secret_permissions = ["backup", "delete", "get", "list", "recover", "restore", "set"]
  }

  # Give access policy for sp-demo-onag
  access_policy {
    tenant_id          = data.azurerm_client_config.tf-tenant-id.tenant_id
    object_id          = azuread_service_principal.tf-sp-demo-onag.object_id
    secret_permissions = ["backup", "delete", "get", "list", "recover", "restore", "set"]
  }

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }
}
# Create secret to store the onag-admin password
resource "azurerm_key_vault_secret" "tf-onag-admin-pwd" {
  name         = "${var.var_demo_vm_name}-admin-pwd"
  value        = "P@ssw0rd123*"
  key_vault_id = azurerm_key_vault.tf-main-kv.id
}


#####################################################
## Demo VM
#####################################################
# Public IP
resource "azurerm_public_ip" "tf-demo-vm-pip" {
  name                = "${var.var_demo_vm_name}-pip"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.tf-main-rg.name
  allocation_method   = "Static"

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }
}

# NIC
resource "azurerm_network_interface" "tf-demo-vm-nic" {
  name                = "${var.var_demo_vm_name}-nic"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.tf-main-rg.name
  ip_configuration {
    name                          = "${var.var_demo_vm_name}-config"
    subnet_id                     = azurerm_subnet.tf-front-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-demo-vm-pip.id
  }

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }
}

# NSG
resource "azurerm_network_security_group" "tf-demo-vm-nsg" {
  name                = "${var.var_demo_vm_name}-nsg"
  location            = var.var_location
  resource_group_name = azurerm_resource_group.tf-main-rg.name

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }
}

# NSG Rules
resource "azurerm_network_security_rule" "tf-demo-vm-nic-rules1" {
  name                        = "Allow-In-RDP-All"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-main-rg.name
  network_security_group_name = azurerm_network_security_group.tf-demo-vm-nsg.name
}

# NIC - NSG association
resource "azurerm_network_interface_security_group_association" "tf-demo-vm-nic-nsg-link" {
  network_interface_id      = azurerm_network_interface.tf-demo-vm-nic.id
  network_security_group_id = azurerm_network_security_group.tf-demo-vm-nsg.id
}

# VM
resource "azurerm_windows_virtual_machine" "tf-demo-vm" {
  name                     = var.var_demo_vm_name
  location                 = var.var_location
  resource_group_name      = azurerm_resource_group.tf-main-rg.name
  network_interface_ids    = [azurerm_network_interface.tf-demo-vm-nic.id]
  size                     = var.var_demo_vm_size
  admin_username           = var.var_demo_vm_admin_name
  admin_password           = "P@ssw0rd123*" #Password will be renewed by a AA runbook
  provision_vm_agent       = true
  timezone                 = "Romance Standard Time"
  enable_automatic_updates = true


  os_disk {
    name                 = "${var.var_demo_vm_name}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date
  }

}


#####################################################
## Azure Automation Account for sitemaps 
#####################################################
# Automation
resource "azurerm_automation_account" "tf-automation-account" {
  name                = var.var_automation_account_name
  resource_group_name = azurerm_resource_group.tf-main-rg.name
  location            = var.var_location

  sku_name = var.var_automation_account_sku

  tags = {
    app_environment            = var.var_tag_app_environment
    app_project_name           = var.var_tag_app_project_name
    app_owner                  = var.var_tag_app_owner
    app_auto_shutdown_schedule = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date       = var.var_tag_app_rg_creation_date

  }
}
#Import Az modules
resource "azurerm_automation_module" "tf-automation-account-azaccount-module" {
  name                    = "Az.Accounts"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/2.1.2"
  }
}
resource "azurerm_automation_module" "tf-automation-account-azcompute-module" {
  name                    = "Az.Compute"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name

  depends_on = [
    azurerm_automation_module.tf-automation-account-azaccount-module
  ]

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Compute/4.6.0"
  }
}
resource "azurerm_automation_module" "tf-automation-account-azkeyvault-module" {
  name                    = "Az.KeyVault"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name

  depends_on = [
    azurerm_automation_module.tf-automation-account-azcompute-module
  ]

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.KeyVault/3.0.0"
  }
}

## Define variables
#SubscriptionId
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-subscriptionid-var" {
  name                    = "SubscriptionId"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = data.azurerm_client_config.tf-tenant-id.subscription_id
}
#TenantId
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-tenantid-var" {
  name                    = "TenantId"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = data.azurerm_client_config.tf-tenant-id.tenant_id
}
#ClientId
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-clientid-var" {
  name                    = "ClientId"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = azuread_service_principal.tf-sp-demo-onag.application_id
}
#SecretId
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-secretid-var" {
  name                    = "SecretId"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = azurerm_key_vault_secret.tf-main-kv-sp-demo-onag-secret.value
  encrypted               = true
}
#KVName
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-main-kv-var" {
  name                    = "KVName"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = azurerm_key_vault.tf-main-kv.name
}
#KVSecretName
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-kvsecret-var" {
  name                    = "KVSecretName"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = azurerm_key_vault_secret.tf-onag-admin-pwd.name
}
#Location
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-location-var" {
  name                    = "Location"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = var.var_location
}
#RGName
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-rgname-var" {
  name                    = "RGName"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = azurerm_resource_group.tf-main-rg.name
}
#UserLogin
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-userlogin-var" {
  name                    = "UserLogin"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = var.var_demo_vm_admin_name
}
#VMName
resource "azurerm_automation_variable_string" "tf-automation-rotate-password-vmname-var" {
  name                    = "VMName"
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  value                   = var.var_demo_vm_name
}

/*
#Add Powershell script for Password Rotation
data "local_file" "tf-password-rotation-ps1-script" {
  filename = "${path.module}/PasswordRotation.ps1"
}
#Runbook for Password Rotation
resource "azurerm_automation_runbook" "tf-password-rotation-runbook" {
  name                    = var.var_password_rotation_runbook_name
  resource_group_name     = azurerm_resource_group.tf-main-rg.name
  location                = var.var_location
  automation_account_name = azurerm_automation_account.tf-automation-account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Runbook to rotate local passwords"
  runbook_type            = "PowerShell"

  content = data.local_file.tf-password-rotation-ps1-script.content

  tags = {
    app_environment             = var.var_tag_app_environment
    app_project_name            = var.var_tag_app_project_name
    app_owner                   = var.var_tag_app_owner
    app_auto_shutdown_schedule  = var.var_tag_app_auto_shutdown_schedule
    app_rg_creation_date        = var.var_tag_app_rg_creation_date
  }
}
*/