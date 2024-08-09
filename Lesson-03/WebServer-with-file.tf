#----------------------------------------------------------
# My Terraform
#
# Build WebServer during Bootstrap
#
# Made by Darya
#----------------------------------------------------------

/*
provider "aws" {
  region = "eu-central-1"
}
*/

provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_instance" "my_webserver" {
  ami                         = "ami-01dad638e8f31ab9a"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.my_webserver.id]
  user_data_replace_on_change = true # This need to added!!!!  
  user_data                   = file("user-data.sh")

  tags = {
    Name  = "Web Server Build by Terraform"
    Owner = "Darya"
  }
}


resource "aws_security_group" "my_webserver" {
  name        = "WebServer Security Group"
  description = "My First SecurityGroup"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Web Server SecurityGroup"
    Owner = "Darya"
  }
}
