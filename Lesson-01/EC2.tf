provider "aws" {
    region     = "eu-north-1"
}

resource "aws_instance" "my-first-EC2" {
    ami = "ami-0914547665e6a707c"
    instance_type = "t3.micro"
}