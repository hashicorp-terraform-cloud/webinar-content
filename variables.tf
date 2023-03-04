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