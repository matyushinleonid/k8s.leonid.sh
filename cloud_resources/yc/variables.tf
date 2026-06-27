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

variable "prometheus_workspace_id" {
  type    = string
  default = "monkfdekjpg063d6i61u"
}

locals {
  ssh_keys = "ubuntu:${file(var.ssh_key_path)}"
}

variable "argocd_admin_lockbox_secret_id" {
  type    = string
  default = "e6q7r4bj2ik149jarhq5"
}

variable "argocd_github_lockbox_secret_id" {
  type    = string
  default = "e6q864he4ggl6se9gng5"
}