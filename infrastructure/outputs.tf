output "data_bucket_arn" {
  value = module.s3.data_bucket_arn
}

output "airflow_bucket_arn" {
  value = module.s3.airflow_bucket_arn
}

output "logs_bucket_arn" {
  value = module.s3.logs_bucket_arn
}