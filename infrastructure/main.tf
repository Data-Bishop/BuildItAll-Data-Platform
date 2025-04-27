module "emr" {
  source       = "./modules/emr"
  project_name = local.secrets["project_name"]
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = local.secrets["vpc_cidr"]
}

module "s3" {
  source               = "./modules/s3"
  data_bucket_name     = local.secrets["data_bucket_name"]
  airflow_bucket_name  = local.secrets["airflow_bucket_name"]
  logs_bucket_name     = local.secrets["logs_bucket_name"]
  project_name         = local.secrets["project_name"]
  aws_account_id       = local.secrets["aws_account_id"]
  airflow_role_arn     = module.airflow_ec2.airflow_role_arn
  emr_default_role_arn = module.emr.emr_default_role_arn
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = local.secrets["project_name"]
  vpc_cidr     = local.secrets["vpc_cidr"]
}

module "airflow_ec2" {
  source             = "./modules/airflow_ec2"
  project_name       = local.secrets["project_name"]
  aws_account_id     = local.secrets["aws_account_id"]
  aws_region         = local.secrets["aws_region"]
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ami_id             = local.secrets["ami_id"]
  key_pair_name      = local.secrets["key_pair_name"]
  vpc_cidr           = local.secrets["vpc_cidr"]
}

module "bastion" {
  source            = "./modules/bastion"
  project_name      = local.secrets["project_name"]
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  ami_id            = local.secrets["ami_id"]
  key_pair_name     = local.secrets["key_pair_name"]
  allowed_ip        = local.secrets["allowed_ip"]
}