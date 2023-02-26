provider aws {
  region = local.aws_region
}

terraform {
  required_version = ">= 1, < 2"

  required_providers {
    aws = {
      version = "~> 4.56"
    }
  }

  #backend s3 {
  #  bucket  = "pf-fg-states-us-east-1"
  #  region  = "us-east-1"
  #  key     = "pf-fg.terraform.tfstate"
  #  encrypt = true
  #}
}
