output "cluster_id" {
  value = yandex_kubernetes_cluster.k8s_cluster.id
}

output "cluster_name" {
  value = yandex_kubernetes_cluster.k8s_cluster.name
}

output "cluster_status" {
  value = yandex_kubernetes_cluster.k8s_cluster.status
}

output "cluster_external_v4_endpoint" {
  value = yandex_kubernetes_cluster.k8s_cluster.master[0].external_v4_endpoint
}

output "cluster_internal_v4_endpoint" {
  value = yandex_kubernetes_cluster.k8s_cluster.master[0].internal_v4_endpoint
}

output "network_id" {
  value = yandex_vpc_network.k8s_network.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.k8s_subnet.id
}

output "service_account_id" {
  value = yandex_iam_service_account.k8s_sa.id
}

output "node_group_id" {
  value = yandex_kubernetes_node_group.k8s_node_group.id
}
