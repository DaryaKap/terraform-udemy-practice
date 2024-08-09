#----------------------------------------------------------
# My Terraform
#
# Different Accounts
#
# Made by Dasha
#----------------------------------------------------------



provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}


provider "aws" {
  #access_key
  #secret_key
  region = "us-east-1"
  alias  = "USA"
}



data "aws_ami" "usa_aws_linux" {
  provider    = aws.USA
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


resource "aws_instance" "my_Europe_server" {
  instance_type = "t3.micro"
  ami           = "ami-01dad638e8f31ab9a"

  tags = {
    Name = "Europe Server"
  }
}



resource "aws_instance" "my_USA_server" {
  provider      = aws.USA
  instance_type = "t3.micro"
  ami           = data.aws_ami.usa_aws_linux.id

  tags = {
    Name = "USA Server"
  }
}



