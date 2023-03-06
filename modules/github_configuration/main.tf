terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.18.0"
    }
  }
}

resource "github_repository" "infra" {
  name        = "he-webinar-infra"
  description = "Azure Infrastructure Resources for Demonstrations"

  visibility = "public"

  template {
    owner      = "hashicorp-terraform-cloud"
    repository = "azure-infra"
  }
}

resource "github_repository" "compute" {
  name        = "he-webinar-compute"
  description = "Azure Compute Resources for Demonstrations"

  visibility = "public"

  template {
    owner      = "hashicorp-terraform-cloud"
    repository = "azure-compute"
  }
}

resource "github_repository" "sentinel" {
  name        = "he-webinar-sentinel"
  description = "Sentinel Policies for Azure Resources"

  visibility = "public"

  template {
    owner      = "hashicorp-terraform-cloud"
    repository = "azure-sentinel-policies"
  }
}

resource "github_repository" "multicloud" {
  name        = "he-webinar-multicloud"
  description = "Multicloud Resources Example with Several Providers"

  visibility = "public"

  template {
    owner      = "hashicorp-terraform-cloud"
    repository = "multicloud-infrastructure-stack"
  }
}

data "github_branch" "infra" {
  repository = github_repository.infra.name
  branch     = "main"
}

data "github_branch" "compute" {
  repository = github_repository.compute.name
  branch     = "main"
}

resource "github_branch" "infra-prod" {
  repository = github_repository.infra.name
  branch     = "prod"
  source_branch = data.github_branch.infra.branch
}

resource "github_branch" "infra-test" {
  repository    = github_repository.infra.name
  branch        = "test"
  source_branch = github_branch.infra-prod.branch
}

resource "github_branch" "infra-dev" {
  repository    = github_repository.infra.name
  branch        = "dev"
  source_branch = github_branch.infra-test.branch
}

resource "github_branch" "compute-prod" {
  repository = github_repository.compute.name
  branch     = "prod"
  source_branch = data.github_branch.compute.branch
}

resource "github_branch" "compute-test" {
  repository    = github_repository.compute.name
  branch        = "test"
  source_branch = github_branch.compute-prod.branch
}

resource "github_branch" "compute-dev" {
  repository    = github_repository.compute.name
  branch        = "dev"
  source_branch = github_branch.compute-test.branch
}

resource "github_branch_default" "infra"{
  repository = github_repository.infra.name
  branch     = github_branch.infra-prod.branch
}

resource "github_branch_default" "compute"{
  repository = github_repository.compute.name
  branch     = github_branch.compute-prod.branch
}