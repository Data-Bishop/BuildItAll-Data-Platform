provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "builditall-tfstate"
    key            = "s3-infrastructure.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "builditall-tfstate-lock"
  }
}
