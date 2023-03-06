variable "tfc_organisation" {
  type        = string
  description = "The Organisation in TFC where these resources should be created"
}

variable "tfc_project" {
  type        = string
  description = "The project in TFC to create"
  default     = "HE Webinar"
}

variable "arm_subscription_id" {
  type = string
  description = "The ARM Subscription ID in which we'll be using Dynamic Credentials"
}

variable "arm_tenant_id" {
  type = string
  description = "The ARM Tenant ID in which we'll be using Dynamic Credentials"
}

variable "tfc_azure_run_client_id" {
  type = string
  description = "The Client ID of the Azure AD Application which we'll trust for Dynamic Credentials"
}

variable "sentinel_policy_repository" {
  type = string
  description = "The collection of Sentinel Policies for use with the demo"
}

variable "workspace_configuration_data" {
  type = map(object({
    target_resource_group = string
    teams_notification_url = string
    vcs_repo   = string
    vcs_branch  = string
  })) 
}

variable "kubernetes_sa_token" {
  type = string
  description = "Kubernetes Service Account token used when showing multicloud content"
}

variable "kubernetes_host" {
  type = string
  description = "Kubernetes Host used when showing multicloud content"
}