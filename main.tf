terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      projeto = "oficina"
    }
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/oficina/network/vpc_id"
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = "/oficina/network/vpc_cidr"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "/oficina/network/private_subnet_ids"
}

resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = split(",", data.aws_ssm_parameter.private_subnets.insecure_value)
}

resource "aws_security_group" "db" {
  name        = "${var.db_identifier}-sg"
  description = "PostgreSQL acessivel apenas de dentro da VPC do cluster"
  vpc_id      = data.aws_ssm_parameter.vpc_id.insecure_value

  ingress {
    description = "Pods do EKS e Lambda de autenticacao"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat([data.aws_ssm_parameter.vpc_cidr.insecure_value], var.allowed_cidr_blocks)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier                   = var.db_identifier
  engine                       = "postgres"
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  storage_type                 = "gp3"
  storage_encrypted            = true
  db_name                      = var.db_name
  username                     = var.db_username
  password                     = random_password.db.result
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.db.id]
  publicly_accessible          = false
  multi_az                     = var.multi_az
  backup_retention_period      = 1
  skip_final_snapshot          = true
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  performance_insights_enabled = false
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/oficina/db/host"
  type  = "String"
  value = aws_db_instance.this.address
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/oficina/db/port"
  type  = "String"
  value = tostring(aws_db_instance.this.port)
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/oficina/db/name"
  type  = "String"
  value = aws_db_instance.this.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/oficina/db/username"
  type  = "String"
  value = aws_db_instance.this.username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/oficina/db/password"
  type  = "SecureString"
  value = random_password.db.result
}
