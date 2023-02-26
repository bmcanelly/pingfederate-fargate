
resource aws_ecr_repository this {
  for_each = local.repos

  name = each.key

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  tags = each.value.tags 
}

resource aws_ecr_lifecycle_policy this {
  for_each = local.repos

  repository = each.key 

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 14 images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v-"],
        "countType": "imageCountMoreThan",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource aws_ecr_repository_policy this {
  for_each = local.repos

  repository = each.key 

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "codebuild",
            "Effect": "Allow",
            "Principal": {
              "Service": "codebuild.amazonaws.com"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
EOF
}
