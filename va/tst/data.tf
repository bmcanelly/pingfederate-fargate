
data aws_acm_certificate this {
  domain   = "your-domain.com"
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

data aws_iam_role this {
  name = "tst_pf_task"
}

data aws_vpc this {
  filter {
    name   = "tag:Name"
    values = ["main"]
  }
}

data aws_ecs_cluster this {
  cluster_name = "tst"
}

data aws_route53_zone this {
  name         = "your-domain.com"
  private_zone = false
}

data aws_subnets public {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["public"]
  }
}

data aws_subnets private {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private"]
  }
}
