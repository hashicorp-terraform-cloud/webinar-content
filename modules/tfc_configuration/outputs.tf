output "compute-workspaces" {
    value = local.compute_workspace_ids
}

output "infra-workspaces" {
    value = local.infra_workspace_ids
}

output "multicloud-workspaces" {
    value = local.multicloud_workspace_id
}

output "combined-workspaces" {
  value = local.journey_workspace_ids
}