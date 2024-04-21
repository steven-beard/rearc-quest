resource "aws_iam_policy" "ssm" {
  name        = "${local.name}-ssm-policy"
  description = "SSM Policy for Quest"
  policy      = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_policy" "secret_access_policy" {
  name   = "${local.name}-secret-access-policy"
  policy = data.aws_iam_policy_document.secret_policy.json
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "secret_policy" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [data.aws_secretsmanager_secret.quest.arn]
  }
}
