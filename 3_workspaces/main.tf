provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bucket-with-some-data-files"
        # can use different key in the same bucket for different project/module
        key = "workspaces-example/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tf-dev-locks"
        encrypt = true
    }
}

resource "aws_instance" "example" {
    ami = "ami-02354e95b39ca8dec"
    instance_type = "t2.micro"
    # conditionally set value based on workspace
    # instance_type = terraform.workspace === "default" ? "t2.medium" : "t2.micro"
}

output "instance_dns_name" {
  value       = aws_instance.example.public_dns
  description = "The public dns of the instance"
}