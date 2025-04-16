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