resource "yandex_vpc_security_group" "postgres" {
  name       = "${var.base_name}-postgres"
  network_id = yandex_vpc_network.k8s_network.id

  ingress {
    protocol       = "TCP"
    port           = 6432
    v4_cidr_blocks = concat(var.subnet_cidr, [module.kube.cluster_ipv4_range])
  }
}

resource "yandex_mdb_postgresql_cluster" "postgres" {
  name               = var.base_name
  network_id         = yandex_vpc_network.k8s_network.id
  environment        = "PRODUCTION"
  folder_id          = var.folder_id
  security_group_ids = [yandex_vpc_security_group.postgres.id]

  host {
    zone             = var.zone
    subnet_id        = yandex_vpc_subnet.k8s_subnet.id
    assign_public_ip = false
    priority         = 0
  }

  config {
    version = "18"
    resources {
      disk_size          = 10
      disk_type_id       = "network-ssd"
      resource_preset_id = "c3-c2-m4"
    }
    backup_window_start {
      hours   = 3
      minutes = 0
    }
    backup_retain_period_days = 7
    access {
      web_sql = true
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "TUE"
    hour = 6
  }
}

resource "yandex_mdb_postgresql_user" "temporal" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres.id
  name       = "temporal"
  password   = data.yandex_lockbox_secret_version_entry.temporal_pg_password.text_value
  conn_limit = 50

  grants = ["mdb_admin"]
}

resource "yandex_mdb_postgresql_database" "temporal" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres.id
  name       = "temporal"
  owner      = yandex_mdb_postgresql_user.temporal.name
}

resource "yandex_mdb_postgresql_database" "temporal_visibility" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres.id
  name       = "temporal_visibility"
  owner      = yandex_mdb_postgresql_user.temporal.name

  extension {
    name = "btree_gin"
  }
}
