variable "project_name" {
  description = "Project name for tagging"
  default     = "BuildItAll"
}

variable "data_bucket_name" {
  description = "Name of the S3 bucket for data"
  default     = "builditall-client-data"
}

variable "airflow_bucket_name" {
  description = "Name of the S3 bucket for Airflow DAGs"
  default     = "builditall-airflow"
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for logs"
  default     = "builditall-logs"
}

variable "aws_account_id" {
  description = "AWS account ID"
}