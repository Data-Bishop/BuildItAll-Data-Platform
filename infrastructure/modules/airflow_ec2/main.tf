resource "aws_iam_role" "airflow_role" {
  name = "${var.project_name}-Airflow-Role"
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
          "arn:aws:s3:::builditall-airflow/dags/*",
          "arn:aws:s3:::builditall-airflow/requirements/*",
          "arn:aws:s3:::builditall-airflow/logs/*",
          "arn:aws:s3:::builditall-client-data/scripts/*",
          "arn:aws:s3:::builditall-client-data/raw/*",
          "arn:aws:s3:::builditall-client-data/processed/*",
          "arn:aws:s3:::builditall-logs/airflow/*",
          "arn:aws:s3:::builditall-logs/emr/*",
          "arn:aws:s3:::builditall-airflow",
          "arn:aws:s3:::builditall-client-data",
          "arn:aws:s3:::builditall-logs"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "emr:RunJobFlow",
          "emr:TerminateJobFlows",
          "emr:AddJobFlowSteps",
          "emr:DescribeStep",
          "emr:DescribeCluster"
        ]
        Resource = "*"
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
    cidr_blocks = [var.vpc_cidr]  # VPC CIDR for bastion access
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSM
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "airflow" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.airflow_profile.name
  security_groups        = [aws_security_group.airflow_sg.name]
  subnet_id              = var.private_subnet_ids[0]
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              mkdir -p /home/ec2-user/airflow
              cat <<'DOCKERCOMPOSE' > /home/ec2-user/airflow/docker-compose.yml
              version: '3'
              services:
                airflow:
                  image: apache/airflow:2.6.3
                  ports:
                    - "8080:8080"
                  environment:
                    - AIRFLOW__CORE__EXECUTOR=LocalExecutor
                    - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:////airflow/airflow.db
                    - AIRFLOW__CORE__LOAD_EXAMPLES=false
                    - AWS_DEFAULT_REGION=eu-west-1
                  volumes:
                    - /home/ec2-user/airflow/dags:/opt/airflow/dags
                    - /home/ec2-user/airflow/logs:/opt/airflow/logs
                    - /home/ec2-user/airflow/airflow.db:/airflow/airflow.db
                  command: >
                    bash -c "
                      pip install apache-airflow-providers-amazon==6.0.0 &&
                      airflow db init &&
                      airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@example.com &&
                      airflow scheduler & airflow webserver
                    "
              DOCKERCOMPOSE
              mkdir -p /home/ec2-user/airflow/dags /home/ec2-user/airflow/logs
              aws s3 sync s3://builditall-airflow/dags/ /home/ec2-user/airflow/dags/
              aws s3 cp s3://builditall-airflow/requirements/requirements.txt /home/ec2-user/airflow/requirements.txt
              chown -R ec2-user:ec2-user /home/ec2-user/airflow
              cd /home/ec2-user/airflow
              /usr/local/bin/docker-compose up -d
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