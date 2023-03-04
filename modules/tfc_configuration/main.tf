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
  tag_names      = [each.value.vcs_branch, each.value.target_resource_group]
  queue_all_runs = false

  vcs_repo {
    identifier     = each.value.vcs_repo
    branch         = each.value.vcs_branch
    oauth_token_id = data.tfe_oauth_client.github-client.oauth_token_id
  }
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