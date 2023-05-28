// todo better output
output "role_arns" {
  description = "The ARNs of the IAM roles created for the ECS tasks, these need to be created with the right permissions in the target accounts"
  value       = values(aws_iam_role.taskrole)[*].inline_policy
}