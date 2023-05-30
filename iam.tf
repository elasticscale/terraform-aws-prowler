resource "aws_iam_role" "taskrole" {
  for_each = toset(var.account_ids)
  name     = "${var.prefix}-assumerole-${each.value}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-prowler-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [

        {
          Effect   = "Allow"
          Action   = "sts:AssumeRole"
          Resource = "arn:aws:iam::${each.value}:role/${var.prefix}-scanrole"
        }
      ]
    })
  }
}

resource "aws_iam_role" "eventbridgerole" {
  for_each = toset(var.account_ids)
  name     = "${var.prefix}-eventbridge-${each.value}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-eventbridge-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [

        {
          Effect   = "Allow"
          Action   = "iam:PassRole"
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = "ecs:RunTask"
          Resource = replace(aws_ecs_task_definition.taskdef[each.key].arn, "/:\\d+$/", ":*")
        }
      ]
    })
  }
}

resource "aws_iam_role" "executionrole" {
  name = "${var.prefix}-executionrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-execution-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          Resource = [
            "arn:aws:logs:*:*:*"
          ]
        },

      ]
    })
  }
}