variable "project_name" {
  description = "Project name for tagging"
  default     = "BuildItAll"
}

variable "vpc_id" {
  description = "VPC ID for bastion"
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for bastion"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for bastion"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "key_pair_name" {
  description = "SSH key pair name"
}

variable "allowed_ip" {
  description = "IP range for SSH access"
  default     = "0.0.0.0/0"
}