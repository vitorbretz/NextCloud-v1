resource "aws_internet_gateway" "sp-igw" {
  vpc_id = aws_vpc.sp-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "sp-rtb-pub" {
  vpc_id = aws_vpc.sp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sp-igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rtb"
  }
}