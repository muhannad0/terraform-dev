terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

module "asg" {
    source = "../../modules/cluster/asg-rolling-deploy"

    cluster_name = var.cluster_name
    instance_ami = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"

    min_size = 1
    max_size = 1
    enable_autoscaling = false

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