# Use the official Airflow 2.10.5 image
FROM apache/airflow:2.10.5

# Switch to airflow user (uid=50000)
USER airflow

# Copy requirements.txt
COPY requirements.txt /requirements.txt

# Install dependencies as airflow user
RUN pip install --no-cache-dir -r /requirements.txt