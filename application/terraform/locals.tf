data "aws_region" "current" {}

locals {
  name          = "quest"
  base_domain   = "sbeard.cloud"
  domain_prefix = "rearc"

  tags = {
    App       = local.name
    ManagedBy = "Terraform"
  }
}
