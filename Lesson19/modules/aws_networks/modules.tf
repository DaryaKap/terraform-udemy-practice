#----------------------------------------------------------
# My Terraform
#
# Use Our Terraform Module to create AWS VPC Networks
#
# Made by Darya
#----------------------------------------------------------


# To make module from our code, we need to delete provider block

/*
provider "aws" {
  region     = "eu-north-1"
}
*/

#----------------------------------------------------------


data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-VPC"
  }
}

resource "aws_internet_gateway" "main-GW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-GW"
  }
}


#--------------------Public Subnets and Routing--------------------------------------


resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}


resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-GW.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}


resource "aws_route_table_association" "public_routes_association" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_routes.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)

}


#--------------------NAT Gateway with Elastic IP--------------------------------------


resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}


#--------------------Private Subnets and Routing--------------------------------------


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}


resource "aws_route_table" "private_routes" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-route-private-subnets-${count.index + 1}"
  }
}


resource "aws_route_table_association" "private_routes_association" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_routes[count.index].id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}
