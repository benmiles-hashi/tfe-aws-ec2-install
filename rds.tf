resource "aws_db_parameter_group" "tfe_ec2_pg" {
  name   = "tfe-ec2-pg"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}
resource "aws_db_subnet_group" "tfe_ec2_sg" {
  name       = "tfe-ec2-sg"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Name = "tfe_ec2_sg"
  }
}
resource "aws_security_group" "rds" {
  name   = "tfe_ec2_rds"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tfe_ec2_rds"
  }
}

resource "aws_db_instance" "tfe-ec2-postgres" {
  identifier             = "tfe-ec2-postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.8"
  db_name                = var.db_name
  username               = var.db_username
  password               = local.db_password
  db_subnet_group_name   = aws_db_subnet_group.tfe_ec2_sg.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.tfe_ec2_pg.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}