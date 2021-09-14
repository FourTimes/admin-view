resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-${var.environment}-${var.region_abbr}-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
  tags = merge({ Name = "${var.project}-${var.environment}-ecsTaskExecutionRole" }, tomap(var.additional_tags))
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-${var.environment}-${var.region_abbr}-ecsTaskRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
  tags = merge({ Name = "${var.project}-${var.environment}-ecsTaskRole" }, tomap(var.additional_tags))

}

resource "aws_iam_policy" "dynamodb" {
  name        = "${var.name}-${var.environment}-${var.region_abbr}-task-policy-dynamodb"
  description = "Policy that allows access to DynamoDB"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:CreateTable",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateTable"
        ],
        "Resourcenvironmente" : "*"
      }
    ]
  })
  tags = merge({ Name = "${var.project}-${var.environment}-task-policy-dynamodb" }, tomap(var.additional_tags))
}


data "aws_secretsmanager_secret" "rds" {
  name = "${var.name}-${var.environment}-${var.region_abbr}-rds-secret"
}


resource "aws_iam_policy" "secrets" {
  name        = "${var.name}-${var.environment}-${var.region_abbr}-task-policy-secrets"
  description = "Policy that allows access to the secrets we created"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "StEOFatement" : [
      {
        "Sid" : "AccessSecrets",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : data.aws_secretsmanager_secret.rds.arn
      },
      {
        "Sid" : "AccessSecretsrandompassword",
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetRandomPassword",
        "Resource" : "*"
      }
    ]
  })
  tags = merge({ Name = "${var.project}-${var.environment}-task-policy-secrets" }, tomap(var.additional_tags))

}

resource "aws_iam_policy" "parameterstore" {
  name        = "${var.name}-${var.environment}-${var.region_abbr}-task-policy-parameterstore"
  description = "Policy that allows access to the parameter store we created"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AccessSecrets",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParametersByPath"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = merge({ Name = "${var.project}-${var.environment}-task-policy-parameterstore" }, tomap(var.additional_tags))
}


data "aws_s3_bucket" "diagram" {
  bucket = "${var.name}-${var.environment}-${var.region_abbr}-s3-diagram"
}

resource "aws_iam_policy" "s3" {
  name        = "${var.name}-${var.environment}-task-policy-s3"
  description = "Policy that allows access to S3 for ecs task"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "${data.aws_s3_bucket.diagram.arn}",
          "${data.aws_s3_bucket.diagram.arn}/*"
        ]
      }
    ]
  })
  tags = merge({ Name = "${var.project}-${var.environment}-task-policy-s3" }, tomap(var.additional_tags))
}


resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}


resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-secrets" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets.arn
}


resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-parameterstore" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.parameterstore.arn
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name}-${var.environment}-${var.region_abbr}-task"
  tags = {
    Name        = "${var.name}-${var.environment}-${var.region_abbr}-task"
    Environment = var.environment
  }
}
