data "aws_secretsmanager_secret" "builditall" {
  name = "builditall-secrets"
}

data "aws_secretsmanager_secret_version" "builditall" {
  secret_id = data.aws_secretsmanager_secret.builditall.id
}

locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.builditall.secret_string)
}