terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}

locals {
  # Expanded to be parsed and turned into a file in AzDo pipeline  
  tf_vars_string = join("::",
     ["service_name='gen3'", 
     "env='${var.environment_name}'", 
     "resource_group='${azurerm_resource_group.rg.name}'", 
     "region='${var.location}'", 
     "psql_sku='GP_Gen5_2'", 
     "acr_id='${var.acr_id}", 
     "ip_whitelist=[]"])
}

// This section configures an Azure DevOps Variable Group per environment
resource "azuredevops_variable_group" "vg" {
  project_id   = var.azuredevops_project_id
  name         = format("%s-gen3-vg", upper(var.environment_name))
  description  = "A variable group with variables needed for environment specific CI/CD"
  allow_access = false

  variable {
    name      = format("%s_ARM_CLIENT_ID", upper(var.environment_name))
    value     = azuread_service_principal.sp.application_id
    is_secret = true
  }
  variable {
    name      = format("%s_ARM_CLIENT_SECRET", upper(var.environment_name))
    value     = random_password.sp.result
    is_secret = true
  }
  variable {
    name      = format("%s_TF_VARS", upper(var.environment_name))
    value     = local.tf_vars_string
    is_secret = false
  }
  variable {
    name      = format("%s_AZURE_STORAGE_ACCOUNT_NAME", upper(var.environment_name))
    value     = var.backend_storage_account_name
    is_secret = true
  }
  variable {
    name      = format("%s_AZURE_STORAGE_ACCOUNT_CONTAINER", upper(var.environment_name))
    value     = azurerm_storage_container.tfstate.name
    is_secret = true
  }
  variable {
    name      = format("%s_AZURE_STORAGE_ACCOUNT_SUBSCRIPTION", upper(var.environment_name))
    value     = var.subscription_id
    is_secret = true
  }

}