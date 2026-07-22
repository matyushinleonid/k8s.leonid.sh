resource "yandex_container_registry" "applications" {
  folder_id = var.folder_id
  name      = var.base_name
}

resource "yandex_container_repository" "applications" {
  name = "${yandex_container_registry.applications.id}/k8s.leonid.sh"
}

resource "yandex_container_repository_iam_binding" "github_ci_pusher" {
  repository_id = yandex_container_repository.applications.id
  role          = "container-registry.images.pusher"

  members = [
    "serviceAccount:${yandex_iam_service_account.github_ci.id}",
  ]
}
