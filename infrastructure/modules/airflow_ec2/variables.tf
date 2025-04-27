variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  
}

variable "vpc_id" {
  description = "VPC ID for EC2"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
}