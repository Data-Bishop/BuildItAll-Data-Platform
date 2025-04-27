variable "project_name" {
  description = "Project name for tagging"
  type        = string  
}

variable "vpc_id" {
  description = "VPC ID for bastion"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for bastion"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for bastion"
  type        = string
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
}

variable "allowed_ip" {
  description = "IP range for SSH access"
  type        = string
}