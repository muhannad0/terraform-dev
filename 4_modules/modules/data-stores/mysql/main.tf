resource "aws_db_instance" "example" {
    identifier_prefix = var.db_identifier_prefix
    engine = "mysql"
    allocated_storage = var.db_allocated_storage
    instance_class = var.db_instance_class
    name = var.db_name
    username = var.db_master_username
    # referring to secrets manager
    password = data.aws_secretsmanager_secret_version.db_password.secret_string
    skip_final_snapshot = true
}

data "aws_secretsmanager_secret_version" "db_password" {
    # secret_id = "mysql-master-password-stage"
    secret_id = var.db_master_password_secret_id
}