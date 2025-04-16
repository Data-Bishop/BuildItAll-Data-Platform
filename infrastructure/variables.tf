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

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "key_pair_name" {
  description = "SSH key pair name for bastion"
}

variable "allowed_ip" {
  description = "IP range for bastion SSH and Airflow UI"
  default     = "203.0.113.0/24"
}