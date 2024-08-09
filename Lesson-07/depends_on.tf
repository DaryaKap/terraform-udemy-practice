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

resource "aws_eip" "my_static_eip" {
  instance = aws_instance.my_webserver.id

}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_instance" "my_webserver" {
  ami                    = "ami-01dad638e8f31ab9a"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]

  tags = {
    Name  = "Web Server"
    Owner = "Darya"
  }

  depends_on = [aws_instance.my_Appserver]
}


resource "aws_instance" "my_Appserver" {
  ami                    = "ami-01dad638e8f31ab9a"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]

  tags = {
    Name  = "Application Server"
    Owner = "Darya"
  }

  depends_on = [aws_instance.my_DBserver]
}


resource "aws_instance" "my_DBserver" {
  ami                    = "ami-01dad638e8f31ab9a"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]

  tags = {
    Name  = "Database Server"
    Owner = "Darya"
  }
}


resource "aws_security_group" "my_webserver" {
  name        = "WebServer Security Group"
  description = "My First SecurityGroup"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
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
    Name  = "Web Server SecurityGroup"
    Owner = "Darya"
  }
}
