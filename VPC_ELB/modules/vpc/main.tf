locals {
  subnet_args = {
    "ap-northeast-1a" = "10.0.0.0/24"
    "ap-northeast-1c" = "10.0.1.0/24"
    "ap-northeast-1d" = "10.0.2.0/24"
  }
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "training-terraform-vpc"
  }
}

resource "aws_subnet" "public" {
  for_each = local.subnet_args

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "training-terraform-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "training-terraform-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
