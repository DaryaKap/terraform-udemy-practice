#----------------------------------------------------------
# My Terraform
#
# Network
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
    key    = "dev/nservers/terraform.tfstate"
    region = "eu-north-1"
    #access_key
    #secret_key
  }
}


#----------------------------------------------------------


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state-darya"
    key    = "dev/network/terraform.tfstate"
    region = "eu-north-1"
    #access_key
    #secret_key
  }
}


data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}



#----------------------------------------------------------

resource "aws_instance" "my_webserver" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.my_webserver.id]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_id[0]
  user_data_replace_on_change = true
  user_data                   = filebase64("../../user-data.sh")

  tags = {
    Name  = "WebServer"
    Owner = "Darya"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "my_webserver" {
  name        = "Dynamic Security Group"
  description = "My First SecurityGroup"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id #!!! Outputs from /Layer-1-Networks/network.tf


  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
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


#----------------------------------------------------------


output "network_details" {
  value = data.terraform_remote_state.network
}

output "webserver_sg_id" {
  value = aws_security_group.my_webserver.id
}

output "web_server_public_ip" {
  value = aws_instance.my_webserver.public_ip
}
