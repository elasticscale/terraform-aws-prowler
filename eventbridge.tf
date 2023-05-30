resource "aws_cloudwatch_event_rule" "cron" {
  name                = "${var.prefix}-cron"
  description         = "Run the prowler scans periodically"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  for_each  = toset(var.account_ids)
  target_id = "${var.prefix}-${each.value}-scan"
  arn       = aws_ecs_cluster.cluster.arn
  rule      = aws_cloudwatch_event_rule.cron.name
  role_arn  = aws_iam_role.eventbridgerole[each.key].arn
  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.taskdef[each.key].arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = var.use_nat_gateway ? module.vpc.private_subnets : module.vpc.public_subnets
      security_groups  = [module.task_sg.security_group_id]
      assign_public_ip = var.use_nat_gateway ? false : true
    }
  }
}