resource "aws_vpc" "sp-vpc" {
  cidr_block = "10.0.0.0/23"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "next-cloud-vpc"
  }
}