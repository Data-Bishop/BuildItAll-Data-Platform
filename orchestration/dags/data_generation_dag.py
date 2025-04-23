from datetime import datetime
from airflow import DAG
from airflow.providers.amazon.aws.operators.emr import EmrCreateJobFlowOperator, EmrAddStepsOperator, EmrTerminateJobFlowOperator
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor

default_args = {
    'owner': 'builditall',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
}

JOB_FLOW_OVERRIDES = {
    "Name": "BuildItAll-Data-Generation",
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
                "Market": "ON_DEMAND",
                "InstanceRole": "CORE",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 2,
            }
        ],
        "KeepJobFlowAliveWhenNoSteps": True,
        "TerminationProtected": False,
    },
    "BootstrapActions": [
        {
            "Name": "InstallDependencies",
            "ScriptBootstrapAction": {
                "Path": "s3://builditall-client-data/scripts/bootstrap.sh",
            }
        }
    ],
    "JobFlowRole": "EMR_EC2_DefaultRole",
    "ServiceRole": "EMR_DefaultRole",
    "LogUri": "s3://builditall-logs/emr/",
}

with DAG(
    'data_generation',
    default_args=default_args,
    description='Generate synthetic data daily at 9 AM',
    schedule_interval='0 9 * * *',
    start_date=datetime(2025, 4, 22),
    catchup=False,
) as dag:

    create_cluster = EmrCreateJobFlowOperator(
        task_id='create_emr_cluster',
        job_flow_overrides=JOB_FLOW_OVERRIDES,
    )

    generate_step = EmrAddStepsOperator(
        task_id='generate_data',
        job_flow_id="{{ task_instance.xcom_pull(task_id='create_emr_cluster', key='return_value') }}",
        steps=[
            {
                "Name": "Copy Requirements",
                "ActionOnFailure": "CONTINUE",
                "HadoopJarStep": {
                    "Jar": "command-runner.jar",
                    "Args": [
                        "aws", "s3", "cp",
                        "s3://builditall-client-data/scripts/requirements.txt",
                        "/tmp/requirements.txt"
                    ]
                }
            },
            {
                "Name": "Generate Synthetic Data",
                "ActionOnFailure": "TERMINATE_CLUSTER",
                "HadoopJarStep": {
                    "Jar": "command-runner.jar",
                    "Args": [
                        "spark-submit",
                        "--deploy-mode", "cluster",
                        "s3://builditall-client-data/scripts/data_generator.py",
                        "--output-path", "s3://builditall-client-data/raw/{{ ds }}/"
                    ]
                }
            }
        ],
    )

    monitor_generate = EmrStepSensor(
        task_id='monitor_generate_data',
        job_flow_id="{{ task_instance.xcom_pull(task_id='create_emr_cluster', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_id='generate_data', key='return_value')[1] }}",
    )

    terminate_cluster = EmrTerminateJobFlowOperator(
        task_id='terminate_emr_cluster',
        job_flow_id="{{ task_instance.xcom_pull(task_id='create_emr_cluster', key='return_value') }}",
    )

    create_cluster >> generate_step >> monitor_generate >> terminate_cluster