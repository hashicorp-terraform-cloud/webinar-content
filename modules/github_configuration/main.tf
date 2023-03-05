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
  description = "Cloned repository to use for HE Webinar"

  visibility = "public"

  template {
    owner      = "hashicorp-terraform-cloud"
    repository = "azure-infra"
  }
}

resource "github_repository" "compute" {
  name        = "he-webinar-compute"
  description = "Cloned repository to use for HE Webinar"

  visibility = "public"

  template {
    owner      = "hashicorp-terraform-cloud"
    repository = "azure-compute"
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
  branch     = github_branch.infra-dev.branch
}

resource "github_branch_default" "compute"{
  repository = github_repository.compute.name
  branch     = github_branch.compute-dev.branch
}