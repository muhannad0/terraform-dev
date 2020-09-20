terraform {
    # Require any 0.12.x version of Terraform
    required_version = ">= 0.12"
}

# Read data from data-stores state file
data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = var.db_remote_state_bucket
        key = var.db_remote_state_key
        region = "us-east-1"
    }
}

# Select the default VPC
data "aws_vpc" "default" {
    default = true
}

# Get the subnets in the default VPC
data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

# Get the latest ami image; Amazon Linux 2 Ref: ami-0c94855ba95c71c99
# data "aws_ami" "amzn2" {
#     most_recent = true

#     filter {
#         name = "name"
#         values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
#     }

#     filter {
#         name = "virtualization-type"
#         values = ["hvm"]
#     }

#     owners = ["amazon"]
# }

# Get the User Data script
data "template_file" "user_data" {
    count = var.db_use_default_settings ? 0 : 1
    template = file("${path.module}/user-data.sh")

    vars = {
        server_text = var.server_text
        server_port = var.server_port
        db_address = data.terraform_remote_state.db.outputs.address
        db_port = data.terraform_remote_state.db.outputs.port
    }
}

data "template_file" "user_data_default" {
    count = var.db_use_default_settings ? 1 : 0
    template = file("${path.module}/user-data.sh")

    vars = {
        server_text = var.server_text
        server_port = var.server_port
        db_address = "localhost"
        db_port = 3306
    }
}

resource "aws_lb_target_group" "asg" {
    name = "hello-world-${var.environment}"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = module.alb.alb_http_listener_arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

module "asg" {
    source = "../../cluster/asg-rolling-deploy"

    cluster_name = "hello-world-${var.environment}"
    instance_ami = "ami-0c94855ba95c71c99"
    instance_type = var.instance_type

    user_data = (length(data.template_file.user_data[*].rendered) > 0 ? data.template_file.user_data[0].rendered : data.template_file.user_data_default[0].rendered)
    # user_data = data.template_file.user_data.rendered

    min_size = var.min_size
    max_size = var.max_size
    enable_autoscaling = var.enable_autoscaling
    
    subnet_ids = data.aws_subnet_ids.default.ids
    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    custom_tags = var.custom_tags
}

module "alb" {
    source = "../../networking/alb"

    alb_name = "hello-world-${var.environment}"
    subnet_ids = data.aws_subnet_ids.default.ids
}
