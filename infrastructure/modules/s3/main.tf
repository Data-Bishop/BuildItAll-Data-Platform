resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket_name
  tags = {
    Name        = "${var.project_name}-Data"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket" "airflow_bucket" {
  bucket = var.airflow_bucket_name
  tags = {
    Name        = "${var.project_name}-Airflow"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name
  tags = {
    Name        = "${var.project_name}-Logs"
    Environment = "Prod"
  }
}

resource "aws_s3_object" "data_scripts_prefix" {
  bucket       = aws_s3_bucket.data_bucket.id
  key          = "scripts/"
  content_type = "application/x-directory"
}

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

resource "aws_s3_object" "logs_airflow_prefix" {
  bucket       = aws_s3_bucket.logs_bucket.id
  key          = "airflow/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "logs_emr_prefix" {
  bucket       = aws_s3_bucket.logs_bucket.id
  key          = "emr/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_policy" "airflow_bucket_policy" {
  bucket = aws_s3_bucket.airflow_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-Airflow-Role",
            "arn:aws:iam::${var.aws_account_id}:user/builditall-admin"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.airflow_bucket_name}",
          "arn:aws:s3:::${var.airflow_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "data_bucket_policy" {
  bucket = aws_s3_bucket.data_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-Airflow-Role",
            "arn:aws:iam::${var.aws_account_id}:user/builditall-admin",
            "arn:aws:iam::${var.aws_account_id}:role/EMR_DefaultRole"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.data_bucket_name}",
          "arn:aws:s3:::${var.data_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_account_id}:role/${var.project_name}-Airflow-Role",
            "arn:aws:iam::${var.aws_account_id}:role/EMR_DefaultRole"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.logs_bucket_name}",
          "arn:aws:s3:::${var.logs_bucket_name}/*"
        ]
      }
    ]
  })
}