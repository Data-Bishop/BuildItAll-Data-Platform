# modules/airflow_ec2/outputs.tf
output "airflow_role_arn" {
  description = "ARN of the Airflow IAM role"
  value       = aws_iam_role.airflow_role.arn
}