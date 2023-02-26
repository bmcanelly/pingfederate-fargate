locals {
  aws_region = "us-east-1"
  ohio       = "us-east-2"
  name       = "pf"
  log_bucket = "pingfederate-fargate-logs-us-east-1"
  account_id = data.aws_caller_identity.local.account_id

  clustering_bucket = "pf-clustering-unique-name"
  description_tag   = "Managed by Terraform"

  vpcs = {
    main = {
      name = "pf"
      cidr = "172.30.18.0/23"

      azs             = ["us-east-1a",     "us-east-1b",      "us-east-1c"]
      private_subnets = ["172.30.19.0/26", "172.30.19.64/26", "172.30.19.128/26"]
      public_subnets  = ["172.30.18.0/27", "172.30.18.32/27", "172.30.18.64/27"]

      public_subnet_tags  = { Name = "public"  }
      private_subnet_tags = { Name = "private" }

      manage_default_route_table = true
      default_route_table_tags   = { Name = "${local.name}-default"}

      public_route_table_tags  = { Name = "public"  }
      private_route_table_tags = { Name = "private" }

      manage_default_security_group = true
      default_security_group_tags   = { Name = "${local.name}-default"}

      manage_default_network_acl = true
      default_network_acl_tags   = { Name = "${local.name}-default"}

      public_dedicated_network_acl = true
      public_inbound_acl_rules     = concat(local.network_acls["default_inbound"],
                                            local.network_acls["public_inbound"])
      public_outbound_acl_rules    = concat(local.network_acls["default_outbound"],
                                            local.network_acls["public_outbound"])

      private_dedicated_network_acl = true
      private_inbound_acl_rules     = concat(local.network_acls["default_inbound"],
                                             local.network_acls["private_inbound"])
      private_outbound_acl_rules    = concat(local.network_acls["default_outbound"],
                                             local.network_acls["private_outbound"])

      public_acl_tags  = { Name = "public"  }
      private_acl_tags = { Name = "private" }

      enable_dns_hostnames = true
      enable_dns_support   = true

      enable_nat_gateway  = true
      single_nat_gateway  = false
      reuse_nat_ips       = true
      external_nat_ip_ids = aws_eip.nat.*.id

      enable_dhcp_options              = true
      dhcp_options_domain_name         = "pf-fg.local"
      dhcp_options_domain_name_servers = ["172.30.18.2"]

      enable_flow_log                      = true
      create_flow_log_cloudwatch_log_group = true
      create_flow_log_cloudwatch_iam_role  = true
      flow_log_max_aggregation_interval    = 60
      flow_log_file_format                 = "parquet"

      tags = {
        Description = local.description_tag
      }

      customer_gateways = {
        bedwatch = {
          bgp_asn    = 65001
          ip_address = "1.2.3.4"
        }
      }
      enable_vpn_gateway = true
    }
  }

  cidrs = {
    any = "0.0.0.0/0"
  }

  network_acls = {
    default_inbound  = []
    default_outbound = []

    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 200
        rule_action = "allow"
        icmp_code   = -1
        icmp_type   = 8
        protocol    = "icmp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]

    private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 9031
        to_port     = 9031
        protocol    = "-1"
        cidr_block  = "172.30.18.0/27"
      },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = 9031
        to_port     = 9031
        protocol    = "-1"
        cidr_block  = "172.30.18.32/27"
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = 9031
        to_port     = 9031
        protocol    = "-1"
        cidr_block  = "172.30.18.64/27"
      },
      {
        rule_number = 200
        rule_action = "allow"
        icmp_code   = -1
        icmp_type   = 8
        protocol    = "icmp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }

  cloudwatch = {
    flow_log_group_name = "pingfederate-fargate-vpc-flow-${local.aws_region}"

    LOG_GROUPS = {
    }
  }

  build_defaults = {
    service_role    = "arn:aws:iam::${local.account_id}:role/bedwatch_codebuild"
    build_timeout   = 20
    privileged_mode = true

    concurrent_build_limit = 1

    arm_amzn2_small_builder = {
      image        = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
      compute_type = "BUILD_GENERAL1_SMALL"
      type         = "ARM_CONTAINER"
    }
  }

  builds = {
    pf-image-updater = {
      service_role  = local.build_defaults.service_role
      build_timeout = local.build_defaults.build_timeout

      concurrent_build_limit = local.build_defaults.concurrent_build_limit

      sources = [{
        type      = "NO_SOURCE"
        buildspec = file("buildspec/pf_image_updater.yml")
      }]

      environment = [{
        compute_type = local.build_defaults.arm_amzn2_small_builder.compute_type
        image        = local.build_defaults.arm_amzn2_small_builder.image
        type         = local.build_defaults.arm_amzn2_small_builder.type

        privileged_mode = local.build_defaults.privileged_mode

        environment_variables = [
          {
            name  = "REPO"
            value = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/pingfederate"
            type  = "PLAINTEXT"
          },
        ]
      }]

      vpc_config = [{
        vpc_id             = module.vpc.vpc_id
        subnets            = module.vpc.private_subnets
        security_group_ids = [module.vpc.default_security_group_id]
      }]

      artifacts = [{
        type = "NO_ARTIFACTS"
      }]
    }
  }

  assume_role_policy = <<EOF
      {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  roles = {
    prd = {
      name               = "prd_pf_task"
      description        = "production environment pingfederate task"
      assume_role_policy = local.assume_role_policy
      policy_arn         = aws_iam_policy.prd_pf_task.arn
    }

    tst = {
      name               = "tst_pf_task"
      description        = "test environment pingfederate task"
      assume_role_policy = local.assume_role_policy
      policy_arn         = aws_iam_policy.tst_pf_task.arn
    }
  }

  clusters = {
    prd = {
      containerInsights = "enabled"
      tags = {
        Environment = "prd"
        Description = local.description_tag
      }
    }
    tst = {
      containerInsights = "enabled"
      tags = {
        Environment = "tst"
        Description = local.description_tag
      }
    }
  }

  repos = {
    pingfederate = {
      scan_on_push = true
      tags = {
        Description = local.description_tag
      }
    }
  }
}
