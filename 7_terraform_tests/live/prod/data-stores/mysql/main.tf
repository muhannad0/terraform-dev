terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
    }
}

module "mysql" {
    source = "../../../../modules/data-stores/mysql"

    db_instance_class = "db.t2.micro"
    db_allocated_storage = 10
    db_identifier_prefix = "hello-world-prod"

    db_name = var.db_name
    db_admin_username = var.db_username
    db_admin_password = data.aws_secretsmanager_secret_version.db_password.secret_string

}

data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = "mysql-master-password-prod"
}
