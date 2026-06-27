variable "cloud_id" {
  type    = string
  default = null
}

variable "folder_id" {
  type    = string
  default = "b1g3o4ahe2b4o5od724t"
}

variable "zone" {
  type    = string
  default = "ru-central1-d"
}

variable "service_account_key_file" {
  type    = string
  default = "~/keys/yc_key.json"
}

variable "cluster_name" {
  type    = string
  default = "k8s-leonid-sh"
}

variable "network_name" {
  type    = string
  default = "k8s-leonid-sh"
}

variable "subnet_name" {
  type    = string
  default = "k8s-leonid-sh"
}

variable "subnet_cidr" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "service_account_name" {
  type    = string
  default = "k8s-leonid-sh"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "node_group_name" {
  type    = string
  default = "ng1-k8s-leonid-sh"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_platform_id" {
  type    = string
  default = "standard-v3"
}

variable "node_cores" {
  type    = number
  default = 2
}

variable "node_memory" {
  type    = number
  default = 4
}

variable "node_core_fraction" {
  type    = number
  default = 100
}

variable "node_disk_type" {
  type    = string
  default = "network-ssd"
}

variable "node_disk_size" {
  type    = number
  default = 64
}

variable "enable_public_ip_for_nodes" {
  type    = bool
  default = true
}

variable "enable_public_ip_for_master" {
  type    = bool
  default = true
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}
