terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

resource "aws_db_instance" "example" {
    identifier_prefix = var.db_identifier_prefix
    engine = "mysql"
    allocated_storage = var.db_allocated_storage
    instance_class = var.db_instance_class
    name = var.db_name
    username = var.db_admin_username
    password = var.db_admin_password
    skip_final_snapshot = true
}