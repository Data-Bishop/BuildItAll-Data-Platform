variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "data_bucket_name" {
  description = "Name of the S3 bucket for data"
  type        = string
}

variable "airflow_bucket_name" {
  description = "Name of the S3 bucket for Airflow DAGs"
  type        = string
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for logs"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "airflow_role_arn" {
  description = "ARN of the Airflow IAM role"
  type        = string
}

variable "emr_default_role_arn" {
  description = "ARN of the EMR Default Role"
  type        = string
}