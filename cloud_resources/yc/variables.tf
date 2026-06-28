variable "folder_id" {
  type    = string
  default = "b1g3o4ahe2b4o5od724t"
}

variable "zone" {
  type    = string
  default = "ru-central1-d"
}

variable "base_name" {
  type    = string
  default = "k8s-leonid-sh"
}

variable "subnet_cidr" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/k8s.leonid.sh.pub"
}

variable "email_address" {
  type    = string
  default = "matyushinleonid@users.noreply.github.com"
}

variable "domain" {
  type    = string
  default = "leonid.sh"
}

locals {
  ssh_keys = "ubuntu:${file(var.ssh_key_path)}"
}
