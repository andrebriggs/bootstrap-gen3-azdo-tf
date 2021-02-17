
variable "environment_name" {
  type        = string
  description = "The name of the environment"
}

variable "location" {
  type        = string
  description = "The region to deploy the environment to"
}

variable "subscription_id" {
  type        = string
  description = "The subscription id to create service principals in"
}

variable "product_name" {
  type        = string
  description = "Name of the overarching product"
  default = "abrig-gen3" // TODO: change to simple "gen3"
}

variable "acr_id" {
  type        = string
  description = "ACR ID to use for kubernetes deployments"
}

variable "backend_storage_account_name" {
  type        = string
  description = "the name of the storage account in which to provision a tf state container"
}
variable "azuredevops_project_id" {
  type        = string
  description = "the Id of the AzDO project"
}
