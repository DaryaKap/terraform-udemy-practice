#----------------------------------------------------------
# My Terraform
#
# Conditions in Terraform
#
# Made by Dasha
#----------------------------------------------------------



provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}


variable "env" {
  default = "prod"
}

variable "prod_owner" {
  default = "Darya"
}


variable "noprod_owner" {
  default = "Anyone"
}


resource "aws_instance" "my_web_server1" {
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = (var.env == "prod" ? "t2.micro" : "t3.micro") #!!!

  tags = {
    Name  = "${var.env}-server"
    Owner = (var.env == "prod" ? var.prod_owner : var.noprod_owner)
  }
}


resource "aws_instance" "my_web_server2" {
  count         = var.env == "dev" ? 1 : 0 #!!!
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = "t3.micro"

  tags = {
    Name = "New-Server"
  }
}


#--------------Lookups------------------------------------------


variable "ec2_size" {
  default = {
    "prod"    = "t3.medium"
    "dev"     = "t3.micro"
    "staging" = "t2.small"
  }
}

resource "aws_instance" "my_web_server3" {
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = lookup(var.ec2_size, var.env) #!!!

  tags = {
    Name = "New-Server"
  }
}


resource "aws_instance" "my_web_server4" {
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = var.env == "prod" ? var.ec2_size["prod"] : "t2.micro" #!!!

  tags = {
    Name = "New-Server"
  }
}



#---------------------------Example with Security Group---------------------------




variable "allow_ports_list" {
  default = {
    "prod" = ["80", "443"]
    "dev"  = ["80", "443", "8080", "22"]
  }
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "my_webserver" {
  name        = "Dynamic Security Group"
  description = "My First SecurityGroup"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id


  dynamic "ingress" {
    for_each = lookup(var.allow_ports_list, var.env)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic SecurityGroup"
    Owner = "Darya"
  }
}








