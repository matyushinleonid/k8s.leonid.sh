resource "yandex_vpc_security_group" "k8s_sg" {
  name       = var.cluster_name
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.k8s_network.id

  ingress {
    protocol          = "TCP"
    description       = "Load balancer health checks"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol          = "ANY"
    description       = "Allow master-node and node-node communication inside this security group"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "Allow pod-pod and service-service traffic inside cluster subnet"
    v4_cidr_blocks = yandex_vpc_subnet.k8s_subnet.v4_cidr_blocks
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol    = "ICMP"
    description = "Allow ICMP from private networks"
    v4_cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16"
    ]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow Kubernetes API access from the internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow NodePort services from the internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
