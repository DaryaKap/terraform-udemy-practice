#----------------------------------------------------------
# My Terraform
#
# Variables
#
# Made by Dasha
#----------------------------------------------------------



provider "aws" {
  #access_key
  #secret_key
  region = var.region
}



data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  full_project_name = "${var.environment} ${var.project_name}"
  project_owner     = "${var.owner} owner of ${var.project_name}"
}

locals {
  country  = "Poland"
  city     = "Warsaw"
  az_list  = join(",", data.aws_availability_zones.available.names)
  location = "In ${local.az_list} there are AZ: ${local.az_list}"
  region   = data.aws_region.current.name
}




resource "aws_eip" "my_static_ip" {
  # vpc = true # Need to add in new AWS Provider version

  tags = {
    Name       = "Static IP"
    Owner      = var.owner
    Project    = local.full_project_name
    proj_owner = local.project_owner
    city       = local.city
    region_azs = local.az_list
    location   = local.location
  }
}
