# **Spark Jobs Documentation**

## **1. Purpose**
Spark jobs are used for data generation and processing. They run on Amazon EMR clusters and interact with S3 for input and output data.

---

## **2. Spark Jobs**
### **2.1 Data Generator**
- **Script**: `data_generator.py`
- **Purpose**: Generates synthetic data and saves it to the `raw/` folder in the S3 bucket.
- **Inputs**:
  - Configuration parameters (e.g., number of records, schema).
- **Outputs**:
  - Synthetic data in CSV or Parquet format.
- **Execution**:
  - Submitted to the EMR cluster by the `data_generation_dag.py` DAG.

### **2.2 Data Processor**
- **Script**: `data_processor.py`
- **Purpose**: Processes raw data into structured formats and saves it to the `processed/` folder in the S3 bucket.
- **Inputs**:
  - Raw data from the `raw/` folder in the S3 bucket.
- **Outputs**:
  - Processed data in Parquet or other structured formats.
- **Execution**:
  - Submitted to the EMR cluster by the `data_processing_dag.py` DAG.

---

## **3. Configuration**
- **Dependencies**:
  - Python dependencies for Spark jobs are listed in `spark_jobs/requirements.txt`.
- **Bootstrap Script**:
  - `bootstrap.sh` installs required dependencies on EMR nodes.

---

## **4. Workflow**
### **4.1 Data Generation**
1. The `data_generator.py` script is submitted to the EMR cluster.
2. The script generates synthetic data and saves it to the `raw/` folder in the S3 bucket.

### **4.2 Data Processing**
1. The `data_processor.py` script is submitted to the EMR cluster.
2. The script processes raw data and saves it to the `processed/` folder in the S3 bucket.

---

## **5. Logs**
- **Location**:
  - Spark job logs are stored in the `builditall-logs/emr/` folder in the S3 bucket.
- **Access**:
  - Logs can be accessed via the EMR console or directly from the S3 bucket.

---