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


resource "aws_route_table_association" "sp-rtb-assoc-pub-1a" {
  subnet_id      = aws_subnet.sp-sub-pub-1a.id
  route_table_id = aws_route_table.sp-rtb-pub.id
}
resource "aws_route_table_association" "sp-rtb-assoc-pub-1b" {
  subnet_id      = aws_subnet.sp-sub-pub-1b.id
  route_table_id = aws_route_table.sp-rtb-pub.id
}