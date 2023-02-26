
module lb_sg {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.cname}_lb"
  vpc_id      = data.aws_vpc.this.id
  description = "Managed by Terraform"

  tags = {
    Name        = "${local.cname}_lb"
    Description = "Managed by Terraform"
  }

  ingress_cidr_blocks = local.cidrs.allowed
  ingress_rules       = ["https-443-tcp", "all-icmp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 9999
      to_port     = 9999
      protocol    = "tcp"
      cidr_blocks = join(",", local.cidrs.admin_allowed)
    },
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module app_sg {
  source = "terraform-aws-modules/security-group/aws"

  name        = local.cname
  vpc_id      = data.aws_vpc.this.id
  description = "Managed by Terraform"

  tags = {
    Name        = local.cname
    Description = "Managed by Terraform"
  }

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.lb_sg.security_group_id
    },
    {
      from_port                = 7600
      to_port                  = 7600
      protocol                 = "tcp"
      source_security_group_id = module.admin_sg.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
}

module admin_sg {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.cname}_admin"
  vpc_id      = data.aws_vpc.this.id
  description = "Managed by Terraform"

  tags = {
    Name        = "${local.cname}_admin"
    Description = "Managed by Terraform"
  }

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp"]
  

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 9999
      to_port     = 9999
      protocol    = "tcp"
      cidr_blocks = join(",", local.cidrs.admin_allowed)
    },
  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.lb_sg.security_group_id
    },
    {
      from_port                = 7600
      to_port                  = 7600
      protocol                 = "tcp"
      source_security_group_id = module.app_sg.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
}

module efs_sg {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.cname}_efs"
  vpc_id      = data.aws_vpc.this.id
  description = "Managed by Terraform"

  tags = {
    Name        = "${local.cname}_efs"
    Description = "Managed by Terraform"
  }

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "nfs-tcp"
      source_security_group_id = module.app_sg.security_group_id
    },
    {
      rule                     = "nfs-tcp"
      source_security_group_id = module.admin_sg.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
}
