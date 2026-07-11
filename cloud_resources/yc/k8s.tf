module "kube" {
  source = "github.com/terraform-yc-modules/terraform-yc-kubernetes.git"

  cluster_name = var.base_name

  network_id              = yandex_vpc_network.k8s_network.id
  network_policy_provider = ""
  enable_cilium_policy    = false

  master_locations = [
    {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }
  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "03:00"
      duration   = "3h"
    }
  ]

  master_logging = {
    log_group_id = module.apps.k8s_logging_group_id
  }

  node_groups_defaults = {
    template_name = "{instance_group.id}-{instance.zone_id}-{instance.index}"
    platform_id   = "standard-v3"
    node_cores    = 4
    node_memory   = 8
    node_gpus     = 0
    core_fraction = 100
    disk_type     = "network-ssd"
    disk_size     = 64
    preemptible   = false
    nat           = false
    ipv4          = true
    ipv6          = false
  }

  node_groups = {
    "${var.base_name}-ng-01" = {

      fixed_scale = {
        size = 2
      }

      platform_id   = "standard-v3"
      node_cores    = 2
      node_memory   = 8
      core_fraction = 100

      disk_type = "network-ssd"
      disk_size = 64

      node_labels = {
        node_group = "ng-01"
      }

      node_locations = [
        {
          zone      = var.zone
          subnet_id = yandex_vpc_subnet.k8s_subnet.id
        }
      ]

    }
  }

  service_account_name = var.base_name
  node_account_name    = "${var.base_name}-nodes"
  create_kms           = true
  kms_key = {
    name = var.base_name
  }

  public_access           = true
  enable_default_rules    = true
  enable_node_ssh_access  = true
  enable_node_ports_rules = true
  enable_outgoing_traffic = true
  allowed_ips             = ["0.0.0.0/0"]
  allowed_ips_ssh         = ["0.0.0.0/0"]

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "false"
    ssh-keys       = local.ssh_keys
  }
}
