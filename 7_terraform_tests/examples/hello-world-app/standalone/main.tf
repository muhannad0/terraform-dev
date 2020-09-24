terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

module "hello_world_app" {
    source = "../../modules/services/hello-world-app"
    
    environment = var.environment

    mysql_config = var.mysql_config

    instance_type = "t2.micro"
    min_size = 1
    max_size = 2
    enable_autoscaling = false

    server_text = var.server_text
}
