variable "name" {
  type    = string
  default = "dev-vm"
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "server_type" {
  type    = string
  default = "cx33"
}

variable "image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/hetzner-dev.pub"
}

variable "backups" {
  type    = bool
  default = false
}

variable "socks5_port" {
  type    = number
  default = 32768

  validation {
    condition     = var.socks5_port >= 1024 && var.socks5_port <= 65535
    error_message = "socks5_port must be between 1024 and 65535."
  }
}

variable "socks5_source_ips" {
  type    = set(string)
  default = ["0.0.0.0/0", "::/0"]
}
