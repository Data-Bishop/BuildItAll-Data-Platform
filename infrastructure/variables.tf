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
  default = local.secrets["aws_region"]
}

variable "project_name" {
  default = local.secrets["project_name"]
}

variable "aws_account_id" {
  default = local.secrets["aws_account_id"]
}

variable "data_bucket_name" {
  default = local.secrets["data_bucket_name"]
}

variable "airflow_bucket_name" {
  default = local.secrets["airflow_bucket_name"]
}

variable "logs_bucket_name" {
  default = local.secrets["logs_bucket_name"]
}

variable "ami_id" {
  default = local.secrets["ami_id"]
}

variable "vpc_cidr" {
  default = local.secrets["vpc_cidr"]
}

variable "key_pair_name" {
  default = local.secrets["key_pair_name"]
}

variable "allowed_ip" {
  default = local.secrets["allowed_ip"]
}