# **Onboarding Guide**## **1. Prerequisites**
Before you begin, ensure you have the following installed and configured on your local machine:

### **1.1 Tools**
- **AWS CLI**:
  - Install the AWS CLI: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
  - Configure the AWS CLI with your credentials:
    ```bash
    aws configure
    ```
- **Terraform**:
  - Install Terraform (version `1.5.0` or later): [Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### **1.2 AWS Access**
- Ensure you have access to the AWS account where the infrastructure will be deployed.
- Create the `builditall-secrets` in AWS Secrets Manager.

---

## **2. Repository Setup**

### **2.1 Clone the Repository**
Clone the repository to your local machine:
```bash
git clone https://github.com/<your-org>/BuildItAll_Data_Platform.git
cd BuildItAll_Data_Platform
```

##**2.2 Install Python Dependencies**
Navigate to the `orchestration` directory and install the required Python packages:
```bash
cd orchestration
pip install -r requirements.txt
```

---

## **3. Infrastructure Deployment**

### **3.1 Bootstrap the Terraform Backend**
The Terraform backend must be set up before deploying the infrastructure. This includes creating the S3 bucket and DynamoDB table for state storage.

1. Navigate to the `infrastructure/bootstrap` directory:
   ```bash
   cd infrastructure/bootstrap
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the configuration:
   ```bash
   terraform apply
   ```

### **3.2 Deploy the Infrastructure**
1. Navigate to the root `infrastructure` directory:
   ```bash
   cd ../
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the deployment:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

---

## **4. Airflow Setup**

### **4.1 Start Airflow Locally**
1. Navigate to the `orchestration` directory:
   ```bash
   cd orchestration
   ```
2. Start Airflow using Docker Compose:
   ```bash
   docekr build -t custom-airflow:latest .
   docker-compose up airflow-init
   docker-compose up
   ```
3. Access the Airflow UI:
   - Open your browser and navigate to `http://localhost:8080`.
   - Use the default credentials:
     - **Username**: `airflow`
     - **Password**: `airflow`

---

## **5. Spark Jobs**

### **5.1 Running Spark Jobs**
1. Spark jobs are located in the `spark_jobs` directory.
2. Submit a Spark job to the EMR cluster using the Airflow DAGs:
   - `data_generation_dag.py`: Submits the `data_generator.py` job.
   - `data_processing_dag.py`: Submits the `data_processor.py` job.

---

## **6. CI/CD Pipelines**

### **6.1 Continuous Integration (CI)**
- The CI pipeline validates Terraform configurations and Python code.
- **Trigger**: Runs on pull requests to the `dev` or `main` branches.

### **6.2 Continuous Deployment (CD)**
- The CD pipeline deploys the Terraform infrastructure and uploads DAGs and scripts to S3.
- **Trigger**: Runs on pushes to the `main` branch.

---

## **7. Accessing Resources**

### **7.1 Bastion Host**
Use AWS SSM to connect to the bastion host:
```bash
aws ssm start-session --target <bastion-instance-id>
```

### **7.2 Airflow UI**
Use SSH port forwarding or SSM to access the Airflow UI:
```bash
ssh -i /path/to/private-key.pem -L 8080:<airflow-private-ip>:8080 ec2-user@<bastion-public-ip>
```
Navigate to `http://localhost:8080` in your browser.

---

## **8. Troubleshooting**

### **8.1 Terraform Issues**
- **State Locking**:
  - If you encounter a state lock issue, unlock it using:
    ```bash
    terraform force-unlock <lock-id>
    ```

### **8.2 Airflow Issues**
- **Webserver Not Starting**:
  - Check the logs:
    ```bash
    docker-compose logs webserver
    ```

### **8.3 Spark Job Failures**
- Check the EMR logs in the `builditall-logs/emr/` S3 bucket.

---

## **9. Additional Resources**
- [AWS Documentation](https://aws.amazon.com/documentation/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)

---