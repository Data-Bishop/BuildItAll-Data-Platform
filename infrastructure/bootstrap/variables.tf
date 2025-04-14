variable "aws_region" {
  description = "AWS region for resources"
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for tagging"
  default     = "BuildItAll"
}

variable "tfstate_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  default     = "builditall-tfstate"
}
