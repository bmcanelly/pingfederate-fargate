
resource aws_codebuild_project this {
  for_each = local.builds
  name          = each.key 
  service_role  = each.value.service_role
  build_timeout = each.value.build_timeout

  dynamic source {
    for_each = each.value.sources
    content { 
      type = source.value.type
      buildspec = source.value.buildspec 
    }
  }

  concurrent_build_limit = each.value.concurrent_build_limit

  dynamic environment {
    for_each = each.value.environment
    content {
      compute_type = environment.value.compute_type
      image        = environment.value.image 
      type         = environment.value.type 

      privileged_mode = environment.value.privileged_mode

      dynamic environment_variable {
        for_each = environment.value.environment_variables
        content {
          name  = environment_variable.value.name
          value = environment_variable.value.value
          type  = environment_variable.value.type
        }
      }
    }
  }

  dynamic vpc_config {
    for_each = each.value.vpc_config
    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets 
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic artifacts {
    for_each = each.value.artifacts
    content {
      type = artifacts.value.type
    }
  }
}

resource aws_cloudwatch_event_rule this {
  name                = "image_updater"
  schedule_expression = "cron(0 8 * * ? *)"
  is_enabled          = "true"
}

resource aws_cloudwatch_event_target this {
  target_id = aws_cloudwatch_event_rule.this.name
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = aws_codebuild_project.this["pf-image-updater"].id
  role_arn  = local.build_defaults.service_role
}
