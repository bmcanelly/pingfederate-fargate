
resource aws_ecs_task_definition admin {
  family                = local.tasks.admin.task_family
  container_definitions = file(local.tasks.admin.task_path)
  network_mode          = local.tasks.network_mode
  cpu                   = local.tasks.admin.cpu
  memory                = local.tasks.admin.memory
  task_role_arn         = data.aws_iam_role.this.arn
  execution_role_arn    = data.aws_iam_role.this.arn

  requires_compatibilities = local.tasks.compatibilities

  runtime_platform {
    operating_system_family = local.tasks.operating_system_family
    cpu_architecture        = local.tasks.cpu_architecture
  }

  volume {
    name = "in"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.this_in.id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.data.id
        iam             = "ENABLED"
      }
    }
  }

  tags = local.services.admin.tags
}

resource aws_ecs_service admin {
  name            = local.services.admin.name
  launch_type     = local.services.launch_type
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.admin.arn

  scheduling_strategy    = local.services.admin.scheduling_strategy
  enable_execute_command = local.services.admin.enable_execute_command

  deployment_minimum_healthy_percent = local.services.admin.deployment_minimum_healthy_percent
  deployment_maximum_percent         = local.services.admin.deployment_maximum_percent

  load_balancer {
    target_group_arn = aws_lb_target_group.admin.arn
    container_name   = local.services.admin.lb.container_name
    container_port   = local.services.admin.lb.container_port
  }

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [module.admin_sg.security_group_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  propagate_tags          = local.services.propagate_tags
  enable_ecs_managed_tags = local.services.enable_ecs_managed_tags

  tags = local.services.admin.tags

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

resource aws_ecs_task_definition this {
  family                = local.tasks.main.task_family
  container_definitions = file(local.tasks.main.task_path)
  network_mode          = local.tasks.network_mode
  cpu                   = local.tasks.main.cpu
  memory                = local.tasks.main.memory
  task_role_arn         = data.aws_iam_role.this.arn
  execution_role_arn    = data.aws_iam_role.this.arn

  requires_compatibilities = local.tasks.compatibilities

  runtime_platform {
    operating_system_family = local.tasks.operating_system_family
    cpu_architecture        = local.tasks.cpu_architecture
  }

  volume {
    name = "in"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.this_in.id
        iam             = "ENABLED"
      }
    }
  }

  tags = local.services.main.tags
}

resource aws_ecs_service this {
  name            = local.services.main.name
  launch_type     = local.services.launch_type
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  enable_execute_command = local.services.main.enable_execute_command

  tags = local.services.main.tags
 
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.services.main.lb.container_name
    container_port   = local.services.main.lb.container_port
  }

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [module.app_sg.security_group_id]
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
