from datetime import datetime

from airflow import DAG
from airflow.providers.amazon.aws.operators.emr import (
    EmrAddStepsOperator, EmrCreateJobFlowOperator, EmrTerminateJobFlowOperator)
from airflow.providers.amazon.aws.sensors.emr import (EmrJobFlowSensor,
                                                      EmrStepSensor)
from config.config import configs
from notification.email_alert import task_fail_alert, task_success_alert

default_args = {
    'owner': 'builditall',
    'depends_on_past': False,
    'environment': 'PROD',
    'on_failure_callback': task_fail_alert,
    'on_success_callback': task_success_alert,
    'retries': 2,
}

JOB_FLOW_OVERRIDES = {
    "Name": "BuildItAll-Data-Processing",
    "ReleaseLabel": "emr-6.9.0",
    "Applications": [{"Name": "Spark"}],
    "Instances": {
        "InstanceGroups": [
            {
                "Name": "Master",
                "Market": "ON_DEMAND",
                "InstanceRole": "MASTER",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 1,
            },
            {
                "Name": "Core",
                "Market": "SPOT",
                "InstanceRole": "CORE",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 1,
            },
        ],
        "KeepJobFlowAliveWhenNoSteps": True,
        "TerminationProtected": False,
        "Ec2SubnetId": configs["emr_subnet_id"],
        "EmrManagedMasterSecurityGroup": configs["emr_master_security_group_id"],
        "EmrManagedSlaveSecurityGroup": configs["emr_slave_security_group_id"],
    },
    "JobFlowRole": "BuildItAll-EMR-EC2-Profile",
    "ServiceRole": "EMR_DefaultRole",
    "LogUri": "s3://builditall-logs/emr/",
}

with DAG(
    "data_processing",
    default_args=default_args,
    description="Process synthetic data daily at 6 PM",
    schedule_interval="0 18 * * *",
    start_date=datetime(2025, 4, 22),
    catchup=False,
) as dag:

    create_cluster = EmrCreateJobFlowOperator(
        task_id="create_emr_cluster",
        job_flow_overrides=JOB_FLOW_OVERRIDES,
    )

    wait_for_cluster = EmrJobFlowSensor(
        task_id="wait_for_cluster",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
        target_states=["WAITING"],
        poke_interval=30,
        timeout=1800,
    )

    process_step = EmrAddStepsOperator(
        task_id="process_data",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
        steps=[
            {
                "Name": "Process Synthetic Data",
                "ActionOnFailure": "TERMINATE_CLUSTER",
                "HadoopJarStep": {
                    "Jar": "command-runner.jar",
                    "Args": [
                        "spark-submit",
                        "--deploy-mode",
                        "cluster",
                        "s3://builditall-client-data/scripts/data_processor.py",
                        "--input-path",
                        "s3://builditall-client-data/raw/{{ ts[:10] }}/",
                        "--output-path",
                        "s3://builditall-client-data/processed/{{ ts[:10] }}/",
                    ],
                },
            }
        ],
    )

    monitor_process = EmrStepSensor(
        task_id="monitor_process_data",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_ids='process_data', key='return_value')[0] }}",
    )

    terminate_cluster = EmrTerminateJobFlowOperator(
        task_id="terminate_emr_cluster",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
    )

    (
        create_cluster
        >> wait_for_cluster
        >> process_step
        >> monitor_process
        >> terminate_cluster
    )
