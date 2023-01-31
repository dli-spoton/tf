
# IAM
data "aws_iam_policy_document" "ssm" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ssm_patch" {
  name               = local.patch_name
  description        = "IAM role for: ${local.patch_name}"
  assume_role_policy = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_policy" "ssm_run_command" {
  name        = local.patch_name
  description = "SSM RUN_COMMAND IAM policy for: ${local.patch_name}"
  policy      = data.aws_iam_policy_document.ssm_run_command.json
  tags        = local.tags
}
resource "aws_iam_role_policy_attachment" "ssm_run_command" {
  role       = aws_iam_role.ssm_patch.name
  policy_arn = aws_iam_policy.ssm_run_command.arn
}
data "aws_iam_policy_document" "ssm_run_command" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:CancelCommand",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
      "ssm:GetCommandInvocation",
      "ssm:ListTagsForResource",
      "ssm:GetParameters",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "resource-groups:ListGroups",
      "resource-groups:ListGroupResources",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "tag:GetResources",
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole", ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = ["ssm.amazonaws.com"]
      variable = "iam:PassedToService"
    }
  }
}
