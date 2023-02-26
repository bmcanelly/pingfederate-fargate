
resource aws_ecs_cluster this {
  for_each = local.clusters

  name = each.key
  tags = each.value.tags
  setting {
    name  = "containerInsights" 
    value = each.value.containerInsights
  }
}
