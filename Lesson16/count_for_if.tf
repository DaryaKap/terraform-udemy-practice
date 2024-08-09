#----------------------------------------------------------
# My Terraform
#
# Count, for, if
#
# Made by Dasha
#----------------------------------------------------------



#----------------------Count---------------------------------------

provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"
}



variable "iam_users" {
  description = "List of IAM users"
  default     = ["Vasya", "Dasha", "Vanya", "Kolya", "Misha", "Pasha"]
}

resource "aws_iam_user" "user1" {
  name = "Dasha_Kap"
}

resource "aws_iam_user" "user2" {
  count = length(var.iam_users)               #!!!
  name  = element(var.iam_users, count.index) #!!!

}

resource "aws_instance" "server" {
  count         = 3
  ami           = "ami-01dad638e8f31ab9a"
  instance_type = "t3.micro"

  tags = {
    Name = "Server Name ${count.index + 1}" #!!!
  }
}


#----------------------For---------------------------------------


output "created_iam_users" {
  value = aws_iam_user.user2[*].id
}


output "created_iam_user_arn" {
  value = [
    for user in aws_iam_user.user2 : #!!!  Using [], because it is a list
    "Username: ${user.name} has arn: ${user.arn}"
  ]
}


output "created_iam_user_map" {
  value = {
    for user in aws_iam_user.user2 : #!!!  Using {} because it is a tuple (map)
    user.unique_id => user.id
  }
}


output "created_iam_user_custom" {
  value = [
    for x in aws_iam_user.user2 :
    x.name
    if length(x.name) == 4 #!!!
  ]
}


output "servers_all" {
  value = {
    for server in aws_instance.server : #!!!
    server.id => server.public_ip
  }

}
