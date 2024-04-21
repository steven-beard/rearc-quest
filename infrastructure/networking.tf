locals {
  azs      = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
  vpc_cidr = "10.0.0.0/24"

  # Split the VPC CIDR into two partitions /25 (128 addresses each)
  partition = cidrsubnets(local.vpc_cidr, 1, 1)

  # Split first partition into two /26 subnets (64 addresses each)
  public_subnets = cidrsubnets(local.partition[0], 1, 1)

  # Split second partition into two /26 subnets (64 addresses each)
  private_subnets      = cidrsubnets(local.partition[1], 1, 1)
  public_subnet_names  = [for az in local.azs : "${local.name}-${az}-public"]
  private_subnet_names = [for az in local.azs : "${local.name}-${az}-private"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  public_subnet_names  = local.public_subnet_names
  private_subnet_names = local.private_subnet_names
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9.0"

  name                  = local.name
  load_balancer_type    = "application"
  internal              = false
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.public_subnets
  security_groups       = [aws_security_group.alb.id]
  create_security_group = false

  listeners = {
    http_tcp_listener = {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },

    https_listener = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.quest_acm.acm_certificate_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${local.name}-alb"
  vpc_id = module.vpc.vpc_id
  description = "SG for quest ALB"
  tags = {
    "Name" = "${local.name}-alb"
  }
}

resource "aws_security_group_rule" "alb_http" {
  description       = "Allow HTTP inbound traffic"
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_https" {
  description       = "Allow HTTPS inbound traffic"
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}
