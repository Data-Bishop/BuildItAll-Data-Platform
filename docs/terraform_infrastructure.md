# **Terraform Infrastructure Documentation**

## **1. Purpose**
The Terraform infrastructure is designed to provision and manage the resources required for the **BuildItAll Data Platform**. It automates the creation of compute, storage, networking, and orchestration components in AWS, ensuring consistency, scalability, and security.

---

## **2. Modules**
The infrastructure is modularized to promote reusability and maintainability. Each module is responsible for provisioning a specific set of resources.

### **2.1 VPC Module**
- **Purpose**: Creates a Virtual Private Cloud (VPC) with public and private subnets, routing, and endpoints.
- **Resources**:
  - VPC
  - Public and private subnets
  - Internet Gateway
  - NAT Gateway
  - Route tables and associations
  - S3 VPC Endpoint
- **Inputs**:
  - `project_name`: Name for tagging resources.
  - `vpc_cidr`: CIDR block for the VPC.
- **Outputs**:
  - `vpc_id`: ID of the created VPC.
  - `public_subnet_ids`: List of public subnet IDs.
  - `private_subnet_ids`: List of private subnet IDs.

---

### **2.2 S3 Module**
- **Purpose**: Creates S3 buckets for storing raw data, processed data, orchestration files, and logs.
- **Resources**:
  - S3 buckets:
    - `builditall-client-data`
    - `builditall-airflow`
    - `builditall-logs`
  - Bucket policies for access control.
- **Inputs**:
  - `project_name`: Name for tagging resources.
  - `data_bucket_name`: Name of the data bucket.
  - `airflow_bucket_name`: Name of the Airflow bucket.
  - `logs_bucket_name`: Name of the logs bucket.
  - `aws_account_id`: AWS account ID.
  - `airflow_role_arn`: ARN of the Airflow IAM role.
  - `emr_default_role_arn`: ARN of the EMR Default Role.
- **Outputs**:
  - ARNs and names of the created buckets.

---

### **2.3 EMR Module**
- **Purpose**: Provisions IAM roles and security groups required for Amazon EMR clusters.
- **Resources**:
  - IAM roles and policies:
    - `EMR_DefaultRole`
    - `EMR_EC2_DefaultRole`
  - Security groups for EMR master and slave nodes.
- **Inputs**:
  - `project_name`: Name for tagging resources.
  - `vpc_id`: ID of the VPC.
  - `vpc_cidr`: CIDR block for the VPC.
- **Outputs**:
  - ARNs of the EMR roles.
  - Security group IDs for EMR master and slave nodes.

---

### **2.4 Airflow EC2 Module**
- **Purpose**: Provisions an EC2 instance for running Apache Airflow.
- **Resources**:
  - EC2 instance with Docker Compose setup.
  - IAM role and instance profile for Airflow.
  - Security group for Airflow.
- **Inputs**:
  - `project_name`: Name for tagging resources.
  - `aws_account_id`: AWS account ID.
  - `aws_region`: AWS region.
  - `vpc_id`: ID of the VPC.
  - `private_subnet_ids`: List of private subnet IDs.
  - `ami_id`: AMI ID for the EC2 instance.
  - `key_pair_name`: SSH key pair name.
  - `vpc_cidr`: CIDR block for the VPC.
- **Outputs**:
  - ARN of the Airflow IAM role.
  - Private IP of the Airflow EC2 instance.

---

### **2.5 Bastion Module**
- **Purpose**: Provisions a bastion host for secure access to private resources.
- **Resources**:
  - EC2 instance for the bastion host.
  - IAM role and instance profile for SSM access.
  - Security group for SSH access.
- **Inputs**:
  - `project_name`: Name for tagging resources.
  - `vpc_id`: ID of the VPC.
  - `public_subnet_ids`: List of public subnet IDs.
  - `ami_id`: AMI ID for the EC2 instance.
  - `key_pair_name`: SSH key pair name.
  - `allowed_ip`: CIDR block for allowed SSH access.
- **Outputs**:
  - Public IP of the bastion host.

---

#### **2.6 Backend Module**
The Terraform state is stored remotely in an S3 bucket to enable collaboration and state locking.
- **Purpose**: Configures the remote backend for Terraform state storage.
- **Resources**:
  - S3 bucket (`builditall-tfstate`) for storing the Terraform state file.
  - DynamoDB table (`builditall-tfstate-lock`) for state locking and consistency.

---

## **3. Deployment**
Terraform is deployed using the **GitHub CD pipeline**. The pipeline automates the following steps:
1. **Terraform Initialization**:
   - Initializes the Terraform backend and downloads required providers.
2. **Terraform Plan**:
   - Generates an execution plan to show the changes Terraform will make.
3. **Terraform Apply**:
   - Applies the changes to provision or update the infrastructure.

The pipeline ensures consistent and automated deployments, reducing the risk of manual errors.

---