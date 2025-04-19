#!/bin/bash

# Update and install dependencies
yum update -y
yum install -y docker

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add ec2-user to the Docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create directories for Airflow
mkdir -p /home/ec2-user/airflow/dags /home/ec2-user/airflow/logs /home/ec2-user/airflow/plugins /home/ec2-user/airflow/config

# Sync DAGs from S3 if they exist
if aws s3 ls s3://builditall-airflow/dags/ >/dev/null 2>&1; then
  aws s3 sync s3://builditall-airflow/dags/ /home/ec2-user/airflow/dags/
fi

# Copy requirements.txt from S3 if it exists
if aws s3 ls s3://builditall-airflow/requirements/requirements.txt >/dev/null 2>&1; then
  aws s3 cp s3://builditall-airflow/requirements/requirements.txt /home/ec2-user/airflow/requirements.txt
fi

# # Set permissions
# chown -R ec2-user:ec2-user /home/ec2-user/airflow