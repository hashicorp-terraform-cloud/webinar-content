output "infra-repository" {
  value = github_repository.infra.full_name
}

output "compute-repository" {
  value = github_repository.compute.full_name
}

output "multicloud-repository" {
  value = github_repository.multicloud.full_name
}

output "sentinel-repository" {
  value = github_repository.sentinel.full_name
}