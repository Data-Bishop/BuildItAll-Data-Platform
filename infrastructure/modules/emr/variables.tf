variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EC2"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}