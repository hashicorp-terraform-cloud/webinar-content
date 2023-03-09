# Terraform Webinar Content

This repository will create a baseline set of demonstratble infrastructure and supporting configurations in Terraform Cloud. 

The script shows a rough walkthrough involing:

**Infrastructure as Code Workflows**
* VCS Integration
* Decomposable Infrastructure
* Environment Promotion

**Terraform Providers**
* Private Module Registry Overview
* Private Module Registry Example

**Integrated Cost Estimation**
* Cost Estimation Overview
* Cost Estimation Example

**Risk Reduction through Policy As Code and Health Checks**
* Policy as Code Overview
* Working with Policies
* Infrastructure Health

## Usage

The Terraform configuration is currently designed to be bootstrapped from a local machine.

The repository relies on template GH repositories in order to make this process repeatable. These are part of the hashicorp-terraform-cloud organisation.

It also sets up Dynamic Credentials between TFC and Azure so being logged into the Azure CLI is critical.

```
github_token        = 
github_organisation = 
tfc_api_token       = 
teams_notification_urls = {
  dev        = 
  prod       = 
  test       = 
  multicloud = 
}

azure_federated_credentials = {
  "webinar-compute-dev" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-compute-dev"
  }
  "webinar-compute-test" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-compute-test"
  }
  "webinar-compute-prod" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-compute-prod"
  }
  "webinar-infra-dev" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-infra-dev"
  }
  "webinar-infra-test" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-infra-test"
  }
  "webinar-infra-prod" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-infra-prod"
  }
  "webinar-multicloud" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-multicloud"
  }
  "webinar-no-code" = {
    tfc_project   = "HE Webinar"
    tfc_workspace = "webinar-no-code"
  }
}

tfc_organisation = 

kubernetes_sa_token = 
kubernetes_host     = 
```
