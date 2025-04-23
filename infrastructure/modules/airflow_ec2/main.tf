resource "aws_iam_role" "airflow_role" {
  name = "Airflow_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name        = "${var.project_name}-Airflow-Role"
    Environment = "Prod"
  }  
}

resource "aws_iam_role_policy" "airflow_policy" {
  name = "${var.project_name}-Airflow-Policy"
  role = aws_iam_role.airflow_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::builditall-airflow",
          "arn:aws:s3:::builditall-airflow/*",
          "arn:aws:s3:::builditall-client-data",
          "arn:aws:s3:::builditall-client-data/*",
          "arn:aws:s3:::builditall-logs",
          "arn:aws:s3:::builditall-logs/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticmapreduce:RunJobFlow",
          "elasticmapreduce:TerminateJobFlows",
          "elasticmapreduce:AddJobFlowSteps",
          "elasticmapreduce:DescribeStep",
          "elasticmapreduce:DescribeCluster",
          "elasticmapreduce:ListSteps",
          "elasticmapreduce:ListClusters"
        ]
        Resource = [
          "arn:aws:elasticmapreduce:eu-west-1:905418032356:cluster/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::905418032356:role/EMR_DefaultRole",
          "arn:aws:iam::905418032356:role/EMR_EC2_DefaultRole"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:StartSession"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "airflow_profile" {
  name = "${var.project_name}-Airflow-Profile"
  role = aws_iam_role.airflow_role.name
}

resource "aws_security_group" "airflow_sg" {
  name        = "${var.project_name}-Airflow-SG"
  description = "Security group for Airflow EC2"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-Airflow-SG"
  }
}

resource "aws_instance" "airflow" {
  ami                    = var.ami_id
  instance_type          = "t3.large"
  iam_instance_profile   = aws_iam_instance_profile.airflow_profile.name
  vpc_security_group_ids = [aws_security_group.airflow_sg.id]
  subnet_id              = var.private_subnet_ids[0]
  key_name               = var.key_pair_name
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  user_data = <<-EOF
              #!/bin/bash
              # Download setup script from S3
              aws s3 cp s3://builditall-airflow/setup.sh /home/ec2-user/setup.sh
              chmod +x /home/ec2-user/setup.sh
              /home/ec2-user/setup.sh

              # Download and execute the start script
              aws s3 cp s3://builditall-airflow/start-airflow.sh /home/ec2-user/start-airflow.sh
              chmod +x /home/ec2-user/start-airflow.sh
              /home/ec2-user/start-airflow.sh
              EOF
  tags = {
    Name        = "${var.project_name}-Airflow"
    Environment = "Prod"
  }
}

resource "aws_ssm_parameter" "airflow_url" {
  name  = "/${var.project_name}/airflow_url"
  type  = "String"
  value = "http://${aws_instance.airflow.private_ip}:8080"
}