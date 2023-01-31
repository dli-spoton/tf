
resource "aws_ssm_maintenance_window" "patch" {
  name        = local.patch_name
  schedule    = "cron(0 7 ? * SAT *)"
  cutoff      = 0
  duration    = 1
  description = "Maintenance Window for AWS-RunPatchBaseline"
  tags        = local.tags
}

resource "aws_ssm_maintenance_window_target" "patch" {
  window_id     = aws_ssm_maintenance_window.patch.id
  name          = local.patch_name
  description   = "Maintenance Window Target for ssm_patch:default"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:ssm_patch"
    values = ["default"]
  }
}

resource "aws_ssm_maintenance_window_task" "patch" {
  window_id        = aws_ssm_maintenance_window.patch.id
  max_concurrency  = 1
  max_errors       = 1
  cutoff_behavior  = "CONTINUE_TASK"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  service_role_arn = aws_iam_role.ssm_patch.arn
  name             = local.patch_name
  description      = "Run AWS-RunPatchBaseline"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch.id]
  }

  priority = 0

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      timeout_seconds = 600
      # output to Cloudwatch logs
      # requires aws_cloudwatch_log_group.ssm_patch
      # requires instance profile with permissions like aws_iam_policy_document.cloudwatch_logs
      cloudwatch_config {
        cloudwatch_log_group_name = aws_cloudwatch_log_group.ssm_patch.name
        cloudwatch_output_enabled = true
      }
    }
  }
}

# Cloudwatch logs group
resource "aws_cloudwatch_log_group" "ssm_patch" {
  name              = local.patch_name
  retention_in_days = "30"
  tags              = local.tags
}

### Cloudwatch logs policy for EC2
data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:*"
    ]
  }
}
