module "azure-dynamic-credentials-bootstrap" {
  source = "git@github.com:hashicorp-terraform-cloud/azure-dynamic-credentials-bootstrap.git"

  tfc_organisation      = var.tfc_organisation
  federated_credentials = var.azure_federated_credentials
}

module "github_configuration" {
  source = "./modules/github_configuration"
}

module "tfc_configuration" {
  source = "./modules/tfc_configuration"

  tfc_organisation           = var.tfc_organisation
  tfc_project                = var.tfc_project
  arm_subscription_id        = module.azure-dynamic-credentials-bootstrap.raw_arm_subscription_id
  arm_tenant_id              = module.azure-dynamic-credentials-bootstrap.raw_arm_tenant_id
  tfc_azure_run_client_id    = module.azure-dynamic-credentials-bootstrap.raw_tfc_azure_run_client_id
  sentinel_policy_repository = module.github_configuration.sentinel-repository
  kubernetes_host            = var.kubernetes_host
  kubernetes_sa_token        = var.kubernetes_sa_token
  workspace_configuration_data = {
    "webinar-infra-dev" = {
      target_resource_group  = "webinar-infra-dev"
      teams_notification_url = var.teams_notification_urls.dev
      vcs_branch             = "dev"
      vcs_repo               = module.github_configuration.infra-repository
    }
    "webinar-infra-test" = {
      target_resource_group  = "webinar-infra-test"
      teams_notification_url = var.teams_notification_urls.test
      vcs_branch             = "test"
      vcs_repo               = module.github_configuration.infra-repository
    }
    "webinar-infra-prod" = {
      target_resource_group  = "webinar-infra-prod"
      teams_notification_url = var.teams_notification_urls.prod
      vcs_branch             = "prod"
      vcs_repo               = module.github_configuration.infra-repository
    }
    "webinar-compute-dev" = {
      target_resource_group  = "webinar-infra-dev"
      teams_notification_url = var.teams_notification_urls.dev
      vcs_branch             = "dev"
      vcs_repo               = module.github_configuration.compute-repository
    }
    "webinar-compute-test" = {
      target_resource_group  = "webinar-infra-test"
      teams_notification_url = var.teams_notification_urls.test
      vcs_branch             = "test"
      vcs_repo               = module.github_configuration.compute-repository
    }
    "webinar-compute-prod" = {
      target_resource_group  = "webinar-infra-prod"
      teams_notification_url = var.teams_notification_urls.prod
      vcs_branch             = "prod"
      vcs_repo               = module.github_configuration.compute-repository
    }
    "webinar-multicloud" = {
      target_resource_group  = "webinar-multicloud"
      teams_notification_url = var.teams_notification_urls.multicloud
      vcs_branch             = "main"
      vcs_repo               = module.github_configuration.multicloud-repository
    }
  }

  depends_on = [
    module.github_configuration
  ]
}