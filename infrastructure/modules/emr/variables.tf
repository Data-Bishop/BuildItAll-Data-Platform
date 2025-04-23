variable "project_name" {
  description = "Project name for tagging"
  default     = "BuildItAll"
}

variable "vpc_id" {
  description = "VPC ID for EC2"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}