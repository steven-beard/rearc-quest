resource "aws_cloudwatch_log_group" "ecs" {
  name       = "/aws/ecs/${local.name}"
  kms_key_id = aws_kms_key.this.arn
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.11.1"

  cluster_name = local.name

  create_cloudwatch_log_group = false
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs.name
      }
    }
  }
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

resource "aws_ecr_repository" "this" {
  name = local.name
}
