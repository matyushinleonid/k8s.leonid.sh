variable "zone" {
  type    = string
  default = "eu-central"
}

variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "lb-001_internal_ipv4" {
  type    = string
  default = "10.0.1.4"
}

variable "ctrl-001_internal_ipv4" {
  type    = string
  default = "10.0.1.5"
}

variable "worker-001_internal_ipv4" {
  type    = string
  default = "10.0.1.6"
}

variable "server_type" {
  type    = string
  default = "cx22"
}

variable "image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "datacenter" {
  type    = string
  default = "nbg1-dc3"
}

variable "common_ssh_public_key" {
  type = string
}
