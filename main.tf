provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
  type        = number
  default     = "8080"
  description = "The port the server will use for HTTP requests"
}

# Get the latest ami image; Amazon Linux 2
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

resource "aws_launch_configuration" "example" {
    image_id = data.aws_ami.amzn2.id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    user_data = <<-EOF
        #!/bin/bash -xe
        exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
        yum update -y
        wget https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
        chmod +x busybox-x86_64
        mv busybox-x86_64 /usr/local/bin/busybox
        echo "Hello World" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
        EOF
    # tags = {
    #     Name = "terraform-example"
    # }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    target_group_arns = [aws_lb_target_group.asg.id]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10
    desired_capacity = 3

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_lb" "example" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
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
    name = "terraform-asg-example"
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
    name = "teraform-example-alb"

    # Allow inbound HTTP requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow all outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "instance" {
    name = "teraform-example-instance"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    # ingress {
    #     from_port = 22
    #     to_port = 22
    #     protocol = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The public dns of the load balancer"
}
