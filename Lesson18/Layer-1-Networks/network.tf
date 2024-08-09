#----------------------------------------------------------
# My Terraform
#
# Network
# terraform.tfstate file on S3
#
# Made by Dasha
#----------------------------------------------------------


provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}


terraform {
  backend "s3" {
    bucket = "my-terraform-state-darya"
    key    = "dev/network/terraform.tfstate"
    region = "eu-north-1"

    #secret_key
  }
}


#----------------------------------------------------------


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnets_cidr" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}


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



resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
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



#----------------------------------------------------------


output "vpc_id" {
  value = aws_vpc.main.id
}


output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}


output "public_subnet_id" {
  value = aws_subnet.public_subnets[*].id
}
