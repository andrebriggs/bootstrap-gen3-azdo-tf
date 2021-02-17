// This section creates a project
# resource "azuredevops_project" "project" {}
resource "azuredevops_project" "project" {
  name       = "BedrockRocks"
  # visibility         = "organization"
  version_control    = "Git"
  work_item_template = "Scrum"
  description = "[Managed with Terraform] Updated with Terraform Azure DevOps Provider!"
}

# resource "tls_private_key" "node-ssh-key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

// This section configures an Azure DevOps Variable Group
resource "azuredevops_variable_group" "vg" {
  project_id   = azuredevops_project.project.id
  name         = "rush-bootstrap-vg"
  description  = "[Managed with Terraform] A variable group with base variables needed for CI/CD"
  allow_access = true

#   variable {
#     name      = "SSH_KEY_PUB"
#     value     = tls_private_key.node-ssh-key.public_key_openssh
#     is_secret = false
#   }
#   variable {
#     name      = "SSH_KEY_PRIV"
#     value     = tls_private_key.node-ssh-key.private_key_pem
#     is_secret = false
#   }
  variable {
    name      = "ACR_NAME"
    value     = azurerm_container_registry.acr.name
    is_secret = false
  }
  variable {
    name      = "AZDO_ORG_URL"
    value     = var.AZDO_ORG_SERVICE_URL
  }
  variable {
    name      = "AZDO_PAT"
    value     = var.AZDO_PAT
    is_secret = true
  }
  variable {
    name      = "ARM_ACCESS_KEY"
    value     = azurerm_storage_account.ci.primary_access_key
    is_secret = true
  }
  variable {
    name  = "RESOURCE_GROUP"
    value = var.resource_group_name
  }
  variable {
    name  = "IMAGE_NAME"
    value = var.build_agent_image_name
  }
  variable {
    name  = "AZP_POOL"
    value = var.agent_pool_name
  }

  variable {
    name  = "SP_CLIENT_ID"
    value = var.SP_CLIENT_ID
    is_secret = false
  }
  variable {
    name  = "SP_CLIENT_PASS"
    value = var.SP_CLIENT_PASS
    is_secret = true
  }
  variable {
    name  = "SUBSCRIPTION_ID"
    value = var.SUBSCRIPTION_ID
    is_secret = false
  }
  variable {
    name  = "TENANT_ID"
    value = var.TENANT_ID
    is_secret = false
  }
}

resource "azuredevops_agent_pool" "pool" {
  name           = var.agent_pool_name
  auto_provision = false
}