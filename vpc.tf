
# VPC PRINCIPAL

resource "aws_vpc" "sp-vpc" {
  cidr_block           = "10.0.0.0/22" # Cobre 10.0.0.0 - 10.0.3.255
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}


# SUBNETS PÚBLICAS

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


# SUBNETS PRIVADAS

resource "aws_subnet" "sp-sub-prv-1a" {
  vpc_id            = aws_vpc.sp-vpc.id
  availability_zone = "sa-east-1a"
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "${var.project_name}-private-subnet-1a"
  }
}

resource "aws_subnet" "sp-sub-prv-1b" {
  vpc_id            = aws_vpc.sp-vpc.id
  availability_zone = "sa-east-1b"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "${var.project_name}-private-subnet-1b"
  }
}


# INTERNET GATEWAY

resource "aws_internet_gateway" "sp-igw" {
  vpc_id = aws_vpc.sp-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}


# ELASTIC IP para NAT GATEWAY

resource "aws_eip" "sp-nat-eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}


# NAT GATEWAY (em subnet pública 1a)

resource "aws_nat_gateway" "sp-nat" {
  allocation_id = aws_eip.sp-nat-eip.id
  subnet_id     = aws_subnet.sp-sub-pub-1a.id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.sp-igw]
}


# ROUTE TABLE PÚBLICA

resource "aws_route_table" "sp-rtb-public" {
  vpc_id = aws_vpc.sp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sp-igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rtb"
  }
}


# ASSOCIAÇÕES DE SUBNETS PÚBLICAS

resource "aws_route_table_association" "sp-rtb-assoc-publi-1a" {
  subnet_id      = aws_subnet.sp-sub-pub-1a.id
  route_table_id = aws_route_table.sp-rtb-public.id
}

resource "aws_route_table_association" "sp-rtb-assoc-publi-1b" {
  subnet_id      = aws_subnet.sp-sub-pub-1b.id
  route_table_id = aws_route_table.sp-rtb-public.id
}


# ROUTE TABLE PRIVADA

resource "aws_route_table" "sp-rtb-private" {
  vpc_id = aws_vpc.sp-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sp-nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rtb"
  }
}


# ASSOCIAÇÕES DE SUBNETS PRIVADAS

resource "aws_route_table_association" "sp-rtb-assoc-prv-1a" {
  subnet_id      = aws_subnet.sp-sub-prv-1a.id
  route_table_id = aws_route_table.sp-rtb-private.id
}

resource "aws_route_table_association" "sp-rtb-assoc-prv-1b" {
  subnet_id      = aws_subnet.sp-sub-prv-1b.id
  route_table_id = aws_route_table.sp-rtb-private.id
}
