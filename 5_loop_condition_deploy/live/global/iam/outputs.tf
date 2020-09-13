# output "all_users" {
#     value = aws_iam_user.example
#     description = "Details of all users"
# }

output "all_users_arn" {
    value = values(aws_iam_user.example)[*].arn
    description = "The ARN of all the users"
}

output "all_users_upper_case" {
    value = [for name in var.user_names : upper(name)]
}

output "short_names_upper_case" {
    value = [for name in var.user_names : upper(name) if length(name) < 5]
}

output "bios" {
    value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

output "bios_upper_case" {
    value = {for name, role in var.hero_thousand_faces: upper(name) => upper(role)}
}

output "for_directive" {
    value = <<EOF
    %{ for name in var.user_names }
        ${name}
    %{ endfor }
    EOF
}

output "for_directive_strip_marker" {
    value = <<EOF
    %{ for name in var.user_names ~}
        ${name}
    %{ endfor ~}
    EOF
}