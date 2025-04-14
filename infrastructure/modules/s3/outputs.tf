output "data_bucket_arn" {
  value = aws_s3_bucket.data_bucket.arn
}

output "data_bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "airflow_bucket_arn" {
  value = aws_s3_bucket.airflow_bucket.arn
}

output "airflow_bucket_name" {
  value = aws_s3_bucket.airflow_bucket.bucket
}

output "logs_bucket_arn" {
  value = aws_s3_bucket.logs_bucket.arn
}

output "logs_bucket_name" {
  value = aws_s3_bucket.logs_bucket.bucket
}