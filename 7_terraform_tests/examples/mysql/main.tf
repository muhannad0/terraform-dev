terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

provider "aws" {
    region = "us-east-1"
}

module "mysql" {
    source = "../../modules/data-stores/mysql"

    db_instance_class = "db.t2.micro"
    db_allocated_storage = 10
    db_identifier_prefix = "example-db-"

    db_name = var.db_name
    db_admin_username = var.db_username
    db_admin_password = var.db_password

}
