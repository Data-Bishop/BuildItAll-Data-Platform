output "tfstate_bucket_arn" {
  value = aws_s3_bucket.tfstate_bucket.arn
}

output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate_bucket.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tfstate_lock.name
}
