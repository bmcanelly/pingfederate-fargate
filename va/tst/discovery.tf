
data aws_service_discovery_dns_namespace this {
  name = local.discovery_zone
  type = "DNS_PRIVATE"
}

resource aws_service_discovery_service this {
  name = local.name

  dns_config {
    namespace_id = data.aws_service_discovery_dns_namespace.this.id
    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 10
  }
}
