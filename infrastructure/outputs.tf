output "data_bucket_arn" {
  value = module.s3.data_bucket_arn
}

output "airflow_bucket_arn" {
  value = module.s3.airflow_bucket_arn
}

output "logs_bucket_arn" {
  value = module.s3.logs_bucket_arn
}

output "airflow_private_ip" {
  description = "Private IP of the Airflow EC2 instance"
  value       = module.airflow_ec2.airflow_private_ip
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "emr_master_sg_id" {
  description = "ID of the EMR Master Security Group"
  value       = module.emr.emr_master_sg_id
}

output "emr_slave_sg_id" {
  description = "ID of the EMR Slave Security Group"
  value       = module.emr.emr_slave_sg_id
}