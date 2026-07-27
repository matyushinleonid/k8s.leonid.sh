variable "name" {
  type    = string
  default = "amnezia-vpn"
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "server_type" {
  type    = string
  default = "cx23"
}

variable "image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/hetzner-amnezia.pub"
}

variable "backups" {
  type    = bool
  default = false
}
