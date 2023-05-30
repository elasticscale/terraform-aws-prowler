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
        },
        {
          Effect   = "Allow"
          Action   = "elasticfilesystem:ClientRootAccess"
          Resource = aws_efs_file_system.efs.arn
        }
      ]
    })
  }
}

resource "aws_iam_role" "executionrole" {
  for_each = toset(var.account_ids)
  name     = "${var.prefix}-executionrole-${each.value}"
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

resource "aws_iam_role" "datasync" {
  name = "${var.prefix}-datasyncrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-datasync-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = "s3:*",
          Resource = [
            "${module.bucket.s3_bucket_arn}",
            "${module.bucket.s3_bucket_arn}/*"
          ]
        },
        {
          Effect   = "Allow"
          Action   = "elasticfilesystem:ClientRootAccess"
          Resource = aws_efs_file_system.efs.arn
        }

      ]
    })
  }
}
