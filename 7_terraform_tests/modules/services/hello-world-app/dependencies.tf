# Read data from data-stores state file
data "terraform_remote_state" "db" {
    count = var.mysql_config == null ? 1 : 0
    backend = "s3"

    config = {
        bucket = var.db_remote_state_bucket
        key = var.db_remote_state_key
        region = "us-east-1"
    }
}

# Select the default VPC
data "aws_vpc" "default" {
    count = var.vpc_id == null ? 1 : 0
    default = true
}

# Get the subnets in the default VPC
data "aws_subnet_ids" "default" {
    count = var.subnet_ids == null ? 1 : 0
    vpc_id = data.aws_vpc.default[0].id
}

locals {
    mysql_config = (
        var.mysql_config == null ? data.terraform_remote_state.db[0].outputs : var.mysql_config
    )

    vpc_id = (
        var.vpc_id == null ? data.aws_vpc.default[0].id : var.vpc_id
    )

    subnet_ids = (
        var.subnet_ids == null ? data.aws_subnet_ids.default[0].ids : var.subnet_ids
    )
}