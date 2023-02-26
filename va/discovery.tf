
resource aws_service_discovery_private_dns_namespace this {
  name = "pf.local"
  vpc  = module.vpc.vpc_id
}
