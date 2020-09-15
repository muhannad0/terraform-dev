provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bucket-with-some-data-files"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tf-dev-locks"
        encrypt = true
    }
}

module "webserver_cluster" {
    source = "../../../../modules/services/webserver-cluster"

    cluster_name = "webservers-stage"
    db_remote_state_bucket = "bucket-with-some-data-files"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

    instance_ami = "ami-0c94855ba95c71c99"
    server_text = "New Server Text"

    instance_type = "t2.micro"
    min_size = 2
    max_size = 2
    enable_autoscaling = false
    # enable_new_user_data = true
}