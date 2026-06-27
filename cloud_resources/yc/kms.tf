resource "yandex_kms_symmetric_key" "k8s_kms_key" {
  name              = var.cluster_name
  folder_id         = var.folder_id
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}
