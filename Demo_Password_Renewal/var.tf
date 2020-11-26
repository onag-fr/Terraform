#####################################################
## RG
#####################################################
# Main RG
variable "var_main_rg_name" {
    default = "DEMO-ONAG-RG01"
}


#####################################################
## Location
#####################################################
variable "var_location" {
    default = "westeurope"
  }


#####################################################
## Tags
#####################################################
variable "var_tag_app_environment" {
    default = "Intégration"
}
variable "var_tag_app_project_name" {
    default = "RotateAdminPass"
}
variable "var_tag_app_owner" {
    default = "onag@grow-una.com"
}
variable "var_tag_app_auto_shutdown_schedule" {
    default = "TBD"
}
variable "var_tag_app_rg_creation_date" {
    default = "2020-11-20"
}


#####################################################
## Network
#####################################################
#VNET
variable "var_main_vnet_name" {
  default = "DEMO-ONAG-VN01"
}
variable "var_vnet_add_space" {
  default = ["10.0.0.0/24"]
}
# Front subnet
variable "var_front_subnet" {
    default = "DEMO-ONAG-FRONT-SN01"
}
variable "var_front_subnet_prefix" {
    default = ["10.0.0.0/28"]
}


#####################################################
## Service Principal Name
#####################################################
variable "var_sp_demo_onag" {
    default = "sp-demo-onag"
}

#####################################################
## Main KV
#####################################################
variable "var_main_kv_name" {
    default = "onag-kv"
}


#####################################################
## Demo VM
#####################################################
variable "var_demo_vm_name" {
  default = "winsrv001"
}
variable "var_demo_vm_size" {
  default = "Standard_B4ms"
}
variable "var_demo_vm_admin_name" {
  default = "onag-admin"
}


#####################################################
## Azure Automation Account
#####################################################
variable "var_automation_account_name" {
  default = "aa-demo-onag"
}
variable "var_automation_account_sku" {
  default = "Basic"
}
variable "var_password_rotation_runbook_name" {
  default = "Password-Rotation-Runbook"
}