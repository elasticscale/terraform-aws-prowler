resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "taskdef" {
  depends_on               = [aws_iam_role.taskrole, aws_iam_role.executionrole]
  for_each                 = toset(var.account_ids)
  family                   = "${var.prefix}-prowler-${each.value}"
  task_role_arn            = aws_iam_role.taskrole[each.key].arn
  execution_role_arn       = aws_iam_role.executionrole[each.key].arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  volume {
    name = "scanresults"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.accesspoint.id
        iam             = "ENABLED"
      }
    }
  }
  container_definitions = jsonencode([
    {
      name      = "prowler"
      image     = "toniblyx/prowler:stable"
      cpu       = 1024
      memory    = 2048
      essential = true
      command   = ["aws", "-M", "csv", "json", "json-asff", "html", "-o", "/scanresults"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.prefix}-prowler-${each.value}"
          awslogs-region        = var.region
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "prowler"
        }
      }
      mountPoints = [
        {
          sourceVolume  = "scanresults"
          containerPath = "/scanresults"
        }
      ]
    },
  ])
}

module "task_sg" {
  source                                = "terraform-aws-modules/security-group/aws"
  name                                  = "${var.prefix}-task"
  vpc_id                                = module.vpc.vpc_id
  ingress_with_source_security_group_id = []
  egress_rules                          = ["all-all"]
}