variable "project_name" {
  description = "Project name for tagging"
  default     = "BuildItAll"
}

variable "vpc_id" {
  description = "VPC ID for EC2"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}