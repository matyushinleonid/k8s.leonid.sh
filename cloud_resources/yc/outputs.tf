output "cluster_id" {
  value = module.kube.cluster_id
}

output "cluster_name" {
  value = module.kube.cluster_name
}

output "cluster_status" {
  value = module.kube.cluster_status
}

output "cluster_external_v4_endpoint" {
  value = module.kube.external_v4_endpoint
}

output "cluster_internal_v4_endpoint" {
  value = module.kube.internal_v4_endpoint
}
