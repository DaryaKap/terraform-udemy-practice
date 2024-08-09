#----------------------------------------------------------
# Provision Highly Availabe Web in any Region Default VPC
# Create:
#    - Security Group for Web Server and ALB
#    - Launch Template with Auto AMI Lookup
#    - Auto Scaling Group using 2 Availability Zones
#    - Application Load Balancer in 2 Availability Zones
#    - Application Load Balancer TargetGroup
# Update to Web Servers will be via Green/Blue Deployment Strategy
#-----------------------------------------------------------


provider "aws" {
  #access_key
  #secret_key
  region = "eu-north-1"

  default_tags {
    tags = {
      Owner     = "Darya"
      CreatedBy = "Terraform"
    }
  }
}


data "aws_availability_zones" "available" {}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#---------------------------------------------------------------------

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "my_webserver" {
  name        = "Dynamic Security Group"
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
    Name = "Web Security Group"
  }
}

#---------------------------------------------------------------------


resource "aws_launch_template" "web" {
  name = "WebServer-HA-LA"
  # name_prefix     = "WebServer-Highly-Available-LC-"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = filebase64("user-data_with_color.sh")

  lifecycle {
    create_before_destroy = true
  }
}


#---------------------------------------------------------------------


resource "aws_autoscaling_group" "WEB-ASG" {
  name = "ASG-${aws_launch_template.web.latest_version}"
  # launch_configuration = aws_launch_configuration.web.name
  min_size         = 2
  max_size         = 2
  min_elb_capacity = 2
  # health_check_type    = "ELB" #ping web page
  # load_balancers       = [aws_elb.Web-ELB.name]
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  target_group_arns   = [aws_lb_target_group.web-TG.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }


  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG-v${aws_launch_template.web.latest_version}"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


#---------------------------------------------------------------------


resource "aws_lb" "web-lb" {
  name               = "WebServer-HA-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_webserver.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
}


resource "aws_lb_target_group" "web-TG" {
  name                 = "WebServer-HA-TG"
  vpc_id               = aws_default_vpc.default.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10 #seconds
}



resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-TG.arn
  }
}

/*
resource "aws_elb" "Web-ELB" {
  name = "WebServer-HA-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.my_webserver.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }

  tags = {
    Name = "WebServer-HA-ELB"
  }
}
*/

#---------------------------------------------------------------------


resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}


#---------------------------------------------------------------------


output "web_loadbalancer_url" {
  value = aws_lb.web-lb.dns_name
}
