from airflow.models import Variable

configs = {
    "emr_subnet_id": Variable.get("emr_subnet_id"),
    "emr_master_security_group_id": Variable.get("emr_master_security_group_id"),
    "emr_slave_security_group_id": Variable.get("emr_slave_security_group_id")
}
