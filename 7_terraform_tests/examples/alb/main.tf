terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

module "alb" {
    source = "../../modules/networking/alb"

    alb_name = "${var.alb_name}-alb"
    subnet_ids = data.aws_subnet_ids.default.ids
}

# Select the default VPC
data "aws_vpc" "default" {
    default = true
}

# Get the subnets in the default VPC
data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}