resource aws_eip nat {
  count = 3
  vpc   = true
  tags  = { Name = "ngw" }
}

module vpc {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.19.0"

  name = local.vpcs.main.name
  cidr = local.vpcs.main.cidr

  azs             = local.vpcs.main.azs
  public_subnets  = local.vpcs.main.public_subnets
  private_subnets = local.vpcs.main.private_subnets

  manage_default_network_acl = local.vpcs.main.manage_default_network_acl
  default_network_acl_tags   = local.vpcs.main.default_network_acl_tags

  manage_default_route_table = local.vpcs.main.manage_default_route_table
  default_route_table_tags   = local.vpcs.main.default_route_table_tags

  manage_default_security_group = local.vpcs.main.manage_default_security_group
  default_security_group_tags   = local.vpcs.main.default_security_group_tags

  public_dedicated_network_acl = local.vpcs.main.public_dedicated_network_acl
  public_inbound_acl_rules     = local.vpcs.main.public_inbound_acl_rules
  public_outbound_acl_rules    = local.vpcs.main.public_outbound_acl_rules

  private_dedicated_network_acl = local.vpcs.main.private_dedicated_network_acl
  private_inbound_acl_rules     = local.vpcs.main.private_inbound_acl_rules
  private_outbound_acl_rules    = local.vpcs.main.private_outbound_acl_rules

  public_subnet_tags  = local.vpcs.main.public_subnet_tags
  private_subnet_tags = local.vpcs.main.private_subnet_tags

  public_acl_tags  = local.vpcs.main.public_acl_tags
  private_acl_tags = local.vpcs.main.private_acl_tags

  public_route_table_tags  = local.vpcs.main.public_route_table_tags
  private_route_table_tags = local.vpcs.main.private_route_table_tags

  enable_dns_hostnames = local.vpcs.main.enable_dns_hostnames
  enable_dns_support   = local.vpcs.main.enable_dns_support

  enable_nat_gateway  = local.vpcs.main.enable_nat_gateway
  single_nat_gateway  = local.vpcs.main.single_nat_gateway
  reuse_nat_ips       = local.vpcs.main.reuse_nat_ips
  external_nat_ip_ids = local.vpcs.main.external_nat_ip_ids

  enable_dhcp_options              = local.vpcs.main.enable_dhcp_options
  dhcp_options_domain_name         = local.vpcs.main.dhcp_options_domain_name
  dhcp_options_domain_name_servers = local.vpcs.main.dhcp_options_domain_name_servers

  enable_flow_log                      = local.vpcs.main.enable_flow_log
  create_flow_log_cloudwatch_log_group = local.vpcs.main.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = local.vpcs.main.create_flow_log_cloudwatch_iam_role
  flow_log_max_aggregation_interval    = local.vpcs.main.flow_log_max_aggregation_interval
  flow_log_file_format                 = local.vpcs.main.flow_log_file_format

  # customer_gateways  = local.vpcs.main.customer_gateways
  # enable_vpn_gateway = local.vpcs.main.enable_vpn_gateway

  tags = local.vpcs.main.tags
}

resource aws_cloudwatch_log_group flow_log {
  name = local.cloudwatch.flow_log_group_name
}

resource aws_iam_role vpc_flow_log_cloudwatch {
  name_prefix        = "vpc-flow-log-role-"
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json
}

data aws_iam_policy_document flow_log_cloudwatch_assume_role {
  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource aws_iam_role_policy_attachment vpc_flow_log_cloudwatch {
  role       = aws_iam_role.vpc_flow_log_cloudwatch.name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch.arn
}

resource aws_iam_policy vpc_flow_log_cloudwatch {
  name_prefix = "vpc-flow-log-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch.json
}

data aws_iam_policy_document vpc_flow_log_cloudwatch {
  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource aws_s3_bucket vpc_logs {
  bucket = "main-vpc-logs-${local.aws_region}"

  tags = {
    Name        = "main vpc logs s3 bucket"
    Environment = "prd"
  }
}

resource aws_s3_bucket_acl vpc_logs {
  bucket = aws_s3_bucket.vpc_logs.id
  acl    = "private"
}

resource aws_s3_bucket_public_access_block vpc_logs {
  bucket = aws_s3_bucket.vpc_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
