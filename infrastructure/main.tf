module "s3" {
  source             = "./modules/s3"
  data_bucket_name   = var.data_bucket_name
  airflow_bucket_name = var.airflow_bucket_name
  logs_bucket_name   = var.logs_bucket_name
  project_name       = var.project_name
}