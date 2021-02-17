# Azure Terraform Bootstrap for Gen3 Data Commons

This repository is intended to simplify setting up CI/CD required for Gen3 data commons infrastructure CI/CD on **Azure DevOps**. It aims to do the following:

* Deploy Azure dependencies required for automated CI/CD of Terraform deployments
* Configure variables in AzDO required for automated CI/CD of Terraform deployments
* Configure dependencies for each environment of the Gen3 data commons(`dev`, `integration`, `prod`, etc...)

> **Note**: This does not deploy instances of the Gen3 environment on Azure. It only sets up the dependencies needed to do that deployment.

## Requirements

* `terraform` version `v0.14.6` was used for this repo. A `.terraform.lock.hcl` [file](https://discuss.hashicorp.com/t/terraform-0-14-the-dependency-lock-file/15696) is included and depends on Terraform 0.14
* A shell environment, preferrably bash
* Necessary Azure subscription role assignments to create service principals and assign roles.

## What gets configured?

This template will configure resources for CI and create a base skeleton for Gen3 data commons environments:

| Description | Reason | Notes |
| ---         | ---    | ---   |
| AzDO variable groups | References to variables needed by CI pipelines | See details [here](TODO)
| Azure storage account| Needed for overall (CI and ENV specific) Terraform backend state | See details [here](TODO)
| Azure Container Registry | Creates ACR used for CI/CD pipelines (e.g. Custom build agent Docker image being built) | See details [here](TODO)
| ACR Push/Pull | Needed by the pipeline that builds the base image used by all of the infrastructure CI/CD in Azure DevOps | N/A |
| Environment Deploy | Needed by each environment to execute a deployment of resources into Azure.  | One generated for each environment (dev, test, pre-prod, etc). See details [here](TODO)
<!-- | AzDO variable groups for each environment | References to environment specific variables needed by environment specific Terraform pipelines | See details [here](TODO) -->

## First Time Instructions

<!-- 1. Initial deployment of this template
2. Enable the backend state for this deployment -->

<!-- ### 1. First Time Setup

A Terraform [Backend Configuration](https://www.terraform.io/docs/backends/index.html) that hosts the [Terraform State](https://www.terraform.io/docs/state/index.html) is included in this template. Also a state for each _environment_ deployment.

The first time you use this bootstrap you **_will not use backend state_** configured for the initial deployment of this template. These steps will take you through the following: -->

### 1. Disable backend state

For the **first** deployment, the contents of `backend.tf` will need to be commented out. Don't worry -- we'll uncomment this later.

```bash
# Comment out all lines in backend.tf
$ sed -i '' 's/^/#/' backend.tf
<file commented> 

# Verify file is commented out
$ cat backend.tf
```

### 2. Configure your environment

```bash
# Make a copy of the `.env.template` file named `.env`
$ cp .env.template .env

# Replace all occurences of "**REPLACE_ME**" in .env file using editor of choice (VS Code in this case)
$ code .env

# Once the .env has the correct values dot source the file
$ . .env

# Log into the Azure CLI
$ az login

# Set your default subscription - this will dictate where resources will be provisioned
$ az account set --subscription "<your subscription ID>"
```

### 3. Run the deployment

```bash
# Initialize the Terraform environment
$ terraform init

# See what the deployment will do. No changes will be applied, but you can review the changes that will be applied in the next step
$ terraform plan

# Deploy the changes. Choose 'yes' when prompted
$ terraform apply

```

> **Note**: At the end of a successful `terraform apply` please make a note of the outputs printed to console that match the outputs defined in `outputs.tf`

### 4. Enable backend state

Enabling backend state will store the deployment state in Azure. This will allow others to run the deployment without you needing to worry about the state configuration.

Start by uncommenting the contents of `backend.tf`

```bash
# Uncomment all lines in backend.tf
$ sed -i '' 's/^##*//' backend.tf
<file uncommented> 

# Verify file is uncommented
$ cat backend.tf
```

Set the requested environment variables to access the backend state

```bash
$ export ARM_ACCESS_KEY=$(terraform output backend-state-account-key)
$ export ARM_ACCOUNT_NAME=$(terraform output backend-state-account-name)
$ export ARM_CONTAINER_NAME=$(terraform output backend-state-bootstrap-container-name)

# Initialize the deployment with the backend
$ terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"
```

You should see something along the lines of the following, to which you want to answer `yes`:

```bash
Do you want to copy existing state to the new backend?
```

If things work, you will see the following message and the state file should end up in Azure:

```bash
Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```

🎉 **Congratulations!** 🎉 You have now bootstrapped the Azure and Azure DevOps infrastructure needed to deploy a Gen3 data common.

At this point you would commit your git changes via pull request. Be sure not to commit any secrets.

## Next Steps

At this point your need to hydrate your new `dev` environment with the actual resources that Gen3 needs for a `dev` environment. For instance:

* AKS with GitOps
* Azure PSQL
* Azure Storage
* Vnet
* etc

A forthcoming repository will describe the steps needed.

## Additional Scenarios for Bootstrap

### Add a new environment

You will need to open `azure.tf` to configure a new environment. Be default only a `dev` environment is configured. You can can uncomment and modify the `integration` and `prod` environments at the bottom of the file. For instance to add another enviroment named `pre-prod` add the following:

```hcl
module "pre-prod" {
  source                        = "./environment"
  acr_id                        = azurerm_container_registry.acr.id
  environment_name              = "pre-prod"
  location                      = var.location
  subscription_id               = data.azurerm_client_config.current.subscription_id
  azuredevops_project_id        = data.azuredevops_project.project.id
  backend_storage_account_name  = azurerm_storage_account.ci.name
}
```

Next, set your necessary environment variables, login to Azure and re-run Terraform commands

```bash
# Configure your .env file and dot source the file
$ . .env

# Log into the Azure CLI
$ az login

# Set your default subscription - this will dictate where resources will be provisioned
$ az account set --subscription "<your subscription ID>"

# Initialize with the remote backend, plan, and apply
$ terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"
$ terraform plan
$ terraform apply
```

Done!

### Rotate Service Principal Passwords

If the need arises to rotate the credentials for any of the generated service principals, the following command can be used to quickly rotate the credentials and also update all configuration in Azure DevOps:

```bash
# Configure your .env file and dot source the file
$ . .env

# Log into the Azure CLI
$ az login

# Set your default subscription - this will dictate where resources will be provisioned
$ az account set --subscription "<your subscription ID>"

# Initialize with the remote backend, plan, and apply
$ terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"

# `taint` all passwords - this triggers Terraform to regenerate these and update all dependent configuration
$ terraform state list | grep random_password | xargs -L 1 terraform taint
$ terraform plan
$ terraform apply
```

Done!

### Importing an existing Azure DevOps project to bootstrapping

If you're in a situation where the Azure DevOps projects already existing then by default Terraform can't manage it. There is a involved solution using the Terraform [import](https://learn.hashicorp.com/tutorials/terraform/state-import) command. 

> **Note**: This scenario would be expected to occur on a **first time run** of this repository and all your environment variables are set from your `.env` file

An example of usage with this repo:

In the `azdo.tf` comment out the resource block starting with

```hcl
resource "azuredevops_project" "project" {
  ...
}
```

Next add the following line to `azdo.tf` above the commented out section

```hcl
resource "azuredevops_project" "project" {}
```

Save the `azdo.tf` file and in a console window

```console
# Terraform will bring in your existing project to the Terraform state
$ terraform import azuredevops_project.project (My existing AZDO project name)
```

Remove the recently added `resource "azuredevops_project" "project" {}` line,

Uncomment the originally commented block

```hcl
resource "azuredevops_project" "project" {
  ...
}
```

Run `terraform plan` to make sure everything works.

## TODOs and Considerations

- [ ] Fix broken links in Notes column of `What gets configured?` table 
- [ ] Remove hardcoded references (search for string `TODO:`)
- [ ] Setup a service connection in AzDO using service principal fields. See [here](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm#automatic-azurerm-service-endpoint)
- [ ] Create a [Manifest](https://github.com/microsoft/bedrock/blob/master/gitops/PipelineThinking.md#gitops-in-bedrock) repo in AzDO as part of the bootstrapping
- [ ] Create a directory for environment (default is `dev`) in the configured gitops branch (default is `main` for AzDO repos) for the manifest repo. If we don't do this Flux won't work seamlessly out the box
- [ ] We still need bash scripts for build agent pipeline to create ACI since ACI needs a Docker image and we have to build the Docker image first.
