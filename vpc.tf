resource "aws_vpc" "sp-vpc" {
  cidr_block           = "10.0.0.0/23"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "sp-sub-pub-1a" {
  vpc_id                  = aws_vpc.sp-vpc.id
  availability_zone       = "sa-east-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-1a"
  }
}
resource "aws_subnet" "sp-sub-pub-1b" {
  vpc_id                  = aws_vpc.sp-vpc.id
  availability_zone       = "sa-east-1b"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet-1b"
  }
}

