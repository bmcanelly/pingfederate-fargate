
resource aws_s3_bucket this {
  bucket = local.log_bucket

  tags = {
    Name        = "pf-fg s3 bucket"
    Environment = "prd"
  }
}

resource aws_s3_bucket_acl this {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource aws_s3_bucket_public_access_block this {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_lifecycle_configuration this {
  bucket = aws_s3_bucket.this.id
  rule {
    status = "Enabled"
    id     = "pf-fg-s3-lifecycle"
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration {
      days                         = 365
      expired_object_delete_marker = false
    }
  }
}

resource aws_s3_bucket_policy this {
  bucket = aws_s3_bucket.this.bucket
  policy = data.aws_iam_policy_document.this.json
}
