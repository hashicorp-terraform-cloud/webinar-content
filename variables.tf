variable "github_token" {
  type        = string
  description = "The GitHub PAT"
}

variable "github_organisation" {
  type        = string
  description = "The GitHub Organisation within which we'll be working"
}

variable "tfc_api_token" {
  type        = string
  description = "The TFC API Token"
}

variable "teams_notification_urls" {
  type        = map(any)
  description = "The collection of Teams notification URLs"
}

variable "tfc_organisation" {
  type        = string
  description = "The TFC Organisation"
}

variable "tfc_project" {
  type        = string
  default     = "HE Webinar"
  description = "The TFC Project"
}

variable "azure_federated_credentials" {
  type = map(object({
    tfc_workspace = string
    tfc_project   = string
  }))
}

variable "kubernetes_sa_token" {
  type        = string
  description = "Kubernetes Service Account token used when showing multicloud content"
  default     = ""
}

variable "kubernetes_host" {
  type        = string
  description = "Kubernetes Host used when showing multicloud content"
  default     = ""
}