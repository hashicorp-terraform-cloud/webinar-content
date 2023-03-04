output "infra-repository" {
  value = github_repository.infra.full_name
}

output "compute-repository" {
  value = github_repository.compute.full_name
}
