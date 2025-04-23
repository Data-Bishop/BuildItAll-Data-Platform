output "emr_default_role_arn" {
  description = "ARN of the EMR Default Role"
  value       = aws_iam_role.emr_default_role.arn
}

output "emr_ec2_default_role_arn" {
  description = "ARN of the EMR EC2 Default Role"
  value       = aws_iam_role.emr_ec2_default_role.arn
}

output "emr_ec2_profile_name" {
  description = "Name of the EMR EC2 instance profile"
  value       = aws_iam_instance_profile.emr_ec2_profile.name
}

output "emr_master_sg_id" {
  description = "ID of the EMR Master Security Group"
  value       = aws_security_group.emr_master.id
}

output "emr_slave_sg_id" {
  description = "ID of the EMR Slave Security Group"
  value       = aws_security_group.emr_slave.id
}