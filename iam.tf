resource "aws_iam_role" "taskrole" {
  depends_on = [ aws_iam_role.securityhubrole ]
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

resource "aws_iam_role" "securityhubrole" {
  for_each = toset(var.account_ids)
  name     = "${var.prefix}-securityhub-${each.value}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${var.security_account_id}:role/${var.prefix}-assumerole-${each.value}"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-securityhub-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [

        {
          Effect   = "Allow"
          Action   = ["securityhub:BatchImportFindings", "securityhub:GetFindings"]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "executionrole" {
  name     = "${var.prefix}-executionrole"
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