terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bucket-with-some-data-files"
        key = "prod/services/hello-world-app/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tf-dev-locks"
        encrypt = true
    }
}

module "hello_world_app" {
    source = "../../../../modules/services/hello-world-app"
    
    environment = var.environment

    db_remote_state_bucket = var.db_remote_state_bucket
    db_remote_state_key = var.db_remote_state_key

    instance_type = "t2.micro"
    min_size = 2
    max_size = 5
    enable_autoscaling = true

    custom_tags = {
        Owner = "team-foo"
        DeployedBy = "TeamTF"
    }

    server_text = "Hello World Prod"
}