from datetime import datetime

from airflow import DAG
from airflow.providers.amazon.aws.operators.emr import (
    EmrCreateJobFlowOperator,
    EmrAddStepsOperator,
    EmrTerminateJobFlowOperator,
)
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor, EmrJobFlowSensor

default_args = {
    "owner": "builditall",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 2,
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
                "Market": "SPOT",
                "InstanceRole": "CORE",
                "InstanceType": "m5.xlarge",
                "InstanceCount": 1,
            },
        ],
        "KeepJobFlowAliveWhenNoSteps": True,
        "TerminationProtected": False,
        "Ec2SubnetId": "subnet-0845fc0a3f7481d13",
        "EmrManagedMasterSecurityGroup": "sg-07a77bd9558cf8ad5",
        "EmrManagedSlaveSecurityGroup": "sg-002ab4a2ae544fd4c",
    },
    "BootstrapActions": [
        {
            "Name": "InstallDependencies",
            "ScriptBootstrapAction": {
                "Path": "s3://builditall-client-data/scripts/bootstrap.sh",
            },
        }
    ],
    "JobFlowRole": "BuildItAll-EMR-EC2-Profile",
    "ServiceRole": "EMR_DefaultRole",
    "LogUri": "s3://builditall-logs/emr/",
}

with DAG(
    "data_generation",
    default_args=default_args,
    description="Generate synthetic data daily at 9 AM",
    schedule_interval="0 9 * * *",
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

    generate_step = EmrAddStepsOperator(
        task_id="generate_data",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
        steps=[
            {
                "Name": "Generate Synthetic Data",
                "ActionOnFailure": "TERMINATE_CLUSTER",
                "HadoopJarStep": {
                    "Jar": "command-runner.jar",
                    "Args": [
                        "spark-submit",
                        "--deploy-mode",
                        "cluster",
                        "s3://builditall-client-data/scripts/data_generator.py",
                        "--output-path",
                        "s3://builditall-client-data/raw/{{ ds }}/",
                    ],
                },
            }
        ],
    )

    monitor_generate = EmrStepSensor(
        task_id="monitor_generate_data",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_ids='generate_data', key='return_value')[0] }}",
    )

    terminate_cluster = EmrTerminateJobFlowOperator(
        task_id="terminate_emr_cluster",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
    )

    (
        create_cluster
        >> wait_for_cluster
        >> generate_step
        >> monitor_generate
        >> terminate_cluster
    )
