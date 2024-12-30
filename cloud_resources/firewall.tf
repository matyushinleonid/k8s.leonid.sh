locals {
  all_ips = ["0.0.0.0/0", "::/0"]
}

resource "hcloud_firewall" "lb_firewall" {
  name = "lb-firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = local.all_ips
    description = "Allow HTTP"
  }
}

resource "hcloud_firewall" "basic_firewall" {
  name = "basic-firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = local.all_ips
    description = "Allow SSH"
  }

  rule {
    direction   = "in"
    protocol    = "icmp"
    source_ips  = local.all_ips
    description = "Allow ICMP for health checks"
  }
}


resource "hcloud_firewall" "k8s_cpl_firewall" {
  name = "k8s-cpl-firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = local.all_ips
    description = "Kubernetes API server"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "2379-2380"
    source_ips  = [var.subnet_cidr]
    description = "etcd"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = local.all_ips
    description = "Kubelet API"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10259"
    source_ips  = [var.subnet_cidr]
    description = "kube-scheduler"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10257"
    source_ips  = [var.subnet_cidr]
    description = "kube-controller-manager"
  }
}

resource "hcloud_firewall" "k8s_worker_firewall" {
  name = "k8s-worker-firewall"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = local.all_ips
    description = "Kubelet API"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "10256"
    source_ips  = [var.subnet_cidr]
    description = "kube-proxy"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "30000-32767"
    source_ips  = [var.subnet_cidr]
    description = "NodePort services"
  }

  rule {
    direction   = "in"
    protocol    = "udp"
    port        = "30000-32767"
    source_ips  = [var.subnet_cidr]
    description = "NodePort services"
  }
}
