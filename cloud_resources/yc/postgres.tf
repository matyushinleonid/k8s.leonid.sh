resource "yandex_mdb_postgresql_cluster" "postgres" {
  name        = var.base_name
  network_id  = yandex_vpc_network.k8s_network.id
  environment = "PRODUCTION"
  folder_id   = var.folder_id

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

resource "yandex_dns_recordset" "pg_cname" {
  zone_id = yandex_dns_zone.local_dns.id
  name    = "postgres.local."
  type    = "CNAME"
  ttl     = 600
  data    = [yandex_mdb_postgresql_cluster.postgres.host[0].fqdn]
}

data "yandex_lockbox_secret_version" "temporal_pg" {
  secret_id = "e6qojcm2ke05j3v745t1"
}

resource "yandex_mdb_postgresql_user" "temporal" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres.id
  name       = "temporal"
  password   = data.yandex_lockbox_secret_version.temporal_pg.entries["temporal_postgres_password"]
  conn_limit = 50

  permission {
    database_name = yandex_mdb_postgresql_database.temporal.name
  }

  grants = ["mdb_admin"]
}

resource "yandex_mdb_postgresql_database" "temporal" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres.id
  name       = "temporal"
  owner      = yandex_mdb_postgresql_user.temporal.name
}