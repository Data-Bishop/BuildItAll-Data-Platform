resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.tfstate_bucket_name
  tags = {
    Name        = var.tfstate_bucket_name
    Project     = var.project_name
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "tfstate_bucket" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfstate_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.tfstate_bucket]
  bucket     = aws_s3_bucket.tfstate_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "tfstate_bucket" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_bucket" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name           = "${var.tfstate_bucket_name}-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "${var.tfstate_bucket_name}-lock"
    Project     = var.project_name
    Environment = "Production"
  }
}
