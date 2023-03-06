data "tfe_organization" "tfc" {
  name = var.tfc_organisation
}

resource "tfe_project" "webinar" {
  organization = data.tfe_organization.tfc.name
  name         = "${var.tfc_project}"
}

data "tfe_oauth_client" "github-client" {
  organization     = data.tfe_organization.tfc.name
  service_provider = "github"
}

resource "tfe_workspace" "he-webinar-workspace" {
  for_each = var.workspace_configuration_data

  name           = each.key
  organization   = data.tfe_organization.tfc.name
  project_id     = tfe_project.webinar.id
  tag_names      = [each.value.vcs_branch]
  queue_all_runs = false
  assessments_enabled = true

  vcs_repo {
    identifier     = each.value.vcs_repo
    branch         = each.value.vcs_branch
    oauth_token_id = data.tfe_oauth_client.github-client.oauth_token_id
  }
}

resource "tfe_notification_configuration" "teams" {
  for_each =  tfe_workspace.he-webinar-workspace

  name             = "Microsoft Teams Notification for ${each.key}"
  enabled          = true
  destination_type = "microsoft-teams"
  triggers         = ["run:created", "run:planning", "run:needs_attention", "run:applying", "run:completed", "run:errored", "assessment:drifted", "assessment:failed" ]
  workspace_id     = each.value.id
  url              = lookup(var.workspace_configuration_data, each.key).teams_notification_url
}

locals {
      multicloud_workspace_id = {
        for k,v in tfe_workspace.he-webinar-workspace : k => v if startswith(v.name, "webinar-multicloud")
     }
     compute_workspace_ids = {
        for k,v in tfe_workspace.he-webinar-workspace : k => v if startswith(v.name, "webinar-compute")
     }
     infra_workspace_ids = {
        for k,v in tfe_workspace.he-webinar-workspace : k => v if startswith(v.name, "webinar-infra")
     }
     journey_workspace_ids = merge(local.compute_workspace_ids,local.infra_workspace_ids)
}

