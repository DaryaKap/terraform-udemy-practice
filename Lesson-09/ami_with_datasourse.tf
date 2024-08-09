#
# Find Latest AMI id of:
#    - Ubuntu 22.04
#    - Amazon Linux 2
#    - Windows Server 2022 Base
#
#


provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}



data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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


data "aws_ami" "latest_windows_2022" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

}




output "ubuntu_latest_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "ubuntu_latest_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}

output "amazon_linux_latest_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "amazon_linux_latest_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}

output "latest_windows_2022_latest_ami_id" {
  value = data.aws_ami.latest_windows_2022.id
}

output "latest_windows_2022_latest_ami_name" {
  value = data.aws_ami.latest_windows_2022.name
}
