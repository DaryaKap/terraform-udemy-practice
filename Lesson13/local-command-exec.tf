#----------------------------------------------------------
# My Terraform
#
# Local command execution
#
# Made by Dasha
#----------------------------------------------------------



provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "dir >> log1.txt"
  }
}


resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -n 5 www.google.com >> ping.txt"
  }
}


resource "null_resource" "command3" {
  provisioner "local-exec" {
    command     = "print('Hello World!')"
    interpreter = ["python", "-c"]
  }
}
