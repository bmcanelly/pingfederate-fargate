locals {
  aws_region = "us-east-1"

  name  = "tst-pf"
  app   = "pf"
  env   = "tst"
  cname = "tst_pf"

  dns_zone       = "your-domain.com"
  discovery_zone = "pf.local"

  cidrs = {
    allowed       = ["127.0.0.1/32"]
    admin_allowed = ["127.0.0.1/32"]
  }

  services = {
    launch_type = "FARGATE"

    propagate_tags          = "SERVICE"
    enable_ecs_managed_tags = true

    main = {
      name = local.app

      enable_execute_command = "true"

      lb = {
        container_name = local.cname
        container_port = 9031
      }

      tags = {
        Name        = local.cname
        Owner       = "your_org"
        Description = "Managed by Terraform"
      }
    }

    admin = {
      name = "${local.app}-admin"

      scheduling_strategy    = "REPLICA"
      enable_execute_command = "true"

      lb = {
        container_name = "${local.cname}_admin"
        container_port = 9999
      }

      deployment_minimum_healthy_percent = 0
      deployment_maximum_percent         = 100

      tags = {
        Name        = "${local.cname}_admin"
        Owner       = "our_org"
        Description = "Managed by Terraform"
      }
    }
  }

  tasks = {
    network_mode            = "awsvpc"
    compatibilities         = ["FARGATE"]
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
    main = {
      task_family = local.cname
      task_path   = "configs/tst.json"
      cpu         = "1024"
      memory      = "3072"
    }
    admin = {
      task_family = "${local.cname}_admin"
      task_path   = "configs/admin.json"
      cpu         = "1024"
      memory      = "3072"
    }
  }

  lb = {
    name          = local.name 
    internal      = false
    idle_timeout  = 300
    subnet_filter = ["public"]

    enable_waf_fail_open = true

    access_logs = {
      bucket  = "your-unique-logs-bucket-${local.aws_region}"
      prefix  = "${local.env}/${local.app}"
      enabled = true
    }

    tags = {
      Name        = "${local.cname}_lb"
      Environment = local.env
      Description = "Managed by Terraform"
    }

    target_groups = {
      main = {
        name                 = local.name
        port                 = 80
        protocol             = "HTTPS"
        target_type          = "ip"
        deregistration_delay = 10

        health_check = {
          interval            = 30
          path                = "/${local.app}/heartbeat.ping"
          port                = "traffic-port"
          protocol            = "HTTPS"
          timeout             = 25
          healthy_threshold   = 2
          unhealthy_threshold = 4
          matcher             = "200"
        }
      }
      admin = {
        name                 = "${local.name}-admin"
        port                 = 80
        protocol             = "HTTPS"
        target_type          = "ip"
        deregistration_delay = 10

        health_check = {
          interval            = 30
          path                = "/${local.app}/heartbeat.ping"
          port                = "traffic-port"
          protocol            = "HTTPS"
          timeout             = 25
          healthy_threshold   = 2
          unhealthy_threshold = 2
          matcher             = "200"
        }
      }
    }

    listeners = {
      main = {
        port       = "443"
        protocol   = "HTTPS"
        ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
      }

      admin = {
        port       = "9999"
        protocol   = "HTTPS"
        ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
      }
    }
  }

  cloudwatch = {
    log_groups = {
      main = {
        name              = "/${local.app}/${local.env}"
        retention_in_days = 0

        tags = {
          App         = local.name
          Environment = local.env
          Description = "Managed by Terraform"
        }
      }
      admin = {
        name              = "/${local.app}/${local.env}/admin"
        retention_in_days = 0

        tags = {
          App         = local.name
          Environment = local.env
          Description = "Managed by Terraform"
        }
      }
    }
  }
}
