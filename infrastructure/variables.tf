variable "aws_region" {
  description = "AWS region for resources"
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for tagging"
  default     = "BuildItAll"
}

variable "aws_account_id" {
  description = "AWS account ID"
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