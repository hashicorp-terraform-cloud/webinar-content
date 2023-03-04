terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.18.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.42.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_organisation
}