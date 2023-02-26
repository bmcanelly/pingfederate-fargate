
resource aws_cloudwatch_log_group this {
  name              = local.cloudwatch.log_groups.main.name
  retention_in_days = local.cloudwatch.log_groups.main.retention_in_days
  tags              = local.cloudwatch.log_groups.main.tags
}

resource aws_cloudwatch_log_group admin {
  name              = local.cloudwatch.log_groups.admin.name
  retention_in_days = local.cloudwatch.log_groups.admin.retention_in_days
  tags              = local.cloudwatch.log_groups.admin.tags
}
