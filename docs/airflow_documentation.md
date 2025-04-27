# **Airflow Documentation**

## **1. Purpose**
Apache Airflow is used to orchestrate workflows for data generation and processing. It schedules and monitors tasks, ensuring that workflows are executed in the correct order and at the right time.

---

## **2. Components**
### **2.1 Airflow Deployment**
- **Deployment**: Airflow is deployed on an EC2 instance using Docker Compose.
- **Services**:
  - **Webserver**: Provides the Airflow UI, accessible on port `8080`.
  - **Scheduler**: Manages the execution of tasks in the DAGs.
  - **Worker**: Executes tasks in parallel using Celery.
  - **Postgres**: Stores metadata for Airflow.
  - **Redis**: Acts as the Celery broker for task distribution.

### **2.2 DAGs**
- **Location**: DAGs are stored in the `orchestration/dags/` directory.
- **Key DAGs**:
  - `data_generation_dag.py`: Generates synthetic data using Spark on EMR.
  - `data_processing_dag.py`: Processes raw data into structured formats using Spark on EMR.

### **2.3 Configuration**
- **Docker Compose**:
  - The `docker-compose.yml` file defines the services and their dependencies.
- **Dependencies**:
  - Python dependencies are listed in `requirements.txt`.
  - Custom configurations are stored in `config/config.py`.

---

## **3. Workflow**
### **3.1 Data Generation DAG**
- **Trigger**: Runs daily at `9:00 AM`.
- **Steps**:
  1. Creates an EMR cluster.
  2. Submits the `data_generator.py` Spark job to generate synthetic data.
  3. Saves the generated data to the `raw/` folder in the S3 bucket.
  4. Terminates the EMR cluster.

### **3.2 Data Processing DAG**
- **Trigger**: Runs daily at `6:00 PM`.
- **Steps**:
  1. Creates an EMR cluster.
  2. Submits the `data_processor.py` Spark job to process raw data into structured formats.
  3. Saves the processed data to the `processed/` folder in the S3 bucket.
  4. Terminates the EMR cluster.

---

## **4. Access**
### **4.1 Airflow UI**
- **Access Method**:
  - Use SSH port forwarding or AWS SSM to access the Airflow UI.
  - Navigate to `http://localhost:8080` in your browser.

### **4.2 Logs**
- **Location**:
  - Airflow logs are stored in the `builditall-logs/airflow/` folder in the S3 bucket.

---