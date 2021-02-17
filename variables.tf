variable "location" {
  type        = string
  description = "Location in which to provision Azure resources"
  default     = "westus2"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resource group the CI/CD resources will be created in"
  default = "abrig-gen3-ci-rg" # TODO: Change this
}

variable "azure_devops_project_name" {
  type        = string
  description = "Name of the Azure DevOps project that is hosting the bootstrap"
  default = "BedrockRocks"
}

variable "build_agent_image_name" {
  type        = string
  description = "Name of Docker images that will be used for a build agent"
  default = "rush-gen3-build-agent"
}

variable "agent_pool_name" {
  type        = string
  description = "Name of agent pool that is used to run build agents"
  default = "rush-gen3-pool"
}

# Below variables expected in as env vars with prefix TF_VAR_[ENV VAR]
# e.g. export TF_VAR_AZDO_ORG_SERVICE_URL="https://dev.azure.com/abrig"
variable AZDO_ORG_SERVICE_URL {}
variable AZDO_PAT {}
variable SP_CLIENT_ID {}
variable SP_CLIENT_PASS {}
variable SUBSCRIPTION_ID {}
variable TENANT_ID {}
