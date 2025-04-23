#!/bin/bash

cd /home/ec2-user/airflow

# Download the Docker Compose file from S3
aws s3 cp s3://builditall-airflow/docker-compose.yml /home/ec2-user/airflow/docker-compose.yml

# Download the Docker Compose file from S3
aws s3 cp s3://builditall-airflow/Dockerfile /home/ec2-user/airflow/Dockerfile

# Set the Airflow UID
echo -e "AIRFLOW_UID=$(id -u)" > .env

# Build the cutom image
docker build -t custom-airflow:latest .

# Start Airflow using Docker Compose
/usr/local/bin/docker-compose up airflow-init

/usr/local/bin/docker-compose up -d