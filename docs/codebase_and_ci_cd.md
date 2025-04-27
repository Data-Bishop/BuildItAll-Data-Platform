# **Codebase Documentation**

## **1. Repository Structure**
The repository is organized into directories and files that represent the different components of the **BuildItAll Data Platform**. Below is an overview of the structure:
```graphql
BuildItAll_Data_Platform/
├── .github/
│   └── workflows/                # GitHub Actions workflows for CI/CD
│       ├── ci.yml                # Continuous Integration workflow
│       ├── cd.yml                # Continuous Deployment workflow
├── docs/                         # Documentation file
├── infrastructure/               # Terraform configuration for AWS resources
│   ├── bootstrap/                # Bootstrap resources for Terraform backend
│   │   ├── main.tf               # S3 bucket and DynamoDB table for state storage
│   │   ├── provider.tf           # AWS provider configuration
│   │   ├── variables.tf          # Input variables for bootstrap
│   │   ├── outputs.tf            # Outputs for bootstrap resources
│   │   ├── terraform.tfvars      # Default variable values for bootstrap
│   ├── modules/                  # Terraform modules for reusable components
│   │   ├── vpc/                  # VPC module
│   │   ├── s3/                   # S3 buckets module
│   │   ├── emr/                  # EMR cluster IAM roles and security groups
│   │   ├── airflow_ec2/          # Airflow EC2 instance module
│   │   ├── bastion/              # Bastion host module
│   ├── main.tf                   # Root module for Terraform
│   ├── provider.tf               # AWS provider configuration
│   ├── variables.tf              # Input variables for Terraform
│   ├── outputs.tf                # Outputs for Terraform resources
├── orchestration/                # Airflow orchestration setup
│   ├── dags/                     # Airflow DAGs
│   │   ├── data_generation_dag.py # DAG for data generation
│   │   ├── data_processing_dag.py # DAG for data processing
│   │   ├── notification/         # Notification scripts
│   │   │   └── email_alert.py    # Email notifications for task success/failure
│   │   ├── config/               # Configuration files
│   │   │   └── config.py         # Airflow configuration variables
│   ├── setup.sh                  # Script to set up Airflow dependencies
│   ├── start-airflow.sh          # Script to start Airflow services
│   ├── requirements.txt          # Python dependencies for Airflow
│   ├── docker-compose.yml        # Docker Compose configuration for Airflow
│   ├── Dockerfile                # Custom Dockerfile for Airflow
├── spark_jobs/                   # Spark job scripts
│   ├── data_generator.py         # Spark job for synthetic data generation
│   ├── data_processor.py         # Spark job for data processing
│   ├── requirements.txt          # Python dependencies for Spark jobs
│   ├── bootstrap.sh              # Bootstrap script for EMR cluster
├── .gitignore                    # Git ignore rules
```
---

## **2. CI/CD**

### **2.1 Continuous Integration (CI)**
The CI pipeline ensures code quality and validates Terraform configurations. It is defined in `.github/workflows/ci.yml`.

#### **CI Workflow Steps**
1. **Terraform Validation**:
   - Validates the Terraform configuration files.
   - Ensures proper formatting using `terraform fmt`.
   - Runs `terraform validate` to check for syntax errors.
2. **Python Linting**:
   - Uses `isort` to check import sorting in Python files.
   - Uses `flake8` to enforce Python code style and linting rules.

#### **Trigger**:
- Runs on every pull request to the `dev` or `main` branches.

---

### **2.2 Continuous Deployment (CD)**
The CD pipeline automates the deployment of Terraform infrastructure and uploads necessary files to S3. It is defined in `.github/workflows/cd.yml`.

#### **CD Workflow Steps**
1. **Terraform Deployment**:
   - Initializes the Terraform backend.
   - Runs `terraform plan` to generate an execution plan.
   - Applies the Terraform configuration to provision or update AWS resources.
2. **File Upload to S3**:
   - Uploads Airflow setup scripts, DAGs, and Spark job scripts to the appropriate S3 buckets.

#### **Trigger**:
- Runs on every push to the `main` branch.

---