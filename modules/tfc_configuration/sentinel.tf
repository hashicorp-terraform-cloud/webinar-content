resource "tfe_policy_set" "azure-policies" {
  name          = "azure-sentinel-policies"
  description   = "A set of policies to apply to Azure resources"
  organization  = var.tfc_organisation
  kind          = "sentinel"
  workspace_ids = [ for workspace in tfe_workspace.he-webinar-workspace: workspace.id]

  vcs_repo {
    identifier         = var.sentinel_policy_repository
    oauth_token_id     = data.tfe_oauth_client.github-client.oauth_token_id
  }
}