module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  for_each = toset(var.account_ids)

  name       = "${var.prefix}-step-function"
  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "RunScan",
  "States": {
    "RunScan": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "Cluster": "arn:aws:ecs:eu-west-1:564033685323:cluster/prowler-scanner-cluster",
        "TaskDefinition": "arn:aws:ecs:eu-west-1:564033685323:task-definition/prowler-scanner-prowler-564033685323:15"
      },
      "End": true
    }
  }
}
EOF

  service_integrations = {
    ecs_Sync = {
    }

    stepfunction_Sync = {
    
      events = true
    }
  }

  type = "STANDARD"

}