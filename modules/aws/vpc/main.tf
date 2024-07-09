resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

// Bastion host will be in this subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.avl_zone
}

// Havoc C2, RedELK and GoPhish will be in this subnet
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.avl_zone
}

resource "aws_internet_gateway" "myinternetgw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myinternetgw.id
  }
}

resource "aws_route_table_association" "awsrt-assoc" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.myroutetable.id
}

resource "aws_route_table" "nat-route-table-subnet2" {
  depends_on = [aws_nat_gateway.nat-gw]
  vpc_id     = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }
}

resource "aws_eip" "my-eip" {
  domain           = "vpc"
  public_ipv4_pool = "amazon"
}

resource "aws_nat_gateway" "nat-gw" {
  depends_on    = [aws_eip.my-eip]
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.subnet1.id
}

resource "aws_route_table_association" "subnet1-nat-route-table-association" {
  depends_on = [
    aws_route_table.nat-route-table-subnet2
  ]

  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.nat-route-table-subnet2.id
}