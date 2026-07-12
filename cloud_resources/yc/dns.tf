resource "yandex_dns_zone" "local_dns" {
  name             = "pg-internal-zone"
  zone             = "local."
  public           = false
  private_networks = [yandex_vpc_network.k8s_network.id]
}

resource "yandex_dns_recordset" "pg_cname" {
  zone_id = yandex_dns_zone.local_dns.id
  name    = "postgres.local."
  type    = "CNAME"
  ttl     = 600
  data    = [yandex_mdb_postgresql_cluster.postgres.host[0].fqdn]
}
