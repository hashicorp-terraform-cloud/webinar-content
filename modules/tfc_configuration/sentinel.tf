data "tfe_workspace_ids" "webinar" {
  names        = ["webinar-*"]
  organization = var.tfc_organisation
}

locals {
    filtered_workspace_ids = flatten([for id in data.tfe_workspace_ids.webinar.ids: id[*]])
}

resource "tfe_policy_set" "azure-policies" {
  name          = "azure-sentinel-policies"
  description   = "A set of policies to apply to Azure resources"
  organization  = var.tfc_organisation
  kind          = "sentinel"
  workspace_ids = local.filtered_workspace_ids

  vcs_repo {
    identifier         = var.sentinel_policy_repository
    oauth_token_id     = data.tfe_oauth_client.github-client.oauth_token_id
  }
}