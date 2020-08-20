provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
  type        = number
  default     = "8080"
  description = "The port the server will use for HTTP requests"
}


resource "aws_instance" "example" {
    ami = "ami-02354e95b39ca8dec"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    # key_name = "use1-keypair"
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
    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "teraform-example-instance"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # ingress {
    #     from_port = 22
    #     to_port = 22
    #     protocol = "tcp"
    #     cidr_blocks = ["43.231.28.181/32"]
    # }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_dns" {
  value       = aws_instance.example.public_dns
  description = "The public dns of the web server"
}
