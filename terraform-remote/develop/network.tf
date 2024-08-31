
# Network - ref.: https://www.harrisoncramer.me/setting-up-docker-with-terraform-and-ec2/
resource "aws_vpc" "develop" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "develop_vpc"
  }
}

resource "aws_subnet" "develop" {
  vpc_id                  = aws_vpc.develop.id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  
  tags = {
    Name = "develop_subnet"
  }
}

resource "aws_internet_gateway" "develop" {
  vpc_id = aws_vpc.develop.id

  tags = {
    Name = "develop_gateway"
  }
}

resource "aws_route_table" "develop" {
  vpc_id = aws_vpc.develop.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.develop.id
  }
 
  tags = {
    Name = "develop_route_table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.develop.id
  route_table_id = aws_route_table.develop.id
}
