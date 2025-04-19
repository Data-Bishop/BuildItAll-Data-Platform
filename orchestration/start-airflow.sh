#!/bin/bash

cd /home/ec2-user/airflow

# Download the Docker Compose file from S3
aws s3 cp s3://builditall-airflow/docker-compose.yml /home/ec2-user/airflow/docker-compose.yml

# Start Airflow using Docker Compose
/usr/local/bin/docker-compose up -d