provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bucket-with-some-data-files"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tf-dev-locks"
        encrypt = true
    }
}

resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-web-database"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "example_database"
    username = "admin"
    # referring to secrets manager
    password = data.aws_secretsmanager_secret_version.db_password.secret_string
    skip_final_snapshot = true
}

data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = "mysql-master-password-stage"
}