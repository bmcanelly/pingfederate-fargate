
resource aws_cloudwatch_log_group this {
  for_each          = local.cloudwatch.LOG_GROUPS
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
}
