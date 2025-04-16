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