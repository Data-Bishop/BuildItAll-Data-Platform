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
          "arn:aws:elasticmapreduce:${var.aws_region}:${var.aws_account_id}:cluster/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/EMR_DefaultRole",
          "arn:aws:iam::${var.aws_account_id}:role/EMR_EC2_DefaultRole"
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

              # Create a systemd service to sync files from S3
              cat <<EOT > /etc/systemd/system/s3-sync.service
              [Unit]
              Description=Sync Airflow files from S3
              After=network.target

              [Service]
              Type=simple
              ExecStart=/usr/bin/aws s3 sync s3://builditall-airflow/dags/ /home/ec2-user/airflow/dags/
              ExecStartPost=/usr/bin/aws s3 cp s3://builditall-airflow/requirements/requirements.txt /home/ec2-user/airflow/requirements.txt
              ExecStartPost=/usr/bin/aws s3 cp s3://builditall-airflow/docker-compose.yml /home/ec2-user/airflow/docker-compose.yml
              ExecStartPost=/usr/bin/aws s3 cp s3://builditall-airflow/Dockerfile /home/ec2-user/airflow/Dockerfile

              Restart=always
              RestartSec=300  # Restart every 5 minutes

              [Install]
              WantedBy=multi-user.target
              EOT

              # Reload systemd to recognize the new service
              systemctl daemon-reload

              # Enable and start the service
              systemctl enable s3-sync.service
              systemctl start s3-sync.service           
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