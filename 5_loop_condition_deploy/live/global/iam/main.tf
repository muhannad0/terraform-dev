provider "aws" {
    region = "us-east-1"
}

# Using count
# resource "aws_iam_user" "example" {
#     count = 3
#     name = var.user_names[count.index]
# }

# Using for_each
resource "aws_iam_user" "example" {
    for_each = toset(var.user_names)
    name = each.value
}