########################################################################################################################
#Tag app_owner policy on main RG
resource "azurerm_policy_definition" "tf-main-rg-policy-def-app-owner" {
  name         = "Def:Tag app_owner ${var.var_main_rg_name}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Def:Tag app_owner ${var.var_main_rg_name}"
  description  = "This policy governs the application of RG tags on its own resources app_owner"

  policy_rule = <<POLICY_RULE
    {
    "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      "then": {
        "effect": "append",
        "details": [
          {
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "value": "[parameters('tagValue')]"
          }
        ]
      }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "tagName": {
        "type": "String",
        "metadata": {
          "description": "Name of the tag"
        }
      },
      "tagValue": {
        "type": "String",
        "metadata": {
          "description": "Value of the tag"
        }
      }
  }
PARAMETERS
}

resource "azurerm_policy_assignment" "tf-main-rg-policy-ass-app-owner" {
  name                 = "Ass:Tag app_owner ${var.var_main_rg_name}"
  scope                = azurerm_resource_group.tf-main-rg.id
  policy_definition_id = azurerm_policy_definition.tf-main-rg-policy-def-app-owner.id
  display_name         = "Ass:Tag app_owner ${var.var_main_rg_name}"

  parameters = <<PARAMETERS
{
  "tagName": {
    "value": "app_owner"
  },
  "tagValue": {
    "value": "${var.var_tag_app_owner}"
  }

}
PARAMETERS
}

########################################################################################################################
#Tag app_environment policy on main RG
resource "azurerm_policy_definition" "tf-main-rg-policy-def-app-environment" {
  name         = "Def:Tag app_environment ${var.var_main_rg_name}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Def:Tag app_environment ${var.var_main_rg_name}"
  description  = "This policy governs the application of RG tags on its own resources app_environment"

  policy_rule = <<POLICY_RULE
    {
    "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      "then": {
        "effect": "append",
        "details": [
          {
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "value": "[parameters('tagValue')]"
          }
        ]
      }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "tagName": {
        "type": "String",
        "metadata": {
          "description": "Name of the tag"
        }
      },
      "tagValue": {
        "type": "String",
        "metadata": {
          "description": "Value of the tag"
        }
      }
  }
PARAMETERS
}

resource "azurerm_policy_assignment" "tf-main-rg-policy-ass-app-environment" {
  name                 = "Ass:Tag app_environment ${var.var_main_rg_name}"
  scope                = azurerm_resource_group.tf-main-rg.id
  policy_definition_id = azurerm_policy_definition.tf-main-rg-policy-def-app-environment.id
  display_name         = "Ass:Tag app_environment ${var.var_main_rg_name}"

  parameters = <<PARAMETERS
{
  "tagName": {
    "value": "app_environment"
  },
  "tagValue": {
    "value": "${var.var_tag_app_environment}"
  }

}
PARAMETERS
}

########################################################################################################################
#Tag project_name policy on main RG
resource "azurerm_policy_definition" "tf-main-rg-policy-def-app-project-name" {
  name         = "Def:Tag app_project_name ${var.var_main_rg_name}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Def:Tag app_project_name ${var.var_main_rg_name}"
  description  = "This policy governs the application of RG tags on its own resources app_project_name"

  policy_rule = <<POLICY_RULE
    {
    "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      "then": {
        "effect": "append",
        "details": [
          {
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "value": "[parameters('tagValue')]"
          }
        ]
      }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "tagName": {
        "type": "String",
        "metadata": {
          "description": "Name of the tag"
        }
      },
      "tagValue": {
        "type": "String",
        "metadata": {
          "description": "Value of the tag"
        }
      }
  }
PARAMETERS
}

resource "azurerm_policy_assignment" "tf-main-rg-policy-ass-app-project-name" {
  name                 = "Ass:Tag app_project_name ${var.var_main_rg_name}"
  scope                = azurerm_resource_group.tf-main-rg.id
  policy_definition_id = azurerm_policy_definition.tf-main-rg-policy-def-app-project-name.id
  display_name         = "Ass:Tag app_project_name ${var.var_main_rg_name}"

  parameters = <<PARAMETERS
{
  "tagName": {
    "value": "app_project_name"
  },
  "tagValue": {
    "value": "${var.var_tag_app_project_name}"
  }

}
PARAMETERS
}

########################################################################################################################
#Tag auto_shutdown_schedule policy on main RG
resource "azurerm_policy_definition" "tf-main-rg-policy-def-app-auto-shutdown-schedule" {
  name         = "Def:Tag app_auto_shutdown_schedule ${var.var_main_rg_name}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Def:Tag app_auto_shutdown_schedule ${var.var_main_rg_name}"
  description  = "This policy governs the application of RG tags on its own resources app_auto_shutdown_schedule"

  policy_rule = <<POLICY_RULE
    {
    "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      "then": {
        "effect": "append",
        "details": [
          {
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "value": "[parameters('tagValue')]"
          }
        ]
      }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "tagName": {
        "type": "String",
        "metadata": {
          "description": "Name of the tag"
        }
      },
      "tagValue": {
        "type": "String",
        "metadata": {
          "description": "Value of the tag"
        }
      }
  }
PARAMETERS
}

resource "azurerm_policy_assignment" "tf-main-rg-policy-ass-app-auto-shutdown-schedule" {
  name                 = "Ass:Tag app_auto_shutdown_schedule ${var.var_main_rg_name}"
  scope                = azurerm_resource_group.tf-main-rg.id
  policy_definition_id = azurerm_policy_definition.tf-main-rg-policy-def-app-auto-shutdown-schedule.id
  display_name         = "Ass:Tag app_auto_shutdown_schedule ${var.var_main_rg_name}"

  parameters = <<PARAMETERS
{
  "tagName": {
    "value": "app_auto_shutdown_schedule"
  },
  "tagValue": {
    "value": "${var.var_tag_app_auto_shutdown_schedule}"
  }

}
PARAMETERS
}

########################################################################################################################
#Tag creation_date policy on main RG
resource "azurerm_policy_definition" "tf-main-rg-policy-def-app-rg-creation-date" {
  name         = "Def:Tag app_rg_creation_date ${var.var_main_rg_name}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Def:Tag app_rg_creation_date ${var.var_main_rg_name}"
  description  = "This policy governs the application of RG tags on its own resources app_rg_creation_date"

  policy_rule = <<POLICY_RULE
    {
    "if": {
        "field": "[concat('tags[', parameters('tagName'), ']')]",
        "exists": "false"
      },
      "then": {
        "effect": "append",
        "details": [
          {
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "value": "[parameters('tagValue')]"
          }
        ]
      }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "tagName": {
        "type": "String",
        "metadata": {
          "description": "Name of the tag"
        }
      },
      "tagValue": {
        "type": "String",
        "metadata": {
          "description": "Value of the tag"
        }
      }
  }
PARAMETERS
}

resource "azurerm_policy_assignment" "tf-main-rg-policy-ass-app-creation-date" {
  name                 = "Ass:Tag app_rg_creation_date ${var.var_main_rg_name}"
  scope                = azurerm_resource_group.tf-main-rg.id
  policy_definition_id = azurerm_policy_definition.tf-main-rg-policy-def-app-rg-creation-date.id
  display_name         = "Ass:Tag app_rg_creation_date ${var.var_main_rg_name}"

  parameters = <<PARAMETERS
{
  "tagName": {
    "value": "app_rg_creation_date"
  },
  "tagValue": {
    "value": "${var.var_tag_app_rg_creation_date}"
  }

}
PARAMETERS
}
