provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bucket-with-some-data-files"
        key = "prod/data-stores/mysql/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tf-dev-locks"
        encrypt = true
    }
}

module "mysql_database" {
    source = "../../../modules/data-stores/mysql"

    db_instance_class = "db.t2.micro"
    db_allocated_storage = 20
    db_identifier_prefix = "web-db-prod-"

    db_name = "example_db"
    db_master_username = "admin"
    db_master_password_secret_id = "mysql-master-password-prod"

}