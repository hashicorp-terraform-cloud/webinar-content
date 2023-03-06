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

resource "tfe_workspace_variable_set" "kubernetes_credentials" {
  for_each = local.multicloud_workspace_id
  variable_set_id = tfe_variable_set.kubernetes_credentials.id
  workspace_id    = each.value.id
}

resource "tfe_workspace_variable_set" "az_dynamic_credentials" {
  for_each = tfe_workspace.he-webinar-workspace

  variable_set_id = tfe_variable_set.az_dynamic_credentials.id
  workspace_id    = each.value.id
}

resource "tfe_variable" "rg_name" {
  for_each =  local.journey_workspace_ids

  key          = "rg_name"
  value        = lookup(var.workspace_configuration_data, each.key).target_resource_group
  category     = "terraform"
  workspace_id = each.value.id
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

resource "tfe_variable" "resource_name" {
  for_each =  local.multicloud_workspace_id

  key          = "resource_name"
  value        = ""
  category     = "terraform"
  workspace_id    = each.value.id
}

resource "tfe_workspace_variable_set" "multicloud_ssh_admin_user_public_key" {
  for_each =  local.multicloud_workspace_id

  variable_set_id = data.tfe_variable_set.ssh_admin_user_public_key.id

  workspace_id    = each.value.id
}
// end raining badness