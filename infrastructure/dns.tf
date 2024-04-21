data "aws_route53_zone" "selected" {
  name = local.base_domain
}

module "quest_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "${local.domain_prefix}.${local.base_domain}"
  zone_id     = data.aws_route53_zone.selected.zone_id
  subject_alternative_names = [
    "*.${local.domain_prefix}.${local.base_domain}",
  ]

  validation_method = "DNS"
    wait_for_validation = false
  tags = {
    Name = "${local.domain_prefix}.${local.base_domain}"
  }
}

resource "aws_route53_record" "rearc" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${local.domain_prefix}.${local.base_domain}"
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "rearc-wildcard" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "*.${local.domain_prefix}.${local.base_domain}"
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

