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


resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&"
  keepers = {
    keeper1 = "keeper" # if keeper changes - password will be changed
  }
}



resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Maste Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}


output "rds_password" {
  value = random_string.rds_password.result
}



data "aws_ssm_parameter" "my_rds_password" {
  name       = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password]
}



