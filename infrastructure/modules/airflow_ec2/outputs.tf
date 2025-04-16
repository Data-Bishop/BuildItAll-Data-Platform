output "airflow_role_arn" {
  description = "ARN of the Airflow IAM role"
  value       = aws_iam_role.airflow_role.arn
}

output "airflow_private_ip" {
  description = "Private IP of the Airflow EC2 instance"
  value       = aws_instance.airflow.private_ip
}