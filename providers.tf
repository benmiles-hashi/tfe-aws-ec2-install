terraform {
  cloud {
    organization = "ben-miles-org"
    workspaces {
      name = "tfe-aws-ec2-install"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}
provider "vault" {
  address = var.vault_addr
  namespace = var.vault_namespace
  auth_login_userpass {
    username = var.vault_username
    password = var.vault_password
  }
}
provider "aws" {
  region = var.region
}
provider "postgresql" {
  host            = aws_db_instance.tfe-ec2-postgres.address
  port            = aws_db_instance.tfe-ec2-postgres.port
  database        = var.db_name
  username        = var.db_username
  password        = local.db_password
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}