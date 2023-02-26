
data aws_kms_key s3 {
  key_id = "alias/aws/s3"
}

data aws_elb_service_account main {}

data aws_caller_identity local {}

data aws_iam_policy_document this {
  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.log_bucket}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_elb_service_account.main.arn
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      "arn:aws:s3:::${local.log_bucket}"
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryWrite"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.log_bucket}/*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }

    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}
