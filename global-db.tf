/*# providers.tf
provider "aws" {
  alias  = "sa"         # São Paulo (primary)
  region = "sa-east-1"
}

provider "aws" {
  alias  = "va"         # Virginia (secondary)
  region = "us-east-1"
}

# 1) Global cluster (created in primary region)
resource "aws_rds_global_cluster" "global" {
  provider          = aws.sa
  global_cluster_identifier = "my-global-cluster"
  engine            = "aurora-postgresql"
  engine_version    = "17.4" # ajuste conforme seu engine
}

# 2) Primary cluster (assume you imported existing cluster into Terraform state)
# If creating new:
resource "aws_rds_cluster" "primary" {
  provider                  = aws.sa
  cluster_identifier        = "my-primary-cluster"
  engine                    = "aurora-postgresql"
  engine_version            = "17.4"
  global_cluster_identifier = aws_rds_global_cluster.global.global_cluster_identifier
  # subnet_group_name, vpc_security_group_ids, master_username/password, etc...
}

# 3) Primary instances (writer/reader) - change instance_class to r6g.large when ready
resource "aws_rds_cluster_instance" "primary_instances" {
  provider         = aws.sa
  count            = 2
  identifier       = "primary-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.primary.cluster_identifier
  instance_class   = "db.r6g.large"  # altere quando for aplicar upgrade
  engine           = aws_rds_cluster.primary.engine
  engine_version   = aws_rds_cluster.primary.engine_version
}

# 4) Secondary cluster in Virginia — mark it part of the same global cluster
resource "aws_rds_cluster" "secondary" {
  provider                  = aws.va
  cluster_identifier        = "my-secondary-cluster"
  engine                    = "aurora-postgresql"
  engine_version            = "17.4"
  global_cluster_identifier = aws_rds_global_cluster.global.global_cluster_identifier
  # IMPORTANT: configure subnet_group_name, vpc_security_group_ids, etc for us-east-1
}

resource "aws_rds_cluster_instance" "secondary_instances" {
  provider         = aws.va
  count            = 2
  identifier       = "secondary-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.secondary.cluster_identifier
  instance_class   = "db.r6g.large"
  engine           = aws_rds_cluster.secondary.engine
  engine_version   = aws_rds_cluster.secondary.engine_version
}
*/