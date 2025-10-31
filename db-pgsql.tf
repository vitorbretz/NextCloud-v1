
# DB Subnet Group (subnets privadas)

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [
    aws_subnet.sp-sub-prv-1a.id,
    aws_subnet.sp-sub-prv-1b.id
  ]

  tags = {
    Name = "Aurora Subnet Group"
  }
}


# Aurora RDS Cluster

resource "aws_rds_cluster" "aurora_pg_cluster" {
  cluster_identifier     = "aurora-postgres-dev"
  engine                 = "aurora-postgresql"
  engine_version         = "17.4"
  database_name          = "nextcloud"
  master_username        = "nextcloud"
  master_password        = "MySecurePass123!"
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg-aurora.id]
  storage_encrypted      = true
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name        = "aurora-postgres-dev"
    Environment = "dev"
  }
}


# Aurora RDS Cluster Instance

resource "aws_rds_cluster_instance" "aurora_pg_instance" {
  identifier             = "aurora-postgres-dev-instance-1"
  cluster_identifier     = aws_rds_cluster.aurora_pg_cluster.id
  instance_class         = "db.t4g.large"
  engine                 = aws_rds_cluster.aurora_pg_cluster.engine
  publicly_accessible    = false
  auto_minor_version_upgrade = false
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "Aurora PostgreSQL Instance"
  }
}