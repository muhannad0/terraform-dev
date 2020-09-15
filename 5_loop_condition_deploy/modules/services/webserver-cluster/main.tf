# Read data from data-stores state file
data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = var.db_remote_state_bucket
        key = var.db_remote_state_key
        region = "us-east-1"
    }
}

# Module local variables
locals {
    http_port = 80
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    any_ip = ["0.0.0.0/0"]
}

# Get the latest ami image; Amazon Linux 2 Ref: ami-0c94855ba95c71c99
data "aws_ami" "amzn2" {
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon"]
}

# Select the default VPC
data "aws_vpc" "default" {
    default = true
}

# Get the subnets in the default VPC
data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

# Get the User Data script
data "template_file" "user_data" {
    # count = var.enable_new_user_data ? 0 : 1

    template = file("${path.module}/user-data.sh")

    vars = {
        server_port = var.server_port
        db_address = data.terraform_remote_state.db.outputs.address
        db_port = data.terraform_remote_state.db.outputs.port
        server_text = var.server_text
    }
}

# data "template_file" "user_data_new" {
#     count = var.enable_new_user_data ? 1 : 0

#     template = file("${path.module}/user-data-new.sh")

#     vars = {
#         server_port = var.server_port
#     }
# }

resource "aws_launch_configuration" "example" {
    # image_id = data.aws_ami.amzn2.id
    image_id = var.instance_ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance.id]

    # Check if template_file.user_data returns an array, then use that file, otherwise, use the new file.
    # user_data = length(data.template_file.user_data[*]) > 0 ? data.template_file.user_data[0].rendered : data.template_file.user_data_new[0].rendered
    user_data = data.template_file.user_data.rendered

    # tags = {
    #     Name = "terraform-example"
    # }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    # Depend explicitly on specific cluster launch config name so that forces ASG to replaced along with new launch config
    name = "${var.cluster_name}-${aws_launch_configuration.example.name}"
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    target_group_arns = [aws_lb_target_group.asg.id]
    health_check_type = "ELB"

    min_size = var.min_size
    max_size = var.max_size

    # Wait for at least this many instances to pass health check before considering ASG deploy sucessful
    min_elb_capacity = var.min_size

    # When replacing this ASG, create replacement first, then only delete the original
    lifecycle {
        create_before_destroy = true
    }

    tag {
        key = "Name"
        value = "${var.cluster_name}-asg"
        propagate_at_launch = true
    }

    dynamic "tag" {
        for_each = var.custom_tags

        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    count = var.enable_autoscaling ? 1 : 0
    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 5
    desired_capacity = 5
    recurrence = "0 9 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    count = var.enable_autoscaling ? 1 : 0
    scheduled_action_name = "scale-in-at-night"
    min_size = 2
    max_size = 5
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_lb" "example" {
    name = "${var.cluster_name}-alb"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_lb_target_group" "asg" {
    name = "${var.cluster_name}-alb-tg"
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
    listener_arn = aws_lb_listener.http.arn
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
resource "aws_security_group" "alb" {
    name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb.id

    # Allow inbound HTTP requests
    from_port = local.http_port
    to_port = local.http_port
    protocol = local.tcp_protocol
    cidr_blocks = local.any_ip
}

resource "aws_security_group_rule" "allow_all_outbound" {
    type = "egress"
    security_group_id = aws_security_group.alb.id

    # Allow all outbound requests
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.any_ip
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_instance_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.instance.id

    from_port = var.server_port
    to_port = var.server_port
    protocol = local.tcp_protocol
    source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "allow_instance_all_outbound" {
    type = "egress"
    security_group_id = aws_security_group.instance.id

    # Allow all outbound requests
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.any_ip
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
    alarm_name = "${var.cluster_name}-high-cpu-utilization"
    namespace = "AWS/EC2"
    metric_name = "CPUUtilization"

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.example.name
    }

    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    period = 300
    statistic = "Average"
    threshold = 90
    unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
    # Create only if instance type is 't'. %.1s extracts the first character from string.
    count = format("%.1s", var.instance_type) == "t" ? 1 : 0

    alarm_name = "${var.cluster_name}-low-cpu-credit-balance"
    namespace = "AWS/EC2"
    metric_name = "CPUCreditBalance"

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.example.name
    }

    comparison_operator = "LessThanThreshold"
    evaluation_periods = 1
    period = 300
    statistic = "Minimum"
    threshold = 10
    unit = "Count"
}
