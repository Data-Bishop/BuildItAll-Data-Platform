data "aws_secretsmanager_secret" "builditall" {
  name = "builditall-secrets"
}

data "aws_secretsmanager_secret_version" "builditall" {
  secret_id = data.aws_secretsmanager_secret.builditall.id
}

locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.builditall.secret_string)
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "data_bucket_name" {
  description = "The name of the S3 bucket for client data"
  type        = string
}

variable "airflow_bucket_name" {
  description = "The name of the S3 bucket for Airflow"
  type        = string
}

variable "logs_bucket_name" {
  description = "The name of the S3 bucket for logs"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "key_pair_name" {
  description = "The name of the EC2 key pair"
  type        = string
}

variable "allowed_ip" {
  description = "The IP address allowed to access the resources"
  type        = string
}