# Function App With Private HTTP Endpoint

Private endpoints for Azure Functions enable access to a Function App within a specified virtual network and restrict public internet access to it. Only clients which are connected to the virtual network are able to access the Function App. HTTP requests that originate from outside the virtual network address space are unable to reach the Function App.

## Features

This project framework provides the following features:

* A Function App with a basic .NET HTTP triggered Azure Function.
* An Azure Virtual Network, Private Endpoint, and related resources that restrict access to the Function App.
* An Azure Key Vault instance used to securely store all secret values.
* All components are deployable via Bicep or Terraform.

## Architecture

![Architecture diagram](./media/architectureDiagram.png)

## Getting Started

### Prerequisites

* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
* [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools)
* [.NET](https://docs.microsoft.com/dotnet/core/install/)
* [Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install) or [Terraform](https://www.terraform.io/downloads.html)

### Deploy the Infrastructure

The project can be deployed using _either_ Bicep _or_ Terraform.

#### Bicep

1. Create a new Azure resource group to deploy the bicep template to, passing in a location and name - `az group create --location <LOCATION> --name <RESOURCE_GROUP_NAME>`
2. The [azuredeploy.parameters.json](./IaC/bicep/azuredeploy.parameters.json) file contains the necessary variables to deploy the bicep project. Update the file with appropriate values. Descriptions for each parameter can be found in the [main.bicep](./IaC/bicep/main.bicep) file.
3. Optionally, verify what bicep will deploy, passing in the name of the resource group created earlier and the necessary parameters for the Bicep template - `az deployment group what-if --resource-group <RESOURCE_GROUP_NAME> --template-file .\main.bicep --parameters .\azuredeploy.parameters.json`
4. Deploy the template, passing in the name of the resource group created earlier and the necessary parameters for the bicep template - `az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file .\main.bicep --parameters .\azuredeploy.parameters.json`

#### Terraform

1. The [terraform.tfvars](./IaC/terraform/terraform.tfvars) file contains the necessary variables to apply the terraform configuration. Update the file with appropriate values. Descriptions for each variable can be found in the [variables.tf](./IaC/terraform/variables.tf) file.
2. Initialize terraform - `terraform init`
3. Optionally, verify what terraform will deploy - `terraform plan`
4. Deploy the configuration - `terraform apply`

### Deploy the Function App Code

Enabling Private Endpoints on a Function App also makes the Source Control Manager (SCM) site publicly inaccessible. The project is equipped with a script that utilizes zip deploy for Azure Functions for quick, local deployment purposes. The script deploys a separate Azure Storage account, zips up the Function App source code and pushes it to an Azure Storage container, and adds the `WEBSITE_RUN_FROM_PACKAGE` application setting to the Function App that points to the zip file. In an environment with dedicated pipelines, use self-hosted agents that are deployed into a subnet on the virtual network.

1. Navigate to the [./scripts](./scripts) directory.
2. Deploy the code to the function app provisioned by Bicep or Terraform - `./deploy-azure-functions-code.sh <SUBSCRIPTION_ID> <RESOURCE_GROUP_NAME> <FUNCTION_APP_NAME>`

### Test the Function App

1. Open Powershell on the local machine.
1. Make a GET request to the HTTP triggered Azure Function - `curl https://<FUNCTION_APP_NAME>.azurewebsites.net/api/HttpRequestProcessor`
1. Observe a DNS error.
1. Navigate to the [Azure Portal](https://portal.azure.com) and find the Virtual Machine that was provisioned.
1. Open the **Connect** blade and select **Bastion**.
1. Input the admin username and password used in the infrastructure deployment and **Connect**.
1. Open Powershell in the Bastion window.
1. Make a GET request to the HTTP triggered Azure Function - `curl https://<FUNCTION_APP_NAME>.azurewebsites.net/api/HttpRequestProcessor`
1. Observe a 200 response.

## Resources

* [Tutorial: Integrate Azure Functions with an Azure virtual network by using private endpoints](https://docs.microsoft.com/azure/azure-functions/functions-create-vnet)
* [Integrate your app with an Azure virtual network](https://docs.microsoft.com/azure/app-service/overview-vnet-integration)
* [Azure Functions networking options](https://docs.microsoft.com/azure/azure-functions/functions-networking-options)
* [Configure Azure Storage firewalls and virtual networks](https://docs.microsoft.com/azure/storage/common/storage-network-security)
* [Deployment technologies in Azure Functions](https://docs.microsoft.com/azure/azure-functions/functions-deployment-technologies)
* [Run a self-hosted agent in Docker](https://docs.microsoft.com/azure/devops/pipelines/agents/docker?view=azure-devops)
