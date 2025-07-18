resource "aws_db_instance" "litellm" {
  identifier             = "litellm-postgresql"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.default.id]
  tags = {
    Name = "litellm-postgresql"
  }
  engine_version      = "17.4"
  publicly_accessible = false
  multi_az            = true
  username            = "litellm_user"
  password            = "litellm_password"
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  lifecycle {
    ignore_changes = [
      password,
      username,
    ]
  }
}
resource "aws_db_subnet_group" "default" {
  name        = "litellm-postgresql-subnet-group"
  subnet_ids  = [data.aws_subnets.SubnetPrivateUSWEST2A.ids[0], data.aws_subnets.SubnetPrivateUSWEST2B.ids[0], data.aws_subnets.SubnetPrivateUSWEST2C.ids[0]]
  description = "Subnet group for litellm PostgreSQL"
  tags = {
    Name = "litellm-postgresql-subnet-group"
  }
}

