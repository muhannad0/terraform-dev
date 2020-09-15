provider "aws" {
    region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "bucket-with-some-data-files"
        key = "global/iam/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "tf-dev-locks"
        encrypt = true
    }
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

resource "aws_iam_policy" "cloudwatch_read_only" {
    name = "cloudwatch-read-only"
    policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
    statement {
        sid = "ReadOnlyAccess"
        effect = "Allow"
        actions = [
            "cloudwatch:Describe*",
            "cloudwatch:Get*",
            "cloudwatch:List*"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_policy" "cloudwatch_full_access" {
    name = "cloudwatch-full-access"
    policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
    statement {
        sid = "FullAccess"
        effect = "Allow"
        actions = ["cloudwatch:*"]
        resources = ["*"]
    }
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_full_access" {
    count = var.give_neo_cloudwatch_full_access ? 1 : 0

    user = aws_iam_user.example["neo"].name
    policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_read_only" {
    count = var.give_neo_cloudwatch_full_access ? 0 : 1

    user = aws_iam_user.example["neo"].name
    policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}
