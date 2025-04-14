# Data Bucket
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket_name
  tags = {
    Name        = var.data_bucket_name
    Project     = var.project_name
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "data_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.data_bucket]
  bucket     = aws_s3_bucket.data_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id
  rule {
    id     = "archive-old-data"
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create prefixes for data bucket
resource "aws_s3_object" "data_raw_prefix" {
  bucket       = aws_s3_bucket.data_bucket.id
  key          = "raw/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "data_processed_prefix" {
  bucket       = aws_s3_bucket.data_bucket.id
  key          = "processed/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "data_scripts_prefix" {
  bucket       = aws_s3_bucket.data_bucket.id
  key          = "scripts/"
  content_type = "application/x-directory"
}

# Airflow Bucket
resource "aws_s3_bucket" "airflow_bucket" {
  bucket = var.airflow_bucket_name
  tags = {
    Name        = var.airflow_bucket_name
    Project     = var.project_name
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "airflow_bucket" {
  bucket = aws_s3_bucket.airflow_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "airflow_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.airflow_bucket]
  bucket     = aws_s3_bucket.airflow_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "airflow_bucket" {
  bucket = aws_s3_bucket.airflow_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "airflow_dags_prefix" {
  bucket       = aws_s3_bucket.airflow_bucket.id
  key          = "dags/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "airflow_requirements_prefix" {
  bucket       = aws_s3_bucket.airflow_bucket.id
  key          = "requirements/"
  content_type = "application/x-directory"
}

# Logs Bucket
resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name
  tags = {
    Name        = var.logs_bucket_name
    Project     = var.project_name
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.logs_bucket]
  bucket     = aws_s3_bucket.logs_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
  rule {
    id     = "expire-old-logs"
    status = "Enabled"
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "logs_emr_prefix" {
  bucket       = aws_s3_bucket.logs_bucket.id
  key          = "emr/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "logs_mwaa_prefix" {
  bucket       = aws_s3_bucket.logs_bucket.id
  key          = "mwaa/"
  content_type = "application/x-directory"
}