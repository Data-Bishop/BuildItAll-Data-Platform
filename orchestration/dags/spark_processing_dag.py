from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.emr import (
    EmrCreateJobFlowOperator, 
    EmrAddStepsOperator,
    EmrTerminateJobFlowOperator
)
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor
from airflow.models import Variable

# Configuration from Airflow Variables
CLIENT_BUCKET = Variable.get("client_bucket", "builditall-client-data")
SCRIPTS_BUCKET = Variable.get("scripts_bucket", "builditall-airflow-scripts")
LOG_BUCKET = Variable.get("log_bucket", "builditall-logs")

default_args = {
    'owner': 'builditall',
    'depends_on_past': False,
    'email_on_failure': True,
    'email_on_retry': True,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'tags': ['production', 'client-data']
}

JOB_FLOW_OVERRIDES = {
    "Name": "BuildItAll-Spark-Processing",
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
                "InstanceType": "r5.2xlarge",
                "InstanceCount": 4,
                "EbsConfiguration": {
                    "EbsBlockDeviceConfigs": [{
                        "VolumeSpecification": {
                            "SizeGB": 32,
                            "VolumeType": "gp3"
                        },
                        "VolumesPerInstance": 2
                    }]
                }
            }
        ],
        "KeepJobFlowAliveWhenNoSteps": False,
        "TerminationProtected": False,
    },
    "BootstrapActions": [
        {
            "Name": "InstallDependencies",
            "ScriptBootstrapAction": {
                "Path": f"s3://{SCRIPTS_BUCKET}/bootstrap.sh",
            }
        }
    ],
    "JobFlowRole": "EMR_EC2_DefaultRole",
    "ServiceRole": "EMR_DefaultRole",
    "LogUri": f"s3://{LOG_BUCKET}/emr-logs/",
    "Configurations": [
        {
            "Classification": "spark-defaults",
            "Properties": {
                "spark.dynamicAllocation.enabled": "true",
                "spark.shuffle.service.enabled": "true",
                "spark.sql.adaptive.enabled": "true"
            }
        }
    ]
}

with DAG(
    'client_data_processing',
    default_args=default_args,
    description='Production data processing pipeline with version control',
    schedule_interval='@daily',
    start_date=datetime(2025, 4, 23),
    catchup=False,
    max_active_runs=1,
    params={
        "script_name": "data_processor.py",
        "input_path": "raw/",
        "output_path": "processed/"
    }
) as dag:

    create_cluster = EmrCreateJobFlowOperator(
        task_id='create_emr_cluster',
        job_flow_overrides=JOB_FLOW_OVERRIDES,
        aws_conn_id='aws_default'
    )

    processing_steps = [
        {
            "Name": "DataValidation",
            "ActionOnFailure": "TERMINATE_CLUSTER",
            "HadoopJarStep": {
                "Jar": "command-runner.jar",
                "Args": [
                    "spark-submit",
                    "--deploy-mode", "cluster",
                    "--conf", "spark.sql.shuffle.partitions=200",
                    "--conf", "spark.executor.memoryOverhead=2g",
                    f"s3://{SCRIPTS_BUCKET}/scripts/data_validator.py",
                    "--input-path", f"s3://{CLIENT_BUCKET}/{{{{ params.input_path }}}}",
                    "--rules-path", f"s3://{SCRIPTS_BUCKET}/validation_rules.yaml"
                ]
            }
        },
        {
            "Name": "DataProcessing",
            "ActionOnFailure": "TERMINATE_CLUSTER",
            "HadoopJarStep": {
                "Jar": "command-runner.jar",
                "Args": [
                    "spark-submit",
                    "--deploy-mode", "cluster",
                    "--conf", "spark.sql.shuffle.partitions=200",
                    "--conf", "spark.executor.instances=10",
                    "--conf", "spark.dynamicAllocation.enabled=true",
                    f"s3://{SCRIPTS_BUCKET}/scripts/{{{{ params.script_name }}}}",
                    "--input-path", f"s3://{CLIENT_BUCKET}/{{{{ params.input_path }}}}",
                    "--output-path", f"s3://{CLIENT_BUCKET}/{{{{ params.output_path }}}}/{{{{ ds_nodash }}}}"
                ]
            }
        }
    ]

    add_steps = EmrAddStepsOperator(
        task_id='add_processing_steps',
        job_flow_id="{{ task_instance.xcom_pull(task_id='create_emr_cluster', key='return_value') }}",
        steps=processing_steps,
        aws_conn_id='aws_default'
    )

    monitor_steps = EmrStepSensor(
        task_id='monitor_processing_steps',
        job_flow_id="{{ task_instance.xcom_pull(task_id='create_emr_cluster', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_id='add_processing_steps', key='return_value')[1] }}",
        aws_conn_id='aws_default',
        timeout=3600,
        poke_interval=30
    )

    terminate_cluster = EmrTerminateJobFlowOperator(
        task_id='terminate_emr_cluster',
        job_flow_id="{{ task_instance.xcom_pull(task_id='create_emr_cluster', key='return_value') }}",
        aws_conn_id='aws_default',
        trigger_rule='all_done'
    )

    create_cluster >> add_steps >> monitor_steps >> terminate_cluster