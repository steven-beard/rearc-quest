data "aws_secretsmanager_secret" "quest" {
  name = "${local.name}/secrets"
}

locals {
  vpc_id                = data.terraform_remote_state.quest.outputs.vpc_id
  listener_arn          = data.terraform_remote_state.quest.outputs.alb_listener_arn
  ecs_cluster_arn       = data.terraform_remote_state.quest.outputs.ecs_cluster_arn
  ecs_private_subnets   = data.terraform_remote_state.quest.outputs.private_subnets
  kms_key_arn           = data.terraform_remote_state.quest.outputs.kms_key_arn
  alb_security_group_id = data.terraform_remote_state.quest.outputs.alb_security_group_id
  ecr_url               = data.terraform_remote_state.quest.outputs.ecr_url
}

resource "aws_cloudwatch_log_group" "quest" {
  name              = "${local.name}/service"
  retention_in_days = 14
  kms_key_id        = local.kms_key_arn
}

resource "aws_lb_target_group" "quest" {
  name        = local.name
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = 3000
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
}

resource "aws_alb_listener_rule" "this" {
  listener_arn = local.listener_arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quest.arn
  }

  condition {
    host_header {
      values = ["${local.domain_prefix}.${local.base_domain}"]
    }
  }
}

resource "aws_security_group" "ecs_service" {
  vpc_id      = local.vpc_id
  name        = "${local.name}-ecs"
  description = "SG for quest ECS service"
  tags = {
    "Name" = "${local.name}-ecs"
  }
}

resource "aws_security_group_rule" "ecs_service" {
  description              = "Allow HTTP inbound traffic"
  security_group_id        = aws_security_group.ecs_service.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "TCP"
  source_security_group_id = local.alb_security_group_id
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.ecs_service.id
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.1"

  name                  = local.name
  cluster_arn           = local.ecs_cluster_arn
  subnet_ids            = local.ecs_private_subnets
  create_security_group = false
  security_group_ids    = [aws_security_group.ecs_service.id]

  enable_autoscaling = true
  desired_count      = "1"

  requires_compatibilities    = ["FARGATE"]
  create_iam_role             = false
  enable_execute_command      = true
  tasks_iam_role_policies     = { ssm = aws_iam_policy.ssm.arn }
  task_exec_iam_role_policies = { secrets = aws_iam_policy.secret_access_policy.arn, task = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" }

  container_definitions = {
    "quest" = {
      image = "${local.ecr_url}:latest"
      linuxParameters = {
        "initProcessEnabled" : true
      }
      essential              = true
      enable_execute_command = true
      secrets = [
        {
          name      = "SECRET_WORD"
          valueFrom = "${data.aws_secretsmanager_secret.quest.arn}:secret_word::"
        }
      ]
      port_mappings = [
        {
          name          = "quest"
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.quest.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
      health_check = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
        interval    = 10
        retries     = 3
        startPeriod = 90
      }
    }
  }
  load_balancer = {
    quest = {
      target_group_arn = aws_lb_target_group.quest.arn
      container_name   = local.name
      container_port   = 3000
    }
  }
}
