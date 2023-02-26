resource aws_lb this {
  name            = local.lb.name
  internal        = local.lb.internal
  idle_timeout    = local.lb.idle_timeout
  security_groups = [module.lb_sg.security_group_id]
  subnets         = data.aws_subnets.public.ids

  enable_waf_fail_open = local.lb.enable_waf_fail_open

  access_logs {
    bucket  = local.lb.access_logs.bucket
    prefix  = local.lb.access_logs.prefix
    enabled = local.lb.access_logs.enabled
  }

  tags = local.lb.tags
}

resource aws_lb_target_group this {
  name                 = local.lb.target_groups.main.name
  port                 = local.lb.target_groups.main.port
  protocol             = local.lb.target_groups.main.protocol
  vpc_id               = data.aws_vpc.this.id
  target_type          = local.lb.target_groups.main.target_type
  deregistration_delay = local.lb.target_groups.main.deregistration_delay

  health_check {
    interval            = local.lb.target_groups.main.health_check.interval
    path                = local.lb.target_groups.main.health_check.path
    port                = local.lb.target_groups.main.health_check.port
    protocol            = local.lb.target_groups.main.health_check.protocol
    timeout             = local.lb.target_groups.main.health_check.timeout
    healthy_threshold   = local.lb.target_groups.main.health_check.healthy_threshold
    unhealthy_threshold = local.lb.target_groups.main.health_check.unhealthy_threshold
    matcher             = local.lb.target_groups.main.health_check.matcher
  }
}

resource aws_lb_listener this {
  load_balancer_arn = aws_lb.this.arn
  port              = local.lb.listeners.main.port
  protocol          = local.lb.listeners.main.protocol
  ssl_policy        = local.lb.listeners.main.ssl_policy
  certificate_arn   = data.aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource aws_lb_target_group admin {
  name                 = local.lb.target_groups.admin.name
  port                 = local.lb.target_groups.admin.port
  protocol             = local.lb.target_groups.admin.protocol
  vpc_id               = data.aws_vpc.this.id
  target_type          = local.lb.target_groups.admin.target_type
  deregistration_delay = local.lb.target_groups.admin.deregistration_delay

  health_check {
    interval            = local.lb.target_groups.admin.health_check.interval
    path                = local.lb.target_groups.admin.health_check.path
    port                = local.lb.target_groups.admin.health_check.port
    protocol            = local.lb.target_groups.admin.health_check.protocol
    timeout             = local.lb.target_groups.admin.health_check.timeout
    healthy_threshold   = local.lb.target_groups.admin.health_check.healthy_threshold
    unhealthy_threshold = local.lb.target_groups.admin.health_check.unhealthy_threshold
    matcher             = local.lb.target_groups.admin.health_check.matcher
  }
}

resource aws_lb_listener admin {
  load_balancer_arn = aws_lb.this.arn
  port              = local.lb.listeners.admin.port
  protocol          = local.lb.listeners.admin.protocol
  ssl_policy        = local.lb.listeners.admin.ssl_policy
  certificate_arn   = data.aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }
}
