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

resource "tfe_variable_set" "kubernetes_credentials" {
  name         = "Kubernetes Credential for HE Webinar"
  description  = "Kubernetes Credentials for HE Webinar"
  organization = data.tfe_organization.tfc.name
}

resource "tfe_variable" "kube_host" {
  key             = "KUBE_HOST"
  value           = var.kubernetes_host
  category        = "env"
  sensitive = true
  variable_set_id = tfe_variable_set.kubernetes_credentials.id
}

resource "tfe_variable" "kube_token" {
  key             = "KUBE_TOKEN"
  value           = var.kubernetes_sa_token
  category        = "env"
  sensitive = true
  variable_set_id = tfe_variable_set.kubernetes_credentials.id
}

resource "tfe_variable_set" "az_dynamic_credentials" {
  name         = "Azure Credentials for HE Webinar"
  description  = "Azure Dynamic Credentials for HE Webinar"
  organization = data.tfe_organization.tfc.name
}

resource "tfe_variable" "arm_subscription_id" {
  key             = "ARM_SUBSCRIPTION_ID"
  value           = var.arm_subscription_id
  category        = "env"
  variable_set_id = tfe_variable_set.az_dynamic_credentials.id
}

resource "tfe_variable" "arm_tenant_id" {
  key             = "ARM_TENANT_ID"
  value           = var.arm_tenant_id
  category        = "env"
  variable_set_id = tfe_variable_set.az_dynamic_credentials.id
}

resource "tfe_variable" "tfc_azure_run_client_id" {
  key             = "TFC_AZURE_RUN_CLIENT_ID"
  value           = var.tfc_azure_run_client_id
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.az_dynamic_credentials.id
}

resource "tfe_variable" "tfc_azure_provider_auth" {
  key             = "TFC_AZURE_PROVIDER_AUTH"
  value           = true
  category        = "env"
  variable_set_id = tfe_variable_set.az_dynamic_credentials.id
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

resource "tfe_workspace_variable_set" "kubernetes_credentials" {
  variable_set_id = tfe_variable_set.kubernetes_credentials.id
  workspace_id    = local.multicloud_workspace_id
}

resource "tfe_workspace_variable_set" "az_dynamic_credentials" {
  for_each = tfe_workspace.he-webinar-workspace

  variable_set_id = tfe_variable_set.az_dynamic_credentials.id
  workspace_id    = each.value.id
}

resource "tfe_variable" "rg_name" {
  for_each =  tfe_workspace.he-webinar-workspace

  key          = "rg_name"
  value        = lookup(var.workspace_configuration_data, each.key).target_resource_group
  category     = "terraform"
  workspace_id = each.value.id
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

data "tfe_workspace_ids" "multicloud" {
  names        = ["webinar-multicloud"]
  organization = var.tfc_organisation

  depends_on = [
    tfe_workspace.he-webinar-workspace
  ]
}

locals {
      multicloud_workspace_id = flatten({
        for k,v in tfe_workspace.he-webinar-workspace : k => v if startswith(v.name, "webinar-multicloud")
     })
     compute_workspace_ids = {
        for k,v in tfe_workspace.he-webinar-workspace : k => v if startswith(v.name, "webinar-compute")
     }
}

resource "tfe_variable" "vm_owner" {
  for_each =  local.compute_workspace_ids

  key          = "vm_owner"
  value        = "Ben"
  category     = "terraform"
  workspace_id = each.value.id
}

resource "tfe_variable" "ssh_admin_user" {
  for_each =  local.compute_workspace_ids

  key          = "ssh_admin_user"
  value        = "rheluser"
  category     = "terraform"
  workspace_id = each.value.id
}

resource "tfe_variable" "vm_name_prefix" {
  for_each =  local.compute_workspace_ids

  key          = "vm_name_prefix"
  value        = "webinar"
  category     = "terraform"
  workspace_id = each.value.id
}

resource "tfe_variable" "vm_instance_count" {
  for_each =  local.compute_workspace_ids

  key          = "vm_instance_count"
  value        = "1"
  category     = "terraform"
  workspace_id = each.value.id
}

resource "tfe_workspace_variable_set" "ssh_admin_user_public_key" {
  for_each =  local.compute_workspace_ids

  variable_set_id = data.tfe_variable_set.ssh_admin_user_public_key.id
  workspace_id    = each.value.id
}

// this is bad and needs replacing with dynamic credentials and generated keys
data "tfe_variable_set" "aws_credentials" {
  name         = "AWS Credentials"
  organization = var.tfc_organisation
}

data "tfe_variable_set" "ssh_admin_user_public_key" {
  name         = "SSH Public Key"
  organization = var.tfc_organisation
}

resource "tfe_workspace_variable_set" "aws_credentials" {
  for_each =  local.multicloud_workspace_id

  variable_set_id = data.tfe_variable_set.aws_credentials.id
  
  workspace_id    = each.value.id
}

resource "tfe_variable" "multicloud_ssh_admin_user" {
  for_each =  local.multicloud_workspace_id

  key          = "ssh_admin_user"
  value        = "rheluser"
  category     = "terraform"
  workspace_id    = each.value.id
}

resource "tfe_workspace_variable_set" "multicloud_ssh_admin_user_public_key" {
  for_each =  local.multicloud_workspace_id

  variable_set_id = data.tfe_variable_set.ssh_admin_user_public_key.id
  
  workspace_id    = each.value.id
}
// end raining badness